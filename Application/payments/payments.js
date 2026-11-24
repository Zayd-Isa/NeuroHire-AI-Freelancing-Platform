"use strict";
const $ = (id) => document.getElementById(id);
const money = (value) =>
  new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(
    Number(value),
  );
const date = (value) =>
  new Date(value).toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
let session, data, selectedPayment, paymentAttempt, noticeTimer;
function element(tag, text, className) {
  const node = document.createElement(tag);
  if (text != null) node.textContent = text;
  if (className) node.className = className;
  return node;
}
function notify(text) {
  $("notice").textContent = text;
  $("notice").hidden = false;
  clearTimeout(noticeTimer);
  noticeTimer = setTimeout(() => {
    $("notice").hidden = true;
  }, 7000);
}
function loginScreen() {
  session = null;
  $("workspace").hidden = true;
  $("identity").hidden = true;
  $("login-screen").hidden = false;
  $("payment-dialog").close();
}
async function api(url, options = {}) {
  let response;
  try {
    response = await fetch(`/api${url}`, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...(session ? { "X-CSRF-Token": session.csrf } : {}),
        ...options.headers,
      },
    });
  } catch {
    throw new Error(
      "Cannot reach the server. Check that the local application is running.",
    );
  }
  const body =
    response.status === 204 ? null : await response.json().catch(() => null);
  if (!response.ok) {
    if (response.status === 401 && url !== "/session") loginScreen();
    throw new Error(
      body?.error || "The server could not complete this request.",
    );
  }
  return body;
}
async function busy(form, errorID, action) {
  const button = form.querySelector('button[type="submit"]');
  button.disabled = true;
  $(errorID).textContent = "";
  try {
    await action();
  } catch (error) {
    $(errorID).textContent = error.message;
  } finally {
    button.disabled = false;
  }
}
function options(select, rows, id, title, empty) {
  const previous = select.value;
  select.replaceChildren(element("option", empty));
  select.firstChild.value = "";
  rows.forEach((row) => {
    const option = element("option", row[title]);
    option.value = row[id];
    select.append(option);
  });
  if ([...select.options].some((option) => option.value === previous))
    select.value = previous;
}
async function startWorkspace() {
  session = await api("/session");
  await loadWorkspace();
  $("login-screen").hidden = true;
  $("workspace").hidden = false;
  $("identity").hidden = false;
  $("person").textContent = session.name;
  $("workspace-role").textContent = `${session.role} workspace`;
  history.replaceState(
    {},
    "",
    `/Application/payments/${session.role.toLowerCase()}/`,
  );
}
async function loadWorkspace() {
  $("connection").textContent = "● Updating…";
  try {
    data = await api("/workspace");
    $("released-label").textContent =
      session.role === "Freelancer" ? "Released earnings" : "Released payments";
    $("released-value").textContent = money(
      session.role === "Freelancer"
        ? data.totals.ReleasedNet
        : data.totals.ReleasedGross,
    );
    $("open-value").textContent = money(data.totals.OpenGross);
    $("commission-value").textContent = money(data.totals.Commission);
    $("rating-label").textContent =
      session.role === "Admin" ? "Payment records" : "Your review rating";
    $("rating-value").textContent =
      session.role === "Admin"
        ? data.totals.PaymentCount
        : data.rating?.ReviewAverage == null
          ? "No ratings yet"
          : `${Number(data.rating.ReviewAverage).toFixed(1)} / 5`;
    $("rating-detail").textContent =
      session.role === "Admin"
        ? "Across the platform"
        : `${data.rating?.ReviewCount || 0} ${Number(data.rating?.ReviewCount) === 1 ? "review" : "reviews"} received`;
    $("payment-count").textContent = data.totals.PaymentCount;
    $("review-count").textContent = data.reviews.length;
    $("payment-compose").hidden = session.role !== "Client";
    $("payment-guide").hidden = session.role === "Client";
    $("guide-copy").textContent =
      session.role === "Admin"
        ? "Open a payment to apply an allowed status change. Every change needs an explanation."
        : "See your net earnings, review the history, or flag a held payment that needs attention.";
    $("review-compose").hidden = session.role === "Admin";
    options(
      $("assignment"),
      data.assignments.filter(
        (a) => a.RemainingAmount > 0 && a.AssignmentStatus !== "Terminated",
      ),
      "AssignmentID",
      "ProjectTitle",
      "Choose an assignment",
    );
    const reviewable = data.assignments.filter(
      (a) =>
        a.AssignmentStatus === "Completed" &&
        !(session.role === "Client" ? a.ClientReviewed : a.FreelancerReviewed),
    );
    options(
      $("review-assignment"),
      reviewable,
      "AssignmentID",
      "ProjectTitle",
      "Choose completed work",
    );
    $("review-form").hidden = reviewable.length === 0;
    $("review-unavailable").hidden = reviewable.length > 0;
    $("fee-label").textContent = `Platform fee (${session.feeBps / 100}%)`;
    updateAssignment();
    renderPayments();
    renderReviews();
    $("connection").textContent = "● Connected · up to date";
  } catch (error) {
    $("connection").textContent = "● Update unavailable";
    throw error;
  }
}
function renderPayments() {
  const search = $("search").value.toLowerCase();
  const status = $("status-filter").value;
  const rows = data.payments.filter(
    (p) =>
      (!status || p.PaymentStatus === status) &&
      `${p.ProjectTitle} ${p.TransactionRef}`.toLowerCase().includes(search),
  );
  $("payment-rows").replaceChildren();
  $("payments-empty").hidden = rows.length > 0;
  for (const payment of rows) {
    const row = element("tr");
    const project = element("td");
    project.append(
      element("span", payment.ProjectTitle, "project-name"),
      element("span", payment.TransactionRef, "reference"),
    );
    const statusCell = element("td");
    statusCell.append(
      element(
        "span",
        payment.PaymentStatus,
        `status ${payment.PaymentStatus.toLowerCase().replaceAll(" ", "-")}`,
      ),
    );
    const action = element("td");
    const button = element("button", "View →", "text-button");
    button.setAttribute("aria-label", `View payment ${payment.PaymentID}`);
    button.addEventListener("click", () =>
      openPayment(payment.PaymentID).catch((error) => notify(error.message)),
    );
    action.append(button);
    row.append(
      project,
      element("td", money(payment.GrossAmount)),
      element("td", money(payment.NetAmount)),
      statusCell,
      action,
    );
    $("payment-rows").append(row);
  }
}
function renderReviews() {
  $("review-list").replaceChildren();
  $("reviews-empty").hidden = data.reviews.length > 0;
  for (const review of data.reviews) {
    const card = element("article", null, "review-card");
    const top = element("div", null, "review-top");
    const stars = element(
      "span",
      "★".repeat(review.Rating) + "☆".repeat(5 - review.Rating),
      "review-stars",
    );
    stars.setAttribute("aria-label", `${review.Rating} out of 5 stars`);
    top.append(
      element("strong", `${review.ReviewerName} → ${review.RevieweeName}`),
      stars,
    );
    card.append(
      top,
      element("span", review.ProjectTitle, "review-meta"),
      element("p", review.Comment || "No written comment."),
      element("span", date(review.CreatedAt), "review-meta"),
    );
    if (review.IsVerifiedCompletedAssignment)
      card.append(element("div", "✓ Completed assignment", "verified"));
    $("review-list").append(card);
  }
}
function updateAssignment() {
  const assignment = data?.assignments.find(
    (a) => a.AssignmentID === Number($("assignment").value),
  );
  options(
    $("milestone"),
    data?.milestones.filter(
      (m) =>
        m.AssignmentID === assignment?.AssignmentID && m.RemainingAmount > 0,
    ) || [],
    "MilestoneID",
    "MilestoneTitle",
    "Whole assignment",
  );
  updateRemaining();
}
function updateRemaining() {
  const assignment = data?.assignments.find(
    (a) => a.AssignmentID === Number($("assignment").value),
  );
  const milestone = data?.milestones.find(
    (m) => m.MilestoneID === Number($("milestone").value),
  );
  $("remaining").textContent = assignment
    ? `${money(Math.min(assignment.RemainingAmount, milestone?.RemainingAmount ?? Infinity))} available to record`
    : "Only your assignments are shown.";
}
function previewFee() {
  const raw = $("amount").value;
  const [whole, fraction = ""] = /^\d{1,8}(\.\d{1,2})?$/.test(raw)
    ? raw.split(".")
    : ["0", "00"];
  const cents = Number(whole) * 100 + Number(fraction.padEnd(2, "0"));
  const fee = Math.round((cents * (session?.feeBps || 0)) / 10000);
  $("fee-preview").textContent = money(fee / 100);
  $("net-preview").textContent = money((cents - fee) / 100);
}
function allowedStatuses(payment) {
  if (session.role === "Client")
    return payment.PaymentStatus === "Pending"
      ? ["Cancelled"]
      : payment.PaymentStatus === "Held in Escrow"
        ? ["Disputed"]
        : [];
  if (session.role === "Freelancer")
    return payment.PaymentStatus === "Held in Escrow" ? ["Disputed"] : [];
  return (
    {
      Pending: ["Held in Escrow", "Failed", "Cancelled"],
      "Held in Escrow": ["Released", "Refunded", "Disputed"],
      Disputed: ["Held in Escrow", "Released", "Refunded"],
      Released: ["Refunded"],
    }[payment.PaymentStatus] || []
  );
}
async function openPayment(id) {
  const payment = data.payments.find((p) => p.PaymentID === id);
  const events = await api(`/payments/${id}/history`);
  selectedPayment = id;
  $("detail-title").textContent = payment.ProjectTitle;
  $("detail-ref").textContent =
    `${payment.TransactionRef} · ${payment.PaymentStatus} · ${payment.ClientName} → ${payment.FreelancerName}`;
  $("detail-amounts").replaceChildren();
  for (const [label, value] of [
    ["Gross", payment.GrossAmount],
    [`Fee (${Number(payment.PlatformFeeRate) * 100}%)`, payment.PlatformFee],
    ["Freelancer net", payment.NetAmount],
  ]) {
    const group = element("div");
    group.append(element("small", label), element("strong", money(value)));
    $("detail-amounts").append(group);
  }
  $("timeline").replaceChildren();
  events.forEach((event) => {
    const li = element("li");
    li.append(
      element("strong", event.NewStatus),
      element(
        "small",
        `${date(event.OccurredAt)} · ${event.ActorType}${event.ActorID ? ` #${event.ActorID}` : ""}`,
      ),
      element("p", event.Reason),
    );
    $("timeline").append(li);
  });
  const statuses = allowedStatuses(payment);
  $("new-status").replaceChildren();
  statuses.forEach((status) => {
    const option = element("option", status);
    option.value = status;
    $("new-status").append(option);
  });
  $("status-form").hidden = !statuses.length;
  $("status-error").textContent = "";
  $("status-reason").value = "";
  if (!$("payment-dialog").open) $("payment-dialog").showModal();
}

$("login-form").addEventListener("submit", (event) => {
  event.preventDefault();
  busy(event.currentTarget, "login-error", async () => {
    await api("/session", {
      method: "POST",
      body: JSON.stringify(Object.fromEntries(new FormData(event.target))),
    });
    $("password").value = "";
    await startWorkspace();
  });
});
$("logout").addEventListener("click", async () => {
  try {
    await api("/session", { method: "DELETE" });
    loginScreen();
    history.replaceState({}, "", "/Application/payments/login/");
  } catch (error) {
    notify(error.message);
  }
});
$("refresh").addEventListener("click", async () => {
  $("refresh").disabled = true;
  try {
    await loadWorkspace();
    notify("Workspace refreshed from the database.");
  } catch (error) {
    notify(error.message);
  } finally {
    $("refresh").disabled = false;
  }
});
$("search").addEventListener("input", renderPayments);
$("status-filter").addEventListener("change", renderPayments);
$("assignment").addEventListener("change", updateAssignment);
$("milestone").addEventListener("change", updateRemaining);
$("amount").addEventListener("input", previewFee);
for (const name of ["payments", "reviews"])
  $(name + "-tab").addEventListener("click", () => {
    for (const other of ["payments", "reviews"]) {
      $(other + "-section").hidden = other !== name;
      $(other + "-tab").classList.toggle("selected", other === name);
      $(other + "-tab").setAttribute("aria-pressed", String(other === name));
    }
  });
$("payment-form").addEventListener("submit", (event) => {
  event.preventDefault();
  busy(event.currentTarget, "payment-error", async () => {
    const body = {
      assignmentId: Number($("assignment").value),
      milestoneId: $("milestone").value ? Number($("milestone").value) : null,
      amount: $("amount").value,
    };
    const signature = JSON.stringify(body);
    if (paymentAttempt?.signature !== signature)
      paymentAttempt = { signature, key: crypto.randomUUID() };
    const result = await api("/payments", {
      method: "POST",
      body: JSON.stringify({ ...body, idempotencyKey: paymentAttempt.key }),
    });
    paymentAttempt = null;
    $("amount").value = "";
    previewFee();
    await loadWorkspace();
    notify(`Payment #${result.paymentId} saved as Pending.`);
    await openPayment(result.paymentId);
  });
});
$("status-form").addEventListener("submit", (event) => {
  event.preventDefault();
  busy(event.currentTarget, "status-error", async () => {
    await api(`/payments/${selectedPayment}/status`, {
      method: "POST",
      body: JSON.stringify({
        status: $("new-status").value,
        reason: $("status-reason").value,
      }),
    });
    await loadWorkspace();
    await openPayment(selectedPayment);
    notify("Status updated. The change is recorded in payment history.");
  });
});
$("review-form").addEventListener("submit", (event) => {
  event.preventDefault();
  busy(event.currentTarget, "review-error", async () => {
    await api("/reviews", {
      method: "POST",
      body: JSON.stringify({
        assignmentId: Number($("review-assignment").value),
        rating: Number(new FormData(event.target).get("rating")),
        comment: $("review-comment").value,
      }),
    });
    event.target.reset();
    await loadWorkspace();
    notify("Review published. The participant rating has been updated.");
  });
});
$("close-dialog").addEventListener("click", () => $("payment-dialog").close());
const requestedRole = location.pathname.split("/").filter(Boolean).at(-1);
const roleRadio = document.querySelector(
  `input[name="role"][value="${{ client: "Client", freelancer: "Freelancer", admin: "Admin" }[requestedRole] || "Client"}"]`,
);
roleRadio.checked = true;
startWorkspace().catch((error) => {
  loginScreen();
  if (error.message !== "Please sign in to continue.")
    $("login-error").textContent = error.message;
});
