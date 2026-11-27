# NeuroHire AI — NeuroLance Hub

**AI Projects & Services Freelancing Platform** for the PUSL2019 Information Management and Retrieval coursework.

One database · one design system · six feature branches · one integrated platform.

## Project purpose

NeuroHire AI (database name `NeuroLanceHubDB`) models a platform where clients post AI projects, freelancers list AI skills and services, freelancers submit proposals, clients select a freelancer, and the platform records assignments, milestones, payments, reviews, and disputes.

The repository contains the complete Microsoft SQL Server database (schema, keys, constraints, triggers, functions, views, stored procedures, and synthetic sample data), the shared UI design system, and the fully working **Payments & Reviews portal** (Member 4): a secure Node.js/Express backend connected to SQL Server with client, freelancer, and admin workspaces. The other modules start from the shared scaffolds. The payment portal records a demonstration ledger; it does not charge cards or transfer real money.

## Team

| Role                        | Module                                                |
| --------------------------- | ----------------------------------------------------- |
| Team Leader                 | Database core, UI standards, integration coordination |
| Member 1                    | Freelancer module                                     |
| Member 2                    | Client & project module                               |
| Member 3                    | Proposal & assignment module                          |
| **Member 4 — Sri Monishan** | **Payments & reviews module (complete)**              |
| Member 5                    | Admin, reports & final QA                             |

## Tech stack

| Layer           | Technology                                                            | Why it was chosen                                                                                                                |
| --------------- | --------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Database        | **Microsoft SQL Server 2016 SP1+ (tested on SQL Server 2022), T-SQL** | Enterprise relational engine: keys, constraints, triggers, UDFs, views, stored procedures, transactions, table-valued parameters |
| Backend         | **Node.js 24 + Express 5**                                            | Modern, fast, async JavaScript server with a small dependency footprint                                                          |
| Database driver | **`mssql` (Tedious)**                                                 | Pure-JavaScript SQL Server driver: no ODBC/native driver install on any OS                                                       |
| Frontend        | **HTML5, CSS3, vanilla JavaScript**                                   | No build step; runs in any modern browser                                                                                        |
| Shared design   | `Shared/styles.css`                                                   | One colour/typography system across all modules                                                                                  |
| Security        | **scrypt password hashing, CSRF tokens, Helmet, express-rate-limit**  | See [Security](#security)                                                                                                        |
| Testing         | **Node.js API tests, Playwright browser tests, SQL smoke test**       | Automated end-to-end verification against the real database                                                                      |
| Version control | Git + GitHub feature-branch workflow                                  | One branch per member, merged into `main`                                                                                        |

## Security

The payment portal follows OWASP-recommended practice:

- **Password hashing:** memory-hard **scrypt** (N=131072, r=8, p=1) with a random 16-byte salt per user and a 64-byte derived key. Passwords are never stored in plain text, and comparison is timing-safe.
- **Sessions:** HttpOnly, `SameSite=Strict` cookies with a one-hour lifetime.
- **CSRF protection:** every state-changing request needs a matching Origin header and CSRF token.
- **Rate limiting:** 12 sign-in attempts per 15 minutes; 180 API requests per minute.
- **HTTP hardening:** Helmet security headers and a 16 KB request-body limit.
- **SQL injection protection:** every query is parameterized or a stored-procedure call.
- **Authorization:** actor IDs come from the server session, never from the browser; every payment and review is ownership-checked by role.
- **Least privilege:** the app connects with a dedicated SQL login that holds only the module role, never `db_owner`.
- **Database-enforced rules:** fee-rate snapshots, idempotency keys that block duplicate payments, allowed status transitions only, and an append-only payment status history.
- **No secrets in Git:** `.env` files and generated preview accounts are ignored. No card numbers, CVV, or real credentials exist anywhere in the project.

## What you need to install

Works on **Windows, Linux, and macOS**. Nothing in the repository is OS-specific.

| Software                                          | Required? | Notes                                                                                         |
| ------------------------------------------------- | --------- | --------------------------------------------------------------------------------------------- |
| [Git](https://git-scm.com/)                       | Yes       | To clone/pull the repository                                                                  |
| [Node.js 24](https://nodejs.org/)                 | Yes       | `package.json` requires Node 24                                                               |
| Microsoft SQL Server (Express or Developer, free) | Yes       | The database engine. A team/shared server or a Docker container also works                    |
| SQL Server Management Studio (SSMS)               | Optional  | To browse the database and run queries. SSMS is a client only; it does not include the engine |
| Docker                                            | Optional  | Only if you prefer running SQL Server in a container                                          |
| Playwright Chromium                               | Optional  | Only to rerun browser tests: `npx playwright install chromium`                                |

**Windows SQL Server one-time settings:** in _SQL Server Configuration Manager_, enable **TCP/IP** on port **1433** and restart the service. In SSMS, enable **SQL Server and Windows Authentication mode** (server properties → Security).

## Run the payment portal

Full guide: [Payment preview setup](./Documentation/PaymentPreview.md).

```sh
npm ci                 # install locked dependencies
# create Backend/.env.setup with your local SQL admin login (see the guide)
npm run db:prepare     # builds NeuroLanceHubDB (scripts 01–09) and a limited app login
npm start              # starts the API and portal
```

Open **http://127.0.0.1:3000/Application/payments/** and sign in with an account from the generated, Git-ignored `Backend/preview-accounts.txt`.

Verification:

```sh
npm run test:api       # 35 HTTP assertions plus commission, totals, audit, rating, ownership and least-privilege checks
npm run test:ui        # browser workflow for all three roles, desktop and mobile
```

## Payments & reviews portal features

- **Client workspace:** create payments for assigned projects with a live commission/net preview; view payment history; review the freelancer once the project is complete.
- **Freelancer workspace:** view earnings, payment status and history; review the client.
- **Admin workspace:** hold, release, or refund payments; view the full audited status history.
- **Responsive UI** on desktop and mobile, using the shared NeuroHire design system.

Screenshots from the running SQL-connected portal are in [`Documentation/Screenshots/member4`](./Documentation/Screenshots/member4).

## Team completion checklist

[x] means the repository contains the working artifact.

### Team Leader — database, shared design, and integration

- [x] GitHub repository, `main` branch, and feature-branch naming created.
- [x] Microsoft SQL Server database set up; all core tables created.
- [x] Primary keys, foreign keys, relationships, and constraints finalized.
- [x] Initial sample database structure and synthetic data prepared.
- [x] Shared CSS style file with theme colours, fonts, buttons, spacing, and layout rules.
- [x] Folder structure and integration method defined; database script and design system shared with all members.
- [x] Database design, ER model, normalization rationale, and data dictionary documented.
- [x] Clean install of all database scripts verified on SQL Server 2022.
- [x] Member 4 payment & review module integrated into `main`.
- [ ] Add database screenshots to the coursework evidence.
- [ ] Add a rendered ER diagram image to the coursework evidence.
- [ ] Review and merge the remaining members' branches.
- [ ] Coordinate final integration testing, report, and presentation.

### Member 1 — freelancer module

- [x] Freelancer, skill, freelancer-skill, and service tables with synthetic records.
- [x] Freelancer search/reporting SQL (`usp_FindFreelancersBySkill`, freelancer summary and rating objects).
- [x] Freelancer registration, profile, skills/services, dashboard, and project-browsing pages.
- [ ] Connect screens to the database; add test cases, screenshots, and evidence.
- [ ] Present the freelancer features.

### Member 2 — client and project module

- [x] Client, project, and project-requirement tables with synthetic records.
- [x] `usp_CreateProject` transactional project creation with required skills.
- [ ] Client/organization profiles and project create/edit/requirements pages.
- [ ] Connect screens to the database; add test cases, screenshots, and evidence.
- [ ] Present project creation.

### Member 3 — proposals and assignments module

- [x] Proposal, assignment, and milestone tables with synthetic workflow records.
- [x] Assignment triggers validate participants and synchronize statuses and completion counts.
- [ ] Proposal submission, review/selection, and assignment pages.
- [ ] Connect the workflow to the database; add tests, screenshots, and evidence.
- [ ] Present the proposal-to-assignment workflow.

### Member 4 — payments and reviews module (Sri Monishan) ✅ complete

- [x] Payment recording and payment status management (pending, held in escrow, released, refunded).
- [x] Client ↔ freelancer review and rating features, restricted to assigned participants after completion.
- [x] Payment history, review details, and result summaries for client, freelancer, and admin.
- [x] Payment logic connected to the shared schema: fee-rate snapshots, idempotency, allowed status transitions, append-only status history.
- [x] Module SQL objects: `08_payment_review_module.sql`, `09_payment_web_support.sql`, stored procedures, views, and a rollback-only smoke test.
- [x] Secure Node.js/Express API: scrypt password hashing, sessions, CSRF, rate limiting, ownership checks, least-privilege SQL role.
- [x] Automated API and browser tests passing; desktop/mobile screenshots; setup and module documentation.
- [ ] Present the payment and review features in the final presentation.

### Member 5 — administration, reports, and final QA

- [x] Admin and dispute tables with synthetic records.
- [x] Reporting views/procedure and dispute validation logic.
- [ ] Admin dashboard for users, categories, project monitoring, and platform overview.
- [ ] Project, freelancer, client, and payment reporting screens.
- [ ] Integrated system testing, final bug fixing, test results, and screenshots.
- [ ] Critical evaluation/improvements section; present the admin/reporting features.

### Shared work — all six members

- [x] Common database schema and shared SQL scripts.
- [x] Database design, data dictionary, and sample data.
- [x] Shared CSS design system and page scaffolds.
- [ ] Every member works on an individual branch and pushes tested code.
- [ ] Every member adds screenshots and evidence for the report.
- [ ] Prepare and deliver the 15-minute group presentation.

## Shared UI foundation

`Shared/styles.css` defines the platform palette (navy, warm white, butter-gold, cyan neural logo), typography, page width, and links. `Application/index.html` is the portal selector with separate freelancer, client, proposal, payment/review, and admin paths. The payment portal uses `/Application/payments/login/` with `/client/`, `/freelancer/`, and `/admin/` workspaces. See [UI route boundaries](./Documentation/UIFoundation.md).

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

## Set up the database manually (Windows or Linux)

`npm run db:prepare` does all of this automatically. To do it by hand, use SSMS, Azure Data Studio, or `sqlcmd` (they understand the `GO` batch separator) and run in order:

1. `Database/setup_database.sql`: creates `NeuroLanceHubDB` if it does not exist.
2. `Database/01_freelancer_module.sql`
3. `Database/02_client_project_module.sql`
4. `Database/03_proposals_and_assignments.sql`
5. `Database/04_payments_and_reviews.sql`
6. `Database/05_admin_and_disputes.sql`
7. `Database/06_database_objects.sql`: type, functions, views, procedures, and triggers.
8. `Database/07_sample_data.sql`: synthetic examples.
9. `Database/08_payment_review_module.sql`: payment audit, commission snapshots, payment history, Member 4 procedures/views.
10. `Database/09_payment_web_support.sql`: backend read models, login lookup, Unicode review text.
11. `Database/tests/08_payment_review_smoke_test.sql`: verifies the payment flow and rolls its changes back.

The table-creation scripts are for a clean database and are not idempotent. The sample-data script can be rerun; it checks natural keys first. Sample records use reserved `.test` email domains, demo transaction references, and non-authenticating password markers; they are not real users or payments. Real portal accounts are created by `npm run db:prepare` with scrypt-hashed passwords.

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

## Coursework evidence

The SQL portion includes the required triggers, user-defined functions, views, and stored procedures, plus synthetic sample data. Member 4's runtime screenshots and test evidence are included. The final report still needs the rendered ER diagram, database screenshots, the other modules' evidence, the critical evaluation, and the presentation recording. Follow the assessment brief's rules on permitted tools and referencing before submission.

## Member 4 — payments and reviews (Sri Monishan)

`Payments` remains linked to `ProjectAssignments` and optional `ProjectMilestones`; the client and freelancer IDs must match that assignment. Each payment keeps a `PlatformFeeRate` snapshot so later policy changes do not rewrite older records. `dbo.usp_RecordPayment` calculates the platform commission and freelancer net from the gross amount, rejects amounts above the agreed project/milestone value, starts each record as `Pending`, and accepts an idempotency key so a retry cannot create a duplicate. The 10% rate is only the coursework sample default, not a promised business rate.

Status changes are handled through `dbo.usp_TransitionPayment`. The database validates allowed transitions and records each status event in append-only `PaymentStatusHistory`. The existing account-total trigger counts a payment only while `Released`; a full refund reverses the cached totals. `dbo.vw_PaymentHistory`, `dbo.vw_PaymentStatusHistory`, `dbo.vw_ProjectPaymentSummary`, and `dbo.vw_ParticipantReviewSummary` provide payment/review history and summaries. `dbo.usp_GetClientPaymentHistory`, `dbo.usp_GetFreelancerPaymentHistory`, and `dbo.usp_GeneratePaymentRevenueReport` provide common retrieval/reporting paths.

`dbo.usp_CreateAssignmentReview` accepts one client-to-freelancer or freelancer-to-client review only for a completed assignment and checks the reviewer is the assigned party. The review trigger maintains the existing rating summaries; `dbo.vw_ReviewDetails` exposes project, reviewer, rating, comment, timestamp, and completed-assignment verification.

**Security boundary:** the Express backend derives actor IDs from authenticated server sessions, checks ownership, and issues parameterized SQL/procedure calls. Its dedicated database login has the module role, not `db_owner`. Passwords use memory-hard scrypt (N=131072, r=8, p=1, random 16-byte salt, 64-byte derived key) and timing-safe comparison. Cookies are HttpOnly/SameSite=Strict with a one-hour lifetime. Mutations require a matching Origin and CSRF token. Helmet supplies HTTP security headers; sign-in and API requests are rate-limited. Sessions and rate limits are in memory for this single-process local preview; restarting logs everyone out. Public deployment requires HTTPS, persistent sessions, operational monitoring, and integration with the team's shared account lifecycle.

Payment amounts, review text, and ratings remain queryable business data. There is no real payment gateway or card collection. Commission is controlled by server configuration `PLATFORM_FEE_BPS` (1000 = 10% demo default), saved as a snapshot, and calculated by SQL. USD is the preview display convention; the shared schema has no currency column or currency conversion. See [OWASP password storage guidance](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) and [Node.js scrypt documentation](https://nodejs.org/download/release/v24.21.0/docs/api/crypto.html#cryptoscryptpassword-salt-keylen-options-callback).

## Git workflow

The project uses `main` as the integrated branch and feature branches for team modules. Pull the latest `main`, work in the branch agreed by the team, and integrate through review. Keep the central schema and shared SQL objects coordinated so modules use the same table names and relationships.

For UI work, each member should own their module's HTML and any module-specific stylesheet. Keep shared tokens and shared components in `Shared/styles.css`; coordinate changes there with the team leader to reduce merge conflicts. Submit changes through a pull request targeting `main` when repository rules require review.
