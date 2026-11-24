-- Administration & Disputes Module
-- PUSL2019 Coursework: AI Freelancing Platform
-- Database: NeuroLanceHubDB

USE NeuroLanceHubDB;
GO

-- Table: AdminUsers
-- Platform administrative staff, managers, and dispute resolution officers
CREATE TABLE AdminUsers (
    AdminID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role VARCHAR(50) NOT NULL DEFAULT 'Administrator',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Admin_Role CHECK (Role IN ('Administrator', 'Platform Manager', 'Dispute Officer', 'Decision Maker'))
);
GO

-- Table: PlatformDisputes
-- Formal complaints or dispute tickets between clients and freelancers
CREATE TABLE PlatformDisputes (
    DisputeID INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentID INT NOT NULL,
    RaisedByID INT NOT NULL,
    RaisedByType VARCHAR(20) NOT NULL,
    Reason VARCHAR(150) NOT NULL,
    Description VARCHAR(MAX) NOT NULL,
    DisputeStatus VARCHAR(20) NOT NULL DEFAULT 'Open',
    ResolutionNotes VARCHAR(MAX) NULL,
    ResolvedByAdminID INT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ResolvedAt DATETIME NULL,

    CONSTRAINT CK_Dispute_Type CHECK (RaisedByType IN ('Client', 'Freelancer')),
    CONSTRAINT CK_Dispute_Status CHECK (DisputeStatus IN ('Open', 'Under Investigation', 'Resolved', 'Dismissed')),
    CONSTRAINT FK_Disputes_Assignment FOREIGN KEY (AssignmentID) REFERENCES ProjectAssignments(AssignmentID),
    CONSTRAINT FK_Disputes_Admin FOREIGN KEY (ResolvedByAdminID) REFERENCES AdminUsers(AdminID)
);
GO

-- Performance Indexes on Foreign Keys and frequently filtered columns
CREATE NONCLUSTERED INDEX IX_Projects_ClientID ON Projects(ClientID);
CREATE NONCLUSTERED INDEX IX_Projects_Status ON Projects(ProjectStatus);
CREATE NONCLUSTERED INDEX IX_Proposals_ProjectID ON Proposals(ProjectID);
CREATE NONCLUSTERED INDEX IX_FreelancerSkills_SkillID ON FreelancerSkills(SkillID);
CREATE NONCLUSTERED INDEX IX_Payments_AssignmentID ON Payments(AssignmentID);
GO
