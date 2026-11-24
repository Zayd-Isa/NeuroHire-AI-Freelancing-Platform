# NeuroHire AI — NeuroLance Hub Database

AI Projects and Services Freelancing Platform for the PUSL2019 Information Management and Retrieval coursework.

## Project purpose

NeuroHire AI (using the database name `NeuroLanceHubDB`) models a platform where clients post AI projects, freelancers list AI skills and services, freelancers submit proposals, clients select a freelancer, and the platform records assignments, milestones, payments, reviews, and disputes.

This repository delivers the SQL Server database foundation, reusable objects, synthetic sample data, design notes, and a shared HTML/CSS foundation. Member 4 includes a working local payment/review interface and Node.js backend connected to SQL Server. Other member pages remain starter scaffolds. The payment module records a demonstration ledger; it does not charge cards or transfer money.

## Run the live payment preview

See [Payment preview setup](./Documentation/PaymentPreview.md) for the complete steps. Install Node.js 24, run `npm ci`, configure SQL Server, then run `npm start`. Open **http://127.0.0.1:3000/Application/payments/**.

**Docker is optional.** Teammates can use SQL Server installed on Windows, a local SQL Server container, or the team's shared SQL Server. Docker was used for the Linux validation environment. The application only requires Node.js and a reachable SQL Server instance.

The local setup generates private sign-in details in ignored `Backend/preview-accounts.txt`. See [screenshots and verification](./Documentation/PaymentPreview.md#verification-and-screenshots).

## Team completion checklist

This checklist follows the six-role responsibility plan. **[x] means the repository contains the named artifact or implementation; it does not prove which teammate authored it, that it runs successfully on the team's SQL Server instance, or that the work has been demonstrated.** The SQL foundation covers several modules. Member 4 now has a locally verified interface, API, and screenshot evidence; other module workflows and the final integrated presentation remain unfinished.

### Team Leader — database, shared design, and integration

- [x] GitHub repository and the existing database module structure are present.
- [x] Existing table names and relationships are documented; keys and constraints are defined in the SQL scripts.
- [x] SQL Server setup/run order and shared database-object integration are documented.
- [x] Database design, assumptions, normalization rationale, and data dictionary are documented.
- [x] Clean-install all database scripts on SQL Server 2022 running on Linux; the setup, schema, object, and sample-data scripts completed successfully.
- [ ] Capture and add the required database screenshots from the team's coursework environment.
- [x] Create a shared CSS design system and consistent landing/module starter scaffolds.
- [x] Provide a common application folder structure and links between starter pages.
- [ ] Complete the feature workflows and review/merge the team's individual branches.
- [ ] Add the rendered database diagram and actual database screenshots to the coursework evidence.
- [ ] Coordinate the final report, critical evaluation, and team presentation/recording.

### Member 1 — freelancer module

- [x] Freelancer, skill, freelancer-skill, and service tables are in the schema; synthetic example records are provided.
- [x] Freelancer search/reporting SQL foundation is present (`usp_FindFreelancersBySkill` and freelancer summary/rating objects).
- [ ] Build freelancer registration, profile, skills/services, dashboard, and project-browsing features on top of the starter scaffold.
- [ ] Connect and demonstrate the screens against the shared database; add module test cases and screenshots.
- [ ] Write the freelancer-module evidence and present the freelancer features.

### Member 2 — client and project module

- [x] Client, project, and project-requirement tables are in the schema; synthetic example records are provided.
- [x] `usp_CreateProject` supplies a transactional SQL foundation for creating a project and its required skills.
- [ ] Build client/organization profiles and project create/edit/requirements features, including skills, budget, and deadline.
- [ ] Connect and demonstrate the screens against the shared database; add module test cases and screenshots.
- [ ] Write the client/project evidence and present project creation.

### Member 3 — proposals and assignments module

- [x] Proposal, assignment, and milestone tables are in the schema; synthetic workflow records are provided.
- [x] Assignment-related triggers validate linked participants and synchronize project/proposal statuses and completion counts.
- [ ] Build proposal submission, review/selection, and assignment workflows on top of the starter scaffold.
- [ ] Connect and demonstrate the workflow against the shared database; add tests, screenshots, and evidence.
- [ ] Present the proposal-to-assignment workflow.

### Member 4 — payments and reviews module

- [x] Payment and review tables are in the schema; synthetic pending, escrow, released-payment, and review records are provided.
- [x] Payment/review triggers maintain account totals and ratings; payment/review views and reporting objects are present.
- [x] Fee-rate snapshots, duplicate-request idempotency, allowed status transitions, and append-only payment status history are implemented.
- [x] Review creation is restricted to the assigned participants after assignment completion; detailed review and participant-summary views are provided.
- [x] Build client/freelancer/admin payment workspaces, payment history, status actions, and review/rating forms connected to the shared schema.
- [x] Connect the Node.js/Express API using parameterized SQL, authenticated sessions, ownership checks, CSRF protection, and a dedicated SQL role.
- [x] Add API/browser verification, desktop/mobile screenshots, and module setup/report documentation.
- [ ] Present the module and verify it in the final integrated team environment. No real payment gateway is implemented.

### Member 5 — administration, reports, and final QA

- [x] Admin and dispute tables are in the schema; synthetic example records are provided.
- [x] Database reporting views/procedure and dispute validation logic are present.
- [ ] Build admin features for users, categories, project monitoring, and platform overview.
- [ ] Build and demonstrate project, freelancer, client, and payment reporting screens.
- [ ] Perform integrated system testing and final bug fixing; add test results and screenshots.
- [ ] Write the critical evaluation/improvements section and present the admin/reporting features.

### Shared work — all six members

- [x] A common database schema and shared SQL scripts are in the repository.
- [x] A database design/data dictionary and SQL sample data are present.
- [x] Use the shared CSS design system and page scaffolds as the starting point.
- [ ] Keep module-specific behavior and styling within each member's owned files.
- [ ] Each member pulls the latest integrated branch, works on the agreed feature branch, and contributes tested changes through review.
- [ ] Capture genuine screenshots and workflow/test evidence from the running project.
- [ ] Prepare and deliver the planned team presentation; each member should explain their own verified contribution.

The checked items describe the **current repository contents**; they do not prove which teammate authored a feature or delivered its presentation. The shared UI remains a foundation for the other modules. Member 4 has its own local interface, backend, and evidence. Final team integration and presentation work remain.

## Shared UI foundation

`Shared/styles.css` is a small shared base for the platform palette, text, page width, and basic links. The visual direction uses navy, warm white, butter-gold, and a cyan neural logo inspired by the team reference. It deliberately avoids finished dashboard layouts and feature controls.

`Application/index.html` is a simple portal selector. Freelancer, client, proposal, payment/review, and admin areas have separate paths. Shared sign-in paths at `/Application/freelancer/login/`, `/Application/client/login/`, and `/Application/admin/login/` remain placeholders. Member 4's working sign-in is `/Application/payments/login/`, with separate `/Application/payments/client/`, `/Application/payments/freelancer/`, and `/Application/payments/admin/` workspaces. See [UI route boundaries](./Documentation/UIFoundation.md).

## Technology

- **Database:** Microsoft SQL Server, using T-SQL. SQL Server can run on Linux; the scripts use SQL Server syntax such as `IDENTITY`, `GO`, `CREATE OR ALTER`, table-valued parameters, and `THROW`.
- **Version control:** Git and GitHub.
- **Frontend:** HTML, CSS, vanilla JavaScript; no frontend build step.
- **Backend:** Node.js 24, Express 5, `mssql`/Tedious; Helmet and express-rate-limit for HTTP headers and request limits.
- **Authentication:** Node.js `crypto.scrypt`, random salts, timing-safe password verification, HttpOnly/SameSite session cookies, CSRF tokens, and server-side role/ownership checks.
- **Development:** SQL Server 2022 in Docker on Linux (optional); Playwright for browser verification and genuine screenshots.
- **Compatibility:** SQL Server 2016 SP1 or later is required for `CREATE OR ALTER`. Use a SQL Server instance/container and a client that understands `GO`, such as `sqlcmd` or a SQL Server editor.

## Database architecture

The database is named `NeuroLanceHubDB`. Its 15 original tables and their names are preserved; Member 4's additive payment-history table brings the current total to 16. The design has five functional areas:

1. **Freelancers and skills:** `Freelancers`, `SkillCategories`, `AISkills`, `FreelancerSkills`, and `AIServices`.
2. **Clients and projects:** `Clients`, `Projects`, and `ProjectRequirements`.
3. **Proposals and assignments:** `Proposals`, `ProjectAssignments`, and `ProjectMilestones`.
4. **Payments and reviews:** `Payments`, `PaymentStatusHistory`, and `Reviews`.
5. **Administration and disputes:** `AdminUsers` and `PlatformDisputes`.

The many-to-many links are represented by `FreelancerSkills` (freelancers ↔ AI skills) and `ProjectRequirements` (projects ↔ required AI skills). Each project belongs to one client and may receive many proposals. `ProjectAssignments` links a project to its accepted proposal, freelancer, and client; its unique project and proposal constraints allow at most one assignment per project and proposal. An assignment can have multiple milestones, payments, reviews, and disputes. A review is unique per assignment and direction (`ReviewerType`).

The diagram, assumptions, normalization notes, and table inventory are in [`Documentation/DatabaseDesign.md`](./Documentation/DatabaseDesign.md) and [`Documentation/DataDictionary.md`](./Documentation/DataDictionary.md).

## Implemented SQL features

### Integrity and query performance

The module scripts define primary keys, foreign keys, unique constraints, check constraints, defaults, identity columns, and indexes. These rules validate individual records and preserve the relationships represented by the schema.

### Triggers

- `TR_ProjectAssignments_SyncProjectAndProposalStatus` checks that the project, proposal, client, and freelancer agree; then it synchronizes project/proposal statuses and the freelancer's completed-project count after an assignment is inserted or updated.
- `TR_Payments_UpdateAccountTotals` verifies that a payment's client, freelancer, and optional milestone belong to its assignment; it updates freelancer `TotalEarnings` and client `TotalSpent` when a payment is released, adjusted, reversed, or deleted. It applies set-based changes and prevents a negative account total.
- `TR_Reviews_UpdateParticipantRatings` validates that reviewer and reviewee IDs match the assignment and updates the stored client/freelancer rating averages.
- `TR_PlatformDisputes_ValidateRaiser` verifies that the dispute raiser is a client or freelancer on the linked assignment.

The schema keeps summary columns (`TotalEarnings`, `TotalSpent`, `AverageRating`, `ClientRating`, and `CompletedProjects`) for convenient profile/report reads. The triggers maintain them when their corresponding payment, review, or assignment changes occur. Directly editing those summary columns should be avoided.

### Functions, views, and stored procedures

- Functions: `ufn_CalculatePlatformFee` (fee calculation at a supplied rate) and `ufn_CalculateFreelancerRating` (average client-to-freelancer review rating).
- Views: `vw_FreelancerProjectSummary`, `vw_ClientProjectSummary`, and `vw_ProjectPaymentSummary`.
- Procedures: `usp_CreateProject` (creates a project and its skill requirements in one transaction using a table-valued parameter), `usp_FindFreelancersBySkill`, and `usp_GeneratePaymentRevenueReport`.

The proposed 10% fee in sample payment records is a documented demonstration assumption, not a business policy. `ufn_CalculatePlatformFee` takes the fee rate as an input and does not hard-code that assumption.

### Example database queries

```sql
-- Read the reporting views and exercise the scalar functions.
SELECT TOP (10) * FROM dbo.vw_FreelancerProjectSummary;
SELECT TOP (10) * FROM dbo.vw_ClientProjectSummary;
SELECT TOP (10) * FROM dbo.vw_ProjectPaymentSummary;
SELECT dbo.ufn_CalculatePlatformFee(1000.00, 0.1000) AS ExampleFee;
SELECT dbo.ufn_CalculateFreelancerRating(FreelancerID) AS ReviewAverage
FROM dbo.Freelancers;

-- Run the reporting/search procedures.
EXEC dbo.usp_FindFreelancersBySkill @SkillName = 'Python';
EXEC dbo.usp_GeneratePaymentRevenueReport;

-- Demonstrate the payment trigger without keeping the test change.
BEGIN TRANSACTION;
UPDATE dbo.Payments
SET PaymentStatus = 'Held in Escrow', ReleasedDate = NULL
WHERE TransactionRef = 'SEED-NEURO-0001';
SELECT TotalEarnings FROM dbo.Freelancers
WHERE Email = 'asha.perera@example.test';
ROLLBACK TRANSACTION;
```

The last example assumes the sample-data script has run. The rollback restores the sample payment status and account total after displaying the trigger-updated value.

## Set up and run on Linux

You need a SQL Server instance accessible from Linux (local, container, or remote) and a SQL Server client. The SQL scripts are not SQLite or MySQL scripts. Run them in the order below; `GO` is a SQL Server batch separator understood by `sqlcmd` and SQL Server editors.

1. Run `Database/setup_database.sql` once. It creates `NeuroLanceHubDB` if it does not exist.
2. Run `Database/01_freelancer_module.sql`.
3. Run `Database/02_client_project_module.sql`.
4. Run `Database/03_proposals_and_assignments.sql`.
5. Run `Database/04_payments_and_reviews.sql`.
6. Run `Database/05_admin_and_disputes.sql`.
7. Run `Database/06_database_objects.sql` to create the type, functions, views, procedures, and triggers.
8. Run `Database/07_sample_data.sql` to load synthetic examples.
9. Run `Database/08_payment_review_module.sql` to add payment status audit, commission snapshots, payment history, and Member 4 procedures/views.
10. Run `Database/09_payment_web_support.sql` for the backend read models, login lookup, and Unicode review text support.
11. Run `Database/tests/08_payment_review_smoke_test.sql` to verify the Member 4 database flow. It rolls its demonstration changes back.

The table-creation scripts are for a clean database and are not idempotent. Do not run them a second time against a database whose tables already exist. The sample-data script can be rerun; it checks natural keys before adding its own records. It prints row counts at the end.

The sample records use reserved `.test` email domains, demo transaction references, `Demo record only` payment methods, and non-authenticating password markers. They are not real users or payments and must not be used as production credentials. A production application must hash passwords with a suitable password-hashing library before storing them; SQL Server is not performing password hashing in these scripts.

## Schema files

- `Database/setup_database.sql` — database bootstrap.
- `Database/01_freelancer_module.sql` through `Database/05_admin_and_disputes.sql` — original table definitions and indexes.
- `Database/06_database_objects.sql` — SQL programmable objects and business-rule automation.
- `Database/07_sample_data.sql` — at least 10 synthetic rows per table where applicable; 20 AI skills, 22 freelancer-skill links, and 10 reviews are included.
- `Database/08_payment_review_module.sql` — Member 4's auditable payment workflow, fee snapshots, history/review views, and stored procedures.
- `Database/tests/08_payment_review_smoke_test.sql` — rollback-only SQL smoke test for commission, idempotent requests, status transitions, account totals, and reviews.
- `Database/09_payment_web_support.sql` — backend read models, login lookup, and Unicode review support.
- `Backend/` — payment/review API, local provisioning, authentication, and verification scripts.
- `Documentation/PaymentPreview.md` — setup instructions, role workflows, and screenshots.
- `Documentation/DatabaseDesign.md` — ER model, relationships, assumptions, and normalization rationale.
- `Documentation/DataDictionary.md` — column types, key/constraint notes, and field meanings.

## Coursework evidence still needed

The SQL portion now includes the required two-or-more triggers, user-defined functions, views, and stored procedures, plus synthetic sample data. The coursework report and presentation still need to be prepared by the team: include a rendered ER/database diagram, screenshots from a successfully built and populated SQL Server database, query and object demonstrations, critical evaluation, contribution evidence, and the presentation recording. Screenshots and recordings should be captured from the team’s actual running environment; they are not fabricated in this repository.

The assessment brief also asks the team to follow its permitted AI-use level and cite external or AI-generated code where required. Confirm those rules with the coursework instructions and teaching team before submission.

## Member 4 — payments and reviews

`Payments` remains linked to `ProjectAssignments` and optional `ProjectMilestones`; the client and freelancer IDs must match that assignment. Each payment keeps a `PlatformFeeRate` snapshot so later policy changes do not rewrite older records. `dbo.usp_RecordPayment` calculates the platform commission and freelancer net from the gross amount, rejects amounts above the agreed project/milestone value, starts each record as `Pending`, and accepts an idempotency key so a retry cannot create a duplicate. The 10% rate is only the coursework sample default, not a promised business rate.

Status changes are handled through `dbo.usp_TransitionPayment`. The database validates allowed transitions and records each status event in append-only `PaymentStatusHistory`. The existing account-total trigger counts a payment only while `Released`; a full refund reverses the cached totals. `dbo.vw_PaymentHistory`, `dbo.vw_PaymentStatusHistory`, `dbo.vw_ProjectPaymentSummary`, and `dbo.vw_ParticipantReviewSummary` provide payment/review history and summaries. `dbo.usp_GetClientPaymentHistory`, `dbo.usp_GetFreelancerPaymentHistory`, and `dbo.usp_GeneratePaymentRevenueReport` provide common retrieval/reporting paths.

`dbo.usp_CreateAssignmentReview` accepts one client-to-freelancer or freelancer-to-client review only for a completed assignment and checks the reviewer is the assigned party. The review trigger maintains the existing rating summaries; `dbo.vw_ReviewDetails` exposes project, reviewer, rating, comment, timestamp, and completed-assignment verification.

**Security boundary:** the Express backend derives actor IDs from authenticated server sessions, checks ownership, and issues parameterized SQL/procedure calls. Its dedicated database login has the module role, not `db_owner`. Passwords use memory-hard scrypt (N=131072, r=8, p=1, random 16-byte salt, 64-byte derived key) and timing-safe comparison. Cookies are HttpOnly/SameSite=Strict with a one-hour lifetime. Mutations require a matching Origin and CSRF token. Helmet supplies HTTP security headers; sign-in and API requests are rate-limited. Sessions and rate limits are in memory for this single-process local preview; restarting logs everyone out. Public deployment requires HTTPS, persistent sessions, operational monitoring, and integration with the team's shared account lifecycle.

Payment amounts, review text, and ratings remain queryable business data. There is no real payment gateway or card collection. Commission is controlled by server configuration `PLATFORM_FEE_BPS` (1000 = 10% demo default), saved as a snapshot, and calculated by SQL. USD is the preview display convention; the shared schema has no currency column or currency conversion. See [OWASP password storage guidance](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) and [Node.js scrypt documentation](https://nodejs.org/download/release/v24.21.0/docs/api/crypto.html#cryptoscryptpassword-salt-keylen-options-callback).

## Git workflow

The project uses `main` as the integrated branch and feature branches for team modules. Pull the latest `main`, work in the branch agreed by the team, and integrate through review. Keep the central schema and shared SQL objects coordinated so modules use the same table names and relationships.

For UI work, each member should own their module's HTML and any module-specific stylesheet. Keep shared tokens and shared components in `Shared/styles.css`; coordinate changes there with the team leader to reduce merge conflicts. Submit changes through a pull request targeting `main` when repository rules require review.
