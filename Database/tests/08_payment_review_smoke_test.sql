-- Run after Database/08_payment_review_module.sql and sample data.
-- Uses a transaction and rolls every demonstration change back.
USE NeuroLanceHubDB;
GO
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.usp_RecordPayment', N'P') IS NULL
    THROW 51501, 'Run 08_payment_review_module.sql before this smoke test.', 1;

IF (SELECT COUNT_BIG(*) FROM dbo.Payments) < 10
    THROW 51502, 'Load the sample data before running this smoke test.', 1;

IF (SELECT COUNT_BIG(*) FROM dbo.Reviews) < 10
    THROW 51503, 'Expected at least ten sample reviews.', 1;

IF dbo.ufn_CalculatePlatformFee(1000.00, 0.1000) <> 100.00
    THROW 51504, 'Platform commission calculation failed.', 1;

IF EXISTS
(
    SELECT 1 FROM dbo.Payments
    WHERE PlatformFee <> CONVERT(DECIMAL(10,2), ROUND(GrossAmount * PlatformFeeRate, 2))
       OR NetAmount <> GrossAmount - PlatformFee
)
    THROW 51505, 'A payment does not balance against its fee-rate snapshot.', 1;

DECLARE @SeedPaymentID INT, @AssignmentID INT, @MilestoneID INT,
        @ClientID INT, @FreelancerID INT, @GrossAmount DECIMAL(10,2),
        @InitialEarnings DECIMAL(10,2), @InitialSpent DECIMAL(10,2),
        @PaymentID INT, @RetryPaymentID INT, @IdempotencyKey UNIQUEIDENTIFIER,
        @TransactionRef VARCHAR(100), @ReviewID INT, @ReviewerType VARCHAR(20),
        @ReviewerID INT, @ReviewerActorType VARCHAR(20), @NewRating INT,
        @ReviewComment VARCHAR(MAX);

SELECT TOP (1)
       @SeedPaymentID = pay.PaymentID,
       @AssignmentID = pay.AssignmentID,
       @MilestoneID = pay.MilestoneID,
       @ClientID = pay.ClientID,
       @FreelancerID = pay.FreelancerID,
       @GrossAmount = pay.GrossAmount
FROM dbo.Payments AS pay
WHERE pay.PaymentStatus = 'Released'
ORDER BY pay.PaymentID;

IF @SeedPaymentID IS NULL
    THROW 51506, 'A released sample payment is needed for the smoke test.', 1;

DECLARE @ExpectedError INT, @UnfinishedAssignmentID INT,
        @UnfinishedClientID INT;

BEGIN TRY
    UPDATE dbo.Payments
    SET PaymentStatus = 'Refunded'
    WHERE PaymentID = @SeedPaymentID;
    THROW 51514, 'A direct payment status update was unexpectedly accepted.', 1;
END TRY
BEGIN CATCH
    SET @ExpectedError = ERROR_NUMBER();
    IF @ExpectedError <> 51304 THROW;
    PRINT 'PASS: direct status updates are rejected.';
END CATCH;

BEGIN TRY
    EXEC dbo.usp_TransitionPayment
        @PaymentID = @SeedPaymentID,
        @NewStatus = 'Held in Escrow',
        @Reason = 'Negative smoke test: invalid backwards transition.',
        @ActorType = 'System';
    THROW 51515, 'An invalid status transition was unexpectedly accepted.', 1;
END TRY
BEGIN CATCH
    SET @ExpectedError = ERROR_NUMBER();
    IF @ExpectedError <> 51305 THROW;
    PRINT 'PASS: invalid status transitions are rejected.';
END CATCH;

SELECT TOP (1)
       @UnfinishedAssignmentID = AssignmentID,
       @UnfinishedClientID = ClientID
FROM dbo.ProjectAssignments
WHERE AssignmentStatus = 'In Progress'
ORDER BY AssignmentID;

BEGIN TRY
    EXEC dbo.usp_CreateAssignmentReview
        @AssignmentID = @UnfinishedAssignmentID,
        @ReviewerType = 'ClientToFreelancer',
        @ActorType = 'Client',
        @ActorID = @UnfinishedClientID,
        @Rating = 5,
        @Comment = 'Negative smoke test.';
    THROW 51516, 'A review for an unfinished assignment was unexpectedly accepted.', 1;
END TRY
BEGIN CATCH
    SET @ExpectedError = ERROR_NUMBER();
    IF @ExpectedError <> 51432 THROW;
    PRINT 'PASS: reviews for unfinished assignments are rejected.';
END CATCH;

SELECT @InitialEarnings = TotalEarnings
FROM dbo.Freelancers WHERE FreelancerID = @FreelancerID;
SELECT @InitialSpent = TotalSpent
FROM dbo.Clients WHERE ClientID = @ClientID;

SELECT TOP (1)
       @ReviewID = r.ReviewID,
       @ReviewerType = r.ReviewerType,
       @ReviewerID = r.ReviewerID,
       @ReviewComment = r.Comment,
       @NewRating = CASE WHEN r.Rating = 5 THEN 4 ELSE r.Rating + 1 END
FROM dbo.Reviews AS r
INNER JOIN dbo.ProjectAssignments AS pa ON pa.AssignmentID = r.AssignmentID
WHERE pa.AssignmentStatus = 'Completed'
ORDER BY r.ReviewID;

IF @ReviewID IS NULL
    THROW 51507, 'A completed assignment review is needed for the smoke test.', 1;

SET @IdempotencyKey = NEWID();
SET @TransactionRef = CONCAT('M4-SMOKE-', CONVERT(VARCHAR(36), @IdempotencyKey));

BEGIN TRY
    BEGIN TRANSACTION;

    EXEC dbo.usp_TransitionPayment
        @PaymentID = @SeedPaymentID,
        @NewStatus = 'Refunded',
        @Reason = 'Smoke test: free the sample amount for a repeatable payment request.',
        @ActorType = 'System';

    -- Output parameters can arrive with an old value; the procedure must reset it.
    SET @PaymentID = 2147483647;
    EXEC dbo.usp_RecordPayment
        @AssignmentID = @AssignmentID,
        @GrossAmount = @GrossAmount,
        @PaymentMethod = 'Demo record only',
        @TransactionRef = @TransactionRef,
        @IdempotencyKey = @IdempotencyKey,
        @PaymentID = @PaymentID OUTPUT,
        @MilestoneID = @MilestoneID,
        @PlatformFeeRate = 0.1000,
        @PaymentProvider = 'Smoke test',
        @ActorType = 'Client',
        @ActorID = @ClientID;

    EXEC dbo.usp_RecordPayment
        @AssignmentID = @AssignmentID,
        @GrossAmount = @GrossAmount,
        @PaymentMethod = 'Demo record only',
        @TransactionRef = @TransactionRef,
        @IdempotencyKey = @IdempotencyKey,
        @PaymentID = @RetryPaymentID OUTPUT,
        @MilestoneID = @MilestoneID,
        @PlatformFeeRate = 0.1000,
        @PaymentProvider = 'Smoke test',
        @ActorType = 'Client',
        @ActorID = @ClientID;

    IF @PaymentID <> @RetryPaymentID
        THROW 51508, 'An idempotent retry created a duplicate payment.', 1;

    EXEC dbo.usp_TransitionPayment
        @PaymentID = @PaymentID,
        @NewStatus = 'Held in Escrow',
        @Reason = 'Smoke test status progression.',
        @ActorType = 'System';

    EXEC dbo.usp_TransitionPayment
        @PaymentID = @PaymentID,
        @NewStatus = 'Released',
        @Reason = 'Smoke test release progression.',
        @ActorType = 'System';

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.PaymentStatusHistory
        WHERE PaymentID = @PaymentID
          AND NewStatus = 'Pending'
    ) OR NOT EXISTS
    (
        SELECT 1 FROM dbo.PaymentStatusHistory
        WHERE PaymentID = @PaymentID
          AND NewStatus = 'Held in Escrow'
    ) OR NOT EXISTS
    (
        SELECT 1 FROM dbo.PaymentStatusHistory
        WHERE PaymentID = @PaymentID
          AND NewStatus = 'Released'
    )
        THROW 51509, 'Payment status audit history is incomplete.', 1;

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.vw_PaymentHistory
        WHERE PaymentID = @PaymentID
          AND PaymentStatus = 'Released'
          AND PlatformFee = CONVERT(DECIMAL(10,2), ROUND(@GrossAmount * 0.1000, 2))
          AND NetAmount = @GrossAmount - CONVERT(DECIMAL(10,2), ROUND(@GrossAmount * 0.1000, 2))
    )
        THROW 51510, 'Payment history view is missing the expected released payment summary.', 1;

    IF EXISTS
    (
        SELECT 1 FROM dbo.Freelancers
        WHERE FreelancerID = @FreelancerID
          AND TotalEarnings <> @InitialEarnings
    ) OR EXISTS
    (
        SELECT 1 FROM dbo.Clients
        WHERE ClientID = @ClientID
          AND TotalSpent <> @InitialSpent
    )
        THROW 51511, 'Payment release/refund triggers did not reconcile account totals.', 1;

    DELETE FROM dbo.Reviews WHERE ReviewID = @ReviewID;

    DECLARE @ReviewAssignmentID INT;
    SELECT @ReviewAssignmentID = AssignmentID FROM dbo.Reviews WHERE ReviewID = @ReviewID;
    IF @ReviewAssignmentID IS NULL
    BEGIN
        SELECT TOP (1) @ReviewAssignmentID = pa.AssignmentID
        FROM dbo.ProjectAssignments AS pa
        WHERE pa.AssignmentStatus = 'Completed'
          AND NOT EXISTS
          (
              SELECT 1 FROM dbo.Reviews AS r
              WHERE r.AssignmentID = pa.AssignmentID
                AND r.ReviewerType = @ReviewerType
          );
    END;

    IF @ReviewAssignmentID IS NULL
        THROW 51512, 'Could not prepare an eligible assignment for review procedure testing.', 1;

    SET @ReviewerActorType = CASE
        WHEN @ReviewerType = 'ClientToFreelancer' THEN 'Client'
        ELSE 'Freelancer'
    END;

    EXEC dbo.usp_CreateAssignmentReview
        @AssignmentID = @ReviewAssignmentID,
        @ReviewerType = @ReviewerType,
        @ActorType = @ReviewerActorType,
        @ActorID = @ReviewerID,
        @Rating = @NewRating,
        @Comment = @ReviewComment;

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.vw_ReviewDetails
        WHERE AssignmentID = @ReviewAssignmentID
          AND ReviewerType = @ReviewerType
          AND Rating = @NewRating
          AND IsVerifiedCompletedAssignment = 1
    )
        THROW 51513, 'Review details view did not return the verified sample review.', 1;

    SELECT PaymentID, ProjectTitle, GrossAmount, PlatformFeeRate, PlatformFee, NetAmount, PaymentStatus
    FROM dbo.vw_PaymentHistory WHERE PaymentID = @PaymentID;
    SELECT PaymentStatusEventID, PaymentID, PreviousStatus, NewStatus, ActorType, Reason, OccurredAt
    FROM dbo.vw_PaymentStatusHistory WHERE PaymentID = @PaymentID ORDER BY PaymentStatusEventID;
    SELECT ParticipantType, ParticipantName, ReviewAverage, ReviewCount
    FROM dbo.vw_ParticipantReviewSummary
    WHERE (ParticipantType = 'Freelancer' AND ParticipantID = @FreelancerID)
       OR (ParticipantType = 'Client' AND ParticipantID = @ClientID);

    PRINT 'PASS: payment recording, retry idempotency, status audit, commission, summary triggers, and review validation.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
