-- ============================================================================
-- SCRIPT: 02_Programmability.sql
-- PROJECT: NeuroLance Hub - AI Projects & Services Freelancing Platform
-- MODULE: PUSL2019 – Information Management & Retrieval (Coursework C1)
-- TARGET RDBMS: Microsoft SQL Server 2019 / 2022
-- DESCRIPTION: Programmability objects including Triggers, User Defined Functions (UDFs),
--              Views, and Stored Procedures with error handling & transaction control.
-- ============================================================================

USE NeuroLanceHubDB;
GO

-- ============================================================================
-- SECTION 1: USER-DEFINED FUNCTIONS (UDFs)
-- ============================================================================

-- UDF 1: Scalar Function - Calculate Dynamic Platform Fee based on project gross value
IF OBJECT_ID('dbo.fn_CalculatePlatformFee', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_CalculatePlatformFee;
GO
CREATE FUNCTION dbo.fn_CalculatePlatformFee (@GrossAmount DECIMAL(12,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Fee DECIMAL(10,2);

    IF @GrossAmount IS NULL OR @GrossAmount <= 0.00
        SET @Fee = 0.00;
    ELSE IF @GrossAmount < 2000.00
        -- 10% fee for standard tier
        SET @Fee = ROUND(@GrossAmount * 0.10, 2);
    ELSE IF @GrossAmount BETWEEN 2000.00 AND 10000.00
        -- 8% fee for mid-tier enterprise
        SET @Fee = ROUND(@GrossAmount * 0.08, 2);
    ELSE
        -- 5% fee for large volume AI enterprise contracts
        SET @Fee = ROUND(@GrossAmount * 0.05, 2);

    RETURN @Fee;
END;
GO

-- UDF 2: Scalar Function - Calculate Freelancer Average Rating dynamically
IF OBJECT_ID('dbo.fn_GetFreelancerAverageRating', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_GetFreelancerAverageRating;
GO
CREATE FUNCTION dbo.fn_GetFreelancerAverageRating (@FreelancerID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @AvgRating DECIMAL(3,2);

    SELECT @AvgRating = ISNULL(ROUND(AVG(CAST(Rating AS DECIMAL(4,2))), 2), 5.00)
    FROM dbo.Reviews
    WHERE RevieweeID = @FreelancerID
      AND ReviewerType = 'ClientToFreelancer';

    RETURN @AvgRating;
END;
GO

-- UDF 3: Scalar Function - Get comma-separated list of Top AI Skills for a Freelancer
IF OBJECT_ID('dbo.fn_GetFreelancerTopSkills', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_GetFreelancerTopSkills;
GO
CREATE FUNCTION dbo.fn_GetFreelancerTopSkills (@FreelancerID INT)
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @SkillList NVARCHAR(500);

    SELECT @SkillList = STRING_AGG(s.SkillName, ', ')
    FROM dbo.FreelancerSkills fs
    INNER JOIN dbo.AISkills s ON fs.SkillID = s.SkillID
    WHERE fs.FreelancerID = @FreelancerID;

    RETURN ISNULL(@SkillList, 'No skills recorded');
END;
GO

-- UDF 4: Table-Valued Function - Get Project Financial & Escrow Overview
IF OBJECT_ID('dbo.fn_GetProjectPaymentSummary', 'IF') IS NOT NULL DROP FUNCTION dbo.fn_GetProjectPaymentSummary;
GO
CREATE FUNCTION dbo.fn_GetProjectPaymentSummary (@ProjectID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.ProjectID,
        p.Title AS ProjectTitle,
        pa.AssignmentID,
        ISNULL(pa.AgreedPrice, p.Budget) AS AgreedBudget,
        ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.GrossAmount ELSE 0 END), 0.00) AS TotalPaidGross,
        ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.NetAmount ELSE 0 END), 0.00) AS TotalPaidToFreelancer,
        ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Held in Escrow' THEN pay.GrossAmount ELSE 0 END), 0.00) AS CurrentEscrowHeld,
        ISNULL(pa.AgreedPrice, p.Budget) - ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.GrossAmount ELSE 0 END), 0.00) AS RemainingBalance
    FROM dbo.Projects p
    LEFT JOIN dbo.ProjectAssignments pa ON p.ProjectID = pa.ProjectID
    LEFT JOIN dbo.Payments pay ON pa.AssignmentID = pay.AssignmentID
    WHERE p.ProjectID = @ProjectID
    GROUP BY p.ProjectID, p.Title, pa.AssignmentID, pa.AgreedPrice, p.Budget
);
GO

-- ============================================================================
-- SECTION 2: TRIGGERS
-- ============================================================================

-- Trigger 1: Automatically update Project Status & Proposals when Freelancer is Assigned
IF OBJECT_ID('dbo.TR_ProjectAssignments_AfterInsert', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_ProjectAssignments_AfterInsert;
GO
CREATE TRIGGER dbo.TR_ProjectAssignments_AfterInsert
ON dbo.ProjectAssignments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Update Project Status to 'Assigned'
    UPDATE p
    SET p.ProjectStatus = 'Assigned'
    FROM dbo.Projects p
    INNER JOIN inserted i ON p.ProjectID = i.ProjectID;

    -- 2. Mark the winning Proposal as 'Accepted'
    UPDATE pr
    SET pr.ProposalStatus = 'Accepted'
    FROM dbo.Proposals pr
    INNER JOIN inserted i ON pr.ProposalID = i.ProposalID;

    -- 3. Automatically reject all other pending proposals for the same project
    UPDATE pr
    SET pr.ProposalStatus = 'Rejected'
    FROM dbo.Proposals pr
    INNER JOIN inserted i ON pr.ProjectID = i.ProjectID
    WHERE pr.ProposalID <> i.ProposalID
      AND pr.ProposalStatus = 'Pending';
END;
GO

-- Trigger 2: Update Balances, Milestones, and Completed Projects count on Payment Release
IF OBJECT_ID('dbo.TR_Payments_AfterUpdate', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Payments_AfterUpdate;
GO
CREATE TRIGGER dbo.TR_Payments_AfterUpdate
ON dbo.Payments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only act when payment status transitions to 'Released'
    IF UPDATE(PaymentStatus)
    BEGIN
        -- 1. Increment Freelancer Total Earnings by Net Amount
        UPDATE f
        SET f.TotalEarnings = f.TotalEarnings + released.NetAmount
        FROM dbo.Freelancers f
        INNER JOIN (
            SELECT i.FreelancerID, SUM(i.NetAmount) AS NetAmount
            FROM inserted i
            INNER JOIN deleted d ON i.PaymentID = d.PaymentID
            WHERE i.PaymentStatus = 'Released' AND d.PaymentStatus <> 'Released'
            GROUP BY i.FreelancerID
        ) released ON f.FreelancerID = released.FreelancerID;

        -- 2. Increment Client Total Spent by Gross Amount
        UPDATE c
        SET c.TotalSpent = c.TotalSpent + released.GrossAmount
        FROM dbo.Clients c
        INNER JOIN (
            SELECT i.ClientID, SUM(i.GrossAmount) AS GrossAmount
            FROM inserted i
            INNER JOIN deleted d ON i.PaymentID = d.PaymentID
            WHERE i.PaymentStatus = 'Released' AND d.PaymentStatus <> 'Released'
            GROUP BY i.ClientID
        ) released ON c.ClientID = released.ClientID;

        -- 3. If milestone payment, update milestone status to 'Approved'
        UPDATE m
        SET m.MilestoneStatus = 'Approved'
        FROM dbo.ProjectMilestones m
        INNER JOIN inserted i ON m.MilestoneID = i.MilestoneID
        INNER JOIN deleted d ON i.PaymentID = d.PaymentID
        WHERE i.PaymentStatus = 'Released' 
          AND d.PaymentStatus <> 'Released'
          AND i.MilestoneID IS NOT NULL;
    END;
END;
GO

-- Trigger 3: Automatically update aggregate ratings when reviews are submitted
IF OBJECT_ID('dbo.TR_Reviews_AfterInsertUpdate', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_Reviews_AfterInsertUpdate;
GO
CREATE TRIGGER dbo.TR_Reviews_AfterInsertUpdate
ON dbo.Reviews
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update Freelancers' Average Rating
    UPDATE f
    SET f.AverageRating = ISNULL(sub.AvgRating, 5.00)
    FROM dbo.Freelancers f
    INNER JOIN (
        SELECT RevieweeID, ROUND(AVG(CAST(Rating AS DECIMAL(4,2))), 2) AS AvgRating
        FROM dbo.Reviews
        WHERE ReviewerType = 'ClientToFreelancer'
        GROUP BY RevieweeID
    ) sub ON f.FreelancerID = sub.RevieweeID
    WHERE f.FreelancerID IN (SELECT DISTINCT RevieweeID FROM inserted WHERE ReviewerType = 'ClientToFreelancer');

    -- Update Clients' Average Rating
    UPDATE c
    SET c.ClientRating = ISNULL(sub.AvgRating, 5.00)
    FROM dbo.Clients c
    INNER JOIN (
        SELECT RevieweeID, ROUND(AVG(CAST(Rating AS DECIMAL(4,2))), 2) AS AvgRating
        FROM dbo.Reviews
        WHERE ReviewerType = 'FreelancerToClient'
        GROUP BY RevieweeID
    ) sub ON c.ClientID = sub.RevieweeID
    WHERE c.ClientID IN (SELECT DISTINCT RevieweeID FROM inserted WHERE ReviewerType = 'FreelancerToClient');
END;
GO

-- ============================================================================
-- SECTION 3: VIEWS
-- ============================================================================

-- View 1: Freelancer Project and Performance Summary
IF OBJECT_ID('dbo.vw_FreelancerProjectSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_FreelancerProjectSummary;
GO
CREATE VIEW dbo.vw_FreelancerProjectSummary
AS
SELECT 
    f.FreelancerID,
    f.FullName AS FreelancerName,
    f.ProfessionalTitle,
    f.Country,
    f.HourlyRate,
    f.AverageRating,
    f.TotalEarnings,
    f.CompletedProjectsCount,
    f.AvailabilityStatus,
    COUNT(DISTINCT p.ProposalID) AS ProposalsSubmitted,
    COUNT(DISTINCT CASE WHEN p.ProposalStatus = 'Accepted' THEN p.ProposalID END) AS ProposalsAccepted,
    COUNT(DISTINCT CASE WHEN pa.AssignmentStatus = 'Active' THEN pa.AssignmentID END) AS ActiveAssignments
FROM dbo.Freelancers f
LEFT JOIN dbo.Proposals p ON f.FreelancerID = p.FreelancerID
LEFT JOIN dbo.ProjectAssignments pa ON f.FreelancerID = pa.FreelancerID
GROUP BY 
    f.FreelancerID, f.FullName, f.ProfessionalTitle, f.Country, 
    f.HourlyRate, f.AverageRating, f.TotalEarnings, f.CompletedProjectsCount, f.AvailabilityStatus;
GO

-- View 2: Client Project and Expenditure Summary
IF OBJECT_ID('dbo.vw_ClientProjectSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_ClientProjectSummary;
GO
CREATE VIEW dbo.vw_ClientProjectSummary
AS
SELECT 
    c.ClientID,
    c.FullName AS ClientName,
    c.CompanyName,
    c.Industry,
    c.Country,
    c.ClientRating,
    c.TotalSpent,
    COUNT(DISTINCT pr.ProjectID) AS TotalProjectsPosted,
    COUNT(DISTINCT CASE WHEN pr.ProjectStatus = 'Open' THEN pr.ProjectID END) AS OpenProjects,
    COUNT(DISTINCT CASE WHEN pr.ProjectStatus IN ('Assigned', 'In Progress', 'Under Review') THEN pr.ProjectID END) AS OngoingProjects,
    COUNT(DISTINCT CASE WHEN pr.ProjectStatus = 'Completed' THEN pr.ProjectID END) AS CompletedProjects,
    ISNULL(SUM(pr.Budget), 0.00) AS TotalBudgetAllocated
FROM dbo.Clients c
LEFT JOIN dbo.Projects pr ON c.ClientID = pr.ClientID
GROUP BY 
    c.ClientID, c.FullName, c.CompanyName, c.Industry, c.Country, c.ClientRating, c.TotalSpent;
GO

-- View 3: Comprehensive Project Payment & Escrow Status
IF OBJECT_ID('dbo.vw_ProjectPaymentSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_ProjectPaymentSummary;
GO
CREATE VIEW dbo.vw_ProjectPaymentSummary
AS
SELECT 
    p.ProjectID,
    p.Title AS ProjectTitle,
    p.ProjectStatus,
    c.FullName AS ClientName,
    f.FullName AS AssignedFreelancer,
    pa.AgreedPrice,
    ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.NetAmount END), 0.00) AS TotalReleasedToFreelancer,
    ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.PlatformFee END), 0.00) AS TotalPlatformRevenue,
    ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Held in Escrow' THEN pay.GrossAmount END), 0.00) AS EscrowAmountHeld,
    ISNULL(pa.AgreedPrice, 0.00) - ISNULL(SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.GrossAmount END), 0.00) AS OutstandingUnpaidBalance
FROM dbo.Projects p
INNER JOIN dbo.Clients c ON p.ClientID = c.ClientID
LEFT JOIN dbo.ProjectAssignments pa ON p.ProjectID = pa.ProjectID
LEFT JOIN dbo.Freelancers f ON pa.FreelancerID = f.FreelancerID
LEFT JOIN dbo.Payments pay ON pa.AssignmentID = pay.AssignmentID
GROUP BY 
    p.ProjectID, p.Title, p.ProjectStatus, c.FullName, f.FullName, pa.AgreedPrice;
GO

-- View 4: AI Skill Market Demand & Availability Analysis
IF OBJECT_ID('dbo.vw_AISkillMarketDemand', 'V') IS NOT NULL DROP VIEW dbo.vw_AISkillMarketDemand;
GO
CREATE VIEW dbo.vw_AISkillMarketDemand
AS
SELECT 
    s.SkillID,
    s.SkillName,
    sc.CategoryName,
    COUNT(DISTINCT fs.FreelancerID) AS AvailableFreelancersCount,
    COUNT(DISTINCT pr.ProjectID) AS ProjectRequirementsCount,
    ISNULL(ROUND(AVG(pr_proj.Budget), 2), 0.00) AS AvgProjectBudgetForSkill
FROM dbo.AISkills s
INNER JOIN dbo.SkillCategories sc ON s.CategoryID = sc.CategoryID
LEFT JOIN dbo.FreelancerSkills fs ON s.SkillID = fs.SkillID
LEFT JOIN dbo.ProjectRequirements pr ON s.SkillID = pr.SkillID
LEFT JOIN dbo.Projects pr_proj ON pr.ProjectID = pr_proj.ProjectID
GROUP BY s.SkillID, s.SkillName, sc.CategoryName;
GO

-- ============================================================================
-- SECTION 4: STORED PROCEDURES
-- ============================================================================

-- Stored Procedure 1: Create/Register a New AI Project with Required Skills (Transactional)
IF OBJECT_ID('dbo.sp_PostNewProject', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PostNewProject;
GO
CREATE PROCEDURE dbo.sp_PostNewProject
    @ClientID       INT,
    @Title          NVARCHAR(200),
    @Description    NVARCHAR(MAX),
    @Scope          NVARCHAR(50),
    @Budget         DECIMAL(12,2),
    @DurationWeeks  INT,
    @DeadlineDate   DATE,
    @PrimarySkillID INT,
    @RequiredLevel  NVARCHAR(30) = 'Intermediate',
    @NewProjectID   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate Client
        IF NOT EXISTS (SELECT 1 FROM dbo.Clients WHERE ClientID = @ClientID AND IsActive = 1)
        BEGIN
            THROW 50001, 'Invalid or inactive ClientID specified.', 1;
        END

        -- Insert Project
        INSERT INTO dbo.Projects (ClientID, Title, Description, Scope, Budget, DurationWeeks, ProjectStatus, DeadlineDate)
        VALUES (@ClientID, @Title, @Description, @Scope, @Budget, @DurationWeeks, 'Open', @DeadlineDate);

        SET @NewProjectID = SCOPE_IDENTITY();

        -- Associate Primary Required Skill
        IF @PrimarySkillID IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.AISkills WHERE SkillID = @PrimarySkillID)
        BEGIN
            INSERT INTO dbo.ProjectRequirements (ProjectID, SkillID, RequiredLevel)
            VALUES (@NewProjectID, @PrimarySkillID, @RequiredLevel);
        END

        COMMIT TRANSACTION;
        PRINT 'Project created successfully with ProjectID: ' + CAST(@NewProjectID AS NVARCHAR(20));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Stored Procedure 2: Assign Freelancer to Project & Accept Proposal (Transactional)
IF OBJECT_ID('dbo.sp_AssignFreelancerToProject', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AssignFreelancerToProject;
GO
CREATE PROCEDURE dbo.sp_AssignFreelancerToProject
    @ProposalID             INT,
    @ExpectedCompletionDate DATE,
    @NewAssignmentID        INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ProjectID INT, @FreelancerID INT, @ClientID INT, @AgreedPrice DECIMAL(12,2);

        -- Retrieve Proposal and Project Details
        SELECT 
            @ProjectID = pr.ProjectID,
            @FreelancerID = pr.FreelancerID,
            @ClientID = p.ClientID,
            @AgreedPrice = pr.BidAmount
        FROM dbo.Proposals pr
        INNER JOIN dbo.Projects p ON pr.ProjectID = p.ProjectID
        WHERE pr.ProposalID = @ProposalID;

        IF @ProjectID IS NULL
        BEGIN
            THROW 50002, 'Proposal ID does not exist.', 1;
        END

        IF EXISTS (SELECT 1 FROM dbo.ProjectAssignments WHERE ProjectID = @ProjectID)
        BEGIN
            THROW 50003, 'This project has already been assigned.', 1;
        END

        -- Create Project Assignment (Triggers TR_ProjectAssignments_AfterInsert)
        INSERT INTO dbo.ProjectAssignments (
            ProjectID, ProposalID, FreelancerID, ClientID, AgreedPrice, 
            StartDate, ExpectedCompletionDate, AssignmentStatus
        )
        VALUES (
            @ProjectID, @ProposalID, @FreelancerID, @ClientID, @AgreedPrice, 
            SYSUTCDATETIME(), @ExpectedCompletionDate, 'Active'
        );

        SET @NewAssignmentID = SCOPE_IDENTITY();

        -- Create a default initial milestone
        INSERT INTO dbo.ProjectMilestones (AssignmentID, MilestoneTitle, Description, Amount, DueDate, MilestoneStatus)
        VALUES (@NewAssignmentID, 'Milestone 1: Prototype / Architecture Delivery', 'Initial architecture design and proof-of-concept deliverable', @AgreedPrice, @ExpectedCompletionDate, 'In Progress');

        COMMIT TRANSACTION;
        PRINT 'Freelancer assigned successfully. AssignmentID: ' + CAST(@NewAssignmentID AS NVARCHAR(20));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Stored Procedure 3: Record Escrow Deposit and Release Payment
IF OBJECT_ID('dbo.sp_ProcessProjectPayment', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProcessProjectPayment;
GO
CREATE PROCEDURE dbo.sp_ProcessProjectPayment
    @AssignmentID           INT,
    @MilestoneID            INT = NULL,
    @GrossAmount            DECIMAL(12,2),
    @PaymentMethod          NVARCHAR(50),
    @TransactionRef         NVARCHAR(100),
    @Action                 NVARCHAR(20), -- 'ESCROW_DEPOSIT' or 'RELEASE_PAYMENT'
    @NewPaymentID           INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ClientID INT, @FreelancerID INT, @PlatformFee DECIMAL(10,2), @NetAmount DECIMAL(12,2);

        SELECT @ClientID = ClientID, @FreelancerID = FreelancerID
        FROM dbo.ProjectAssignments
        WHERE AssignmentID = @AssignmentID;

        IF @ClientID IS NULL
        BEGIN
            THROW 50004, 'Invalid AssignmentID specified.', 1;
        END

        -- Compute Fee and Net using UDF
        SET @PlatformFee = dbo.fn_CalculatePlatformFee(@GrossAmount);
        SET @NetAmount = @GrossAmount - @PlatformFee;

        IF @Action = 'ESCROW_DEPOSIT'
        BEGIN
            INSERT INTO dbo.Payments (
                AssignmentID, MilestoneID, ClientID, FreelancerID,
                GrossAmount, PlatformFee, NetAmount, PaymentMethod,
                PaymentStatus, TransactionReference, PaymentDate
            )
            VALUES (
                @AssignmentID, @MilestoneID, @ClientID, @FreelancerID,
                @GrossAmount, @PlatformFee, @NetAmount, @PaymentMethod,
                'Held in Escrow', @TransactionRef, SYSUTCDATETIME()
            );
            SET @NewPaymentID = SCOPE_IDENTITY();
        END
        ELSE IF @Action = 'RELEASE_PAYMENT'
        BEGIN
            -- Release existing escrow payment or create directly released payment
            IF EXISTS (SELECT 1 FROM dbo.Payments WHERE TransactionReference = @TransactionRef AND PaymentStatus = 'Held in Escrow')
            BEGIN
                UPDATE dbo.Payments
                SET PaymentStatus = 'Released',
                    ReleasedDate = SYSUTCDATETIME()
                WHERE TransactionReference = @TransactionRef;

                SELECT @NewPaymentID = PaymentID FROM dbo.Payments WHERE TransactionReference = @TransactionRef;
            END
            ELSE
            BEGIN
                INSERT INTO dbo.Payments (
                    AssignmentID, MilestoneID, ClientID, FreelancerID,
                    GrossAmount, PlatformFee, NetAmount, PaymentMethod,
                    PaymentStatus, TransactionReference, PaymentDate, ReleasedDate
                )
                VALUES (
                    @AssignmentID, @MilestoneID, @ClientID, @FreelancerID,
                    @GrossAmount, @PlatformFee, @NetAmount, @PaymentMethod,
                    'Released', @TransactionRef, SYSUTCDATETIME(), SYSUTCDATETIME()
                );
                SET @NewPaymentID = SCOPE_IDENTITY();
            END
        END
        ELSE
        BEGIN
            THROW 50005, 'Invalid Action specified. Must be ESCROW_DEPOSIT or RELEASE_PAYMENT.', 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Stored Procedure 4: Search Freelancers by AI Skill, Rating, and Max Hourly Rate
IF OBJECT_ID('dbo.sp_SearchFreelancersByAISkill', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_SearchFreelancersByAISkill;
GO
CREATE PROCEDURE dbo.sp_SearchFreelancersByAISkill
    @SkillName          NVARCHAR(100) = NULL,
    @MinProficiency     NVARCHAR(30) = NULL,
    @MaxHourlyRate      DECIMAL(10,2) = NULL,
    @MinRating          DECIMAL(3,2) = 1.00
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        f.FreelancerID,
        f.FullName,
        f.ProfessionalTitle,
        f.Country,
        f.HourlyRate,
        f.AverageRating,
        f.CompletedProjectsCount,
        f.AvailabilityStatus,
        s.SkillName,
        fs.ProficiencyLevel,
        fs.YearsExperience,
        dbo.fn_GetFreelancerTopSkills(f.FreelancerID) AS AllSkills
    FROM dbo.Freelancers f
    INNER JOIN dbo.FreelancerSkills fs ON f.FreelancerID = fs.FreelancerID
    INNER JOIN dbo.AISkills s ON fs.SkillID = s.SkillID
    WHERE f.IsActive = 1
      AND (@SkillName IS NULL OR s.SkillName LIKE '%' + @SkillName + '%')
      AND (@MinProficiency IS NULL OR fs.ProficiencyLevel = @MinProficiency)
      AND (@MaxHourlyRate IS NULL OR f.HourlyRate <= @MaxHourlyRate)
      AND (f.AverageRating >= @MinRating)
    ORDER BY f.AverageRating DESC, f.CompletedProjectsCount DESC;
END;
GO

-- Stored Procedure 5: Platform Revenue & Performance Executive Report
IF OBJECT_ID('dbo.sp_GeneratePlatformRevenueReport', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GeneratePlatformRevenueReport;
GO
CREATE PROCEDURE dbo.sp_GeneratePlatformRevenueReport
    @StartDate DATETIME2 = NULL,
    @EndDate   DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL SET @StartDate = DATEADD(YEAR, -1, SYSUTCDATETIME());
    IF @EndDate IS NULL SET @EndDate = SYSUTCDATETIME();

    SELECT 
        COUNT(DISTINCT p.PaymentID) AS TotalReleasedTransactions,
        ISNULL(SUM(p.GrossAmount), 0.00) AS TotalGrossVolume,
        ISNULL(SUM(p.NetAmount), 0.00) AS TotalFreelancerPayout,
        ISNULL(SUM(p.PlatformFee), 0.00) AS TotalPlatformRevenue,
        ISNULL(AVG(p.PlatformFee), 0.00) AS AverageFeePerTransaction,
        COUNT(DISTINCT p.ClientID) AS ActivePayingClients,
        COUNT(DISTINCT p.FreelancerID) AS EarningFreelancersCount
    FROM dbo.Payments p
    WHERE p.PaymentStatus = 'Released'
      AND p.PaymentDate BETWEEN @StartDate AND @EndDate;
END;
GO

PRINT 'All Programmability Objects (4 UDFs, 3 Triggers, 4 Views, 5 Stored Procedures) created successfully.';
GO
