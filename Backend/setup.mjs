// Explicit local preview provisioning only. Never run against production data.
import { readFile, writeFile, access } from "node:fs/promises";
import { randomBytes } from "node:crypto";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { sql, databaseConfig } from "./db.mjs";
import { hashPassword } from "./password.mjs";

const root = fileURLToPath(new URL("../", import.meta.url));
if (
  process.env.PREVIEW_SETUP !== "true" ||
  !["127.0.0.1", "localhost"].includes(process.env.SQL_SERVER)
)
  throw new Error(
    "Preview setup requires PREVIEW_SETUP=true and a localhost SQL Server. Use the manual guide for shared servers.",
  );
if (process.env.SQL_DATABASE && process.env.SQL_DATABASE !== "NeuroLanceHubDB")
  throw new Error("Unexpected database name.");
const master = await new sql.ConnectionPool(
  databaseConfig({ database: "master" }),
).connect();
await master
  .request()
  .query(
    "IF DB_ID(N'NeuroLanceHubDB') IS NULL CREATE DATABASE NeuroLanceHubDB;",
  );
const pool = await new sql.ConnectionPool(
  databaseConfig({ database: "NeuroLanceHubDB" }),
).connect();
async function apply(name) {
  const source = await readFile(path.join(root, "Database", name), "utf8");
  for (const batch of source
    .replace(/^USE NeuroLanceHubDB;\s*$/gim, "")
    .split(/^GO\s*$/gim))
    if (batch.trim()) await pool.request().batch(batch);
  console.log(`Applied ${name}`);
}
const exists = await pool
  .request()
  .query("SELECT OBJECT_ID(N'dbo.Payments') AS ID");
if (!exists.recordset[0].ID) {
  for (const file of [
    "01_freelancer_module.sql",
    "02_client_project_module.sql",
    "03_proposals_and_assignments.sql",
    "04_payments_and_reviews.sql",
    "05_admin_and_disputes.sql",
    "06_database_objects.sql",
    "07_sample_data.sql",
  ])
    await apply(file);
}
await apply("08_payment_review_module.sql");
await apply("09_payment_web_support.sql");

const accountPath = path.join(root, "Backend/preview-accounts.txt");
let accounts;
try {
  accounts = JSON.parse(await readFile(accountPath, "utf8"));
} catch (err) {
  if (err.code !== "ENOENT") throw err;
  const duplicate = await pool
    .request()
    .query(
      "SELECT Email FROM dbo.Clients WHERE Email = 'client@payments.example.test'",
    );
  if (duplicate.recordset.length)
    throw new Error(
      "Preview accounts already exist. Restore your local preview-accounts.txt; passwords are not reset automatically.",
    );
  accounts = ["Client", "Freelancer", "Admin"].map((role) => ({
    role,
    email: `${role.toLowerCase()}@payments.example.test`,
    password: `Nh!${randomBytes(12).toString("hex")}`,
  }));
  await writeFile(accountPath, JSON.stringify(accounts, null, 2) + "\n", {
    mode: 0o600,
  });
}
for (const account of accounts) {
  const hash = await hashPassword(account.password);
  const request = pool
    .request()
    .input("Email", sql.VarChar(100), account.email)
    .input("Hash", sql.VarChar(255), hash);
  if (account.role === "Client")
    await request.query(`IF NOT EXISTS (SELECT 1 FROM dbo.Clients WHERE Email=@Email)
    INSERT dbo.Clients(FullName,Email,Password,CompanyName,Country) VALUES('Nimal Jayasuriya',@Email,@Hash,'LankaData Labs · Preview','Sri Lanka')`);
  if (account.role === "Freelancer")
    await request.query(`IF NOT EXISTS (SELECT 1 FROM dbo.Freelancers WHERE Email=@Email)
    INSERT dbo.Freelancers(FullName,Email,Password,Title,HourlyRate,Country) VALUES('Asha Perera',@Email,@Hash,'AI Engineer',48,'Sri Lanka')`);
  if (account.role === "Admin")
    await request.query(`IF NOT EXISTS (SELECT 1 FROM dbo.AdminUsers WHERE Email=@Email)
    INSERT dbo.AdminUsers(FullName,Email,Password,Role) VALUES('Payment Operations',@Email,@Hash,'Administrator')`);
}
// Dedicated synthetic assignments give reviewers and payment recording room to operate.
await pool.request().batch(`SET XACT_ABORT ON;
BEGIN TRANSACTION;
DECLARE @c INT=(SELECT ClientID FROM dbo.Clients WHERE Email='client@payments.example.test');
DECLARE @f INT=(SELECT FreelancerID FROM dbo.Freelancers WHERE Email='freelancer@payments.example.test');
DECLARE @p INT, @proposal INT, @assignment INT;
IF NOT EXISTS (SELECT 1 FROM dbo.Projects WHERE ClientID=@c AND Title='Customer insights AI · Payment preview')
BEGIN
  INSERT dbo.Projects(ClientID,Title,Description,Budget,ProjectStatus) VALUES(@c,'Customer insights AI · Payment preview','Synthetic completed assignment for the Member 4 preview.',10000,'Open');
  SET @p=SCOPE_IDENTITY();
  INSERT dbo.Proposals(ProjectID,FreelancerID,CoverLetter,BidAmount,EstimatedDays) VALUES(@p,@f,'Preview assignment proposal',10000,14);
  SET @proposal=SCOPE_IDENTITY();
  INSERT dbo.ProjectAssignments(ProjectID,ProposalID,FreelancerID,ClientID,AgreedPrice,ExpectedCompletionDate,AssignmentStatus)
    VALUES(@p,@proposal,@f,@c,10000,CONVERT(DATE,GETDATE()),'Completed');
  SET @assignment=SCOPE_IDENTITY();
  INSERT dbo.ProjectMilestones(AssignmentID,MilestoneTitle,Amount,DueDate,MilestoneStatus)
    VALUES(@assignment,'Model delivery',10000,CONVERT(DATE,GETDATE()),'Approved');
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Projects WHERE ClientID=@c AND Title='Knowledge assistant · Payment preview')
BEGIN
  INSERT dbo.Projects(ClientID,Title,Description,Budget,ProjectStatus) VALUES(@c,'Knowledge assistant · Payment preview','Synthetic ongoing assignment for the Member 4 preview.',5000,'Open');
  SET @p=SCOPE_IDENTITY();
  INSERT dbo.Proposals(ProjectID,FreelancerID,CoverLetter,BidAmount,EstimatedDays) VALUES(@p,@f,'Preview assignment proposal',5000,21);
  SET @proposal=SCOPE_IDENTITY();
  INSERT dbo.ProjectAssignments(ProjectID,ProposalID,FreelancerID,ClientID,AgreedPrice,ExpectedCompletionDate,AssignmentStatus)
    VALUES(@p,@proposal,@f,@c,5000,DATEADD(DAY,21,CONVERT(DATE,GETDATE())),'In Progress');
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Projects WHERE ClientID=@c AND Title='Forecast validation · Payment preview')
BEGIN
  INSERT dbo.Projects(ClientID,Title,Description,Budget,ProjectStatus) VALUES(@c,'Forecast validation · Payment preview','Synthetic completed assignment awaiting participant reviews.',2000,'Open');
  SET @p=SCOPE_IDENTITY();
  INSERT dbo.Proposals(ProjectID,FreelancerID,CoverLetter,BidAmount,EstimatedDays) VALUES(@p,@f,'Preview assignment proposal',2000,7);
  SET @proposal=SCOPE_IDENTITY();
  INSERT dbo.ProjectAssignments(ProjectID,ProposalID,FreelancerID,ClientID,AgreedPrice,ExpectedCompletionDate,AssignmentStatus)
    VALUES(@p,@proposal,@f,@c,2000,CONVERT(DATE,GETDATE()),'Completed');
END;
IF NOT EXISTS (SELECT 1 FROM dbo.Projects WHERE ClientID=@c AND Title='Search quality audit · Payment preview')
BEGIN
  INSERT dbo.Projects(ClientID,Title,Description,Budget,ProjectStatus) VALUES(@c,'Search quality audit · Payment preview','Synthetic completed assignment reserved for hands-on review.',1500,'Open');
  SET @p=SCOPE_IDENTITY();
  INSERT dbo.Proposals(ProjectID,FreelancerID,CoverLetter,BidAmount,EstimatedDays) VALUES(@p,@f,'Preview assignment proposal',1500,7);
  SET @proposal=SCOPE_IDENTITY();
  INSERT dbo.ProjectAssignments(ProjectID,ProposalID,FreelancerID,ClientID,AgreedPrice,ExpectedCompletionDate,AssignmentStatus)
    VALUES(@p,@proposal,@f,@c,1500,CONVERT(DATE,GETDATE()),'Completed');
END;
COMMIT;`);

const assignmentResult = await pool.request()
  .query(`SELECT a.AssignmentID FROM dbo.ProjectAssignments a
 JOIN dbo.Projects p ON p.ProjectID=a.ProjectID JOIN dbo.Clients c ON c.ClientID=a.ClientID
 WHERE c.Email='client@payments.example.test' AND p.Title='Customer insights AI · Payment preview'`);
for (const [key, amount, state] of [
  ["c54b2930-2ec7-49c7-a0ea-47c36c63a701", 1200, "Released"],
  ["c54b2930-2ec7-49c7-a0ea-47c36c63a702", 650, "Held in Escrow"],
  ["c54b2930-2ec7-49c7-a0ea-47c36c63a703", 450, "Pending"],
]) {
  const existing = await pool
    .request()
    .input("Key", sql.UniqueIdentifier, key)
    .query("SELECT PaymentID FROM dbo.Payments WHERE IdempotencyKey=@Key");
  if (existing.recordset.length) continue;
  const result = await pool
    .request()
    .input("AssignmentID", sql.Int, assignmentResult.recordset[0].AssignmentID)
    .input("GrossAmount", sql.Decimal(10, 2), amount)
    .input("PaymentMethod", sql.VarChar(50), "Coursework ledger")
    .input("TransactionRef", sql.VarChar(100), `PREVIEW-${key}`)
    .input("IdempotencyKey", sql.UniqueIdentifier, key)
    .input("PaymentProvider", sql.VarChar(50), "Local demonstration")
    .output("PaymentID", sql.Int)
    .execute("dbo.usp_RecordPayment");
  for (const status of state === "Released"
    ? ["Held in Escrow", "Released"]
    : state === "Pending"
      ? []
      : ["Held in Escrow"])
    await pool
      .request()
      .input("PaymentID", sql.Int, result.output.PaymentID)
      .input("NewStatus", sql.VarChar(20), status)
      .input(
        "Reason",
        sql.VarChar(500),
        "Initial synthetic preview record. No money transferred.",
      )
      .input("ActorType", sql.VarChar(20), "System")
      .execute("dbo.usp_TransitionPayment");
}

const envPath = path.join(root, "Backend/.env");
let appPassword;
try {
  const env = await readFile(envPath, "utf8");
  appPassword = env.match(/^SQL_PASSWORD=(.+)$/m)?.[1];
  if (!appPassword || !env.includes("SQL_USER=neurohire_payment_app"))
    throw new Error(
      "Existing Backend/.env is not the preview app configuration.",
    );
} catch (err) {
  if (err.code !== "ENOENT") throw err;
  appPassword = `Nh!${randomBytes(24).toString("hex")}`;
  await writeFile(
    envPath,
    `SQL_SERVER=127.0.0.1\nSQL_PORT=${process.env.SQL_PORT || 1433}\nSQL_DATABASE=NeuroLanceHubDB\nSQL_USER=neurohire_payment_app\nSQL_PASSWORD=${appPassword}\nSQL_ENCRYPT=true\nSQL_TRUST_CERTIFICATE=true\nHOST=127.0.0.1\nPORT=3000\nAPP_ORIGIN=http://127.0.0.1:3000\nPLATFORM_FEE_BPS=1000\n`,
    { mode: 0o600 },
  );
}
await master.request().input("AppPassword", sql.NVarChar(128), appPassword)
  .query(`
IF SUSER_ID(N'neurohire_payment_app') IS NULL BEGIN
 DECLARE @stmt NVARCHAR(MAX)=N'CREATE LOGIN neurohire_payment_app WITH PASSWORD='+QUOTENAME(@AppPassword,'''')+N', CHECK_POLICY=ON;';
 EXEC sys.sp_executesql @stmt;
END;`);
await pool.request()
  .query(`IF USER_ID(N'neurohire_payment_app') IS NULL CREATE USER neurohire_payment_app FOR LOGIN neurohire_payment_app;
IF IS_ROLEMEMBER(N'NeuroHirePaymentReviewAppRole', N'neurohire_payment_app') <> 1
 ALTER ROLE NeuroHirePaymentReviewAppRole ADD MEMBER neurohire_payment_app;`);
const verify = await new sql.ConnectionPool(
  databaseConfig({
    database: "NeuroLanceHubDB",
    user: "neurohire_payment_app",
    password: appPassword,
  }),
).connect();
await verify
  .request()
  .query("SELECT TOP (1) AssignmentID FROM dbo.vw_PaymentWorkspaceAssignments");
await verify.close();
await pool.close();
await master.close();
console.log(
  "Preview ready. Private sign-in details: Backend/preview-accounts.txt. Start with npm start.",
);
