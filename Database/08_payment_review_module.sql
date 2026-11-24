-- Member 4 payment and review module enhancements.
-- Run after 01 through 07 on NeuroLanceHubDB. This script is repeatable.
-- This is an auditable demo ledger; it does not transfer or hold real money.

USE NeuroLanceHubDB;
GO

/* Preserve existing table names and relationships. Additive columns keep a
   fee-rate snapshot and an idempotency key for safe retries. */
IF COL_LENGTH(N'dbo.Payments', N'PlatformFeeRate') IS NULL
BEGIN
    ALTER TABLE dbo.Payments ADD PlatformFeeRate DECIMAL(5,4) NULL;
END;
GO

UPDATE dbo.Payments
SET PlatformFeeRate = CASE
    WHEN GrossAmount > 0 THEN CONVERT(DECIMAL(5,4), PlatformFee / NULLIF(GrossAmount, 0))
    ELSE 0.0000
END
WHERE PlatformFeeRate IS NULL;
GO

IF EXISTS
(
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'PlatformFeeRate'
      AND is_nullable = 1
)
    ALTER TABLE dbo.Payments ALTER COLUMN PlatformFeeRate DECIMAL(5,4) NOT NULL;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.default_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'DF_Payments_PlatformFeeRate'
)
    ALTER TABLE dbo.Payments ADD CONSTRAINT DF_Payments_PlatformFeeRate
        DEFAULT (0.1000) FOR PlatformFeeRate;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'CK_Payments_PlatformFeeRate'
)
    ALTER TABLE dbo.Payments ADD CONSTRAINT CK_Payments_PlatformFeeRate
        CHECK (PlatformFeeRate >= 0.0000 AND PlatformFeeRate < 1.0000);
GO

IF COL_LENGTH(N'dbo.Payments', N'PaymentProvider') IS NULL
    ALTER TABLE dbo.Payments ADD PaymentProvider VARCHAR(50) NULL;
GO

IF COL_LENGTH(N'dbo.Payments', N'IdempotencyKey') IS NULL
    ALTER TABLE dbo.Payments ADD IdempotencyKey UNIQUEIDENTIFIER NULL;
GO

UPDATE dbo.Payments
SET IdempotencyKey = NEWID()
WHERE IdempotencyKey IS NULL;
GO

IF EXISTS
(
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'IdempotencyKey'
      AND is_nullable = 1
)
    ALTER TABLE dbo.Payments ALTER COLUMN IdempotencyKey UNIQUEIDENTIFIER NOT NULL;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.default_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'DF_Payments_IdempotencyKey'
)
    ALTER TABLE dbo.Payments ADD CONSTRAINT DF_Payments_IdempotencyKey
        DEFAULT (NEWID()) FOR IdempotencyKey;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'UQ_Payments_IdempotencyKey'
)
    ALTER TABLE dbo.Payments ADD CONSTRAINT UQ_Payments_IdempotencyKey
        UNIQUE (IdempotencyKey);
GO

/* New entries begin as Pending. Existing sample statuses are preserved. */
IF EXISTS
(
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'CK_Payment_Status'
)
    ALTER TABLE dbo.Payments DROP CONSTRAINT CK_Payment_Status;
GO

ALTER TABLE dbo.Payments ADD CONSTRAINT CK_Payment_Status
    CHECK (PaymentStatus IN
        ('Pending', 'Held in Escrow', 'Released', 'Refunded', 'Failed', 'Cancelled', 'Disputed'));
GO

IF EXISTS
(
    SELECT 1 FROM sys.default_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND parent_column_id = COLUMNPROPERTY(OBJECT_ID(N'dbo.Payments'), N'PaymentStatus', 'ColumnId')
)
BEGIN
    DECLARE @PaymentStatusDefault SYSNAME, @DropPaymentStatusDefaultSql NVARCHAR(4000);
    SELECT @PaymentStatusDefault = dc.name
    FROM sys.default_constraints AS dc
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND dc.parent_column_id = COLUMNPROPERTY(OBJECT_ID(N'dbo.Payments'), N'PaymentStatus', 'ColumnId');
    SET @DropPaymentStatusDefaultSql =
        N'ALTER TABLE dbo.Payments DROP CONSTRAINT ' + QUOTENAME(@PaymentStatusDefault) + N';';
    EXEC sys.sp_executesql @DropPaymentStatusDefaultSql;
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.default_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'DF_Payments_PaymentStatus'
)
    ALTER TABLE dbo.Payments ADD CONSTRAINT DF_Payments_PaymentStatus
        DEFAULT ('Pending') FOR PaymentStatus;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.Payments')
      AND name = N'CK_Payments_ReleasedDate'
)
    ALTER TABLE dbo.Payments ADD CONSTRAINT CK_Payments_ReleasedDate
        CHECK (PaymentStatus <> 'Released' OR ReleasedDate IS NOT NULL);
GO

IF OBJECT_ID(N'dbo.PaymentStatusHistory', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PaymentStatusHistory
    (
        PaymentStatusEventID BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_PaymentStatusHistory PRIMARY KEY,
        PaymentID INT NOT NULL,
        PreviousStatus VARCHAR(20) NULL,
        NewStatus VARCHAR(20) NOT NULL,
        ActorType VARCHAR(20) NOT NULL,
        ActorID INT NULL,
        Reason VARCHAR(500) NULL,
        OccurredAt DATETIME2(3) NOT NULL
            CONSTRAINT DF_PaymentStatusHistory_OccurredAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT FK_PaymentStatusHistory_Payments
            FOREIGN KEY (PaymentID) REFERENCES dbo.Payments(PaymentID),
        CONSTRAINT CK_PaymentStatusHistory_ActorType
            CHECK (ActorType IN ('System', 'Client', 'Freelancer', 'Admin'))
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.PaymentStatusHistory')
      AND name = N'IX_PaymentStatusHistory_Payment_OccurredAt'
)
    CREATE INDEX IX_PaymentStatusHistory_Payment_OccurredAt
        ON dbo.PaymentStatusHistory (PaymentID, OccurredAt DESC);
GO

/* Capture a baseline once for payments that existed before this audit table. */
INSERT INTO dbo.PaymentStatusHistory
    (PaymentID, PreviousStatus, NewStatus, ActorType, Reason, OccurredAt)
SELECT p.PaymentID, NULL, p.PaymentStatus, 'System',
       'Baseline status imported when payment history was enabled.', SYSUTCDATETIME()
FROM dbo.Payments AS p
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.PaymentStatusHistory AS h
    WHERE h.PaymentID = p.PaymentID
);
GO

CREATE OR ALTER FUNCTION dbo.ufn_CalculateClientRating
(
    @ClientID INT
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @Rating DECIMAL(3,2);

    SELECT @Rating = CONVERT(DECIMAL(3,2), AVG(CONVERT(DECIMAL(5,2), r.Rating)))
    FROM dbo.Reviews AS r
    INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
    WHERE pa.ClientID = @ClientID
      AND r.ReviewerType = 'FreelancerToClient';

    RETURN @Rating;
END;
GO

CREATE OR ALTER VIEW dbo.vw_PaymentHistory
AS
    SELECT
        pay.PaymentID,
        pay.AssignmentID,
        p.ProjectID,
        p.Title AS ProjectTitle,
        pay.MilestoneID,
        m.MilestoneTitle,
        c.ClientID,
        c.FullName AS ClientName,
        f.FreelancerID,
        f.FullName AS FreelancerName,
        pay.GrossAmount,
        pay.PlatformFeeRate,
        pay.PlatformFee,
        pay.NetAmount,
        pay.PaymentMethod,
        pay.PaymentProvider,
        pay.PaymentStatus,
        pay.TransactionRef,
        pay.PaymentDate,
        pay.ReleasedDate
    FROM dbo.Payments AS pay
    INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = pay.AssignmentID
    INNER JOIN dbo.Projects AS p ON p.ProjectID = pa.ProjectID
    INNER JOIN dbo.Clients AS c ON c.ClientID = pay.ClientID
    INNER JOIN dbo.Freelancers AS f ON f.FreelancerID = pay.FreelancerID
    LEFT JOIN dbo.ProjectMilestones AS m ON m.MilestoneID = pay.MilestoneID;
GO

CREATE OR ALTER VIEW dbo.vw_ReviewDetails
AS
    SELECT
        r.ReviewID,
        r.AssignmentID,
        p.ProjectID,
        p.Title AS ProjectTitle,
        r.ReviewerType,
        CASE r.ReviewerType
            WHEN 'ClientToFreelancer' THEN c.FullName
            ELSE f.FullName
        END AS ReviewerName,
        CASE r.ReviewerType
            WHEN 'ClientToFreelancer' THEN f.FullName
            ELSE c.FullName
        END AS RevieweeName,
        r.ReviewerID,
        r.RevieweeID,
        r.Rating,
        r.Comment,
        r.CreatedAt,
        CONVERT(BIT, CASE WHEN pa.AssignmentStatus = 'Completed' THEN 1 ELSE 0 END) AS IsVerifiedCompletedAssignment
    FROM dbo.Reviews AS r
    INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
    INNER JOIN dbo.Projects AS p ON p.ProjectID = pa.ProjectID
    INNER JOIN dbo.Clients AS c ON c.ClientID = pa.ClientID
    INNER JOIN dbo.Freelancers AS f ON f.FreelancerID = pa.FreelancerID;
GO

CREATE OR ALTER VIEW dbo.vw_ParticipantReviewSummary
AS
    SELECT
        'Freelancer' AS ParticipantType,
        f.FreelancerID AS ParticipantID,
        f.FullName AS ParticipantName,
        f.AverageRating AS StoredAverageRating,
        dbo.ufn_CalculateFreelancerRating(f.FreelancerID) AS ReviewAverage,
        COUNT_BIG(r.ReviewID) AS ReviewCount
    FROM dbo.Freelancers AS f
    LEFT JOIN dbo.ProjectAssignments AS pa ON pa.FreelancerID = f.FreelancerID
    LEFT JOIN dbo.Reviews AS r
        ON r.AssignmentID = pa.AssignmentID
       AND r.ReviewerType = 'ClientToFreelancer'
    GROUP BY f.FreelancerID, f.FullName, f.AverageRating
    UNION ALL
    SELECT
        'Client' AS ParticipantType,
        c.ClientID AS ParticipantID,
        c.FullName AS ParticipantName,
        c.ClientRating AS StoredAverageRating,
        dbo.ufn_CalculateClientRating(c.ClientID) AS ReviewAverage,
        COUNT_BIG(r.ReviewID) AS ReviewCount
    FROM dbo.Clients AS c
    LEFT JOIN dbo.ProjectAssignments AS pa ON pa.ClientID = c.ClientID
    LEFT JOIN dbo.Reviews AS r
        ON r.AssignmentID = pa.AssignmentID
       AND r.ReviewerType = 'FreelancerToClient'
    GROUP BY c.ClientID, c.FullName, c.ClientRating;
GO

CREATE OR ALTER VIEW dbo.vw_PaymentStatusHistory
AS
    SELECT
        h.PaymentStatusEventID,
        h.PaymentID,
        h.PreviousStatus,
        h.NewStatus,
        h.ActorType,
        h.ActorID,
        h.Reason,
        h.OccurredAt,
        pay.AssignmentID,
        p.Title AS ProjectTitle,
        pay.ClientID,
        pay.FreelancerID
    FROM dbo.PaymentStatusHistory AS h
    INNER JOIN dbo.Payments AS pay ON pay.PaymentID = h.PaymentID
    INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = pay.AssignmentID
    INNER JOIN dbo.Projects AS p ON p.ProjectID = pa.ProjectID;
GO

CREATE OR ALTER TRIGGER dbo.TR_Payments_EnforceStatusAndWriteHistory
ON dbo.Payments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM deleted AS d
        LEFT JOIN inserted AS i ON i.PaymentID = d.PaymentID
        WHERE i.PaymentID IS NULL
    )
        THROW 51301, 'Payment ledger rows cannot be deleted; transition them to a terminal status instead.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        LEFT JOIN deleted AS d ON d.PaymentID = i.PaymentID
        WHERE CONVERT(DECIMAL(10,2), ROUND(i.GrossAmount * i.PlatformFeeRate, 2)) <> i.PlatformFee
           OR i.NetAmount <> i.GrossAmount - i.PlatformFee
           OR i.PlatformFeeRate < 0.0000
           OR i.PlatformFeeRate >= 1.0000
    )
        THROW 51302, 'Payment gross, fee rate, fee, and net amounts must balance.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        LEFT JOIN deleted AS d ON d.PaymentID = i.PaymentID
        WHERE d.PaymentID IS NULL
          AND i.PaymentStatus <> 'Pending'
    )
        THROW 51303, 'New payment records must begin in Pending status.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.PaymentID = i.PaymentID
        WHERE i.PaymentStatus <> d.PaymentStatus
          AND ISNULL(TRY_CONVERT(INT, SESSION_CONTEXT(N'PaymentTransition')), 0) <> 1
    )
        THROW 51304, 'Change payment status only through dbo.usp_TransitionPayment.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.PaymentID = i.PaymentID
        WHERE (d.PaymentStatus = 'Pending'
               AND i.PaymentStatus NOT IN ('Pending', 'Held in Escrow', 'Failed', 'Cancelled'))
           OR (d.PaymentStatus = 'Held in Escrow'
               AND i.PaymentStatus NOT IN ('Held in Escrow', 'Released', 'Refunded', 'Disputed'))
           OR (d.PaymentStatus = 'Disputed'
               AND i.PaymentStatus NOT IN ('Disputed', 'Held in Escrow', 'Released', 'Refunded'))
           OR (d.PaymentStatus = 'Released'
               AND i.PaymentStatus NOT IN ('Released', 'Refunded'))
           OR (d.PaymentStatus IN ('Refunded', 'Failed', 'Cancelled')
               AND i.PaymentStatus <> d.PaymentStatus)
    )
        THROW 51305, 'The requested payment status transition is not allowed.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.PaymentID = i.PaymentID
        WHERE d.PaymentStatus <> 'Pending'
          AND
          (
              i.AssignmentID <> d.AssignmentID
              OR ISNULL(i.MilestoneID, -1) <> ISNULL(d.MilestoneID, -1)
              OR i.ClientID <> d.ClientID
              OR i.FreelancerID <> d.FreelancerID
              OR i.GrossAmount <> d.GrossAmount
              OR i.PlatformFeeRate <> d.PlatformFeeRate
              OR i.PlatformFee <> d.PlatformFee
              OR i.NetAmount <> d.NetAmount
              OR i.PaymentMethod <> d.PaymentMethod
              OR ISNULL(i.PaymentProvider, '') <> ISNULL(d.PaymentProvider, '')
              OR i.TransactionRef <> d.TransactionRef
              OR i.IdempotencyKey <> d.IdempotencyKey
          )
    )
        THROW 51306, 'Financial facts are immutable after a payment leaves Pending status.', 1;

    INSERT INTO dbo.PaymentStatusHistory
        (PaymentID, PreviousStatus, NewStatus, ActorType, ActorID, Reason)
    SELECT
        i.PaymentID,
        d.PaymentStatus,
        i.PaymentStatus,
        CASE
            WHEN CONVERT(VARCHAR(20), SESSION_CONTEXT(N'ActorType')) IN ('Client', 'Freelancer', 'Admin')
                THEN CONVERT(VARCHAR(20), SESSION_CONTEXT(N'ActorType'))
            ELSE 'System'
        END,
        TRY_CONVERT(INT, SESSION_CONTEXT(N'ActorID')),
        COALESCE(CONVERT(VARCHAR(500), SESSION_CONTEXT(N'PaymentReason')),
                 CASE WHEN d.PaymentID IS NULL THEN 'Payment request recorded.' ELSE NULL END)
    FROM inserted AS i
    LEFT JOIN deleted AS d ON d.PaymentID = i.PaymentID
    WHERE d.PaymentID IS NULL OR i.PaymentStatus <> d.PaymentStatus;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_PaymentStatusHistory_Immutable
ON dbo.PaymentStatusHistory
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    THROW 51307, 'Payment status history is append-only.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_ProjectAssignments_ProtectReviewedCompletion
ON dbo.ProjectAssignments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN deleted AS d ON d.AssignmentID = i.AssignmentID
        INNER JOIN dbo.Reviews AS r ON r.AssignmentID = i.AssignmentID
        WHERE d.AssignmentStatus = 'Completed'
          AND i.AssignmentStatus <> 'Completed'
    )
        THROW 51308, 'An assignment with published reviews cannot be reopened or terminated.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Reviews_UpdateParticipantRatings
ON dbo.Reviews
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS r
        INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
        WHERE pa.AssignmentStatus <> 'Completed'
           OR (r.ReviewerType = 'ClientToFreelancer'
               AND (r.ReviewerID <> pa.ClientID OR r.RevieweeID <> pa.FreelancerID))
           OR (r.ReviewerType = 'FreelancerToClient'
               AND (r.ReviewerID <> pa.FreelancerID OR r.RevieweeID <> pa.ClientID))
    )
        THROW 51309, 'Reviews require a completed assignment and the correct client/freelancer participants.', 1;

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

CREATE OR ALTER PROCEDURE dbo.usp_RecordPayment
    @AssignmentID INT,
    @GrossAmount DECIMAL(10,2),
    @PaymentMethod VARCHAR(50),
    @TransactionRef VARCHAR(100),
    @IdempotencyKey UNIQUEIDENTIFIER,
    @PaymentID INT OUTPUT,
    @MilestoneID INT = NULL,
    @PlatformFeeRate DECIMAL(5,4) = 0.1000,
    @PaymentProvider VARCHAR(50) = NULL,
    @ActorType VARCHAR(20) = 'System',
    @ActorID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @PaymentID = NULL;

    IF @GrossAmount IS NULL OR @GrossAmount <= 0
       OR @PlatformFeeRate IS NULL OR @PlatformFeeRate < 0 OR @PlatformFeeRate >= 1
       OR NULLIF(LTRIM(RTRIM(@PaymentMethod)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(@TransactionRef)), '') IS NULL
       OR @IdempotencyKey IS NULL
        THROW 51401, 'Amount, fee rate, method label, transaction reference, and idempotency key are required.', 1;

    IF @ActorType IS NULL OR @ActorType NOT IN ('System', 'Client', 'Freelancer', 'Admin')
        THROW 51402, 'Actor type is invalid.', 1;

    IF @ActorType <> 'System' AND @ActorID IS NULL
        THROW 51412, 'A participant or administrator actor ID is required.', 1;

    DECLARE @ClientID INT, @FreelancerID INT, @AssignmentPrice DECIMAL(10,2),
            @AssignmentStatus VARCHAR(20), @MilestoneAmount DECIMAL(10,2),
            @Fee DECIMAL(10,2), @ExistingAssignmentID INT,
            @ExistingMilestoneID INT, @ExistingGross DECIMAL(10,2),
            @ExistingMethod VARCHAR(50), @ExistingProvider VARCHAR(50),
            @ExistingTransactionRef VARCHAR(100), @ExistingFeeRate DECIMAL(5,4);

    SET @Fee = dbo.ufn_CalculatePlatformFee(@GrossAmount, @PlatformFeeRate);
    IF @Fee IS NULL OR @Fee >= @GrossAmount
        THROW 51403, 'The platform fee must leave a positive freelancer net amount.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @ClientID = pa.ClientID,
               @FreelancerID = pa.FreelancerID,
               @AssignmentPrice = pa.AgreedPrice,
               @AssignmentStatus = pa.AssignmentStatus
        FROM dbo.ProjectAssignments AS pa WITH (UPDLOCK, HOLDLOCK)
        WHERE pa.AssignmentID = @AssignmentID;

        IF @ClientID IS NULL
            THROW 51404, 'Assignment was not found.', 1;

        IF @AssignmentStatus = 'Terminated'
            THROW 51405, 'A terminated assignment cannot receive a payment request.', 1;

        IF @ActorType = 'Client' AND (@ActorID IS NULL OR @ActorID <> @ClientID)
            THROW 51406, 'The supplied client actor does not own this assignment.', 1;

        IF @ActorType NOT IN ('Client', 'System')
            THROW 51407, 'Freelancers cannot create client payment requests.', 1;

        SELECT @PaymentID = pay.PaymentID,
               @ExistingAssignmentID = pay.AssignmentID,
               @ExistingMilestoneID = pay.MilestoneID,
               @ExistingGross = pay.GrossAmount,
               @ExistingMethod = pay.PaymentMethod,
               @ExistingProvider = pay.PaymentProvider,
               @ExistingTransactionRef = pay.TransactionRef,
               @ExistingFeeRate = pay.PlatformFeeRate
        FROM dbo.Payments AS pay WITH (UPDLOCK, HOLDLOCK)
        WHERE pay.IdempotencyKey = @IdempotencyKey;

        IF @PaymentID IS NOT NULL
        BEGIN
            IF @ExistingAssignmentID <> @AssignmentID
               OR ISNULL(@ExistingMilestoneID, -1) <> ISNULL(@MilestoneID, -1)
               OR @ExistingGross <> @GrossAmount
               OR @ExistingMethod <> @PaymentMethod
               OR ISNULL(@ExistingProvider, '') <> ISNULL(@PaymentProvider, '')
               OR @ExistingTransactionRef <> @TransactionRef
               OR @ExistingFeeRate <> @PlatformFeeRate
                THROW 51408, 'This idempotency key was already used with a different payment request.', 1;

            COMMIT TRANSACTION;
            RETURN;
        END;

        IF @MilestoneID IS NOT NULL
        BEGIN
            SELECT @MilestoneAmount = m.Amount
            FROM dbo.ProjectMilestones AS m WITH (UPDLOCK, HOLDLOCK)
            WHERE m.MilestoneID = @MilestoneID
              AND m.AssignmentID = @AssignmentID;

            IF @MilestoneAmount IS NULL
                THROW 51409, 'The milestone does not belong to the selected assignment.', 1;
        END;

        DECLARE @AssignmentReserved DECIMAL(38,2), @MilestoneReserved DECIMAL(38,2);
        SELECT @AssignmentReserved = COALESCE(SUM(CONVERT(DECIMAL(38,2), pay.GrossAmount)), 0)
        FROM dbo.Payments AS pay WITH (UPDLOCK, HOLDLOCK)
        WHERE pay.AssignmentID = @AssignmentID
          AND pay.PaymentStatus IN ('Pending', 'Held in Escrow', 'Disputed', 'Released');

        IF @AssignmentReserved + @GrossAmount > @AssignmentPrice
            THROW 51410, 'Payment requests cannot exceed the agreed assignment price.', 1;

        IF @MilestoneID IS NOT NULL
        BEGIN
            SELECT @MilestoneReserved = COALESCE(SUM(CONVERT(DECIMAL(38,2), pay.GrossAmount)), 0)
            FROM dbo.Payments AS pay WITH (UPDLOCK, HOLDLOCK)
            WHERE pay.MilestoneID = @MilestoneID
              AND pay.PaymentStatus IN ('Pending', 'Held in Escrow', 'Disputed', 'Released');

            IF @MilestoneReserved + @GrossAmount > @MilestoneAmount
                THROW 51411, 'Payment requests cannot exceed the milestone amount.', 1;
        END;

        EXEC sys.sp_set_session_context @key=N'ActorType', @value=@ActorType;
        EXEC sys.sp_set_session_context @key=N'ActorID', @value=@ActorID;
        EXEC sys.sp_set_session_context @key=N'PaymentReason', @value=N'Payment request recorded.';

        INSERT INTO dbo.Payments
            (AssignmentID, MilestoneID, ClientID, FreelancerID, GrossAmount,
             PlatformFeeRate, PlatformFee, NetAmount, PaymentMethod, PaymentProvider,
             PaymentStatus, TransactionRef, IdempotencyKey)
        VALUES
            (@AssignmentID, @MilestoneID, @ClientID, @FreelancerID, @GrossAmount,
             @PlatformFeeRate, @Fee, @GrossAmount - @Fee, @PaymentMethod, @PaymentProvider,
             'Pending', @TransactionRef, @IdempotencyKey);

        SET @PaymentID = CONVERT(INT, SCOPE_IDENTITY());

        EXEC sys.sp_set_session_context @key=N'ActorType', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'ActorID', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'PaymentReason', @value=NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        EXEC sys.sp_set_session_context @key=N'ActorType', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'ActorID', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'PaymentReason', @value=NULL;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_TransitionPayment
    @PaymentID INT,
    @NewStatus VARCHAR(20),
    @Reason VARCHAR(500),
    @ActorType VARCHAR(20),
    @ActorID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@Reason)), '') IS NULL
       OR @ActorType IS NULL
       OR @ActorType NOT IN ('System', 'Client', 'Freelancer', 'Admin')
       OR (@ActorType <> 'System' AND @ActorID IS NULL)
       OR @NewStatus IS NULL
        THROW 51420, 'A status-change reason and valid actor type are required.', 1;

    DECLARE @CurrentStatus VARCHAR(20), @ClientID INT, @FreelancerID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @CurrentStatus = PaymentStatus,
               @ClientID = ClientID,
               @FreelancerID = FreelancerID
        FROM dbo.Payments WITH (UPDLOCK, HOLDLOCK)
        WHERE PaymentID = @PaymentID;

        IF @CurrentStatus IS NULL
            THROW 51421, 'Payment was not found.', 1;

        IF @ActorType = 'Admin'
           AND NOT EXISTS (SELECT 1 FROM dbo.AdminUsers WHERE AdminID = @ActorID)
            THROW 51425, 'The supplied administrator actor ID was not found.', 1;

        IF @ActorType = 'Client'
           AND (@ActorID IS NULL OR @ActorID <> @ClientID OR @NewStatus NOT IN ('Cancelled', 'Disputed'))
            THROW 51422, 'Clients may only cancel a pending payment or dispute their own held payment.', 1;

        IF @ActorType = 'Freelancer'
           AND (@ActorID IS NULL OR @ActorID <> @FreelancerID OR @NewStatus <> 'Disputed')
            THROW 51423, 'Freelancers may only dispute their own held payment.', 1;

        IF @ActorType IN ('Admin', 'System')
           AND @NewStatus NOT IN ('Held in Escrow', 'Released', 'Refunded', 'Failed', 'Cancelled', 'Disputed')
            THROW 51424, 'The requested payment status is not a transition target.', 1;

        EXEC sys.sp_set_session_context @key=N'PaymentTransition', @value=1;
        EXEC sys.sp_set_session_context @key=N'ActorType', @value=@ActorType;
        EXEC sys.sp_set_session_context @key=N'ActorID', @value=@ActorID;
        EXEC sys.sp_set_session_context @key=N'PaymentReason', @value=@Reason;

        UPDATE dbo.Payments
        SET PaymentStatus = @NewStatus,
            ReleasedDate = CASE
                WHEN @NewStatus = 'Released' THEN COALESCE(ReleasedDate, GETDATE())
                WHEN @NewStatus = 'Refunded' THEN ReleasedDate
                ELSE NULL
            END
        WHERE PaymentID = @PaymentID;

        EXEC sys.sp_set_session_context @key=N'PaymentTransition', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'ActorType', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'ActorID', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'PaymentReason', @value=NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        EXEC sys.sp_set_session_context @key=N'PaymentTransition', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'ActorType', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'ActorID', @value=NULL;
        EXEC sys.sp_set_session_context @key=N'PaymentReason', @value=NULL;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CreateAssignmentReview
    @AssignmentID INT,
    @ReviewerType VARCHAR(20),
    @ActorType VARCHAR(20),
    @ActorID INT,
    @Rating INT,
    @Comment NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @ReviewerType IS NULL OR @ReviewerType NOT IN ('ClientToFreelancer', 'FreelancerToClient')
       OR @Rating IS NULL OR @Rating NOT BETWEEN 1 AND 5
       OR @ActorType IS NULL
       OR @ActorID IS NULL
        THROW 51430, 'Review direction or rating is invalid.', 1;

    DECLARE @AssignmentStatus VARCHAR(20), @ClientID INT, @FreelancerID INT, @RevieweeID INT;

    SELECT @AssignmentStatus = AssignmentStatus,
           @ClientID = ClientID,
           @FreelancerID = FreelancerID
    FROM dbo.ProjectAssignments
    WHERE AssignmentID = @AssignmentID;

    IF @AssignmentStatus IS NULL
        THROW 51431, 'Assignment was not found.', 1;

    IF @AssignmentStatus <> 'Completed'
        THROW 51432, 'Reviews can only be submitted for completed assignments.', 1;

    IF @ReviewerType = 'ClientToFreelancer'
    BEGIN
        IF @ActorType <> 'Client' OR @ActorID <> @ClientID
            THROW 51433, 'Only the assigned client can review this freelancer.', 1;
        SET @RevieweeID = @FreelancerID;
    END;
    ELSE
    BEGIN
        IF @ActorType <> 'Freelancer' OR @ActorID <> @FreelancerID
            THROW 51434, 'Only the assigned freelancer can review this client.', 1;
        SET @RevieweeID = @ClientID;
    END;

    INSERT INTO dbo.Reviews
        (AssignmentID, ReviewerType, ReviewerID, RevieweeID, Rating, Comment)
    VALUES
        (@AssignmentID, @ReviewerType, @ActorID, @RevieweeID, @Rating, @Comment);
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetClientPaymentHistory
    @ClientID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM dbo.vw_PaymentHistory
    WHERE ClientID = @ClientID
    ORDER BY PaymentDate DESC, PaymentID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetFreelancerPaymentHistory
    @FreelancerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM dbo.vw_PaymentHistory
    WHERE FreelancerID = @FreelancerID
    ORDER BY PaymentDate DESC, PaymentID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GeneratePaymentRevenueReport
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL AND @EndDate < @StartDate
        THROW 51440, 'End date must be on or after start date.', 1;

    SELECT
        CONVERT(DATE, pay.PaymentDate) AS PaymentDay,
        COUNT_BIG(*) AS PaymentRequestCount,
        SUM(pay.GrossAmount) AS RecordedGrossAmount,
        SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.GrossAmount ELSE 0 END) AS ReleasedGrossAmount,
        SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.PlatformFee ELSE 0 END) AS RecognizedPlatformCommission,
        SUM(CASE WHEN pay.PaymentStatus = 'Released' THEN pay.NetAmount ELSE 0 END) AS ReleasedFreelancerNet,
        SUM(CASE WHEN pay.PaymentStatus IN ('Pending', 'Held in Escrow', 'Disputed') THEN 1 ELSE 0 END) AS OpenPaymentCount,
        SUM(CASE WHEN pay.PaymentStatus = 'Refunded' THEN 1 ELSE 0 END) AS RefundedPaymentCount,
        SUM(CASE WHEN pay.PaymentStatus = 'Failed' THEN 1 ELSE 0 END) AS FailedPaymentCount
    FROM dbo.Payments AS pay
    WHERE (@StartDate IS NULL OR pay.PaymentDate >= @StartDate)
      AND (@EndDate IS NULL OR pay.PaymentDate < DATEADD(DAY, 1, @EndDate))
    GROUP BY CONVERT(DATE, pay.PaymentDate)
    ORDER BY PaymentDay;
END;
GO

/* Give a trusted backend a narrow role. Do not add browser/user logins here. */
IF DATABASE_PRINCIPAL_ID(N'NeuroHirePaymentReviewAppRole') IS NULL
    EXEC(N'CREATE ROLE NeuroHirePaymentReviewAppRole AUTHORIZATION dbo;');
GO

GRANT SELECT ON OBJECT::dbo.vw_PaymentHistory TO NeuroHirePaymentReviewAppRole;
GRANT SELECT ON OBJECT::dbo.vw_PaymentStatusHistory TO NeuroHirePaymentReviewAppRole;
GRANT SELECT ON OBJECT::dbo.vw_ReviewDetails TO NeuroHirePaymentReviewAppRole;
GRANT SELECT ON OBJECT::dbo.vw_ParticipantReviewSummary TO NeuroHirePaymentReviewAppRole;
GRANT SELECT ON OBJECT::dbo.vw_ProjectPaymentSummary TO NeuroHirePaymentReviewAppRole;
GRANT EXECUTE ON OBJECT::dbo.usp_RecordPayment TO NeuroHirePaymentReviewAppRole;
GRANT EXECUTE ON OBJECT::dbo.usp_TransitionPayment TO NeuroHirePaymentReviewAppRole;
GRANT EXECUTE ON OBJECT::dbo.usp_CreateAssignmentReview TO NeuroHirePaymentReviewAppRole;
GRANT EXECUTE ON OBJECT::dbo.usp_GetClientPaymentHistory TO NeuroHirePaymentReviewAppRole;
GRANT EXECUTE ON OBJECT::dbo.usp_GetFreelancerPaymentHistory TO NeuroHirePaymentReviewAppRole;
GRANT EXECUTE ON OBJECT::dbo.usp_GeneratePaymentRevenueReport TO NeuroHirePaymentReviewAppRole;
GO

/* Payment records deliberately contain method/provider labels and references
   only. Never store PAN, CVV, bank credentials, or raw authentication secrets. */
