import express from "express";
import helmet from "helmet";
import { rateLimit } from "express-rate-limit";
import { randomBytes, createHash } from "node:crypto";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { sql, databaseConfig } from "./db.mjs";
import { hashPassword, verifyPassword } from "./password.mjs";

const root = fileURLToPath(new URL("../", import.meta.url));
const port = Number(process.env.PORT || 3000);
const origin = process.env.APP_ORIGIN || `http://127.0.0.1:${port}`;
const feeBps = Number(process.env.PLATFORM_FEE_BPS || 1000);
if (!Number.isInteger(feeBps) || feeBps < 0 || feeBps > 9999)
  throw new Error("Invalid PLATFORM_FEE_BPS.");
const pool = await new sql.ConnectionPool(databaseConfig()).connect();
const dummyHash = await hashPassword(randomBytes(32).toString("hex"));
const app = express();
const sessions = new Map();
const sessionAge = 60 * 60 * 1000;
const digest = (value) => createHash("sha256").update(value).digest("hex");
const token = () => randomBytes(32).toString("hex");
const cookie = (value, age) =>
  `nh_payment_session=${value}; HttpOnly; SameSite=Strict; Path=/; Max-Age=${age}${process.env.NODE_ENV === "production" ? "; Secure" : ""}`;
setInterval(() => {
  for (const [key, session] of sessions)
    if (session.expires < Date.now()) sessions.delete(key);
}, 60000).unref();

app.disable("x-powered-by");
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: { "upgrade-insecure-requests": null },
    },
  }),
);
app.use(express.json({ limit: "16kb" }));
app.use(
  "/api",
  rateLimit({
    windowMs: 60000,
    limit: 180,
    standardHeaders: "draft-8",
    legacyHeaders: false,
    message: { error: "Too many requests. Please wait a minute." },
  }),
);
app.use("/api", (req, res, next) => {
  res.set("Cache-Control", "no-store");
  if (!["GET", "HEAD"].includes(req.method) && req.get("origin") !== origin)
    return res
      .status(403)
      .json({ error: "This request must come from the payment workspace." });
  const raw = (req.headers.cookie || "")
    .split(";")
    .map((s) => s.trim())
    .find((s) => s.startsWith("nh_payment_session="))
    ?.split("=")[1];
  const key = raw && digest(raw);
  const session = key && sessions.get(key);
  if (session && session.expires > Date.now()) {
    req.session = session;
    req.sessionKey = key;
  }
  next();
});

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 12,
  standardHeaders: "draft-8",
  legacyHeaders: false,
  message: { error: "Too many sign-in attempts. Please wait 15 minutes." },
});
app.post("/api/session", loginLimiter, async (req, res) => {
  const { role, email, password } = req.body || {};
  if (
    !["Client", "Freelancer", "Admin"].includes(role) ||
    typeof email !== "string" ||
    email.length > 100 ||
    typeof password !== "string" ||
    password.length < 1 ||
    password.length > 256
  )
    return res
      .status(400)
      .json({ error: "Enter your role, email, and password." });
  const result = await pool
    .request()
    .input("Role", sql.VarChar(20), role)
    .input("Email", sql.VarChar(100), email.trim().toLowerCase())
    .execute("dbo.usp_PaymentLoginAccount");
  const account = result.recordset?.[0];
  const hash = account?.Password?.startsWith("scrypt$")
    ? account.Password
    : dummyHash;
  const valid = await verifyPassword(password, hash);
  if (!account || hash === dummyHash || !valid)
    return res
      .status(401)
      .json({ error: "Email, password, or role is incorrect." });
  if (req.sessionKey) sessions.delete(req.sessionKey);
  const raw = token();
  sessions.set(digest(raw), {
    id: account.AccountID,
    role,
    name: account.FullName,
    csrf: token(),
    expires: Date.now() + sessionAge,
  });
  res.setHeader("Set-Cookie", cookie(raw, sessionAge / 1000));
  res.json({ role });
});

app.use("/api", (req, res, next) => {
  if (!req.session)
    return res.status(401).json({ error: "Please sign in to continue." });
  if (
    !["GET", "HEAD"].includes(req.method) &&
    req.get("x-csrf-token") !== req.session.csrf
  )
    return res
      .status(403)
      .json({ error: "Your session token is invalid. Refresh the page." });
  next();
});
app.get("/api/session", (req, res) => {
  const { id, role, name, csrf } = req.session;
  res.json({
    id,
    role,
    name,
    csrf,
    feeBps,
    mode: "Coursework ledger · no real charges",
  });
});
app.delete("/api/session", (req, res) => {
  sessions.delete(req.sessionKey);
  res.setHeader("Set-Cookie", cookie("", 0));
  res.status(204).end();
});

const scoped = (session) =>
  pool
    .request()
    .input("ActorID", sql.Int, session.id)
    .input("ActorRole", sql.VarChar(20), session.role);
const scope =
  "(@ActorRole = 'Admin' OR (@ActorRole = 'Client' AND ClientID = @ActorID) OR (@ActorRole = 'Freelancer' AND FreelancerID = @ActorID))";
const validID = (value) =>
  Number.isSafeInteger(Number(value)) &&
  Number(value) > 0 &&
  Number(value) <= 2147483647;
const fail = (status, message) => Object.assign(new Error(message), { status });

app.get("/api/workspace", async (req, res) => {
  const result = await scoped(req.session).query(`
    SELECT * FROM dbo.vw_PaymentWorkspaceAssignments WHERE ${scope} ORDER BY AssignmentID DESC;
    SELECT * FROM dbo.vw_PaymentWorkspaceMilestones WHERE ${scope} ORDER BY MilestoneID;
    SELECT TOP (250) * FROM dbo.vw_PaymentHistory WHERE ${scope} ORDER BY PaymentID DESC;
    SELECT TOP (250) r.* FROM dbo.vw_ReviewDetails r WHERE EXISTS
      (SELECT 1 FROM dbo.vw_PaymentWorkspaceAssignments a WHERE a.AssignmentID = r.AssignmentID AND ${scope})
      ORDER BY r.ReviewID DESC;
    SELECT COUNT_BIG(*) AS PaymentCount,
      COALESCE(SUM(CASE WHEN PaymentStatus = 'Released' THEN GrossAmount ELSE 0 END), 0) AS ReleasedGross,
      COALESCE(SUM(CASE WHEN PaymentStatus = 'Released' THEN NetAmount ELSE 0 END), 0) AS ReleasedNet,
      COALESCE(SUM(CASE WHEN PaymentStatus = 'Released' THEN PlatformFee ELSE 0 END), 0) AS Commission,
      COALESCE(SUM(CASE WHEN PaymentStatus IN ('Pending', 'Held in Escrow', 'Disputed') THEN GrossAmount ELSE 0 END), 0) AS OpenGross
    FROM dbo.vw_PaymentHistory WHERE ${scope};
    SELECT * FROM dbo.vw_ParticipantReviewSummary
    WHERE ParticipantType = @ActorRole AND ParticipantID = @ActorID;
  `);
  res.json({
    assignments: result.recordsets[0],
    milestones: result.recordsets[1],
    payments: result.recordsets[2],
    reviews: result.recordsets[3],
    totals: result.recordsets[4][0],
    rating: result.recordsets[5][0] || null,
  });
});

app.post("/api/payments", async (req, res) => {
  if (req.session.role !== "Client")
    throw fail(403, "Only clients can record a payment.");
  const { assignmentId, milestoneId, amount, idempotencyKey } = req.body || {};
  if (
    !validID(assignmentId) ||
    (milestoneId != null && !validID(milestoneId)) ||
    typeof amount !== "string" ||
    !/^\d{1,8}(\.\d{1,2})?$/.test(amount) ||
    Number(amount) <= 0 ||
    typeof idempotencyKey !== "string" ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
      idempotencyKey,
    )
  )
    throw fail(
      400,
      "Choose an assignment and a valid positive amount with at most two decimal places.",
    );
  const result = await pool
    .request()
    .input("AssignmentID", sql.Int, Number(assignmentId))
    .input(
      "MilestoneID",
      sql.Int,
      milestoneId == null ? null : Number(milestoneId),
    )
    .input("GrossAmount", sql.Decimal(10, 2), Number(amount))
    .input("PlatformFeeRate", sql.Decimal(5, 4), feeBps / 10000)
    .input("PaymentMethod", sql.VarChar(50), "Coursework ledger")
    .input("PaymentProvider", sql.VarChar(50), "Local demonstration")
    .input("TransactionRef", sql.VarChar(100), `DEMO-${idempotencyKey}`)
    .input("IdempotencyKey", sql.UniqueIdentifier, idempotencyKey)
    .input("ActorType", sql.VarChar(20), req.session.role)
    .input("ActorID", sql.Int, req.session.id)
    .output("PaymentID", sql.Int)
    .execute("dbo.usp_RecordPayment");
  res.status(201).json({ paymentId: result.output.PaymentID });
});

app.get("/api/payments/:id/history", async (req, res) => {
  if (!validID(req.params.id)) throw fail(400, "Invalid payment ID.");
  const result = await scoped(req.session)
    .input("PaymentID", sql.Int, Number(req.params.id))
    .query(
      `SELECT * FROM dbo.vw_PaymentStatusHistory WHERE PaymentID = @PaymentID AND ${scope} ORDER BY PaymentStatusEventID;`,
    );
  if (!result.recordset.length) throw fail(404, "Payment was not found.");
  res.json(result.recordset);
});

app.post("/api/payments/:id/status", async (req, res) => {
  const { status, reason } = req.body || {};
  if (
    !validID(req.params.id) ||
    typeof status !== "string" ||
    status.length > 20 ||
    typeof reason !== "string" ||
    reason.trim().length < 3 ||
    reason.length > 500
  )
    throw fail(400, "Choose a status and enter a reason (3–500 characters).");
  // Ownership is checked before mutation; the procedure independently enforces actor permissions.
  const owned = await scoped(req.session)
    .input("PaymentID", sql.Int, Number(req.params.id))
    .query(
      `SELECT PaymentID FROM dbo.vw_PaymentHistory WHERE PaymentID = @PaymentID AND ${scope}`,
    );
  if (!owned.recordset.length) throw fail(404, "Payment was not found.");
  await pool
    .request()
    .input("PaymentID", sql.Int, Number(req.params.id))
    .input("NewStatus", sql.VarChar(20), status)
    .input("Reason", sql.VarChar(500), reason.trim())
    .input("ActorType", sql.VarChar(20), req.session.role)
    .input("ActorID", sql.Int, req.session.id)
    .execute("dbo.usp_TransitionPayment");
  res.json({ updated: true });
});

app.post("/api/reviews", async (req, res) => {
  if (!["Client", "Freelancer"].includes(req.session.role))
    throw fail(403, "Only assignment participants can write reviews.");
  const { assignmentId, rating, comment } = req.body || {};
  if (
    !validID(assignmentId) ||
    !Number.isInteger(rating) ||
    rating < 1 ||
    rating > 5 ||
    typeof comment !== "string" ||
    comment.trim().length < 3 ||
    comment.length > 2000
  )
    throw fail(
      400,
      "Choose a completed assignment, a rating from 1 to 5, and a review (3–2000 characters).",
    );
  await pool
    .request()
    .input("AssignmentID", sql.Int, Number(assignmentId))
    .input(
      "ReviewerType",
      sql.VarChar(20),
      req.session.role === "Client"
        ? "ClientToFreelancer"
        : "FreelancerToClient",
    )
    .input("ActorType", sql.VarChar(20), req.session.role)
    .input("ActorID", sql.Int, req.session.id)
    .input("Rating", sql.Int, rating)
    .input("Comment", sql.NVarChar(sql.MAX), comment.trim())
    .execute("dbo.usp_CreateAssignmentReview");
  res.status(201).json({ created: true });
});

app.use("/api", (req, res) =>
  res.status(404).json({ error: "Endpoint not found." }),
);
app.get(
  ["/", "/Application/payments", "/Application/payments/:role/"],
  (req, res, next) => {
    if (
      req.params.role &&
      !["client", "freelancer", "admin", "login"].includes(req.params.role)
    )
      return next();
    res.sendFile(path.join(root, "Application/payments/index.html"));
  },
);
app.use("/Application", express.static(path.join(root, "Application")));
app.use("/Shared", express.static(path.join(root, "Shared")));
app.use((err, req, res, next) => {
  const number = err.number ?? err.originalError?.info?.number;
  let status = err.status || 500;
  let message =
    err.status && err.status < 500
      ? err.message
      : "The request could not be completed. Please try again.";
  if (number >= 51300 && number <= 51499) {
    status = 409;
    message = err.message;
  }
  if ([2601, 2627].includes(number)) {
    status = 409;
    message = "This request or review already exists. Refresh to see it.";
  }
  if (status === 500)
    console.error(
      "Payment API failure:",
      err.code || "unexpected",
      number || "",
    );
  res.status(status).json({ error: message });
});

const server = app.listen(port, process.env.HOST || "127.0.0.1", () =>
  console.log(`Payment workspace: ${origin}/Application/payments/`),
);
async function close() {
  server.close();
  await pool.close();
  process.exit(0);
}
process.on("SIGINT", close);
process.on("SIGTERM", close);
