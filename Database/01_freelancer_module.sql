-- Freelancer & Skills Module
-- PUSL2019 Coursework: AI Freelancing Platform
-- Database: NeuroLanceHubDB

USE NeuroLanceHubDB;
GO

-- Table: Freelancers
-- Stores profiles of AI freelancers offering services on the platform
CREATE TABLE Freelancers (
    FreelancerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Title VARCHAR(100) NOT NULL,
    Bio VARCHAR(MAX) NULL,
    HourlyRate DECIMAL(10,2) NOT NULL,
    ExperienceYears INT NOT NULL DEFAULT 0,
    Country VARCHAR(60) NOT NULL,
    TotalEarnings DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    AverageRating DECIMAL(3,2) NOT NULL DEFAULT 5.00,
    CompletedProjects INT NOT NULL DEFAULT 0,
    Availability VARCHAR(20) NOT NULL DEFAULT 'Available',
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Freelancers_Rate CHECK (HourlyRate >= 0),
    CONSTRAINT CK_Freelancers_Exp CHECK (ExperienceYears >= 0),
    CONSTRAINT CK_Freelancers_Rating CHECK (AverageRating >= 1.0 AND AverageRating <= 5.0),
    CONSTRAINT CK_Freelancers_Availability CHECK (Availability IN ('Available', 'Busy', 'Unavailable'))
);
GO

-- Table: SkillCategories
-- Broad AI categories like Natural Language Processing, Computer Vision, etc.
CREATE TABLE SkillCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255) NULL
);
GO

-- Table: AISkills
-- Specific tools, libraries and technical skills
CREATE TABLE AISkills (
    SkillID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    SkillName VARCHAR(80) NOT NULL UNIQUE,
    Description VARCHAR(255) NULL,

    CONSTRAINT FK_AISkills_Category FOREIGN KEY (CategoryID) 
        REFERENCES SkillCategories(CategoryID)
);
GO

-- Table: FreelancerSkills
-- Linking table for Many-to-Many relationship between Freelancers and AISkills
CREATE TABLE FreelancerSkills (
    FreelancerSkillID INT IDENTITY(1,1) PRIMARY KEY,
    FreelancerID INT NOT NULL,
    SkillID INT NOT NULL,
    ProficiencyLevel VARCHAR(20) NOT NULL DEFAULT 'Intermediate',
    YearsExperience INT NOT NULL DEFAULT 1,

    CONSTRAINT UQ_Freelancer_Skill UNIQUE (FreelancerID, SkillID),
    CONSTRAINT CK_Proficiency CHECK (ProficiencyLevel IN ('Beginner', 'Intermediate', 'Expert')),
    CONSTRAINT FK_FreelancerSkills_Freelancer FOREIGN KEY (FreelancerID) 
        REFERENCES Freelancers(FreelancerID) ON DELETE CASCADE,
    CONSTRAINT FK_FreelancerSkills_Skill FOREIGN KEY (SkillID) 
        REFERENCES AISkills(SkillID) ON DELETE CASCADE
);
GO

-- Table: AIServices
-- Fixed-price AI services offered directly by freelancers
CREATE TABLE AIServices (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    FreelancerID INT NOT NULL,
    CategoryID INT NOT NULL,
    Title VARCHAR(150) NOT NULL,
    Description VARCHAR(MAX) NOT NULL,
    DeliveryDays INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Revisions INT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Service_Days CHECK (DeliveryDays > 0),
    CONSTRAINT CK_Service_Price CHECK (Price > 0),
    CONSTRAINT FK_AIServices_Freelancer FOREIGN KEY (FreelancerID) 
        REFERENCES Freelancers(FreelancerID) ON DELETE CASCADE,
    CONSTRAINT FK_AIServices_Category FOREIGN KEY (CategoryID) 
        REFERENCES SkillCategories(CategoryID)
);
GO
