import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { randomUUID } from "node:crypto";
import { sql, databaseConfig } from "../db.mjs";

const origin = process.env.APP_ORIGIN || "http://127.0.0.1:3000";
assert(
  ["127.0.0.1", "localhost"].includes(new URL(origin).hostname),
  "Tests only run against localhost preview data.",
);
const accounts = JSON.parse(
  await readFile(new URL("../preview-accounts.txt", import.meta.url), "utf8"),
);
let count = 0;
async function request(
  url,
  {
    actor,
    method = "GET",
    body,
    status = 200,
    csrf = true,
    requestOrigin = origin,
  } = {},
) {
  const response = await fetch(origin + "/api" + url, {
    method,
    headers: {
      Origin: requestOrigin,
      "Content-Type": "application/json",
      ...(actor
        ? {
            Cookie: actor.cookie,
            ...(csrf ? { "X-CSRF-Token": actor.csrf } : {}),
          }
        : {}),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const data = response.status === 204 ? null : await response.json();
  assert.equal(
    response.status,
    status,
    `${method} ${url}: ${JSON.stringify(data)}`,
  );
  count++;
  return { data, response };
}
await request("/workspace", { status: 401 });
await request("/session", {
  method: "POST",
  body: { ...accounts[0], password: "invalid" },
  status: 401,
});
const actors = {};
for (const account of accounts) {
  const login = await request("/session", { method: "POST", body: account });
  const actor = {
    cookie: login.response.headers.get("set-cookie").split(";")[0],
  };
  actor.csrf = (await request("/session", { actor })).data.csrf;
  actors[account.role] = actor;
}
const client = actors.Client,
  freelancer = actors.Freelancer,
  admin = actors.Admin;
const initial = (await request("/workspace", { actor: client })).data;
assert(initial.assignments.length >= 3);
assert(initial.assignments.every((a) => a.ClientName === "Nimal Jayasuriya"));
const ongoing = initial.assignments.find(
  (a) => a.AssignmentStatus === "In Progress",
);
const completed = initial.assignments.find((a) =>
  a.ProjectTitle.startsWith("Customer insights AI"),
);
const adminData = (await request("/workspace", { actor: admin })).data;
const unrelated = adminData.assignments.find(
  (a) => a.ClientID !== ongoing.ClientID,
);
assert(unrelated);
const body = {
  assignmentId: ongoing.AssignmentID,
  amount: "125.50",
  idempotencyKey: randomUUID(),
};
await request("/payments", {
  actor: client,
  method: "POST",
  body,
  csrf: false,
  status: 403,
});
await request("/payments", {
  actor: client,
  method: "POST",
  body,
  requestOrigin: "https://untrusted.example",
  status: 403,
});
await request("/payments", {
  actor: freelancer,
  method: "POST",
  body,
  status: 403,
});
await request("/payments", {
  actor: client,
  method: "POST",
  body: { ...body, assignmentId: unrelated.AssignmentID },
  status: 409,
});
await request("/payments", {
  actor: client,
  method: "POST",
  body: { ...body, amount: "99999999.99" },
  status: 409,
});
const id = (
  await request("/payments", {
    actor: client,
    method: "POST",
    body,
    status: 201,
  })
).data.paymentId;
assert.equal(
  (
    await request("/payments", {
      actor: client,
      method: "POST",
      body,
      status: 201,
    })
  ).data.paymentId,
  id,
);
await request("/payments", {
  actor: client,
  method: "POST",
  body: { ...body, amount: "125.51" },
  status: 409,
});
await request(`/payments/${id}/status`, {
  actor: client,
  method: "POST",
  body: {
    status: "Released",
    reason: "Attempted role spoof",
    actorType: "Admin",
  },
  status: 409,
});
await request(`/payments/${id}/status`, {
  actor: admin,
  method: "POST",
  body: { status: "Released", reason: "Invalid lifecycle jump" },
  status: 409,
});
for (const status of ["Held in Escrow", "Released"])
  await request(`/payments/${id}/status`, {
    actor: admin,
    method: "POST",
    body: { status, reason: "Automated local preview workflow verification." },
  });
let workspace = (await request("/workspace", { actor: client })).data;
const payment = workspace.payments.find((p) => p.PaymentID === id);
assert.equal(payment.PlatformFee, 12.55);
assert.equal(payment.NetAmount, 112.95);
assert.equal(
  Number(
    (workspace.totals.ReleasedGross - initial.totals.ReleasedGross).toFixed(2),
  ),
  125.5,
);
const audit = (await request(`/payments/${id}/history`, { actor: client }))
  .data;
assert.deepEqual(
  audit.map((row) => row.NewStatus),
  ["Pending", "Held in Escrow", "Released"],
);
await request(`/payments/${id}/status`, {
  actor: admin,
  method: "POST",
  body: {
    status: "Refunded",
    reason: "Verification complete: refund synthetic amount.",
  },
});
workspace = (await request("/workspace", { actor: client })).data;
assert.equal(workspace.totals.ReleasedGross, initial.totals.ReleasedGross);
await request(`/payments/${id}/status`, {
  actor: admin,
  method: "POST",
  body: { status: "Released", reason: "Terminal state cannot reopen." },
  status: 409,
});
const unrelatedPayment = adminData.payments.find(
  (p) => p.ClientID !== ongoing.ClientID,
);
await request(`/payments/${unrelatedPayment.PaymentID}/history`, {
  actor: client,
  status: 404,
});
await request("/reviews", {
  actor: client,
  method: "POST",
  body: {
    assignmentId: ongoing.AssignmentID,
    rating: 5,
    comment: "Unfinished assignment rejection.",
  },
  status: 409,
});
await request("/reviews", {
  actor: admin,
  method: "POST",
  body: {
    assignmentId: completed.AssignmentID,
    rating: 5,
    comment: "Admin cannot impersonate a reviewer.",
  },
  status: 403,
});
for (const [actor, already, comment] of [
  [
    client,
    completed.ClientReviewed,
    "Thoughtful work, clear documentation, and a smooth handover. Local preview review.",
  ],
  [
    freelancer,
    completed.FreelancerReviewed,
    "Clear requirements and timely feedback throughout the project. Local preview review.",
  ],
]) {
  const review = { assignmentId: completed.AssignmentID, rating: 5, comment };
  if (!already)
    await request("/reviews", {
      actor,
      method: "POST",
      body: review,
      status: 201,
    });
  await request("/reviews", {
    actor,
    method: "POST",
    body: review,
    status: 409,
  });
}
const after = (await request("/workspace", { actor: client })).data;
assert.equal(after.rating.ReviewAverage, 5);
const db = await new sql.ConnectionPool(databaseConfig()).connect();
await assert.rejects(
  db.request().query("SELECT Password FROM dbo.Clients"),
  (error) => error.number === 229,
);
await assert.rejects(
  db
    .request()
    .query("UPDATE dbo.Payments SET GrossAmount=GrossAmount WHERE 1=0"),
  (error) => error.number === 229,
);
await db.close();
await request("/session", { actor: client, method: "DELETE", status: 204 });
await request("/workspace", { actor: client, status: 401 });
console.log(
  `PASS: ${count} HTTP assertions plus commission, totals, audit sequence, rating, ownership and SQL least-privilege assertions.`,
);
console.log(
  "Synthetic test payment was refunded; reviews remain on the dedicated preview assignment.",
);
