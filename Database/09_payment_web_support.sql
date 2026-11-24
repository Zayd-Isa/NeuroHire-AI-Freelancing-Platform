-- Member 4 backend read models. Apply after 08. No other member's routes are changed.
USE NeuroLanceHubDB;
GO
-- Keep review text intact for multilingual participants; no names or relationships change.
ALTER TABLE dbo.Reviews ALTER COLUMN Comment NVARCHAR(MAX) NULL;
GO
CREATE OR ALTER VIEW dbo.vw_PaymentWorkspaceAssignments
AS
SELECT pa.AssignmentID, pa.ClientID, pa.FreelancerID, p.Title AS ProjectTitle,
       c.FullName AS ClientName, f.FullName AS FreelancerName,
       pa.AgreedPrice, pa.AssignmentStatus,
       pa.AgreedPrice - COALESCE(t.ReservedAmount, 0) AS RemainingAmount,
       CONVERT(BIT, CASE WHEN cr.ReviewID IS NULL THEN 0 ELSE 1 END) AS ClientReviewed,
       CONVERT(BIT, CASE WHEN fr.ReviewID IS NULL THEN 0 ELSE 1 END) AS FreelancerReviewed
FROM dbo.ProjectAssignments pa
JOIN dbo.Projects p ON p.ProjectID = pa.ProjectID
JOIN dbo.Clients c ON c.ClientID = pa.ClientID
JOIN dbo.Freelancers f ON f.FreelancerID = pa.FreelancerID
LEFT JOIN dbo.Reviews cr ON cr.AssignmentID = pa.AssignmentID AND cr.ReviewerType = 'ClientToFreelancer'
LEFT JOIN dbo.Reviews fr ON fr.AssignmentID = pa.AssignmentID AND fr.ReviewerType = 'FreelancerToClient'
OUTER APPLY (
  SELECT SUM(CONVERT(DECIMAL(38,2), GrossAmount)) AS ReservedAmount FROM dbo.Payments pay
  WHERE pay.AssignmentID = pa.AssignmentID AND pay.PaymentStatus IN ('Pending', 'Held in Escrow', 'Released', 'Disputed')
) t;
GO
CREATE OR ALTER VIEW dbo.vw_PaymentWorkspaceMilestones
AS
SELECT m.MilestoneID, m.AssignmentID, m.MilestoneTitle, m.Amount, m.MilestoneStatus,
       m.Amount - COALESCE(t.ReservedAmount, 0) AS RemainingAmount,
       pa.ClientID, pa.FreelancerID
FROM dbo.ProjectMilestones m
JOIN dbo.ProjectAssignments pa ON pa.AssignmentID = m.AssignmentID
OUTER APPLY (
  SELECT SUM(CONVERT(DECIMAL(38,2), GrossAmount)) AS ReservedAmount FROM dbo.Payments pay
  WHERE pay.MilestoneID = m.MilestoneID AND pay.PaymentStatus IN ('Pending', 'Held in Escrow', 'Released', 'Disputed')
) t;
GO
-- Only the trusted backend receives this permission. The hash is never sent to a browser.
CREATE OR ALTER PROCEDURE dbo.usp_PaymentLoginAccount
    @Role VARCHAR(20), @Email VARCHAR(100)
AS
BEGIN
  SET NOCOUNT ON;
  IF @Role = 'Client'
    SELECT ClientID AS AccountID, FullName, Password FROM dbo.Clients WHERE Email = @Email;
  ELSE IF @Role = 'Freelancer'
    SELECT FreelancerID AS AccountID, FullName, Password FROM dbo.Freelancers WHERE Email = @Email;
  ELSE IF @Role = 'Admin'
    SELECT AdminID AS AccountID, FullName, Password FROM dbo.AdminUsers
    WHERE Email = @Email AND Role IN ('Administrator', 'Platform Manager');
END;
GO
GRANT SELECT ON OBJECT::dbo.vw_PaymentWorkspaceAssignments TO NeuroHirePaymentReviewAppRole;
GRANT SELECT ON OBJECT::dbo.vw_PaymentWorkspaceMilestones TO NeuroHirePaymentReviewAppRole;
GRANT EXECUTE ON OBJECT::dbo.usp_PaymentLoginAccount TO NeuroHirePaymentReviewAppRole;
GO
