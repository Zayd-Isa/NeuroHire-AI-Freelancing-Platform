# NeuroHire AI – AI-Powered Freelancing Platform

An AI-powered freelancing platform designed to connect clients with skilled freelancers through intelligent project matching, proposal management, secure payments, and administrative oversight.

---

## 📌 Project Overview

**NeuroHire AI** is a team-based software development project focused on building a freelancing platform that integrates artificial intelligence into the traditional freelancing workflow.

The system is designed to support:

- Freelancer registration and skill management.
- Client registration and project creation.
- AI-assisted project matching.
- Proposal submission and management.
- Project assignments and tracking.
- Secure payment and escrow management.
- Reviews, ratings, and dispute resolution.
- Administrative monitoring and analytics.

The project is being developed collaboratively using GitHub for version control, HTML/CSS for the frontend, and Microsoft SQL Server for database management.

---

## 📊 Current Project Progress

The following table tracks the foundational work completed so far and the remaining development activities.

| Component | Current Status |
|---|---|
| GitHub repository | ✅ Completed |
| Feature branch structure | ✅ Completed |
| Database architecture | ✅ Completed |
| 15 core database tables | ✅ Completed |
| Primary and foreign keys | ✅ Completed |
| Database constraints | ✅ Completed |
| Individual database module scripts | ✅ Merged into main |
| Master database setup script | 🟡 Awaiting PR merge |
| Shared CSS design system | 🟡 Awaiting PR merge |
| Central application navigation | 🟡 Awaiting PR merge |
| Five module starter templates | 🟡 Awaiting PR merge |
| Database data dictionary | 🟡 Awaiting PR merge |
| Team onboarding documentation | 🟡 Awaiting PR merge |
| Sample data insertion | ⬜ Pending |
| Database triggers | ⬜ Pending |
| User-defined functions | ⬜ Pending |
| Database views | ⬜ Pending |
| Stored procedures | ⬜ Pending |
| Frontend module implementation | ⬜ In progress |
| Frontend/database integration | ⬜ Pending |
| System testing and validation | ⬜ Pending |

**Status legend**

- ✅ Completed and reported as integrated into the main branch.
- 🟡 Implemented or pushed to a feature branch; integration into main is pending.
- 🔄 Currently being developed.
- ⬜ Not yet completed.

*Note: Branch and merge statuses should be updated as pull requests are reviewed and merged.*

---

## 🗄️ 1. Database Development

**Database:** `NeuroLanceHubDB`  
**Platform:** Microsoft SQL Server  
**Local development instance:** `.\SQLEXPRESS`

The foundational database architecture has been designed and implemented.

### Completed database components

- 15 core relational tables created.
- Primary keys and foreign key relationships defined.
- Auto-incrementing primary keys implemented.
- Referential integrity constraints established.
- Domain-specific CHECK constraints implemented.
- UNIQUE constraints for relevant fields, including emails and bids.
- Financial balance invariants implemented, including Gross = Net + Fee.
- Individual SQL scripts prepared for the five modules.

### Database module scripts

| File | Module | Status |
|---|---|---|
| `01_freelancer_module.sql` | Freelancer | ✅ Merged |
| `02_client_project_module.sql` | Client & Projects | ✅ Merged |
| `03_proposals_and_assignments.sql` | Proposals & Assignments | ✅ Merged |
| `04_payments_and_reviews.sql` | Payments & Reviews | ✅ Merged |
| `05_admin_and_disputes.sql` | Administration & Disputes | ✅ Merged |
| `setup_database.sql` | Complete database installation | 🟡 Pending PR merge |

### Remaining database tasks

- Insert at least 10 realistic sample records per table.
- Develop 3 database triggers.
- Develop 4 user-defined functions (UDFs).
- Develop 4 database views.
- Develop 5 stored procedures.
- Validate database operations and relationships.
- Capture database screenshots for coursework documentation.

---

## 🎨 2. Shared Frontend Design System

A centralized CSS design system has been prepared to maintain a consistent appearance across all five modules.

**File:** `Shared/styles.css`

### Reported implemented features

- Centralized CSS variables.
- Indigo and Cyan AI-inspired colour palette.
- Consistent typography and spacing.
- Reusable buttons and interactive elements.
- Standardized cards and containers.
- Form inputs and validation styling.
- Status badges.
- Tables and navigation styling.
- Responsive grid layouts.

All team members should use the shared stylesheet rather than creating separate, inconsistent design systems.

**Integration status:** Awaiting the shared UI pull request to be merged into `main`.

---

## 🏗️ 3. Application Structure

The application has been organized into a central navigation hub and five individual modules.

### Planned application structure

```text
Application/
│
├── index.html
│
├── freelancer/
│   └── index.html
│
├── client/
│   └── index.html
│
├── proposals/
│   └── index.html
│
├── payments/
│   └── index.html
│
└── admin/
    └── index.html
```

### Module responsibilities

| Module | Main Responsibilities |
|---|---|
| Freelancer | Registration, profiles and skills |
| Client | Client management and AI project posting |
| Proposals | Proposal submission and assignments |
| Payments | Payment processing and escrow ledger |
| Admin | Disputes, monitoring and analytics |

The current HTML files are starter templates and should not be considered fully implemented application modules.

---

## 📁 4. Repository Structure

The intended repository structure is:

```text
NeuroHire-AI-Freelancing-Platform/
│
├── Application/
│   ├── index.html
│   ├── freelancer/
│   ├── client/
│   ├── proposals/
│   ├── payments/
│   └── admin/
│
├── Database/
│   ├── setup_database.sql
│   ├── 01_freelancer_module.sql
│   ├── 02_client_project_module.sql
│   ├── 03_proposals_and_assignments.sql
│   ├── 04_payments_and_reviews.sql
│   └── 05_admin_and_disputes.sql
│
├── Documentation/
│   └── DataDictionary.md
│
├── Shared/
│   └── styles.css
│
├── TEAM_GUIDE.md
│
└── README.md
```

*Some foundational files are currently awaiting integration into the main branch.*

---

## 👥 5. Team Responsibilities

The project is divided into five development modules.

| Team Member | Feature Branch | Assigned Module |
|---|---|---|
| Member 1 | `feature/freelancer-module` | Freelancer |
| Member 2 | `feature/client-project-module` | Client & Projects |
| Member 3 | `feature/proposals-module` | Proposals & Assignments |
| Member 4 | `feature/payments-module` | Payments & Reviews |
| Member 5 | `feature/admin-module` | Administration & Disputes |

Each member is expected to:

1. Work within their assigned feature branch.
2. Follow the database column names in `Documentation/DataDictionary.md`.
3. Use the centralized stylesheet in `Shared/styles.css`.
4. Avoid modifying another member's module without coordination.
5. Commit changes regularly with meaningful commit messages.
6. Push completed work to their assigned feature branch.
7. Create a Pull Request for review before merging into `main`.

---

## ⚙️ 6. Getting Started

### Prerequisites

Before starting development, ensure that you have:

- Git installed.
- Visual Studio Code or another suitable code editor.
- Microsoft SQL Server.
- SQL Server Management Studio (SSMS).
- Access to the project GitHub repository.

### Step 1 – Clone the repository

```bash
git clone https://github.com/Zayd-Isa/NeuroHire-AI-Freelancing-Platform.git
```

Navigate into the project:

```bash
cd NeuroHire-AI-Freelancing-Platform
```

### Step 2 – Update your local repository

```bash
git checkout main
git pull origin main
```

### Step 3 – Switch to your assigned branch

Example for the freelancer module:

```bash
git checkout feature/freelancer-module
```

Replace the branch name with your assigned branch.

### Step 4 – Set up the database

Once `Database/setup_database.sql` has been merged into `main`:

1. Open SQL Server Management Studio.
2. Connect to your local SQL Server instance.
3. Open `Database/setup_database.sql`.
4. Execute the script.
5. Refresh the Databases folder.
6. Confirm that `NeuroLanceHubDB` and its tables have been created.

**Important:** Do not independently recreate the database tables if the master setup script has already created them.

### Step 5 – Start frontend development

Navigate to your assigned folder under `Application/`.

Use the shared stylesheet:

```html
<link rel="stylesheet" href="../../Shared/styles.css">
```

Adjust the relative path according to the location of your HTML file.

---

## 🔀 7. Git & Pull Request Workflow

We use a feature-branch workflow to maintain collaboration and minimize conflicts.

### Branch naming convention

```text
main
│
├── feature/freelancer-module
├── feature/client-project-module
├── feature/proposals-module
├── feature/payments-module
├── feature/admin-module
└── feature/shared-ui-and-standards
```

### Recommended development workflow

```bash
git checkout main
git pull origin main

git checkout feature/your-module

git add .
git commit -m "Add freelancer registration interface"

git push origin feature/your-module
```

After pushing:

1. Open the GitHub repository.
2. Create a Pull Request.
3. Select `main` as the base branch.
4. Describe the changes.
5. Request review.
6. Merge after approval.

**Important:** Do not commit directly to `main` for individual module development.

---

## 🎯 8. Upcoming Development Milestones

The following activities represent the remaining major development work.

### Phase 1 – Foundational setup

- [x] Create GitHub repository.
- [x] Establish feature branches.
- [x] Design and implement core database architecture.
- [x] Create 15 core tables.
- [x] Define database constraints and relationships.
- [x] Merge five individual database scripts.
- [ ] Merge shared UI and application foundation files into `main`.

### Phase 2 – Database completion

- [ ] Insert realistic sample data (minimum 10 records per table).
- [ ] Implement 3 triggers.
- [ ] Implement 4 UDFs.
- [ ] Implement 4 views.
- [ ] Implement 5 stored procedures.
- [ ] Test database functionality.

### Phase 3 – Frontend development

- [ ] Implement freelancer module.
- [ ] Implement client and project module.
- [ ] Implement proposal module.
- [ ] Implement payments module.
- [ ] Implement administration module.
- [ ] Maintain consistent UI across all modules.

### Phase 4 – Integration and testing

- [ ] Connect frontend components to the database.
- [ ] Validate module interactions.
- [ ] Test user workflows.
- [ ] Validate financial calculations.
- [ ] Test error handling and input validation.
- [ ] Perform final system testing.

### Phase 5 – Coursework documentation

- [ ] Capture required database screenshots.
- [ ] Document database programmability.
- [ ] Prepare implementation evidence.
- [ ] Review the final coursework requirements.
- [ ] Prepare the final submission.

---

## 📚 9. Project Documentation

The following documentation files are intended to help team members work consistently.

| Document | Purpose |
|---|---|
| `README.md` | Project overview and progress tracking |
| `TEAM_GUIDE.md` | Team onboarding and development instructions |
| `Documentation/DataDictionary.md` | Database tables, columns and field references |
| `Database/setup_database.sql` | Master database installation script |
| `Shared/styles.css` | Centralized frontend design system |

---

## 📢 10. Team Development Guidelines

To maintain consistency throughout development:

- Always pull the latest changes before beginning work.
- Work only within your assigned feature branch.
- Follow the existing database architecture.
- Use exact database table and column names.
- Reuse shared CSS components.
- Do not create duplicate database tables.
- Test your changes before creating a Pull Request.
- Communicate any structural changes to the team.
- Keep documentation updated when functionality changes.
- Update this README as major milestones are completed.

---

## 📈 Project Status Updates

This README serves as the central progress reference for the NeuroHire AI development team.

Whenever a significant task is completed, update the corresponding checklist and status table so that every team member can understand the current state of development.

**Repository:** [NeuroHire-AI-Freelancing-Platform](https://github.com/Zayd-Isa/NeuroHire-AI-Freelancing-Platform)

**Development approach:** Collaborative development using GitHub, modular architecture, shared frontend standards and centralized database management.

---

*NeuroHire AI – Building a smarter freelancing experience.*[ggg.pdf](https://github.com/user-attachments/files/35334580/ggg.pdf)
