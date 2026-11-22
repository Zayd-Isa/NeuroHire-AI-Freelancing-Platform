-- ============================================================================
-- SCRIPT: 01_CreateDatabaseAndTables.sql
-- PROJECT: NeuroLance Hub - AI Projects & Services Freelancing Platform
-- MODULE: PUSL2019 – Information Management & Retrieval (Coursework C1)
-- TARGET RDBMS: Microsoft SQL Server 2019 / 2022
-- DESCRIPTION: DDL Script to create database, schema, tables, relationships,
--              integrity constraints, and performance indexes.
-- ============================================================================

-- Step 1: Ensure database exists and switch context
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'NeuroLanceHubDB')
BEGIN
    CREATE DATABASE NeuroLanceHubDB;
    PRINT 'Database [NeuroLanceHubDB] created successfully.';
END
GO

USE NeuroLanceHubDB;
GO

-- ============================================================================
-- Step 2: Drop existing foreign keys and tables if recreating schema
-- ============================================================================

-- Drop tables in reverse dependency order
IF OBJECT_ID('dbo.PlatformDisputes', 'U') IS NOT NULL DROP TABLE dbo.PlatformDisputes;
IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.ProjectMilestones', 'U') IS NOT NULL DROP TABLE dbo.ProjectMilestones;
IF OBJECT_ID('dbo.ProjectAssignments', 'U') IS NOT NULL DROP TABLE dbo.ProjectAssignments;
IF OBJECT_ID('dbo.Proposals', 'U') IS NOT NULL DROP TABLE dbo.Proposals;
IF OBJECT_ID('dbo.ProjectRequirements', 'U') IS NOT NULL DROP TABLE dbo.ProjectRequirements;
IF OBJECT_ID('dbo.Projects', 'U') IS NOT NULL DROP TABLE dbo.Projects;
IF OBJECT_ID('dbo.AIServices', 'U') IS NOT NULL DROP TABLE dbo.AIServices;
IF OBJECT_ID('dbo.FreelancerSkills', 'U') IS NOT NULL DROP TABLE dbo.FreelancerSkills;
IF OBJECT_ID('dbo.AISkills', 'U') IS NOT NULL DROP TABLE dbo.AISkills;
IF OBJECT_ID('dbo.SkillCategories', 'U') IS NOT NULL DROP TABLE dbo.SkillCategories;
IF OBJECT_ID('dbo.AdminUsers', 'U') IS NOT NULL DROP TABLE dbo.AdminUsers;
IF OBJECT_ID('dbo.Clients', 'U') IS NOT NULL DROP TABLE dbo.Clients;
IF OBJECT_ID('dbo.Freelancers', 'U') IS NOT NULL DROP TABLE dbo.Freelancers;
GO

-- ============================================================================
-- Step 3: Create Tables
-- ============================================================================

-- 1. Table: AdminUsers (System Administrators & Managers)
CREATE TABLE dbo.AdminUsers (
    AdminID             INT IDENTITY(1,1) NOT NULL,
    FullName            NVARCHAR(100) NOT NULL,
    Email               NVARCHAR(150) NOT NULL,
    PasswordHash        NVARCHAR(255) NOT NULL,
    Role                NVARCHAR(50)  NOT NULL DEFAULT 'Administrator',
    ContactNumber       NVARCHAR(30)  NULL,
    IsActive            BIT           NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AdminUsers PRIMARY KEY CLUSTERED (AdminID),
    CONSTRAINT UQ_AdminUsers_Email UNIQUE (Email),
    CONSTRAINT CK_AdminUsers_Role CHECK (Role IN ('Administrator', 'Platform Manager', 'Dispute Officer', 'Decision Maker'))
);
GO

-- 2. Table: Clients (Clients & Organizations posting AI projects)
CREATE TABLE dbo.Clients (
    ClientID            INT IDENTITY(1,1) NOT NULL,
    FullName            NVARCHAR(100) NOT NULL,
    Email               NVARCHAR(150) NOT NULL,
    PasswordHash        NVARCHAR(255) NOT NULL,
    CompanyName         NVARCHAR(150) NULL,
    Industry            NVARCHAR(100) NULL,
    Country             NVARCHAR(80)  NOT NULL,
    BillingAddress      NVARCHAR(255) NULL,
    ContactNumber       NVARCHAR(30)  NULL,
    TotalSpent          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    ClientRating        DECIMAL(3,2)  NOT NULL DEFAULT 5.00,
    IsActive            BIT           NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Clients PRIMARY KEY CLUSTERED (ClientID),
    CONSTRAINT UQ_Clients_Email UNIQUE (Email),
    CONSTRAINT CK_Clients_TotalSpent CHECK (TotalSpent >= 0.00),
    CONSTRAINT CK_Clients_Rating CHECK (ClientRating BETWEEN 1.00 AND 5.00)
);
GO

-- 3. Table: Freelancers (AI Practitioners & Service Providers)
CREATE TABLE dbo.Freelancers (
    FreelancerID           INT IDENTITY(1,1) NOT NULL,
    FullName               NVARCHAR(100) NOT NULL,
    Email                  NVARCHAR(150) NOT NULL,
    PasswordHash           NVARCHAR(255) NOT NULL,
    ProfessionalTitle      NVARCHAR(150) NOT NULL,
    Bio                    NVARCHAR(MAX) NULL,
    HourlyRate             DECIMAL(10,2) NOT NULL DEFAULT 25.00,
    YearsOfExperience      INT           NOT NULL DEFAULT 0,
    Country                NVARCHAR(80)  NOT NULL,
    TotalEarnings          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    AverageRating          DECIMAL(3,2)  NOT NULL DEFAULT 5.00,
    CompletedProjectsCount INT           NOT NULL DEFAULT 0,
    AvailabilityStatus     NVARCHAR(30)  NOT NULL DEFAULT 'Available',
    IsActive               BIT           NOT NULL DEFAULT 1,
    CreatedAt              DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Freelancers PRIMARY KEY CLUSTERED (FreelancerID),
    CONSTRAINT UQ_Freelancers_Email UNIQUE (Email),
    CONSTRAINT CK_Freelancers_HourlyRate CHECK (HourlyRate >= 0.00),
    CONSTRAINT CK_Freelancers_YearsExp CHECK (YearsOfExperience >= 0),
    CONSTRAINT CK_Freelancers_TotalEarnings CHECK (TotalEarnings >= 0.00),
    CONSTRAINT CK_Freelancers_AvgRating CHECK (AverageRating BETWEEN 1.00 AND 5.00),
    CONSTRAINT CK_Freelancers_CompletedProjects CHECK (CompletedProjectsCount >= 0),
    CONSTRAINT CK_Freelancers_Availability CHECK (AvailabilityStatus IN ('Available', 'Busy', 'Unavailable'))
);
GO

-- 4. Table: SkillCategories (Taxonomy of AI Domains)
CREATE TABLE dbo.SkillCategories (
    CategoryID          INT IDENTITY(1,1) NOT NULL,
    CategoryName        NVARCHAR(80)  NOT NULL,
    Description         NVARCHAR(300) NULL,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_SkillCategories PRIMARY KEY CLUSTERED (CategoryID),
    CONSTRAINT UQ_SkillCategories_Name UNIQUE (CategoryName)
);
GO

-- 5. Table: AISkills (Granular AI competencies)
CREATE TABLE dbo.AISkills (
    SkillID             INT IDENTITY(1,1) NOT NULL,
    CategoryID          INT           NOT NULL,
    SkillName           NVARCHAR(100) NOT NULL,
    Description         NVARCHAR(300) NULL,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AISkills PRIMARY KEY CLUSTERED (SkillID),
    CONSTRAINT UQ_AISkills_Name UNIQUE (SkillName),
    CONSTRAINT FK_AISkills_SkillCategories FOREIGN KEY (CategoryID)
        REFERENCES dbo.SkillCategories (CategoryID) ON UPDATE CASCADE
);
GO

-- 6. Table: FreelancerSkills (M:N between Freelancers and AISkills)
CREATE TABLE dbo.FreelancerSkills (
    FreelancerSkillID   INT IDENTITY(1,1) NOT NULL,
    FreelancerID        INT           NOT NULL,
    SkillID             INT           NOT NULL,
    ProficiencyLevel    NVARCHAR(30)  NOT NULL DEFAULT 'Intermediate',
    YearsExperience     INT           NOT NULL DEFAULT 1,
    AcquiredAt          DATE          NULL,

    CONSTRAINT PK_FreelancerSkills PRIMARY KEY CLUSTERED (FreelancerSkillID),
    CONSTRAINT UQ_FreelancerSkills UNIQUE (FreelancerID, SkillID),
    CONSTRAINT CK_FreelancerSkills_Proficiency CHECK (ProficiencyLevel IN ('Beginner', 'Intermediate', 'Expert')),
    CONSTRAINT CK_FreelancerSkills_Years CHECK (YearsExperience >= 0),
    CONSTRAINT FK_FreelancerSkills_Freelancer FOREIGN KEY (FreelancerID)
        REFERENCES dbo.Freelancers (FreelancerID) ON DELETE CASCADE,
    CONSTRAINT FK_FreelancerSkills_Skill FOREIGN KEY (SkillID)
        REFERENCES dbo.AISkills (SkillID) ON DELETE CASCADE
);
GO

-- 7. Table: AIServices (Catalogue of standardized AI Services offered by Freelancers)
CREATE TABLE dbo.AIServices (
    ServiceID           INT IDENTITY(1,1) NOT NULL,
    FreelancerID        INT           NOT NULL,
    CategoryID          INT           NOT NULL,
    ServiceTitle        NVARCHAR(150) NOT NULL,
    Description         NVARCHAR(MAX) NOT NULL,
    DeliveryDays        INT           NOT NULL DEFAULT 7,
    StartingPrice       DECIMAL(10,2) NOT NULL,
    RevisionsIncluded   INT           NOT NULL DEFAULT 1,
    IsActive            BIT           NOT NULL DEFAULT 1,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AIServices PRIMARY KEY CLUSTERED (ServiceID),
    CONSTRAINT CK_AIServices_DeliveryDays CHECK (DeliveryDays > 0),
    CONSTRAINT CK_AIServices_StartingPrice CHECK (StartingPrice > 0.00),
    CONSTRAINT CK_AIServices_Revisions CHECK (RevisionsIncluded >= 0),
    CONSTRAINT FK_AIServices_Freelancer FOREIGN KEY (FreelancerID)
        REFERENCES dbo.Freelancers (FreelancerID) ON DELETE CASCADE,
    CONSTRAINT FK_AIServices_Category FOREIGN KEY (CategoryID)
        REFERENCES dbo.SkillCategories (CategoryID)
);
GO

-- 8. Table: Projects (AI Projects posted by Clients)
CREATE TABLE dbo.Projects (
    ProjectID           INT IDENTITY(1,1) NOT NULL,
    ClientID            INT           NOT NULL,
    Title               NVARCHAR(200) NOT NULL,
    Description         NVARCHAR(MAX) NOT NULL,
    Scope               NVARCHAR(50)  NOT NULL DEFAULT 'Medium',
    Budget              DECIMAL(12,2) NOT NULL,
    DurationWeeks       INT           NOT NULL DEFAULT 4,
    ProjectStatus       NVARCHAR(30)  NOT NULL DEFAULT 'Open',
    DeadlineDate        DATE          NULL,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Projects PRIMARY KEY CLUSTERED (ProjectID),
    CONSTRAINT CK_Projects_Scope CHECK (Scope IN ('Small', 'Medium', 'Large')),
    CONSTRAINT CK_Projects_Budget CHECK (Budget > 0.00),
    CONSTRAINT CK_Projects_Duration CHECK (DurationWeeks > 0),
    CONSTRAINT CK_Projects_Status CHECK (ProjectStatus IN ('Open', 'Assigned', 'In Progress', 'Under Review', 'Completed', 'Cancelled')),
    CONSTRAINT FK_Projects_Client FOREIGN KEY (ClientID)
        REFERENCES dbo.Clients (ClientID)
);
GO

-- 9. Table: ProjectRequirements (M:N between Projects and AISkills required)
CREATE TABLE dbo.ProjectRequirements (
    ProjectRequirementID INT IDENTITY(1,1) NOT NULL,
    ProjectID            INT          NOT NULL,
    SkillID              INT          NOT NULL,
    RequiredLevel        NVARCHAR(30) NOT NULL DEFAULT 'Intermediate',

    CONSTRAINT PK_ProjectRequirements PRIMARY KEY CLUSTERED (ProjectRequirementID),
    CONSTRAINT UQ_ProjectRequirements UNIQUE (ProjectID, SkillID),
    CONSTRAINT CK_ProjectRequirements_Level CHECK (RequiredLevel IN ('Beginner', 'Intermediate', 'Expert')),
    CONSTRAINT FK_ProjectRequirements_Project FOREIGN KEY (ProjectID)
        REFERENCES dbo.Projects (ProjectID) ON DELETE CASCADE,
    CONSTRAINT FK_ProjectRequirements_Skill FOREIGN KEY (SkillID)
        REFERENCES dbo.AISkills (SkillID)
);
GO

-- 10. Table: Proposals (Proposals/bids submitted by Freelancers for Projects)
CREATE TABLE dbo.Proposals (
    ProposalID          INT IDENTITY(1,1) NOT NULL,
    ProjectID           INT           NOT NULL,
    FreelancerID        INT           NOT NULL,
    CoverLetter         NVARCHAR(MAX) NOT NULL,
    BidAmount           DECIMAL(12,2) NOT NULL,
    EstimatedDays       INT           NOT NULL,
    ProposalStatus      NVARCHAR(30)  NOT NULL DEFAULT 'Pending',
    SubmittedAt         DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Proposals PRIMARY KEY CLUSTERED (ProposalID),
    CONSTRAINT UQ_Proposals_Project_Freelancer UNIQUE (ProjectID, FreelancerID),
    CONSTRAINT CK_Proposals_BidAmount CHECK (BidAmount > 0.00),
    CONSTRAINT CK_Proposals_EstimatedDays CHECK (EstimatedDays > 0),
    CONSTRAINT CK_Proposals_Status CHECK (ProposalStatus IN ('Pending', 'Accepted', 'Rejected', 'Withdrawn')),
    CONSTRAINT FK_Proposals_Project FOREIGN KEY (ProjectID)
        REFERENCES dbo.Projects (ProjectID),
    CONSTRAINT FK_Proposals_Freelancer FOREIGN KEY (FreelancerID)
        REFERENCES dbo.Freelancers (FreelancerID)
);
GO

-- 11. Table: ProjectAssignments (Binding Contract when a proposal is accepted)
CREATE TABLE dbo.ProjectAssignments (
    AssignmentID            INT IDENTITY(1,1) NOT NULL,
    ProjectID               INT           NOT NULL,
    ProposalID              INT           NOT NULL,
    FreelancerID            INT           NOT NULL,
    ClientID                INT           NOT NULL,
    AgreedPrice             DECIMAL(12,2) NOT NULL,
    StartDate               DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpectedCompletionDate  DATE          NOT NULL,
    ActualCompletionDate    DATE          NULL,
    AssignmentStatus        NVARCHAR(30)  NOT NULL DEFAULT 'Active',

    CONSTRAINT PK_ProjectAssignments PRIMARY KEY CLUSTERED (AssignmentID),
    CONSTRAINT UQ_ProjectAssignments_Project UNIQUE (ProjectID),
    CONSTRAINT UQ_ProjectAssignments_Proposal UNIQUE (ProposalID),
    CONSTRAINT CK_ProjectAssignments_Price CHECK (AgreedPrice > 0.00),
    CONSTRAINT CK_ProjectAssignments_Status CHECK (AssignmentStatus IN ('Active', 'Under Review', 'Completed', 'Terminated')),
    CONSTRAINT FK_ProjectAssignments_Project FOREIGN KEY (ProjectID)
        REFERENCES dbo.Projects (ProjectID),
    CONSTRAINT FK_ProjectAssignments_Proposal FOREIGN KEY (ProposalID)
        REFERENCES dbo.Proposals (ProposalID),
    CONSTRAINT FK_ProjectAssignments_Freelancer FOREIGN KEY (FreelancerID)
        REFERENCES dbo.Freelancers (FreelancerID),
    CONSTRAINT FK_ProjectAssignments_Client FOREIGN KEY (ClientID)
        REFERENCES dbo.Clients (ClientID)
);
GO

-- 12. Table: ProjectMilestones (Structured phase deliverables for an assignment)
CREATE TABLE dbo.ProjectMilestones (
    MilestoneID         INT IDENTITY(1,1) NOT NULL,
    AssignmentID        INT           NOT NULL,
    MilestoneTitle      NVARCHAR(150) NOT NULL,
    Description         NVARCHAR(500) NULL,
    Amount              DECIMAL(10,2) NOT NULL,
    DueDate             DATE          NOT NULL,
    MilestoneStatus     NVARCHAR(30)  NOT NULL DEFAULT 'Pending',
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_ProjectMilestones PRIMARY KEY CLUSTERED (MilestoneID),
    CONSTRAINT CK_ProjectMilestones_Amount CHECK (Amount > 0.00),
    CONSTRAINT CK_ProjectMilestones_Status CHECK (MilestoneStatus IN ('Pending', 'In Progress', 'Submitted', 'Approved', 'Cancelled')),
    CONSTRAINT FK_ProjectMilestones_Assignment FOREIGN KEY (AssignmentID)
        REFERENCES dbo.ProjectAssignments (AssignmentID) ON DELETE CASCADE
);
GO

-- 13. Table: Payments (Escrow, Milestone Releases, and Platform Transactions)
CREATE TABLE dbo.Payments (
    PaymentID               INT IDENTITY(1,1) NOT NULL,
    AssignmentID            INT           NOT NULL,
    MilestoneID             INT           NULL,
    ClientID                INT           NOT NULL,
    FreelancerID            INT           NOT NULL,
    GrossAmount             DECIMAL(12,2) NOT NULL,
    PlatformFee             DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    NetAmount               DECIMAL(12,2) NOT NULL,
    PaymentMethod           NVARCHAR(50)  NOT NULL,
    PaymentStatus           NVARCHAR(30)  NOT NULL DEFAULT 'Held in Escrow',
    TransactionReference    NVARCHAR(100) NOT NULL,
    PaymentDate             DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ReleasedDate            DATETIME2     NULL,

    CONSTRAINT PK_Payments PRIMARY KEY CLUSTERED (PaymentID),
    CONSTRAINT UQ_Payments_TransactionRef UNIQUE (TransactionReference),
    CONSTRAINT CK_Payments_Gross CHECK (GrossAmount > 0.00),
    CONSTRAINT CK_Payments_Fee CHECK (PlatformFee >= 0.00),
    CONSTRAINT CK_Payments_Net CHECK (NetAmount > 0.00),
    CONSTRAINT CK_Payments_Amounts_Match CHECK (NetAmount + PlatformFee = GrossAmount),
    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('Credit Card', 'Bank Transfer', 'PayPal', 'Crypto / Web3', 'Stripe Escrow')),
    CONSTRAINT CK_Payments_Status CHECK (PaymentStatus IN ('Pending', 'Held in Escrow', 'Released', 'Refunded', 'Failed')),
    CONSTRAINT FK_Payments_Assignment FOREIGN KEY (AssignmentID)
        REFERENCES dbo.ProjectAssignments (AssignmentID),
    CONSTRAINT FK_Payments_Milestone FOREIGN KEY (MilestoneID)
        REFERENCES dbo.ProjectMilestones (MilestoneID),
    CONSTRAINT FK_Payments_Client FOREIGN KEY (ClientID)
        REFERENCES dbo.Clients (ClientID),
    CONSTRAINT FK_Payments_Freelancer FOREIGN KEY (FreelancerID)
        REFERENCES dbo.Freelancers (FreelancerID)
);
GO

-- 14. Table: Reviews (Bidirectional ratings between Clients and Freelancers)
CREATE TABLE dbo.Reviews (
    ReviewID            INT IDENTITY(1,1) NOT NULL,
    AssignmentID        INT           NOT NULL,
    ReviewerType        NVARCHAR(20)  NOT NULL,
    ReviewerID          INT           NOT NULL,
    RevieweeID          INT           NOT NULL,
    Rating              INT           NOT NULL,
    Comment             NVARCHAR(MAX) NULL,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Reviews PRIMARY KEY CLUSTERED (ReviewID),
    CONSTRAINT CK_Reviews_ReviewerType CHECK (ReviewerType IN ('ClientToFreelancer', 'FreelancerToClient')),
    CONSTRAINT CK_Reviews_Rating CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT UQ_Reviews_Assignment_Type UNIQUE (AssignmentID, ReviewerType),
    CONSTRAINT FK_Reviews_Assignment FOREIGN KEY (AssignmentID)
        REFERENCES dbo.ProjectAssignments (AssignmentID)
);
GO

-- 15. Table: PlatformDisputes (Audit, dispute management & administrative resolution)
CREATE TABLE dbo.PlatformDisputes (
    DisputeID           INT IDENTITY(1,1) NOT NULL,
    AssignmentID        INT           NOT NULL,
    RaisedByID          INT           NOT NULL,
    RaisedByType        NVARCHAR(20)  NOT NULL,
    Reason              NVARCHAR(200) NOT NULL,
    Description         NVARCHAR(MAX) NOT NULL,
    DisputeStatus       NVARCHAR(30)  NOT NULL DEFAULT 'Open',
    ResolutionNotes     NVARCHAR(MAX) NULL,
    ResolvedByAdminID   INT           NULL,
    CreatedAt           DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ResolvedAt          DATETIME2     NULL,

    CONSTRAINT PK_PlatformDisputes PRIMARY KEY CLUSTERED (DisputeID),
    CONSTRAINT CK_PlatformDisputes_Type CHECK (RaisedByType IN ('Client', 'Freelancer')),
    CONSTRAINT CK_PlatformDisputes_Status CHECK (DisputeStatus IN ('Open', 'Under Investigation', 'Resolved', 'Dismissed')),
    CONSTRAINT FK_PlatformDisputes_Assignment FOREIGN KEY (AssignmentID)
        REFERENCES dbo.ProjectAssignments (AssignmentID),
    CONSTRAINT FK_PlatformDisputes_Admin FOREIGN KEY (ResolvedByAdminID)
        REFERENCES dbo.AdminUsers (AdminID)
);
GO

-- ============================================================================
-- Step 4: Create Performance & Relationship Indexes
-- ============================================================================
CREATE NONCLUSTERED INDEX IX_Projects_ClientID ON dbo.Projects(ClientID);
CREATE NONCLUSTERED INDEX IX_Projects_ProjectStatus ON dbo.Projects(ProjectStatus);
CREATE NONCLUSTERED INDEX IX_Proposals_ProjectID ON dbo.Proposals(ProjectID);
CREATE NONCLUSTERED INDEX IX_Proposals_FreelancerID ON dbo.Proposals(FreelancerID);
CREATE NONCLUSTERED INDEX IX_FreelancerSkills_SkillID ON dbo.FreelancerSkills(SkillID);
CREATE NONCLUSTERED INDEX IX_ProjectRequirements_SkillID ON dbo.ProjectRequirements(SkillID);
CREATE NONCLUSTERED INDEX IX_Payments_AssignmentID ON dbo.Payments(AssignmentID);
CREATE NONCLUSTERED INDEX IX_Payments_PaymentStatus ON dbo.Payments(PaymentStatus);
CREATE NONCLUSTERED INDEX IX_Reviews_RevieweeID ON dbo.Reviews(RevieweeID, ReviewerType);
GO

PRINT 'All 15 tables and performance indexes created successfully.';
GO
