# NeuroLance Hub team guide

## Purpose

This guide records the six-member responsibility plan and shared workflow for the PUSL2019 AI freelancing platform. Roles identify work areas; they do not by themselves prove that a feature is complete. Check the code, database, evidence, and presentation before marking a responsibility done.

## Team roles

### Team leader — database, shared UI standards, and integration

- Maintain the public GitHub repository, `main`, and agreed feature-branch naming.
- Own the central SQL Server schema, table names, keys, relationships, and constraints.
- Maintain the shared CSS/design rules and application folder structure.
- Keep the shared design tokens and reusable components centralized in `Shared/styles.css`; review changes there to avoid overlapping edits.
- Define integration expectations and review feature branches/pull requests.
- Coordinate integration checks, the database diagram, relational mapping, normalization, data dictionary, and presentation flow.

### Member 1 — freelancer module

- Build freelancer registration/profile, skills/services, dashboard, and project-browsing features.
- Use the shared database and UI standards; provide module SQL, sample data, screenshots, and workflow notes.

### Member 2 — client and project module

- Build client/organization profile, project create/edit, and skill-requirement features.
- Provide the related SQL, sample data, screenshots, and project-creation workflow evidence.

### Member 3 — proposal and assignment module

- Build freelancer proposal submission, client proposal review/selection, assignment creation, and project status updates.
- Provide related SQL, sample data, screenshots, and workflow evidence.

### Member 4 — payment and review module

- Build payment history/status and client/freelancer review/rating features.
- Connect the module to the shared schema and payment rules; provide related SQL, sample data, screenshots, and workflow evidence.
- A demo database record is not a real payment integration. A real payment gateway requires separate provider credentials and implementation.

### Member 5 — administration, reports, and final QA

- Build administration/management pages for users, categories, project monitoring, disputes, and platform overview.
- Build and review the project, freelancer, client, service, and payment reports.
- Coordinate final integration checks and collect report/presentation evidence.

## Shared responsibilities

All six members should:

- Use the agreed schema and shared styles; coordinate schema changes with the team leader.
- Work on individual feature branches, pull the latest integrated branch, and submit reviewable changes.
- Keep code, SQL, and documentation together; include meaningful sample data and explain non-obvious logic.
- Check their contribution in the integrated application and record genuine screenshots/evidence.
- Prepare a clear contribution summary and be ready to explain their work in the 15-minute presentation.

## Shared UI foundation

The UI is deliberately a minimal route scaffold rather than a finished application. `Application/index.html` only points to distinct freelancer, client, proposals, payments/reviews, and admin paths. Freelancer, client, and admin each have a separate reserved `login/` path. These login paths are placeholders: they have no forms or authentication. The payment/review page contains no payment form, transaction behavior, gateway, or review workflow.

Use `Shared/styles.css` as the intentionally small base stylesheet. It defines the navy, warm-white, butter-gold, and cyan logo colors plus basic page and link styles. Members can design their assigned module pages independently. The route map and contribution boundaries are in `Documentation/UIFoundation.md`.

Contribution rules:

- Keep common design changes in `Shared/styles.css` and coordinate them with the team leader.
- Keep feature markup in the assigned module page; do not overwrite another member's page.
- Put module-only CSS in a stylesheet inside that module's own folder and keep the shared base small.
- Preserve semantic headings, keyboard focus, and responsive behavior when extending a page.
- Pull the latest `main` before starting and submit a reviewable pull request to `main` according to repository rules.

## Database integration order

On a clean SQL Server database, run:

1. `Database/setup_database.sql`
2. `Database/01_freelancer_module.sql` through `Database/05_admin_and_disputes.sql` in numeric order
3. `Database/06_database_objects.sql`
4. `Database/07_sample_data.sql`

This project uses Microsoft SQL Server T-SQL. Running the SQL Server engine on Linux is supported; it is not interchangeable with SQLite or MySQL. See the root README for the database objects, sample-data cautions, and query examples.

## Handoff checklist

- [ ] The integrated branch builds and each feature has a clear owner and review record.
- [ ] A clean SQL Server database can be created from the documented scripts.
- [ ] Required rows are present, foreign keys and constraints hold, and triggers/functions/views/procedures are demonstrated.
- [ ] Each UI module uses the shared schema and has a working end-to-end flow.
- [ ] The report includes the scenario analysis, assumptions, ER/EER diagram, relational mapping, normalization, data dictionary, SQL evidence, critical evaluation, and future improvements.
- [ ] Screenshots are captured from the actual running system; the presentation recording demonstrates the integrated system and individual contributions.
- [ ] The team has checked the assessment's permitted AI-use level and cited outside/generated code where required.

## Current repository boundary

The SQL schema, programmable objects, synthetic data, design notes, shared CSS design system, and static HTML scaffolds are present. The module workflows, backend integration, genuine runtime screenshots, and presentation recording still need team implementation. Do not mark those checklist items complete based on the shared scaffold or database scripts alone.
