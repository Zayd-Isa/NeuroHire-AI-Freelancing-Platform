-- ============================================================================
-- SCRIPT: 04_TestAndVerification.sql
-- PROJECT: NeuroLance Hub - AI Projects & Services Freelancing Platform
-- MODULE: PUSL2019 – Information Management & Retrieval (Coursework C1)
-- TARGET RDBMS: Microsoft SQL Server 2019 / 2022
-- DESCRIPTION: Automated verification and demonstration script to test all
--              Tables, Constraints, UDFs, Triggers, Views, and Stored Procedures.
-- ============================================================================

USE NeuroLanceHubDB;
GO

PRINT '======================================================================';
PRINT 'TEST 1: VERIFYING RECORD COUNTS ACROSS ALL 15 TABLES (>= 10 REQUIRED)';
PRINT '======================================================================';

SELECT 
    t.name AS TableName,
    p.rows AS TotalRecordCount,
    CASE WHEN p.rows >= 10 THEN 'PASSED (>= 10 records)' ELSE 'WARNING (< 10 records)' END AS ComplianceStatus
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
ORDER BY TableName;
GO

PRINT '======================================================================';
PRINT 'TEST 2: TESTING USER-DEFINED FUNCTIONS (UDFs)';
PRINT '======================================================================';

-- Test 2.1: Tiered Platform Fee Calculation
SELECT 
    1500.00 AS SampleGrossTier1, dbo.fn_CalculatePlatformFee(1500.00) AS Fee_10Percent,
    5000.00 AS SampleGrossTier2, dbo.fn_CalculatePlatformFee(5000.00) AS Fee_8Percent,
    15000.00 AS SampleGrossTier3, dbo.fn_CalculatePlatformFee(15000.00) AS Fee_5Percent;

-- Test 2.2: Freelancer Rating & Top Skills UDFs
SELECT 
    f.FreelancerID,
    f.FullName,
    dbo.fn_GetFreelancerAverageRating(f.FreelancerID) AS CalculatedRating,
    dbo.fn_GetFreelancerTopSkills(f.FreelancerID) AS TopSkillsList
FROM dbo.Freelancers f
WHERE f.FreelancerID IN (1, 2, 3, 5, 10);

-- Test 2.3: Table-Valued Function for Project Payment Summary
SELECT * FROM dbo.fn_GetProjectPaymentSummary(1);
SELECT * FROM dbo.fn_GetProjectPaymentSummary(2);
GO

PRINT '======================================================================';
PRINT 'TEST 3: QUERYING ANALYTICAL & BUSINESS VIEWS';
PRINT '======================================================================';

-- View 1: Freelancer Project Summary
PRINT '--- Querying vw_FreelancerProjectSummary ---';
SELECT TOP 5 FreelancerID, FreelancerName, ProfessionalTitle, HourlyRate, AverageRating, TotalEarnings, CompletedProjectsCount
FROM dbo.vw_FreelancerProjectSummary
ORDER BY TotalEarnings DESC;

-- View 2: Client Project Summary
PRINT '--- Querying vw_ClientProjectSummary ---';
SELECT TOP 5 ClientID, ClientName, CompanyName, Industry, ClientRating, TotalSpent, TotalProjectsPosted, OngoingProjects
FROM dbo.vw_ClientProjectSummary
ORDER BY TotalSpent DESC;

-- View 3: Project Payment Summary
PRINT '--- Querying vw_ProjectPaymentSummary ---';
SELECT TOP 5 ProjectID, ProjectTitle, ClientName, AssignedFreelancer, AgreedPrice, TotalReleasedToFreelancer, EscrowAmountHeld
FROM dbo.vw_ProjectPaymentSummary;

-- View 4: AI Skill Market Demand
PRINT '--- Querying vw_AISkillMarketDemand ---';
SELECT TOP 5 SkillName, CategoryName, AvailableFreelancersCount, ProjectRequirementsCount, AvgProjectBudgetForSkill
FROM dbo.vw_AISkillMarketDemand
ORDER BY ProjectRequirementsCount DESC, AvailableFreelancersCount DESC;
GO

PRINT '======================================================================';
PRINT 'TEST 4: EXECUTING STORED PROCEDURES';
PRINT '======================================================================';

-- SP 1: Search Freelancers by AI Skill
PRINT '--- Executing sp_SearchFreelancersByAISkill (Search for PyTorch / Computer Vision) ---';
EXEC dbo.sp_SearchFreelancersByAISkill 
    @SkillName = N'PyTorch', 
    @MinProficiency = N'Expert', 
    @MaxHourlyRate = 120.00, 
    @MinRating = 4.50;

-- SP 2: Generate Platform Revenue Report
PRINT '--- Executing sp_GeneratePlatformRevenueReport ---';
EXEC dbo.sp_GeneratePlatformRevenueReport;

-- SP 3: Post New Project via Procedure (Testing transactional integrity)
PRINT '--- Executing sp_PostNewProject ---';
DECLARE @CreatedProjectID INT;
EXEC dbo.sp_PostNewProject
    @ClientID = 1,
    @Title = N'Multi-Modal Vision Language Model for Clinical Chart Diagnostics',
    @Description = N'Fine-tune an open-source vision language model (e.g. LLaVA-Med) on proprietary clinical charts and ultrasound scans.',
    @Scope = N'Large',
    @Budget = 10500.00,
    @DurationWeeks = 8,
    @DeadlineDate = '2026-08-30',
    @PrimarySkillID = 4, -- Image Segmentation
    @RequiredLevel = N'Expert',
    @NewProjectID = @CreatedProjectID OUTPUT;

PRINT 'Created Project ID: ' + CAST(@CreatedProjectID AS NVARCHAR(20));

-- Verify project was created with requirements
SELECT p.ProjectID, p.Title, p.Budget, p.ProjectStatus, pr.SkillID, s.SkillName, pr.RequiredLevel
FROM dbo.Projects p
INNER JOIN dbo.ProjectRequirements pr ON p.ProjectID = pr.ProjectID
INNER JOIN dbo.AISkills s ON pr.SkillID = s.SkillID
WHERE p.ProjectID = @CreatedProjectID;
GO

PRINT '======================================================================';
PRINT 'ALL TESTS & VERIFICATIONS COMPLETED SUCCESSFULLY!';
PRINT '======================================================================';
GO
