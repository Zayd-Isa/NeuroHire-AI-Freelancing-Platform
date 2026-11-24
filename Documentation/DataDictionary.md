# NeuroLance Hub data dictionary

This dictionary describes the existing SQL Server tables. `PK` is a primary key, `FK` is a foreign key, `UQ` is a unique constraint, `CK` is a check constraint, and `DF` is a default. Unless stated otherwise, listed columns are `NOT NULL` only where the table script declares them that way. `IDENTITY(1,1)` means SQL Server generates an increasing identifier.

## Freelancers

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| FreelancerID | INT IDENTITY | PK | Freelancer record identifier. |
| FullName | VARCHAR(100) | Required | Display name. |
| Email | VARCHAR(100) | Required, UQ | Login/contact email; unique in this table. |
| Password | VARCHAR(255) | Required | Application-managed password hash; sample marker is not a usable hash. |
| Title | VARCHAR(100) | Required | Professional title. |
| Bio | VARCHAR(MAX) | Nullable | Profile description. |
| HourlyRate | DECIMAL(10,2) | Required, CK >= 0 | Advertised hourly price. |
| ExperienceYears | INT | Required, DF 0, CK >= 0 | Total years of experience. |
| Country | VARCHAR(60) | Required | Freelancer country. |
| TotalEarnings | DECIMAL(10,2) | Required, DF 0.00 | Cached released net payment total; maintained by payment trigger. |
| AverageRating | DECIMAL(3,2) | Required, DF 5.00, CK 1.00–5.00 | Cached client review average; maintained by review trigger. |
| CompletedProjects | INT | Required, DF 0 | Cached completed assignment count; maintained by assignment trigger. |
| Availability | VARCHAR(20) | Required, DF `Available`, CK | `Available`, `Busy`, or `Unavailable`. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Profile creation timestamp. |

## SkillCategories

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| CategoryID | INT IDENTITY | PK | Skill category identifier. |
| CategoryName | VARCHAR(50) | Required, UQ | Unique category name. |
| Description | VARCHAR(255) | Nullable | Category explanation. |

## AISkills

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| SkillID | INT IDENTITY | PK | Skill identifier. |
| CategoryID | INT | Required, FK → SkillCategories.CategoryID | Category that contains this skill. |
| SkillName | VARCHAR(80) | Required, UQ | Unique skill/tool name. |
| Description | VARCHAR(255) | Nullable | Skill explanation. |

## FreelancerSkills

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| FreelancerSkillID | INT IDENTITY | PK | Freelancer-skill link identifier. |
| FreelancerID | INT | Required, FK → Freelancers; cascade delete | Freelancer with this skill. |
| SkillID | INT | Required, FK → AISkills; cascade delete | Skill linked to the freelancer. |
| ProficiencyLevel | VARCHAR(20) | Required, DF `Intermediate`, CK | `Beginner`, `Intermediate`, or `Expert`. |
| YearsExperience | INT | Required, DF 1 | Years using this skill; no range check is currently defined. |
| (FreelancerID, SkillID) | — | UQ | Prevents the same skill being linked twice to one freelancer. |

## AIServices

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| ServiceID | INT IDENTITY | PK | Service identifier. |
| FreelancerID | INT | Required, FK → Freelancers; cascade delete | Freelancer offering the service. |
| CategoryID | INT | Required, FK → SkillCategories | Service category. |
| Title | VARCHAR(150) | Required | Service title. |
| Description | VARCHAR(MAX) | Required | Service scope and details. |
| DeliveryDays | INT | Required, CK > 0 | Expected delivery duration. |
| Price | DECIMAL(10,2) | Required, CK > 0 | Fixed service price. |
| Revisions | INT | Required, DF 1 | Included revision count; no range check is currently defined. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Service creation timestamp. |

## Clients

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| ClientID | INT IDENTITY | PK | Client record identifier. |
| FullName | VARCHAR(100) | Required | Client contact name. |
| Email | VARCHAR(100) | Required, UQ | Contact email; unique in this table. |
| Password | VARCHAR(255) | Required | Application-managed password hash; sample marker is not a usable hash. |
| CompanyName | VARCHAR(100) | Nullable | Organization name. |
| Industry | VARCHAR(80) | Nullable | Business sector. |
| Country | VARCHAR(60) | Required | Client country. |
| BillingAddress | VARCHAR(255) | Nullable | Billing address. |
| ContactNumber | VARCHAR(30) | Nullable | Contact phone number. |
| TotalSpent | DECIMAL(10,2) | Required, DF 0.00, CK >= 0 | Cached released gross payment total; maintained by payment trigger. |
| ClientRating | DECIMAL(3,2) | Required, DF 5.00, CK 1.00–5.00 | Cached freelancer review average; maintained by review trigger. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Client creation timestamp. |

## Projects

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| ProjectID | INT IDENTITY | PK | Project identifier. |
| ClientID | INT | Required, FK → Clients | Client who posted the project. |
| Title | VARCHAR(150) | Required | Project title. |
| Description | VARCHAR(MAX) | Required | Project description and scope. |
| Scope | VARCHAR(20) | Required, DF `Medium`, CK | `Small`, `Medium`, or `Large`. |
| Budget | DECIMAL(10,2) | Required, CK > 0 | Client's project budget. |
| DurationWeeks | INT | Required, DF 4, CK > 0 | Estimated project duration. |
| ProjectStatus | VARCHAR(20) | Required, DF `Open`, CK | `Open`, `Assigned`, `In Progress`, `Completed`, or `Cancelled`. |
| DeadlineDate | DATE | Nullable | Requested project deadline. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Project creation timestamp. |

## ProjectRequirements

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| RequirementID | INT IDENTITY | PK | Project-skill requirement identifier. |
| ProjectID | INT | Required, FK → Projects; cascade delete | Project needing the skill. |
| SkillID | INT | Required, FK → AISkills | Required AI skill. |
| RequiredLevel | VARCHAR(20) | Required, DF `Intermediate`, CK | `Beginner`, `Intermediate`, or `Expert`. |
| (ProjectID, SkillID) | — | UQ | Prevents duplicate requirements for one skill on a project. |

## Proposals

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| ProposalID | INT IDENTITY | PK | Proposal identifier. |
| ProjectID | INT | Required, FK → Projects | Project being bid on. |
| FreelancerID | INT | Required, FK → Freelancers | Freelancer submitting the proposal. |
| CoverLetter | VARCHAR(MAX) | Required | Freelancer's proposal text. |
| BidAmount | DECIMAL(10,2) | Required, CK > 0 | Proposed price. |
| EstimatedDays | INT | Required, CK > 0 | Proposed delivery duration. |
| ProposalStatus | VARCHAR(20) | Required, DF `Pending`, CK | `Pending`, `Accepted`, `Rejected`, or `Withdrawn`. |
| SubmittedAt | DATETIME | Required, DF `GETDATE()` | Proposal submission time. |
| (ProjectID, FreelancerID) | — | UQ | One proposal per freelancer per project. |

## ProjectAssignments

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| AssignmentID | INT IDENTITY | PK | Assignment identifier. |
| ProjectID | INT | Required, FK → Projects, UQ | Assigned project; at most one assignment per project. |
| ProposalID | INT | Required, FK → Proposals, UQ | Accepted proposal; at most one assignment per proposal. |
| FreelancerID | INT | Required, FK → Freelancers | Freelancer performing the work. |
| ClientID | INT | Required, FK → Clients | Client commissioning the work. |
| AgreedPrice | DECIMAL(10,2) | Required, CK > 0 | Contracted price. |
| StartDate | DATETIME | Required, DF `GETDATE()` | Assignment start timestamp. |
| ExpectedCompletionDate | DATE | Required | Target completion date. |
| ActualCompletionDate | DATE | Nullable | Recorded completion date. |
| AssignmentStatus | VARCHAR(20) | Required, DF `Active`, CK | `Active`, `In Progress`, `Completed`, or `Terminated`. |

## ProjectMilestones

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| MilestoneID | INT IDENTITY | PK | Milestone identifier. |
| AssignmentID | INT | Required, FK → ProjectAssignments; cascade delete | Assignment containing the milestone. |
| MilestoneTitle | VARCHAR(100) | Required | Milestone title. |
| Description | VARCHAR(255) | Nullable | Milestone details. |
| Amount | DECIMAL(10,2) | Required, CK > 0 | Amount associated with the milestone. |
| DueDate | DATE | Required | Milestone due date. |
| MilestoneStatus | VARCHAR(20) | Required, DF `Pending`, CK | `Pending`, `In Progress`, `Submitted`, or `Approved`. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Milestone creation timestamp. |

## Payments

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| PaymentID | INT IDENTITY | PK | Payment record identifier. |
| AssignmentID | INT | Required, FK → ProjectAssignments | Assignment being paid. |
| MilestoneID | INT | Nullable, FK → ProjectMilestones | Optional milestone being paid. |
| ClientID | INT | Required, FK → Clients | Payer. |
| FreelancerID | INT | Required, FK → Freelancers | Payee. |
| GrossAmount | DECIMAL(10,2) | Required, CK > 0 | Total client payment. |
| PlatformFeeRate | DECIMAL(5,4) | Required, DF 0.1000, CK 0–0.9999 | Commission-rate snapshot for this payment; the default is only a coursework demo assumption. |
| PlatformFee | DECIMAL(10,2) | Required, DF 0.00, CK >= 0 | Platform fee amount. |
| NetAmount | DECIMAL(10,2) | Required, CK > 0 | Freelancer amount after fee. |
| PaymentMethod | VARCHAR(50) | Required | Safe payment-method label only; never a card number or credential. |
| PaymentProvider | VARCHAR(50) | Nullable | Provider name or integration label; no real gateway is configured. |
| PaymentStatus | VARCHAR(20) | Required, DF `Pending`, CK | `Pending`, `Held in Escrow`, `Released`, `Refunded`, `Failed`, `Cancelled`, or `Disputed`. |
| TransactionRef | VARCHAR(100) | Required, UQ | Unique provider/demo reference; must not contain a card number or secret. |
| IdempotencyKey | UNIQUEIDENTIFIER | Required, UQ, DF `NEWID()` | Prevents a retried payment request from creating a duplicate row. |
| PaymentDate | DATETIME | Required, DF `GETDATE()` | Payment record timestamp. |
| ReleasedDate | DATETIME | Nullable | Time funds were released. |
| NetAmount + PlatformFee | — | CK = GrossAmount | Ensures recorded amounts balance. |

## PaymentStatusHistory

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| PaymentStatusEventID | BIGINT IDENTITY | PK | Status event identifier. |
| PaymentID | INT | Required, FK → Payments.PaymentID | Payment whose status changed. |
| PreviousStatus | VARCHAR(20) | Nullable | Status before the transition; `NULL` for the initial payment request. |
| NewStatus | VARCHAR(20) | Required | Resulting payment status. |
| ActorType | VARCHAR(20) | Required, CK | `System`, `Client`, `Freelancer`, or `Admin`. |
| ActorID | INT | Nullable | Account ID supplied by the trusted application; polymorphic by actor type. |
| Reason | VARCHAR(500) | Nullable | Audit explanation for the event. |
| OccurredAt | DATETIME2(3) | Required, DF `SYSUTCDATETIME()` | UTC time recorded for the status event. |

## Reviews

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| ReviewID | INT IDENTITY | PK | Review identifier. |
| AssignmentID | INT | Required, FK → ProjectAssignments | Assignment being reviewed. |
| ReviewerType | VARCHAR(20) | Required, CK | `ClientToFreelancer` or `FreelancerToClient`. |
| ReviewerID | INT | Required | Reviewer account ID; trigger checks against assignment. |
| RevieweeID | INT | Required | Reviewed account ID; trigger checks against assignment. |
| Rating | INT | Required, CK 1–5 | Review score. |
| Comment | NVARCHAR(MAX) | Nullable | Unicode written review; widened by script 09. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Review creation timestamp. |
| (AssignmentID, ReviewerType) | — | UQ | At most one review per direction on an assignment. |

## AdminUsers

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| AdminID | INT IDENTITY | PK | Administrator identifier. |
| FullName | VARCHAR(100) | Required | Administrator name. |
| Email | VARCHAR(100) | Required, UQ | Unique administrator email. |
| Password | VARCHAR(255) | Required | Application-managed password hash; sample marker is not a usable hash. |
| Role | VARCHAR(50) | Required, DF `Administrator`, CK | `Administrator`, `Platform Manager`, `Dispute Officer`, or `Decision Maker`. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Administrator creation timestamp. |

## PlatformDisputes

| Field | SQL type | Key / constraint | Meaning |
| --- | --- | --- | --- |
| DisputeID | INT IDENTITY | PK | Dispute identifier. |
| AssignmentID | INT | Required, FK → ProjectAssignments | Assignment involved in the dispute. |
| RaisedByID | INT | Required | Client/freelancer ID; `RaisedByType` identifies the table. |
| RaisedByType | VARCHAR(20) | Required, CK | `Client` or `Freelancer`. |
| Reason | VARCHAR(150) | Required | Dispute category or short reason. |
| Description | VARCHAR(MAX) | Required | Dispute details. |
| DisputeStatus | VARCHAR(20) | Required, DF `Open`, CK | `Open`, `Under Investigation`, `Resolved`, or `Dismissed`. |
| ResolutionNotes | VARCHAR(MAX) | Nullable | Admin's resolution notes. |
| ResolvedByAdminID | INT | Nullable, FK → AdminUsers | Admin who resolved the dispute. |
| CreatedAt | DATETIME | Required, DF `GETDATE()` | Dispute creation timestamp. |
| ResolvedAt | DATETIME | Nullable | Resolution timestamp. |

## Supporting indexes

The schema adds nonclustered indexes on `Projects(ClientID)`, `Projects(ProjectStatus)`, `Proposals(ProjectID)`, `FreelancerSkills(SkillID)`, `Payments(AssignmentID)`, and `PaymentStatusHistory(PaymentID, OccurredAt DESC)` to support common joins, filters, and newest-first payment audit history.
