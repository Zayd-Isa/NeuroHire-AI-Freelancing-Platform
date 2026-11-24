import { chromium } from "playwright";
import assert from "node:assert/strict";
import { readFile, mkdir, access } from "node:fs/promises";
import { fileURLToPath } from "node:url";

const origin = process.env.APP_ORIGIN || "http://127.0.0.1:3000";
assert(
  ["127.0.0.1", "localhost"].includes(new URL(origin).hostname),
  "Only run against the local preview.",
);
const accounts = JSON.parse(
  await readFile(new URL("../preview-accounts.txt", import.meta.url), "utf8"),
);
const screenshots = fileURLToPath(
  new URL("../../Documentation/Screenshots/member4/", import.meta.url),
);
await mkdir(screenshots, { recursive: true });
let executablePath = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE;
if (!executablePath && process.platform === "linux") {
  try {
    await access("/usr/bin/chromium");
    executablePath = "/usr/bin/chromium";
  } catch {
    /* Use Playwright's installed browser. */
  }
}
const browser = await chromium.launch({ executablePath, headless: true });
const page = await browser.newPage({
  viewport: { width: 1440, height: 1050 },
  deviceScaleFactor: 1,
});
const errors = [];
page.on("pageerror", (error) => errors.push(error.message));
const shot = (name) =>
  page.screenshot({ path: `${screenshots}/${name}.png`, fullPage: true });
async function signIn(role) {
  const account = accounts.find((account) => account.role === role);
  await page.locator(`.role-picker label:has(input[value="${role}"])`).click();
  await page.getByLabel("Email address").fill(account.email);
  await page.getByLabel("Password", { exact: true }).fill(account.password);
  await page.getByRole("button", { name: "Open my workspace" }).click();
  await page.locator("#workspace").waitFor({ state: "visible" });
  assert.equal(
    await page.locator("#workspace-role").textContent(),
    `${role} workspace`,
  );
}
async function changeStatus(status) {
  await page.locator("#new-status").selectOption(status);
  await page
    .getByLabel("Reason", { exact: true })
    .fill("Browser verification using a synthetic payment.");
  await page.getByRole("button", { name: "Save status change" }).click();
  await page
    .locator("#timeline li strong")
    .filter({ hasText: new RegExp(`^${status}$`) })
    .waitFor();
  assert.equal(await page.locator("#status-error").textContent(), "");
}
try {
  await page.goto(origin + "/Application/payments/");
  await page.locator("#login-screen").waitFor({ state: "visible" });
  await shot("01-sign-in");
  await signIn("Client");
  await shot("02-client-payments");
  const data = await page.evaluate(() =>
    fetch("/api/workspace").then((response) => response.json()),
  );
  const assignment = data.assignments.find(
    (a) => a.AssignmentStatus === "In Progress",
  );
  await page
    .locator("#assignment")
    .selectOption(String(assignment.AssignmentID));
  await page.getByLabel("Gross amount (USD)").fill("12.34");
  assert.equal(await page.locator("#fee-preview").textContent(), "$1.23");
  assert.equal(await page.locator("#net-preview").textContent(), "$11.11");
  await page.getByRole("button", { name: "Record payment" }).click();
  await page.locator("#payment-dialog").waitFor({ state: "visible" });
  await page
    .locator("#timeline li strong")
    .filter({ hasText: /^Pending$/ })
    .waitFor();
  const after = await page.evaluate(() =>
    fetch("/api/workspace").then((response) => response.json()),
  );
  const paymentId = after.payments.find(
    (p) =>
      p.AssignmentID === assignment.AssignmentID &&
      p.GrossAmount === 12.34 &&
      p.PaymentStatus === "Pending",
  ).PaymentID;
  await page.getByRole("button", { name: "Close payment details" }).click();
  await page.getByRole("button", { name: /^Reviews/ }).click();
  await shot("03-client-reviews");
  // Publish through the actual review form on a separate synthetic completed assignment.
  const available = after.assignments.find(
    (a) =>
      a.ProjectTitle.startsWith("Forecast validation") && !a.ClientReviewed,
  );
  if (available) {
    await page
      .locator("#review-assignment")
      .selectOption(String(available.AssignmentID));
    await page.locator('.stars-picker label:has(input[value="4"])').click();
    await page
      .getByLabel("Your review", { exact: true })
      .fill(
        "Careful validation and helpful explanations. Verified in the local browser preview.",
      );
    await page.getByRole("button", { name: "Publish review" }).click();
    await page
      .locator(".review-card")
      .filter({ hasText: "Careful validation and helpful explanations." })
      .waitFor();
    await shot("03-client-reviews");
  }
  await page.getByRole("button", { name: /^Payments/ }).click();
  await page.setViewportSize({ width: 390, height: 844 });
  await shot("04-mobile-payments");
  const overflow = await page.evaluate(() => ({
    width: innerWidth,
    total: document.documentElement.scrollWidth,
    nodes: [...document.querySelectorAll("body *")]
      .filter(
        (el) =>
          el.getBoundingClientRect().right > innerWidth + 1 &&
          getComputedStyle(el).display !== "none",
      )
      .slice(0, 12)
      .map((el) => ({
        tag: el.tagName,
        id: el.id,
        className: el.className,
        width: el.getBoundingClientRect().width,
        right: el.getBoundingClientRect().right,
      })),
  }));
  assert(
    overflow.total <= overflow.width + 1,
    `Mobile overflow: ${JSON.stringify(overflow)}`,
  );
  await page.setViewportSize({ width: 1440, height: 1050 });
  await page.getByRole("button", { name: "Sign out" }).click();
  await signIn("Admin");
  await page
    .getByRole("button", { name: `View payment ${paymentId}`, exact: true })
    .click();
  await page.locator("#payment-dialog").waitFor({ state: "visible" });
  await changeStatus("Held in Escrow");
  await changeStatus("Released");
  await shot("05-admin-status-history");
  await changeStatus("Refunded");
  await page.getByRole("button", { name: "Close payment details" }).click();
  await page.getByRole("button", { name: "Sign out" }).click();
  await signIn("Freelancer");
  assert(await page.locator("#payment-compose").isHidden());
  await shot("06-freelancer-payments");
  assert.deepEqual(errors, [], "No uncaught browser errors");
  console.log(
    "PASS: client payment creation, fee preview, review publication, admin hold/release/refund, freelancer view, responsive layout, and screenshots.",
  );
  console.log(
    "Screenshots captured from the running SQL-connected UI in Documentation/Screenshots/member4.",
  );
} finally {
  await browser.close();
}
