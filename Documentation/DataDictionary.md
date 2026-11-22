# NeuroLance Hub - Database Data Dictionary
**Module:** PUSL2019 – Information Management & Retrieval  
**Assessment:** Coursework (C1)  
**Target RDBMS:** Microsoft SQL Server 2019 / 2022  
**Database Name:** `NeuroLanceHubDB`

---

## Table 1: `AdminUsers`
Stores administrative staff and decision-makers responsible for platform governance, monitoring, dispute resolution, and reporting.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `AdminID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique surrogate identifier for each administrative user. |
| `FullName` | `NVARCHAR(100)` | No | | Full name of the administrator or decision-maker. |
| `Email` | `NVARCHAR(150)` | No | `UNIQUE` | Official enterprise email used for administrative sign-in. |
| `PasswordHash` | `NVARCHAR(255)` | No | | Cryptographic hash of the administrative user credentials. |
| `Role` | `NVARCHAR(50)` | No | `CHECK IN ('Administrator', 'Platform Manager', 'Dispute Officer', 'Decision Maker')` | Administrative role determining authorization level. |
| `ContactNumber` | `NVARCHAR(30)` | Yes | | Phone or international contact number. |
| `IsActive` | `BIT` | No | `DEFAULT 1` | Soft-delete flag; 1 indicates active privileges, 0 suspended. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Timestamp when the administrative account was provisioned. |

---

## Table 2: `Clients`
Maintains profile, business organization details, contact information, and expenditure metrics of clients posting AI projects.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ClientID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique surrogate primary key for each client. |
| `FullName` | `NVARCHAR(100)` | No | | Primary contact person's full name. |
| `Email` | `NVARCHAR(150)` | No | `UNIQUE` | Unique client login and notification email address. |
| `PasswordHash` | `NVARCHAR(255)` | No | | Securely hashed user password. |
| `CompanyName` | `NVARCHAR(150)` | Yes | | Registered company, startup, or institutional name. |
| `Industry` | `NVARCHAR(100)` | Yes | | Primary industry vertical (e.g. Healthcare, Fintech, EdTech). |
| `Country` | `NVARCHAR(80)` | No | | Country of incorporation or primary operation. |
| `BillingAddress` | `NVARCHAR(255)` | Yes | | Tax and invoicing physical address. |
| `ContactNumber` | `NVARCHAR(30)` | Yes | | Direct contact telephone number. |
| `TotalSpent` | `DECIMAL(12,2)` | No | `DEFAULT 0.00`, `CHECK (TotalSpent >= 0)` | Cumulative financial spend released on the platform. |
| `ClientRating` | `DECIMAL(3,2)` | No | `DEFAULT 5.00`, `CHECK (BETWEEN 1.00 AND 5.00)` | Aggregated feedback score awarded by freelancers. |
| `IsActive` | `BIT` | No | `DEFAULT 1` | Account status indicator. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Registration timestamp. |

---

## Table 3: `Freelancers`
Maintains AI specialists, researchers, engineers, and consultants offering technical services.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `FreelancerID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique surrogate primary key for each freelancer. |
| `FullName` | `NVARCHAR(100)` | No | | Freelancer's full legal name. |
| `Email` | `NVARCHAR(150)` | No | `UNIQUE` | Login email and communication handle. |
| `PasswordHash` | `NVARCHAR(255)` | No | | Cryptographic credential hash. |
| `ProfessionalTitle` | `NVARCHAR(150)` | No | | Professional title (e.g. Principal LLM Architect). |
| `Bio` | `NVARCHAR(MAX)` | Yes | | Comprehensive summary of technical background. |
| `HourlyRate` | `DECIMAL(10,2)` | No | `DEFAULT 25.00`, `CHECK (HourlyRate >= 0)` | Standard hourly billing rate in USD. |
| `YearsOfExperience` | `INT` | No | `DEFAULT 0`, `CHECK (YearsOfExperience >= 0)` | Total career years in AI and software engineering. |
| `Country` | `NVARCHAR(80)` | No | | Country of residence. |
| `TotalEarnings` | `DECIMAL(12,2)` | No | `DEFAULT 0.00`, `CHECK (TotalEarnings >= 0)` | Cumulative net payout received through the platform. |
| `AverageRating` | `DECIMAL(3,2)` | No | `DEFAULT 5.00`, `CHECK (BETWEEN 1.00 AND 5.00)` | Cumulative average rating awarded by clients. |
| `CompletedProjectsCount` | `INT` | No | `DEFAULT 0`, `CHECK (>= 0)` | Number of successfully delivered projects. |
| `AvailabilityStatus` | `NVARCHAR(30)` | No | `DEFAULT 'Available'`, `CHECK IN ('Available', 'Busy', 'Unavailable')` | Work availability capacity indicator. |
| `IsActive` | `BIT` | No | `DEFAULT 1` | Profile operational state. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Account registration timestamp. |

---

## Table 4: `SkillCategories`
Higher-level taxonomy grouping specialized Artificial Intelligence domains.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `CategoryID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique category surrogate key. |
| `CategoryName` | `NVARCHAR(80)` | No | `UNIQUE` | Distinct domain name (e.g. Generative AI, Computer Vision). |
| `Description` | `NVARCHAR(300)` | Yes | | Scope description of the AI domain. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Timestamp of creation. |

---

## Table 5: `AISkills`
Master lookup of discrete AI technologies, frameworks, and methodologies.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `SkillID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique skill surrogate key. |
| `CategoryID` | `INT` | No | `FK -> SkillCategories(CategoryID)` | Parent skill category. |
| `SkillName` | `NVARCHAR(100)` | No | `UNIQUE` | Specific technology (e.g. PyTorch, YOLOv8, LangChain). |
| `Description` | `NVARCHAR(300)` | Yes | | Description of the skill application. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Record creation timestamp. |

---

## Table 6: `FreelancerSkills`
Associative table resolving Many-to-Many ($M:N$) relationship between Freelancers and AISkills.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `FreelancerSkillID`| `INT` | No | `PK`, `IDENTITY(1,1)` | Surrogate primary key. |
| `FreelancerID` | `INT` | No | `FK -> Freelancers(FreelancerID) ON DELETE CASCADE` | Associated freelancer. |
| `SkillID` | `INT` | No | `FK -> AISkills(SkillID) ON DELETE CASCADE` | Associated AI skill. |
| `ProficiencyLevel` | `NVARCHAR(30)` | No | `DEFAULT 'Intermediate'`, `CHECK IN ('Beginner', 'Intermediate', 'Expert')` | Assessed technical capability level. |
| `YearsExperience` | `INT` | No | `DEFAULT 1`, `CHECK (YearsExperience >= 0)` | Years working specifically with this technology. |
| `AcquiredAt` | `DATE` | Yes | | Approximate date when skill was mastered. |
| *Composite Unique* | | | `UNIQUE (FreelancerID, SkillID)` | Prevents duplicate skill assignment to the same freelancer. |

---

## Table 7: `AIServices`
Standardized, pre-packaged AI services and deliverables offered directly by freelancers.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ServiceID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique service identifier. |
| `FreelancerID` | `INT` | No | `FK -> Freelancers(FreelancerID) ON DELETE CASCADE` | Freelancer authoring and offering the service package. |
| `CategoryID` | `INT` | No | `FK -> SkillCategories(CategoryID)` | AI domain category. |
| `ServiceTitle` | `NVARCHAR(150)` | No | | Clear service headline (e.g. Turnkey RAG Pipeline). |
| `Description` | `NVARCHAR(MAX)` | No | | Detailed scope of what is delivered. |
| `DeliveryDays` | `INT` | No | `DEFAULT 7`, `CHECK (DeliveryDays > 0)` | Expected turnaround duration in calendar days. |
| `StartingPrice` | `DECIMAL(10,2)` | No | `CHECK (StartingPrice > 0)` | Base package price in USD. |
| `RevisionsIncluded`| `INT` | No | `DEFAULT 1`, `CHECK (>= 0)` | Number of client revision cycles included. |
| `IsActive` | `BIT` | No | `DEFAULT 1` | Availability flag. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Service publishing timestamp. |

---

## Table 8: `Projects`
Represents client-posted project opportunities and software requirements.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ProjectID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique project surrogate identifier. |
| `ClientID` | `INT` | No | `FK -> Clients(ClientID)` | Organization posting the project. |
| `Title` | `NVARCHAR(200)` | No | | Descriptive project title. |
| `Description` | `NVARCHAR(MAX)` | No | | In-depth project specifications, objectives, and datasets. |
| `Scope` | `NVARCHAR(50)` | No | `DEFAULT 'Medium'`, `CHECK IN ('Small', 'Medium', 'Large')` | Estimated project scale and complexity. |
| `Budget` | `DECIMAL(12,2)` | No | `CHECK (Budget > 0)` | Total client budget allocated for the project. |
| `DurationWeeks` | `INT` | No | `DEFAULT 4`, `CHECK (DurationWeeks > 0)` | Projected timeline in weeks. |
| `ProjectStatus` | `NVARCHAR(30)` | No | `DEFAULT 'Open'`, `CHECK IN ('Open', 'Assigned', 'In Progress', 'Under Review', 'Completed', 'Cancelled')` | Current lifecycle state. |
| `DeadlineDate` | `DATE` | Yes | | Expected project delivery cutoff date. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Posting timestamp. |

---

## Table 9: `ProjectRequirements`
Associative table resolving Many-to-Many ($M:N$) relationship between Projects and required AISkills.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ProjectRequirementID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Surrogate primary key. |
| `ProjectID` | `INT` | No | `FK -> Projects(ProjectID) ON DELETE CASCADE` | Associated project. |
| `SkillID` | `INT` | No | `FK -> AISkills(SkillID)` | Required AI skill. |
| `RequiredLevel` | `NVARCHAR(30)` | No | `DEFAULT 'Intermediate'`, `CHECK IN ('Beginner', 'Intermediate', 'Expert')` | Minimum expected proficiency. |
| *Composite Unique* | | | `UNIQUE (ProjectID, SkillID)` | Prevents duplicate skill requirement on a single project. |

---

## Table 10: `Proposals`
Maintains competitive bids and proposals submitted by freelancers for open projects.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ProposalID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique proposal identifier. |
| `ProjectID` | `INT` | No | `FK -> Projects(ProjectID)` | Target project being bid on. |
| `FreelancerID` | `INT` | No | `FK -> Freelancers(FreelancerID)` | Freelancer submitting the bid. |
| `CoverLetter` | `NVARCHAR(MAX)` | No | | Technical methodology, deliverables proposal, and pitch. |
| `BidAmount` | `DECIMAL(12,2)` | No | `CHECK (BidAmount > 0)` | Proposed total execution fee in USD. |
| `EstimatedDays` | `INT` | No | `CHECK (EstimatedDays > 0)` | Freelancer's estimated completion duration in days. |
| `ProposalStatus` | `NVARCHAR(30)` | No | `DEFAULT 'Pending'`, `CHECK IN ('Pending', 'Accepted', 'Rejected', 'Withdrawn')` | State of the proposal. |
| `SubmittedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Submission timestamp. |
| *Composite Unique* | | | `UNIQUE (ProjectID, FreelancerID)` | Ensures a freelancer submits only one active bid per project. |

---

## Table 11: `ProjectAssignments`
Binding legal and operational contract formed when a client accepts a freelancer's proposal.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `AssignmentID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique assignment contract identifier. |
| `ProjectID` | `INT` | No | `FK -> Projects(ProjectID)`, `UNIQUE` | Project being executed ($1:1$ per project). |
| `ProposalID` | `INT` | No | `FK -> Proposals(ProposalID)`, `UNIQUE` | Winning proposal ($1:1$ per winning proposal). |
| `FreelancerID` | `INT` | No | `FK -> Freelancers(FreelancerID)` | Assigned contractor. |
| `ClientID` | `INT` | No | `FK -> Clients(ClientID)` | Contracting client. |
| `AgreedPrice` | `DECIMAL(12,2)` | No | `CHECK (AgreedPrice > 0)` | Contractually locked price in USD. |
| `StartDate` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Contract effective start timestamp. |
| `ExpectedCompletionDate` | `DATE` | No | | Contractual delivery deadline. |
| `ActualCompletionDate` | `DATE` | Yes | | Date the final deliverable was accepted. |
| `AssignmentStatus` | `NVARCHAR(30)` | No | `DEFAULT 'Active'`, `CHECK IN ('Active', 'Under Review', 'Completed', 'Terminated')` | Operational state of the assignment contract. |

---

## Table 12: `ProjectMilestones`
Decomposes an assignment into discrete deliverables and milestone payment checkpoints.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `MilestoneID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique milestone primary key. |
| `AssignmentID` | `INT` | No | `FK -> ProjectAssignments(AssignmentID) ON DELETE CASCADE` | Associated contract assignment. |
| `MilestoneTitle` | `NVARCHAR(150)` | No | | Milestone name (e.g. Data Ingestion, Model Validation). |
| `Description` | `NVARCHAR(500)` | Yes | | Acceptance criteria and expected deliverables. |
| `Amount` | `DECIMAL(10,2)` | No | `CHECK (Amount > 0)` | Value of this specific milestone in USD. |
| `DueDate` | `DATE` | No | | Deadline for milestone submission. |
| `MilestoneStatus` | `NVARCHAR(30)` | No | `DEFAULT 'Pending'`, `CHECK IN ('Pending', 'In Progress', 'Submitted', 'Approved', 'Cancelled')` | Current milestone progression state. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Creation timestamp. |

---

## Table 13: `Payments`
Financial transactions representing escrow funding, platform commission deductions, and net payouts.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `PaymentID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique transaction identifier. |
| `AssignmentID` | `INT` | No | `FK -> ProjectAssignments(AssignmentID)` | Associated project assignment. |
| `MilestoneID` | `INT` | Yes | `FK -> ProjectMilestones(MilestoneID)` | Specific milestone being compensated (if applicable). |
| `ClientID` | `INT` | No | `FK -> Clients(ClientID)` | Payer client. |
| `FreelancerID` | `INT` | No | `FK -> Freelancers(FreelancerID)` | Payee freelancer. |
| `GrossAmount` | `DECIMAL(12,2)` | No | `CHECK (GrossAmount > 0)` | Total billed payment amount. |
| `PlatformFee` | `DECIMAL(10,2)` | No | `DEFAULT 0.00`, `CHECK (PlatformFee >= 0)` | Platform revenue calculated via `fn_CalculatePlatformFee`. |
| `NetAmount` | `DECIMAL(12,2)` | No | `CHECK (NetAmount > 0)` | Net payout to the freelancer (`Gross - PlatformFee`). |
| `PaymentMethod` | `NVARCHAR(50)` | No | `CHECK IN ('Credit Card', 'Bank Transfer', 'PayPal', 'Crypto / Web3', 'Stripe Escrow')` | Payment gateway / transfer method. |
| `PaymentStatus` | `NVARCHAR(30)` | No | `DEFAULT 'Held in Escrow'`, `CHECK IN ('Pending', 'Held in Escrow', 'Released', 'Refunded', 'Failed')` | Escrow / clearing state. |
| `TransactionReference` | `NVARCHAR(100)`| No | `UNIQUE` | Unique external payment gateway transaction hash. |
| `PaymentDate` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Escrow deposit or authorization date. |
| `ReleasedDate` | `DATETIME2` | Yes | | Date funds were released to freelancer wallet. |
| *Integrity Constraint*| | | `CHECK (NetAmount + PlatformFee = GrossAmount)` | Guarantees exact mathematical balance integrity. |

---

## Table 14: `Reviews`
Bidirectional rating and feedback system between clients and freelancers.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ReviewID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique review identifier. |
| `AssignmentID` | `INT` | No | `FK -> ProjectAssignments(AssignmentID)` | Contract assignment on which review is based. |
| `ReviewerType` | `NVARCHAR(20)` | No | `CHECK IN ('ClientToFreelancer', 'FreelancerToClient')` | Direction of the evaluation. |
| `ReviewerID` | `INT` | No | | User ID of the party providing feedback. |
| `RevieweeID` | `INT` | No | | User ID of the party receiving feedback. |
| `Rating` | `INT` | No | `CHECK (Rating BETWEEN 1 AND 5)` | Discrete 1 to 5 star rating. |
| `Comment` | `NVARCHAR(MAX)` | Yes | | Qualitative feedback review text. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Review submission timestamp. |
| *Composite Unique* | | | `UNIQUE (AssignmentID, ReviewerType)` | Enforces maximum 1 review per direction per assignment. |

---

## Table 15: `PlatformDisputes`
Administrative dispute resolution, SLA enforcement, and quality assurance auditing.

| Column Name | Data Type | Nullable | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `DisputeID` | `INT` | No | `PK`, `IDENTITY(1,1)` | Unique dispute ticket identifier. |
| `AssignmentID` | `INT` | No | `FK -> ProjectAssignments(AssignmentID)` | Contested assignment contract. |
| `RaisedByID` | `INT` | No | | ID of the user filing the dispute. |
| `RaisedByType` | `NVARCHAR(20)` | No | `CHECK IN ('Client', 'Freelancer')` | Entity category of claimant. |
| `Reason` | `NVARCHAR(200)` | No | | Summary classification of the grievance. |
| `Description` | `NVARCHAR(MAX)` | No | | Detailed evidentiary submission of the dispute. |
| `DisputeStatus` | `NVARCHAR(30)` | No | `DEFAULT 'Open'`, `CHECK IN ('Open', 'Under Investigation', 'Resolved', 'Dismissed')` | Administrative lifecycle status. |
| `ResolutionNotes` | `NVARCHAR(MAX)` | Yes | | Findings and ruling by the dispute officer. |
| `ResolvedByAdminID`| `INT` | Yes | `FK -> AdminUsers(AdminID)` | Administrator who adjudicated the issue. |
| `CreatedAt` | `DATETIME2` | No | `DEFAULT SYSUTCDATETIME()` | Ticket creation timestamp. |
| `ResolvedAt` | `DATETIME2` | Yes | | Adjudication closure timestamp. |
