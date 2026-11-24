-- Proposals & Project Assignment Module
-- PUSL2019 Coursework: AI Freelancing Platform
-- Database: NeuroLanceHubDB

USE NeuroLanceHubDB;
GO

-- Table: Proposals
-- Bids submitted by freelancers for posted projects
CREATE TABLE Proposals (
    ProposalID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    FreelancerID INT NOT NULL,
    CoverLetter VARCHAR(MAX) NOT NULL,
    BidAmount DECIMAL(10,2) NOT NULL,
    EstimatedDays INT NOT NULL,
    ProposalStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    SubmittedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Project_Freelancer_Bid UNIQUE (ProjectID, FreelancerID),
    CONSTRAINT CK_Bid_Amount CHECK (BidAmount > 0),
    CONSTRAINT CK_Bid_Days CHECK (EstimatedDays > 0),
    CONSTRAINT CK_Proposal_Status CHECK (ProposalStatus IN ('Pending', 'Accepted', 'Rejected', 'Withdrawn')),
    CONSTRAINT FK_Proposals_Project FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    CONSTRAINT FK_Proposals_Freelancer FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID)
);
GO

-- Table: ProjectAssignments
-- Binding contract created when a client accepts a freelancer's proposal
CREATE TABLE ProjectAssignments (
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL UNIQUE,
    ProposalID INT NOT NULL UNIQUE,
    FreelancerID INT NOT NULL,
    ClientID INT NOT NULL,
    AgreedPrice DECIMAL(10,2) NOT NULL,
    StartDate DATETIME NOT NULL DEFAULT GETDATE(),
    ExpectedCompletionDate DATE NOT NULL,
    ActualCompletionDate DATE NULL,
    AssignmentStatus VARCHAR(20) NOT NULL DEFAULT 'Active',

    CONSTRAINT CK_Agreed_Price CHECK (AgreedPrice > 0),
    CONSTRAINT CK_Assignment_Status CHECK (AssignmentStatus IN ('Active', 'In Progress', 'Completed', 'Terminated')),
    CONSTRAINT FK_Assignments_Project FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    CONSTRAINT FK_Assignments_Proposal FOREIGN KEY (ProposalID) REFERENCES Proposals(ProposalID),
    CONSTRAINT FK_Assignments_Freelancer FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID),
    CONSTRAINT FK_Assignments_Client FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);
GO

-- Table: ProjectMilestones
-- Decomposes an active project assignment into structured stages/checkpoints
CREATE TABLE ProjectMilestones (
    MilestoneID INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentID INT NOT NULL,
    MilestoneTitle VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL,
    Amount DECIMAL(10,2) NOT NULL,
    DueDate DATE NOT NULL,
    MilestoneStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Milestone_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Milestone_Status CHECK (MilestoneStatus IN ('Pending', 'In Progress', 'Submitted', 'Approved')),
    CONSTRAINT FK_Milestones_Assignment FOREIGN KEY (AssignmentID) 
        REFERENCES ProjectAssignments(AssignmentID) ON DELETE CASCADE
);
GO
