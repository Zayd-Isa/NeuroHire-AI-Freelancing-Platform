-- NeuroLance Hub programmable database objects
-- Requires SQL Server 2016 SP1 or later (CREATE OR ALTER support).
-- Run after 01_freelancer_module.sql through 05_admin_and_disputes.sql.

USE NeuroLanceHubDB;
GO

-- A table-valued parameter keeps project creation and its skill requirements
-- in one transaction without changing the existing table structure.
IF TYPE_ID(N'dbo.ProjectRequirementInput') IS NULL
BEGIN
    EXEC(N'CREATE TYPE dbo.ProjectRequirementInput AS TABLE
    (
        SkillID INT NOT NULL PRIMARY KEY,
        RequiredLevel VARCHAR(20) NOT NULL
    );');
END;
GO

CREATE OR ALTER FUNCTION dbo.ufn_CalculatePlatformFee
(
    @GrossAmount DECIMAL(10,2),
    @FeeRate DECIMAL(5,4)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    IF @GrossAmount IS NULL OR @GrossAmount < 0
       OR @FeeRate IS NULL OR @FeeRate < 0 OR @FeeRate > 1
        RETURN NULL;

    RETURN CONVERT(DECIMAL(10,2), ROUND(@GrossAmount * @FeeRate, 2));
END;
GO

CREATE OR ALTER FUNCTION dbo.ufn_CalculateFreelancerRating
(
    @FreelancerID INT
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @Rating DECIMAL(3,2);

    SELECT @Rating = CONVERT(DECIMAL(3,2), AVG(CONVERT(DECIMAL(5,2), r.Rating)))
    FROM dbo.Reviews AS r
    INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
    WHERE pa.FreelancerID = @FreelancerID
      AND r.ReviewerType = 'ClientToFreelancer';

    RETURN @Rating;
END;
GO

CREATE OR ALTER VIEW dbo.vw_FreelancerProjectSummary
AS
    SELECT
        pa.AssignmentID,
        pa.ProjectID,
        p.Title AS ProjectTitle,
        pa.FreelancerID,
        f.FullName AS FreelancerName,
        c.ClientID,
        c.FullName AS ClientName,
        pa.AgreedPrice,
        pa.AssignmentStatus,
        pa.StartDate,
        pa.ExpectedCompletionDate,
        COALESCE(payments.GrossPaid, 0.00) AS GrossPaid,
        COALESCE(payments.PlatformFees, 0.00) AS PlatformFees,
        COALESCE(payments.NetPaid, 0.00) AS NetPaid,
        dbo.ufn_CalculateFreelancerRating(pa.FreelancerID) AS CurrentFreelancerRating
    FROM dbo.ProjectAssignments AS pa
    INNER JOIN dbo.Projects AS p ON p.ProjectID = pa.ProjectID
    INNER JOIN dbo.Freelancers AS f ON f.FreelancerID = pa.FreelancerID
    INNER JOIN dbo.Clients AS c ON c.ClientID = pa.ClientID
    LEFT JOIN
    (
        SELECT AssignmentID,
               SUM(GrossAmount) AS GrossPaid,
               SUM(PlatformFee) AS PlatformFees,
               SUM(NetAmount) AS NetPaid
        FROM dbo.Payments
        WHERE PaymentStatus = 'Released'
        GROUP BY AssignmentID
    ) AS payments ON payments.AssignmentID = pa.AssignmentID;
GO

CREATE OR ALTER VIEW dbo.vw_ClientProjectSummary
AS
    SELECT
        c.ClientID,
        c.FullName AS ClientName,
        c.CompanyName,
        p.ProjectID,
        p.Title AS ProjectTitle,
        p.ProjectStatus,
        p.Budget,
        p.CreatedAt,
        COALESCE(proposals.ProposalCount, 0) AS ProposalCount,
        pa.AssignmentID,
        pa.FreelancerID,
        f.FullName AS AssignedFreelancer,
        COALESCE(payments.GrossPaid, 0.00) AS GrossPaid,
        COALESCE(payments.NetPaid, 0.00) AS NetPaid
    FROM dbo.Projects AS p
    INNER JOIN dbo.Clients AS c ON c.ClientID = p.ClientID
    LEFT JOIN
    (
        SELECT ProjectID, COUNT_BIG(*) AS ProposalCount
        FROM dbo.Proposals
        GROUP BY ProjectID
    ) AS proposals ON proposals.ProjectID = p.ProjectID
    LEFT JOIN dbo.ProjectAssignments AS pa ON pa.ProjectID = p.ProjectID
    LEFT JOIN dbo.Freelancers AS f ON f.FreelancerID = pa.FreelancerID
    LEFT JOIN
    (
        SELECT AssignmentID,
               SUM(GrossAmount) AS GrossPaid,
               SUM(NetAmount) AS NetPaid
        FROM dbo.Payments
        WHERE PaymentStatus = 'Released'
        GROUP BY AssignmentID
    ) AS payments ON payments.AssignmentID = pa.AssignmentID;
GO

CREATE OR ALTER VIEW dbo.vw_ProjectPaymentSummary
AS
    SELECT
        p.ProjectID,
        p.Title AS ProjectTitle,
        c.ClientID,
        c.FullName AS ClientName,
        pa.AssignmentID,
        f.FreelancerID,
        f.FullName AS FreelancerName,
        pay.PaymentStatus,
        COUNT_BIG(pay.PaymentID) AS PaymentCount,
        COALESCE(SUM(pay.GrossAmount), 0.00) AS GrossAmount,
        COALESCE(SUM(pay.PlatformFee), 0.00) AS PlatformFees,
        COALESCE(SUM(pay.NetAmount), 0.00) AS FreelancerNetAmount
    FROM dbo.Projects AS p
    INNER JOIN dbo.Clients AS c ON c.ClientID = p.ClientID
    LEFT JOIN dbo.ProjectAssignments AS pa ON pa.ProjectID = p.ProjectID
    LEFT JOIN dbo.Freelancers AS f ON f.FreelancerID = pa.FreelancerID
    LEFT JOIN dbo.Payments AS pay ON pay.AssignmentID = pa.AssignmentID
    GROUP BY p.ProjectID, p.Title, c.ClientID, c.FullName,
             pa.AssignmentID, f.FreelancerID, f.FullName, pay.PaymentStatus;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CreateProject
    @ClientID INT,
    @Title VARCHAR(150),
    @Description VARCHAR(MAX),
    @Scope VARCHAR(20),
    @Budget DECIMAL(10,2),
    @DurationWeeks INT,
    @Requirements dbo.ProjectRequirementInput READONLY,
    @ProjectID INT OUTPUT,
    @DeadlineDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM @Requirements)
        THROW 51101, 'At least one project skill requirement must be supplied.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Projects
            (ClientID, Title, Description, Scope, Budget, DurationWeeks, DeadlineDate)
        VALUES
            (@ClientID, @Title, @Description, @Scope, @Budget, @DurationWeeks, @DeadlineDate);

        SET @ProjectID = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.ProjectRequirements (ProjectID, SkillID, RequiredLevel)
        SELECT @ProjectID, SkillID, RequiredLevel
        FROM @Requirements;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_FindFreelancersBySkill
    @SkillName VARCHAR(80),
    @MinimumExperience INT = 0,
    @Country VARCHAR(60) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimumExperience < 0
        THROW 51102, 'Minimum experience cannot be negative.', 1;

    SELECT f.FreelancerID, f.FullName, f.Title, f.Country,
           f.HourlyRate, f.ExperienceYears,
           fs.ProficiencyLevel, fs.YearsExperience AS SkillYearsExperience,
           dbo.ufn_CalculateFreelancerRating(f.FreelancerID) AS CurrentRating
    FROM dbo.Freelancers AS f
    INNER JOIN dbo.FreelancerSkills AS fs ON fs.FreelancerID = f.FreelancerID
    INNER JOIN dbo.AISkills AS s ON s.SkillID = fs.SkillID
    WHERE s.SkillName = @SkillName
      AND f.ExperienceYears >= @MinimumExperience
      AND (@Country IS NULL OR f.Country = @Country)
      AND f.Availability = 'Available'
    ORDER BY CurrentRating DESC, f.ExperienceYears DESC, f.FullName;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GeneratePaymentRevenueReport
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL AND @EndDate < @StartDate
        THROW 51103, 'End date must be on or after start date.', 1;

    SELECT
        CONVERT(DATE, pay.PaymentDate) AS PaymentDay,
        pay.PaymentStatus,
        COUNT_BIG(*) AS PaymentCount,
        SUM(pay.GrossAmount) AS GrossAmount,
        SUM(pay.PlatformFee) AS PlatformRevenue,
        SUM(pay.NetAmount) AS FreelancerNetAmount
    FROM dbo.Payments AS pay
    WHERE (@StartDate IS NULL OR pay.PaymentDate >= @StartDate)
      AND (@EndDate IS NULL OR pay.PaymentDate < DATEADD(DAY, 1, @EndDate))
    GROUP BY CONVERT(DATE, pay.PaymentDate), pay.PaymentStatus
    ORDER BY PaymentDay, pay.PaymentStatus;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_ProjectAssignments_SyncProjectAndProposalStatus
ON dbo.ProjectAssignments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- The assignment must describe the selected proposal and its project owner.
    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.Proposals AS pr ON pr.ProposalID = i.ProposalID
        INNER JOIN dbo.Projects AS p ON p.ProjectID = i.ProjectID
        WHERE pr.ProjectID <> i.ProjectID
           OR pr.FreelancerID <> i.FreelancerID
           OR p.ClientID <> i.ClientID
    )
        THROW 51201, 'Assignment project, proposal, client, and freelancer must match.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.Reviews AS r ON r.AssignmentID = i.AssignmentID
        WHERE (r.ReviewerType = 'ClientToFreelancer'
               AND (r.ReviewerID <> i.ClientID OR r.RevieweeID <> i.FreelancerID))
           OR (r.ReviewerType = 'FreelancerToClient'
               AND (r.ReviewerID <> i.FreelancerID OR r.RevieweeID <> i.ClientID))
    )
        THROW 51205, 'An assignment cannot be changed so that existing reviews identify the wrong participants.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.PlatformDisputes AS d ON d.AssignmentID = i.AssignmentID
        WHERE (d.RaisedByType = 'Client' AND d.RaisedByID <> i.ClientID)
           OR (d.RaisedByType = 'Freelancer' AND d.RaisedByID <> i.FreelancerID)
    )
        THROW 51207, 'An assignment cannot be changed so that existing disputes identify the wrong raiser.', 1;

    UPDATE p
    SET ProjectStatus = CASE i.AssignmentStatus
                            WHEN 'In Progress' THEN 'In Progress'
                            WHEN 'Completed' THEN 'Completed'
                            WHEN 'Terminated' THEN 'Cancelled'
                            ELSE 'Assigned'
                        END
    FROM dbo.Projects AS p
    INNER JOIN inserted AS i ON i.ProjectID = p.ProjectID
    WHERE p.ProjectStatus <> CASE i.AssignmentStatus
                                 WHEN 'In Progress' THEN 'In Progress'
                                 WHEN 'Completed' THEN 'Completed'
                                 WHEN 'Terminated' THEN 'Cancelled'
                                 ELSE 'Assigned'
                             END;

    UPDATE p
    SET ProposalStatus = CASE
        WHEN p.ProposalID = i.ProposalID THEN 'Accepted'
        WHEN p.ProposalStatus = 'Pending' THEN 'Rejected'
        ELSE p.ProposalStatus
    END
    FROM dbo.Proposals AS p
    INNER JOIN inserted AS i ON i.ProjectID = p.ProjectID
    WHERE (p.ProposalID = i.ProposalID AND p.ProposalStatus <> 'Accepted')
       OR (p.ProposalID <> i.ProposalID AND p.ProposalStatus = 'Pending');

    DECLARE @CompletedProjectDelta TABLE
    (
        FreelancerID INT NOT NULL PRIMARY KEY,
        ProjectDelta INT NOT NULL
    );

    INSERT INTO @CompletedProjectDelta (FreelancerID, ProjectDelta)
    SELECT FreelancerID, SUM(ProjectDelta)
    FROM
    (
        SELECT FreelancerID,
               CASE WHEN AssignmentStatus = 'Completed' THEN 1 ELSE 0 END AS ProjectDelta
        FROM inserted
        UNION ALL
        SELECT FreelancerID,
               CASE WHEN AssignmentStatus = 'Completed' THEN -1 ELSE 0 END AS ProjectDelta
        FROM deleted
    ) AS statusChanges
    GROUP BY FreelancerID;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.Freelancers AS f
        INNER JOIN @CompletedProjectDelta AS d ON d.FreelancerID = f.FreelancerID
        WHERE f.CompletedProjects + d.ProjectDelta < 0
    )
        THROW 51206, 'A project status change would make completed project count negative.', 1;

    UPDATE f
    SET CompletedProjects = f.CompletedProjects + d.ProjectDelta
    FROM dbo.Freelancers AS f
    INNER JOIN @CompletedProjectDelta AS d ON d.FreelancerID = f.FreelancerID
    WHERE d.ProjectDelta <> 0;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Payments_UpdateAccountTotals
ON dbo.Payments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS pay
        INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = pay.AssignmentID
        LEFT JOIN dbo.ProjectMilestones AS m ON m.MilestoneID = pay.MilestoneID
        WHERE pay.ClientID <> pa.ClientID
           OR pay.FreelancerID <> pa.FreelancerID
           OR (pay.MilestoneID IS NOT NULL
               AND (m.MilestoneID IS NULL OR m.AssignmentID <> pay.AssignmentID))
    )
        THROW 51208, 'Payment participants and milestone must belong to the selected assignment.', 1;

    DECLARE @FreelancerDelta TABLE
    (
        FreelancerID INT NOT NULL PRIMARY KEY,
        AmountDelta DECIMAL(38,2) NOT NULL
    );

    INSERT INTO @FreelancerDelta (FreelancerID, AmountDelta)
    SELECT FreelancerID, SUM(AmountDelta)
    FROM
    (
        SELECT FreelancerID, CONVERT(DECIMAL(38,2), NetAmount) AS AmountDelta
        FROM inserted WHERE PaymentStatus = 'Released'
        UNION ALL
        SELECT FreelancerID, -CONVERT(DECIMAL(38,2), NetAmount) AS AmountDelta
        FROM deleted WHERE PaymentStatus = 'Released'
    ) AS changes
    GROUP BY FreelancerID;

    IF EXISTS
    (
        SELECT 1 FROM dbo.Freelancers AS f
        INNER JOIN @FreelancerDelta AS d ON d.FreelancerID = f.FreelancerID
        WHERE CONVERT(DECIMAL(38,2), f.TotalEarnings) + d.AmountDelta < 0
    )
        THROW 51202, 'A payment change would make freelancer earnings negative.', 1;

    UPDATE f
    SET TotalEarnings = CONVERT(DECIMAL(10,2), f.TotalEarnings + d.AmountDelta)
    FROM dbo.Freelancers AS f
    INNER JOIN @FreelancerDelta AS d ON d.FreelancerID = f.FreelancerID
    WHERE d.AmountDelta <> 0;

    DECLARE @ClientDelta TABLE
    (
        ClientID INT NOT NULL PRIMARY KEY,
        AmountDelta DECIMAL(38,2) NOT NULL
    );

    INSERT INTO @ClientDelta (ClientID, AmountDelta)
    SELECT ClientID, SUM(AmountDelta)
    FROM
    (
        SELECT ClientID, CONVERT(DECIMAL(38,2), GrossAmount) AS AmountDelta
        FROM inserted WHERE PaymentStatus = 'Released'
        UNION ALL
        SELECT ClientID, -CONVERT(DECIMAL(38,2), GrossAmount) AS AmountDelta
        FROM deleted WHERE PaymentStatus = 'Released'
    ) AS changes
    GROUP BY ClientID;

    IF EXISTS
    (
        SELECT 1 FROM dbo.Clients AS c
        INNER JOIN @ClientDelta AS d ON d.ClientID = c.ClientID
        WHERE CONVERT(DECIMAL(38,2), c.TotalSpent) + d.AmountDelta < 0
    )
        THROW 51203, 'A payment change would make client spending negative.', 1;

    UPDATE c
    SET TotalSpent = CONVERT(DECIMAL(10,2), c.TotalSpent + d.AmountDelta)
    FROM dbo.Clients AS c
    INNER JOIN @ClientDelta AS d ON d.ClientID = c.ClientID
    WHERE d.AmountDelta <> 0;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Reviews_UpdateParticipantRatings
ON dbo.Reviews
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- ReviewerType selects which side of the existing assignment each ID must match.
    IF EXISTS
    (
        SELECT 1
        FROM inserted AS r
        INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
        WHERE (r.ReviewerType = 'ClientToFreelancer'
               AND (r.ReviewerID <> pa.ClientID OR r.RevieweeID <> pa.FreelancerID))
           OR (r.ReviewerType = 'FreelancerToClient'
               AND (r.ReviewerID <> pa.FreelancerID OR r.RevieweeID <> pa.ClientID))
    )
        THROW 51204, 'Review participants must match the assignment and reviewer type.', 1;

    ;WITH AffectedFreelancers AS
    (
        SELECT pa.FreelancerID
        FROM inserted AS r INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
        UNION
        SELECT pa.FreelancerID
        FROM deleted AS r INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
    )
    UPDATE f
    SET AverageRating = COALESCE(ratings.AverageRating, 5.00)
    FROM dbo.Freelancers AS f
    INNER JOIN AffectedFreelancers AS affected ON affected.FreelancerID = f.FreelancerID
    OUTER APPLY
    (
        SELECT CONVERT(DECIMAL(3,2), AVG(CONVERT(DECIMAL(5,2), r.Rating))) AS AverageRating
        FROM dbo.Reviews AS r
        INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
        WHERE pa.FreelancerID = f.FreelancerID
          AND r.ReviewerType = 'ClientToFreelancer'
    ) AS ratings;

    ;WITH AffectedClients AS
    (
        SELECT pa.ClientID
        FROM inserted AS r INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
        UNION
        SELECT pa.ClientID
        FROM deleted AS r INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
    )
    UPDATE c
    SET ClientRating = COALESCE(ratings.ClientRating, 5.00)
    FROM dbo.Clients AS c
    INNER JOIN AffectedClients AS affected ON affected.ClientID = c.ClientID
    OUTER APPLY
    (
        SELECT CONVERT(DECIMAL(3,2), AVG(CONVERT(DECIMAL(5,2), r.Rating))) AS ClientRating
        FROM dbo.Reviews AS r
        INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
        WHERE pa.ClientID = c.ClientID
          AND r.ReviewerType = 'FreelancerToClient'
    ) AS ratings;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_PlatformDisputes_ValidateRaiser
ON dbo.PlatformDisputes
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS d
        INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = d.AssignmentID
        WHERE (d.RaisedByType = 'Client' AND d.RaisedByID <> pa.ClientID)
           OR (d.RaisedByType = 'Freelancer' AND d.RaisedByID <> pa.FreelancerID)
    )
        THROW 51209, 'Dispute raiser must be the client or freelancer on the assignment.', 1;
END;
GO
