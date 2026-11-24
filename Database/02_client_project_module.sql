-- Client & Project Management Module
-- PUSL2019 Coursework: AI Freelancing Platform
-- Database: NeuroLanceHubDB

USE NeuroLanceHubDB;
GO

-- Table: Clients
-- Stores organizations and individual clients who post AI projects
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    CompanyName VARCHAR(100) NULL,
    Industry VARCHAR(80) NULL,
    Country VARCHAR(60) NOT NULL,
    BillingAddress VARCHAR(255) NULL,
    ContactNumber VARCHAR(30) NULL,
    TotalSpent DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ClientRating DECIMAL(3,2) NOT NULL DEFAULT 5.00,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Clients_Spent CHECK (TotalSpent >= 0),
    CONSTRAINT CK_Clients_Rating CHECK (ClientRating >= 1.0 AND ClientRating <= 5.0)
);
GO

-- Table: Projects
-- AI projects posted by clients
CREATE TABLE Projects (
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT NOT NULL,
    Title VARCHAR(150) NOT NULL,
    Description VARCHAR(MAX) NOT NULL,
    Scope VARCHAR(20) NOT NULL DEFAULT 'Medium',
    Budget DECIMAL(10,2) NOT NULL,
    DurationWeeks INT NOT NULL DEFAULT 4,
    ProjectStatus VARCHAR(20) NOT NULL DEFAULT 'Open',
    DeadlineDate DATE NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Projects_Scope CHECK (Scope IN ('Small', 'Medium', 'Large')),
    CONSTRAINT CK_Projects_Budget CHECK (Budget > 0),
    CONSTRAINT CK_Projects_Duration CHECK (DurationWeeks > 0),
    CONSTRAINT CK_Projects_Status CHECK (ProjectStatus IN ('Open', 'Assigned', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT FK_Projects_Client FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);
GO

-- Table: ProjectRequirements
-- Linking table for Many-to-Many relationship between Projects and required AISkills
CREATE TABLE ProjectRequirements (
    RequirementID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    SkillID INT NOT NULL,
    RequiredLevel VARCHAR(20) NOT NULL DEFAULT 'Intermediate',

    CONSTRAINT UQ_Project_Skill UNIQUE (ProjectID, SkillID),
    CONSTRAINT CK_Req_Level CHECK (RequiredLevel IN ('Beginner', 'Intermediate', 'Expert')),
    CONSTRAINT FK_Req_Project FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID) ON DELETE CASCADE,
    CONSTRAINT FK_Req_Skill FOREIGN KEY (SkillID) REFERENCES AISkills(SkillID)
);
GO
