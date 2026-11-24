# NeuroHire AI — NeuroLance Hub Database

AI Projects and Services Freelancing Platform for the PUSL2019 Information Management and Retrieval coursework.

## Project purpose

NeuroHire AI (using the database name `NeuroLanceHubDB`) models a platform where clients post AI projects, freelancers list AI skills and services, freelancers submit proposals, clients select a freelancer, and the platform records assignments, milestones, payments, reviews, and disputes.

This repository currently delivers the SQL Server database foundation, reusable database objects, repeatable synthetic sample data, database design notes, and a shared HTML/CSS visual foundation. The application pages are starter scaffolds only: they do not implement module workflows, a backend, or a real payment gateway. Coursework screenshots and the presentation recording also remain to be prepared.

## Team completion checklist

This checklist follows the six-role responsibility plan. **[x] means the repository contains the named artifact or implementation; it does not prove which teammate authored it, that it runs successfully on the team's SQL Server instance, or that the work has been demonstrated.** The SQL foundation now covers database logic across several member modules. It is therefore inaccurate to say that only the team-leader area has received work. The module interfaces, app screens, integration, and evidence remain unfinished.

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
- [ ] Build payment status/history and review/rating features and integrate them with the shared schema.
- [ ] Connect and demonstrate the module; add tests and screenshots. No payment gateway is implemented here.
- [ ] Write the module evidence and present payment/review features.

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

The checked items describe the **current repository contents**; they do not prove which teammate authored a feature or delivered its presentation. The shared UI is a foundation, not a completed application. Module workflows, runtime evidence, coursework documentation, and presentation work remain assigned to the team.

## Shared UI foundation

`Shared/styles.css` is a small shared base for the platform palette, text, page width, and basic links. The visual direction uses navy, warm white, butter-gold, and a cyan neural logo inspired by the team reference. It deliberately avoids finished dashboard layouts and feature controls.

`Application/index.html` is a simple portal selector. Freelancer, client, proposal, payment/review, and admin areas have separate paths under `Application/`. Freelancer, client, and admin also have distinct reserved sign-in paths at `/Application/freelancer/login/`, `/Application/client/login/`, and `/Application/admin/login/`. They currently display placeholders only: there are no login forms, authentication, roles, dashboards, or module workflows. See [`Documentation/UIFoundation.md`](./Documentation/UIFoundation.md) for route boundaries and contribution notes.

## Technology

- **Database:** Microsoft SQL Server, using T-SQL. SQL Server can run on Linux; the scripts use SQL Server syntax such as `IDENTITY`, `GO`, `CREATE OR ALTER`, table-valued parameters, and `THROW`.
- **Version control:** Git and GitHub.
- **Application:** static HTML and shared CSS starter foundation; module behaviors and backend are not implemented.
- **Compatibility:** SQL Server 2016 SP1 or later is required for `CREATE OR ALTER`. Use a SQL Server instance/container and a client that understands `GO`, such as `sqlcmd` or a SQL Server editor.

## Database architecture

The database is named `NeuroLanceHubDB`. Its 15 original tables and their names are preserved. The design has five functional areas:

1. **Freelancers and skills:** `Freelancers`, `SkillCategories`, `AISkills`, `FreelancerSkills`, and `AIServices`.
2. **Clients and projects:** `Clients`, `Projects`, and `ProjectRequirements`.
3. **Proposals and assignments:** `Proposals`, `ProjectAssignments`, and `ProjectMilestones`.
4. **Payments and reviews:** `Payments` and `Reviews`.
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

The table-creation scripts are for a clean database and are not idempotent. Do not run them a second time against a database whose tables already exist. The sample-data script can be rerun; it checks natural keys before adding its own records. It prints row counts at the end.

The sample records use reserved `.test` email domains, demo transaction references, `Demo record only` payment methods, and non-authenticating password markers. They are not real users or payments and must not be used as production credentials. A production application must hash passwords with a suitable password-hashing library before storing them; SQL Server is not performing password hashing in these scripts.

## Schema files

- `Database/setup_database.sql` — database bootstrap.
- `Database/01_freelancer_module.sql` through `Database/05_admin_and_disputes.sql` — original table definitions and indexes.
- `Database/06_database_objects.sql` — SQL programmable objects and business-rule automation.
- `Database/07_sample_data.sql` — at least 10 synthetic rows per table where applicable; 20 AI skills, 22 freelancer-skill links, and 10 reviews are included.
- `Documentation/DatabaseDesign.md` — ER model, relationships, assumptions, and normalization rationale.
- `Documentation/DataDictionary.md` — column types, key/constraint notes, and field meanings.

## Coursework evidence still needed

The SQL portion now includes the required two-or-more triggers, user-defined functions, views, and stored procedures, plus synthetic sample data. The coursework report and presentation still need to be prepared by the team: include a rendered ER/database diagram, screenshots from a successfully built and populated SQL Server database, query and object demonstrations, critical evaluation, contribution evidence, and the presentation recording. Screenshots and recordings should be captured from the team’s actual running environment; they are not fabricated in this repository.

The assessment brief also asks the team to follow its permitted AI-use level and cite external or AI-generated code where required. Confirm those rules with the coursework instructions and teaching team before submission.

## Git workflow

The project uses `main` as the integrated branch and feature branches for team modules. Pull the latest `main`, work in the branch agreed by the team, and integrate through review. Keep the central schema and shared SQL objects coordinated so modules use the same table names and relationships.

For UI work, each member should own their module's HTML and any module-specific stylesheet. Keep shared tokens and shared components in `Shared/styles.css`; coordinate changes there with the team leader to reduce merge conflicts. Submit changes through a pull request targeting `main` when repository rules require review.
