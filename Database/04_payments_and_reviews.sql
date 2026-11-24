-- Payments & Reviews Module
-- PUSL2019 Coursework: AI Freelancing Platform
-- Database: NeuroLanceHubDB

USE NeuroLanceHubDB;
GO

-- Table: Payments
-- Tracks escrow deposits, platform commissions, and freelancer payouts
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentID INT NOT NULL,
    MilestoneID INT NULL,
    ClientID INT NOT NULL,
    FreelancerID INT NOT NULL,
    GrossAmount DECIMAL(10,2) NOT NULL,
    PlatformFee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    NetAmount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Held in Escrow',
    TransactionRef VARCHAR(100) NOT NULL UNIQUE,
    PaymentDate DATETIME NOT NULL DEFAULT GETDATE(),
    ReleasedDate DATETIME NULL,

    CONSTRAINT CK_Payment_Gross CHECK (GrossAmount > 0),
    CONSTRAINT CK_Payment_Net CHECK (NetAmount > 0),
    CONSTRAINT CK_Payment_Fee CHECK (PlatformFee >= 0),
    CONSTRAINT CK_Payment_Balance CHECK (NetAmount + PlatformFee = GrossAmount),
    CONSTRAINT CK_Payment_Status CHECK (PaymentStatus IN ('Pending', 'Held in Escrow', 'Released', 'Refunded')),
    CONSTRAINT FK_Payments_Assignment FOREIGN KEY (AssignmentID) REFERENCES ProjectAssignments(AssignmentID),
    CONSTRAINT FK_Payments_Milestone FOREIGN KEY (MilestoneID) REFERENCES ProjectMilestones(MilestoneID),
    CONSTRAINT FK_Payments_Client FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    CONSTRAINT FK_Payments_Freelancer FOREIGN KEY (FreelancerID) REFERENCES Freelancers(FreelancerID)
);
GO

-- Table: Reviews
-- Bidirectional ratings and reviews between clients and freelancers
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    AssignmentID INT NOT NULL,
    ReviewerType VARCHAR(20) NOT NULL,
    ReviewerID INT NOT NULL,
    RevieweeID INT NOT NULL,
    Rating INT NOT NULL,
    Comment VARCHAR(MAX) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Review_Type CHECK (ReviewerType IN ('ClientToFreelancer', 'FreelancerToClient')),
    CONSTRAINT CK_Review_Rating CHECK (Rating >= 1 AND Rating <= 5),
    CONSTRAINT UQ_Assignment_Review UNIQUE (AssignmentID, ReviewerType),
    CONSTRAINT FK_Reviews_Assignment FOREIGN KEY (AssignmentID) REFERENCES ProjectAssignments(AssignmentID)
);
GO
