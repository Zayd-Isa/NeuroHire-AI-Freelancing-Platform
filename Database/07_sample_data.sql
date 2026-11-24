-- Repeatable coursework demonstration data for NeuroLanceHubDB.
-- This is synthetic data only. Payments are held demo records; no money moves.
-- Account Password fields contain an unusable marker, not a working password hash.

USE NeuroLanceHubDB;
GO

INSERT INTO dbo.Freelancers
    (FullName, Email, Password, Title, Bio, HourlyRate, ExperienceYears, Country)
SELECT v.FullName, v.Email, 'DEMO_ONLY_NO_LOGIN_HASH', v.Title, v.Bio,
       v.HourlyRate, v.ExperienceYears, v.Country
FROM (VALUES
    ('Asha Perera', 'asha.perera@example.test', 'Machine Learning Engineer', 'Builds practical predictive models.', 48.00, 5, 'Sri Lanka'),
    ('Ravi Fernando', 'ravi.fernando@example.test', 'Computer Vision Specialist', 'Develops image analysis systems.', 52.00, 6, 'Sri Lanka'),
    ('Maya Silva', 'maya.silva@example.test', 'NLP Engineer', 'Creates language tools and assistants.', 45.00, 4, 'India'),
    ('Daniel Cruz', 'daniel.cruz@example.test', 'Data Scientist', 'Turns business data into useful models.', 42.00, 5, 'Philippines'),
    ('Lina Chen', 'lina.chen@example.test', 'Generative AI Developer', 'Builds retrieval and generation workflows.', 60.00, 7, 'Singapore'),
    ('Omar Haddad', 'omar.haddad@example.test', 'MLOps Engineer', 'Deploys reliable machine learning services.', 58.00, 8, 'United Arab Emirates'),
    ('Priya Nair', 'priya.nair@example.test', 'Deep Learning Engineer', 'Works on neural networks and model tuning.', 55.00, 6, 'India'),
    ('Noah Martin', 'noah.martin@example.test', 'AI Data Engineer', 'Builds clean data pipelines for AI teams.', 40.00, 3, 'United Kingdom'),
    ('Sara Kim', 'sara.kim@example.test', 'AI Research Consultant', 'Evaluates models and prepares experiments.', 62.00, 9, 'South Korea'),
    ('Ethan Brooks', 'ethan.brooks@example.test', 'Automation Developer', 'Connects AI models to business workflows.', 44.00, 4, 'Australia')
) AS v(FullName, Email, Title, Bio, HourlyRate, ExperienceYears, Country)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Freelancers AS f WHERE f.Email = v.Email);
GO

INSERT INTO dbo.Clients
    (FullName, Email, Password, CompanyName, Industry, Country, BillingAddress, ContactNumber)
SELECT v.FullName, v.Email, 'DEMO_ONLY_NO_LOGIN_HASH', v.CompanyName, v.Industry,
       v.Country, v.BillingAddress, v.ContactNumber
FROM (VALUES
    ('Nimal Jayasuriya', 'nimal@lankadata.example.test', 'LankaData Labs', 'Technology', 'Sri Lanka', 'Colombo', '+94-11-555-0101'),
    ('Emma Patel', 'emma@brightretail.example.test', 'Bright Retail', 'Retail', 'United Kingdom', 'London', '+44-20-5550-0102'),
    ('Chen Wei', 'chen@mediscope.example.test', 'MediScope', 'Healthcare', 'Singapore', 'Singapore', '+65-5550-0103'),
    ('Fatima Khan', 'fatima@greenroute.example.test', 'GreenRoute', 'Logistics', 'United Arab Emirates', 'Dubai', '+971-4-555-0104'),
    ('Lucas Santos', 'lucas@finwise.example.test', 'FinWise', 'Finance', 'Brazil', 'Sao Paulo', '+55-11-5550-0105'),
    ('Amina Yusuf', 'amina@learnpath.example.test', 'LearnPath', 'Education', 'Kenya', 'Nairobi', '+254-20-555-0106'),
    ('Oliver Reed', 'oliver@factoryflow.example.test', 'FactoryFlow', 'Manufacturing', 'Australia', 'Sydney', '+61-2-5550-0107'),
    ('Isabella Rossi', 'isabella@travelmind.example.test', 'TravelMind', 'Travel', 'Italy', 'Milan', '+39-02-5550-0108'),
    ('Miguel Torres', 'miguel@civicinsights.example.test', 'Civic Insights', 'Public Services', 'Spain', 'Madrid', '+34-91-555-0109'),
    ('Grace Wong', 'grace@mediaforge.example.test', 'MediaForge', 'Media', 'Canada', 'Toronto', '+1-416-555-0110')
) AS v(FullName, Email, CompanyName, Industry, Country, BillingAddress, ContactNumber)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Clients AS c WHERE c.Email = v.Email);
GO

INSERT INTO dbo.SkillCategories (CategoryName, Description)
SELECT v.CategoryName, v.Description
FROM (VALUES
    ('Machine Learning', 'Predictive and statistical learning methods.'),
    ('Deep Learning', 'Neural network design and training.'),
    ('Natural Language Processing', 'Text, language, and conversational systems.'),
    ('Computer Vision', 'Image and video understanding.'),
    ('Generative AI', 'Systems that generate text, images, or other content.'),
    ('Data Analytics', 'Exploration, reporting, and decision support.'),
    ('MLOps', 'Deployment, monitoring, and lifecycle automation.'),
    ('Data Engineering', 'Data ingestion, quality, and transformation.'),
    ('Robotics', 'Perception and intelligent control systems.'),
    ('AI Automation', 'AI-powered business process automation.')
) AS v(CategoryName, Description)
WHERE NOT EXISTS (SELECT 1 FROM dbo.SkillCategories AS c WHERE c.CategoryName = v.CategoryName);
GO

INSERT INTO dbo.AISkills (CategoryID, SkillName, Description)
SELECT c.CategoryID, v.SkillName, v.Description
FROM (VALUES
    ('Machine Learning', 'Python', 'Python programming for model development.'),
    ('Machine Learning', 'Scikit-learn', 'Classical machine learning toolkit.'),
    ('Machine Learning', 'XGBoost', 'Gradient-boosted decision trees.'),
    ('Deep Learning', 'PyTorch', 'Deep learning framework.'),
    ('Deep Learning', 'TensorFlow', 'Machine learning and neural network framework.'),
    ('Natural Language Processing', 'Natural Language Processing', 'Text processing and language modeling.'),
    ('Natural Language Processing', 'spaCy', 'Production-oriented NLP library.'),
    ('Computer Vision', 'OpenCV', 'Image and video processing library.'),
    ('Computer Vision', 'Computer Vision', 'Image classification and detection methods.'),
    ('Generative AI', 'Large Language Models', 'Prompting and integration of language models.'),
    ('Generative AI', 'Retrieval Augmented Generation', 'Grounded generation over source documents.'),
    ('Generative AI', 'Vector Search', 'Similarity search over vector representations.'),
    ('Data Analytics', 'SQL', 'Relational querying and analysis.'),
    ('Data Analytics', 'Power BI', 'Interactive business intelligence reports.'),
    ('MLOps', 'Docker', 'Container packaging and execution.'),
    ('MLOps', 'MLflow', 'Experiment tracking and model lifecycle management.'),
    ('Data Engineering', 'ETL Pipelines', 'Data extraction, transformation, and loading.'),
    ('Data Engineering', 'Apache Airflow', 'Scheduled workflow orchestration.'),
    ('Robotics', 'ROS', 'Robot application development framework.'),
    ('AI Automation', 'Workflow Automation', 'Automation of repeatable business tasks.')
) AS v(CategoryName, SkillName, Description)
INNER JOIN dbo.SkillCategories AS c ON c.CategoryName = v.CategoryName
WHERE NOT EXISTS (SELECT 1 FROM dbo.AISkills AS s WHERE s.SkillName = v.SkillName);
GO

INSERT INTO dbo.FreelancerSkills (FreelancerID, SkillID, ProficiencyLevel, YearsExperience)
SELECT f.FreelancerID, s.SkillID, v.ProficiencyLevel, v.YearsExperience
FROM (VALUES
    ('asha.perera@example.test', 'Python', 'Expert', 5),
    ('asha.perera@example.test', 'Scikit-learn', 'Expert', 4),
    ('ravi.fernando@example.test', 'OpenCV', 'Expert', 6),
    ('ravi.fernando@example.test', 'PyTorch', 'Intermediate', 4),
    ('maya.silva@example.test', 'Natural Language Processing', 'Expert', 4),
    ('maya.silva@example.test', 'spaCy', 'Expert', 3),
    ('daniel.cruz@example.test', 'SQL', 'Expert', 5),
    ('daniel.cruz@example.test', 'XGBoost', 'Intermediate', 3),
    ('lina.chen@example.test', 'Large Language Models', 'Expert', 6),
    ('lina.chen@example.test', 'Retrieval Augmented Generation', 'Expert', 3),
    ('omar.haddad@example.test', 'Docker', 'Expert', 7),
    ('omar.haddad@example.test', 'MLflow', 'Intermediate', 4),
    ('priya.nair@example.test', 'PyTorch', 'Expert', 6),
    ('priya.nair@example.test', 'TensorFlow', 'Intermediate', 4),
    ('noah.martin@example.test', 'ETL Pipelines', 'Expert', 3),
    ('noah.martin@example.test', 'Apache Airflow', 'Intermediate', 2),
    ('sara.kim@example.test', 'Python', 'Expert', 8),
    ('sara.kim@example.test', 'Power BI', 'Intermediate', 2),
    ('ethan.brooks@example.test', 'Workflow Automation', 'Expert', 4),
    ('ethan.brooks@example.test', 'SQL', 'Intermediate', 2)
) AS v(Email, SkillName, ProficiencyLevel, YearsExperience)
INNER JOIN dbo.Freelancers AS f ON f.Email = v.Email
INNER JOIN dbo.AISkills AS s ON s.SkillName = v.SkillName
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.FreelancerSkills AS fs
     WHERE fs.FreelancerID = f.FreelancerID AND fs.SkillID = s.SkillID);
GO

INSERT INTO dbo.AIServices
    (FreelancerID, CategoryID, Title, Description, DeliveryDays, Price, Revisions)
SELECT f.FreelancerID, c.CategoryID, v.Title, v.Description,
       v.DeliveryDays, v.Price, v.Revisions
FROM (VALUES
    ('asha.perera@example.test', 'Machine Learning', 'Customer churn prediction starter', 'Prepare a baseline churn model and evaluation summary.', 10, 1200.00, 2),
    ('ravi.fernando@example.test', 'Computer Vision', 'Image classification prototype', 'Create an image classifier and document its evaluation.', 12, 1500.00, 2),
    ('maya.silva@example.test', 'Natural Language Processing', 'Support ticket text analysis', 'Classify support tickets and summarize common topics.', 10, 1100.00, 2),
    ('daniel.cruz@example.test', 'Data Analytics', 'AI project data report', 'Prepare a clear analysis of a supplied dataset.', 7, 850.00, 1),
    ('lina.chen@example.test', 'Generative AI', 'Document question-answering prototype', 'Build a retrieval-based question-answering demonstration.', 14, 1800.00, 3),
    ('omar.haddad@example.test', 'MLOps', 'Model deployment packaging', 'Package an existing model for repeatable deployment.', 9, 1400.00, 2),
    ('priya.nair@example.test', 'Deep Learning', 'Neural network model review', 'Review training setup and provide improvement notes.', 8, 1250.00, 2),
    ('noah.martin@example.test', 'Data Engineering', 'AI data pipeline setup', 'Create a documented data preparation pipeline.', 11, 1300.00, 2),
    ('sara.kim@example.test', 'Machine Learning', 'Model evaluation consultation', 'Compare model results and recommend next experiments.', 6, 900.00, 1),
    ('ethan.brooks@example.test', 'AI Automation', 'AI workflow integration plan', 'Map and prototype an AI-assisted workflow.', 10, 1000.00, 2)
) AS v(Email, CategoryName, Title, Description, DeliveryDays, Price, Revisions)
INNER JOIN dbo.Freelancers AS f ON f.Email = v.Email
INNER JOIN dbo.SkillCategories AS c ON c.CategoryName = v.CategoryName
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.AIServices AS s
     WHERE s.FreelancerID = f.FreelancerID AND s.Title = v.Title);
GO

INSERT INTO dbo.Projects
    (ClientID, Title, Description, Scope, Budget, DurationWeeks, ProjectStatus, DeadlineDate)
SELECT c.ClientID, v.Title, v.Description, v.Scope, v.Budget, v.DurationWeeks,
       'Open', DATEADD(DAY, v.DurationWeeks * 7, CONVERT(DATE, GETDATE()))
FROM (VALUES
    ('nimal@lankadata.example.test', 'Forecast regional product demand', 'Build a demand forecast prototype from historical sales.', 'Medium', 3200.00, 6),
    ('emma@brightretail.example.test', 'Classify product catalog images', 'Classify supplied product images into catalog categories.', 'Large', 4500.00, 8),
    ('chen@mediscope.example.test', 'Analyze patient feedback themes', 'Find and summarize themes in de-identified patient feedback.', 'Medium', 2800.00, 5),
    ('fatima@greenroute.example.test', 'Predict delivery delays', 'Estimate delivery delay risk from historical route data.', 'Large', 5200.00, 9),
    ('lucas@finwise.example.test', 'Detect unusual account activity', 'Create a proof of concept for anomaly detection.', 'Large', 6000.00, 10),
    ('amina@learnpath.example.test', 'Build course recommendation model', 'Recommend learning materials using course interaction data.', 'Medium', 3600.00, 6),
    ('oliver@factoryflow.example.test', 'Inspect equipment images', 'Prototype visual inspection for supplied equipment images.', 'Large', 4800.00, 8),
    ('isabella@travelmind.example.test', 'Create a travel support assistant', 'Answer travel questions using approved destination documents.', 'Medium', 3900.00, 7),
    ('miguel@civicinsights.example.test', 'Summarize public service requests', 'Group and summarize public service request text.', 'Small', 2100.00, 4),
    ('grace@mediaforge.example.test', 'Tag media library content', 'Suggest searchable tags for a media library sample.', 'Medium', 3400.00, 6)
) AS v(Email, Title, Description, Scope, Budget, DurationWeeks)
INNER JOIN dbo.Clients AS c ON c.Email = v.Email
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.Projects AS p WHERE p.ClientID = c.ClientID AND p.Title = v.Title);
GO

INSERT INTO dbo.ProjectRequirements (ProjectID, SkillID, RequiredLevel)
SELECT p.ProjectID, s.SkillID, v.RequiredLevel
FROM (VALUES
    ('Forecast regional product demand', 'XGBoost', 'Intermediate'),
    ('Classify product catalog images', 'Computer Vision', 'Expert'),
    ('Analyze patient feedback themes', 'Natural Language Processing', 'Intermediate'),
    ('Predict delivery delays', 'Python', 'Intermediate'),
    ('Detect unusual account activity', 'Scikit-learn', 'Expert'),
    ('Build course recommendation model', 'Python', 'Intermediate'),
    ('Inspect equipment images', 'OpenCV', 'Expert'),
    ('Create a travel support assistant', 'Retrieval Augmented Generation', 'Expert'),
    ('Summarize public service requests', 'spaCy', 'Intermediate'),
    ('Tag media library content', 'Large Language Models', 'Intermediate')
) AS v(ProjectTitle, SkillName, RequiredLevel)
INNER JOIN dbo.Projects AS p ON p.Title = v.ProjectTitle
INNER JOIN dbo.AISkills AS s ON s.SkillName = v.SkillName
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.ProjectRequirements AS pr
     WHERE pr.ProjectID = p.ProjectID AND pr.SkillID = s.SkillID);
GO

INSERT INTO dbo.Proposals
    (ProjectID, FreelancerID, CoverLetter, BidAmount, EstimatedDays)
SELECT p.ProjectID, f.FreelancerID, v.CoverLetter, v.BidAmount, v.EstimatedDays
FROM (VALUES
    ('Forecast regional product demand', 'asha.perera@example.test', 'I will prepare a validated demand forecast and explain the assumptions.', 3000.00, 35),
    ('Classify product catalog images', 'ravi.fernando@example.test', 'I will build and evaluate an image classification prototype.', 4300.00, 45),
    ('Analyze patient feedback themes', 'maya.silva@example.test', 'I will clean the text sample and deliver topic and sentiment findings.', 2600.00, 30),
    ('Predict delivery delays', 'daniel.cruz@example.test', 'I will build a baseline delay model and a clear evaluation report.', 5000.00, 50),
    ('Detect unusual account activity', 'lina.chen@example.test', 'I will compare anomaly detection approaches and document results.', 5700.00, 55),
    ('Build course recommendation model', 'omar.haddad@example.test', 'I will create a reproducible recommendation model prototype.', 3400.00, 35),
    ('Inspect equipment images', 'priya.nair@example.test', 'I will train and evaluate an image inspection prototype.', 4500.00, 45),
    ('Create a travel support assistant', 'noah.martin@example.test', 'I will prepare the document data flow and retrieval prototype.', 3700.00, 40),
    ('Summarize public service requests', 'sara.kim@example.test', 'I will group requests and provide reviewable example summaries.', 1950.00, 25),
    ('Tag media library content', 'ethan.brooks@example.test', 'I will prototype consistent AI-assisted media tagging.', 3200.00, 35)
) AS v(ProjectTitle, FreelancerEmail, CoverLetter, BidAmount, EstimatedDays)
INNER JOIN dbo.Projects AS p ON p.Title = v.ProjectTitle
INNER JOIN dbo.Freelancers AS f ON f.Email = v.FreelancerEmail
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.Proposals AS pr
     WHERE pr.ProjectID = p.ProjectID AND pr.FreelancerID = f.FreelancerID);
GO

INSERT INTO dbo.ProjectAssignments
    (ProjectID, ProposalID, FreelancerID, ClientID, AgreedPrice,
     ExpectedCompletionDate, ActualCompletionDate, AssignmentStatus)
SELECT p.ProjectID, pr.ProposalID, f.FreelancerID, c.ClientID,
       pr.BidAmount, DATEADD(DAY, pr.EstimatedDays, CONVERT(DATE, GETDATE())),
       CASE WHEN seed.AssignmentStatus = 'Completed' THEN CONVERT(DATE, GETDATE()) END,
       seed.AssignmentStatus
FROM (VALUES
    ('Forecast regional product demand', 'asha.perera@example.test', 'Completed'),
    ('Classify product catalog images', 'ravi.fernando@example.test', 'Completed'),
    ('Analyze patient feedback themes', 'maya.silva@example.test', 'Completed'),
    ('Predict delivery delays', 'daniel.cruz@example.test', 'Completed'),
    ('Detect unusual account activity', 'lina.chen@example.test', 'Completed'),
    ('Build course recommendation model', 'omar.haddad@example.test', 'In Progress'),
    ('Inspect equipment images', 'priya.nair@example.test', 'In Progress'),
    ('Create a travel support assistant', 'noah.martin@example.test', 'In Progress'),
    ('Summarize public service requests', 'sara.kim@example.test', 'In Progress'),
    ('Tag media library content', 'ethan.brooks@example.test', 'In Progress')
) AS seed(ProjectTitle, FreelancerEmail, AssignmentStatus)
INNER JOIN dbo.Projects AS p ON p.Title = seed.ProjectTitle
INNER JOIN dbo.Proposals AS pr ON pr.ProjectID = p.ProjectID
INNER JOIN dbo.Freelancers AS f ON f.FreelancerID = pr.FreelancerID
    AND f.Email = seed.FreelancerEmail
INNER JOIN dbo.Clients AS c ON c.ClientID = p.ClientID
WHERE NOT EXISTS (SELECT 1 FROM dbo.ProjectAssignments AS pa WHERE pa.ProjectID = p.ProjectID);
GO

INSERT INTO dbo.ProjectMilestones
    (AssignmentID, MilestoneTitle, Description, Amount, DueDate, MilestoneStatus)
SELECT pa.AssignmentID, 'Demonstration delivery', 'Synthetic sample milestone for coursework reporting.',
       pa.AgreedPrice, pa.ExpectedCompletionDate,
       CASE WHEN pa.AssignmentStatus = 'Completed' THEN 'Approved' ELSE 'Pending' END
FROM dbo.ProjectAssignments AS pa
WHERE pa.ProjectID IN
    (SELECT ProjectID FROM dbo.Projects WHERE Title IN
     ('Forecast regional product demand', 'Classify product catalog images',
      'Analyze patient feedback themes', 'Predict delivery delays',
      'Detect unusual account activity', 'Build course recommendation model',
      'Inspect equipment images', 'Create a travel support assistant',
      'Summarize public service requests', 'Tag media library content'))
  AND NOT EXISTS
    (SELECT 1 FROM dbo.ProjectMilestones AS m
     WHERE m.AssignmentID = pa.AssignmentID AND m.MilestoneTitle = 'Demonstration delivery');
GO

INSERT INTO dbo.Payments
    (AssignmentID, MilestoneID, ClientID, FreelancerID, GrossAmount,
     PlatformFee, NetAmount, PaymentMethod, PaymentStatus, TransactionRef, ReleasedDate)
SELECT pa.AssignmentID, m.MilestoneID, pa.ClientID, pa.FreelancerID,
       pa.AgreedPrice, CONVERT(DECIMAL(10,2), ROUND(pa.AgreedPrice * 0.10, 2)),
       CONVERT(DECIMAL(10,2), pa.AgreedPrice - ROUND(pa.AgreedPrice * 0.10, 2)),
       'Demo record only', v.PaymentStatus, v.TransactionRef,
       CASE WHEN v.PaymentStatus = 'Released' THEN GETDATE() END
FROM (VALUES
    ('Forecast regional product demand', 'SEED-NEURO-0001', 'Released'),
    ('Classify product catalog images', 'SEED-NEURO-0002', 'Released'),
    ('Analyze patient feedback themes', 'SEED-NEURO-0003', 'Released'),
    ('Predict delivery delays', 'SEED-NEURO-0004', 'Released'),
    ('Detect unusual account activity', 'SEED-NEURO-0005', 'Released'),
    ('Build course recommendation model', 'SEED-NEURO-0006', 'Held in Escrow'),
    ('Inspect equipment images', 'SEED-NEURO-0007', 'Held in Escrow'),
    ('Create a travel support assistant', 'SEED-NEURO-0008', 'Held in Escrow'),
    ('Summarize public service requests', 'SEED-NEURO-0009', 'Held in Escrow'),
    ('Tag media library content', 'SEED-NEURO-0010', 'Held in Escrow')
) AS v(ProjectTitle, TransactionRef, PaymentStatus)
INNER JOIN dbo.Projects AS p ON p.Title = v.ProjectTitle
INNER JOIN dbo.ProjectAssignments AS pa ON pa.ProjectID = p.ProjectID
INNER JOIN dbo.ProjectMilestones AS m ON m.AssignmentID = pa.AssignmentID
    AND m.MilestoneTitle = 'Demonstration delivery'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Payments AS pay WHERE pay.TransactionRef = v.TransactionRef);
GO

INSERT INTO dbo.Reviews
    (AssignmentID, ReviewerType, ReviewerID, RevieweeID, Rating, Comment)
SELECT pa.AssignmentID, v.ReviewerType,
       CASE WHEN v.ReviewerType = 'ClientToFreelancer' THEN pa.ClientID ELSE pa.FreelancerID END,
       CASE WHEN v.ReviewerType = 'ClientToFreelancer' THEN pa.FreelancerID ELSE pa.ClientID END,
       v.Rating, v.Comment
FROM (VALUES
    ('Forecast regional product demand', 'ClientToFreelancer', 5, 'Clear forecast and useful documentation.'),
    ('Classify product catalog images', 'ClientToFreelancer', 4, 'Good prototype and evaluation.'),
    ('Analyze patient feedback themes', 'ClientToFreelancer', 5, 'Careful handling of the sample data.'),
    ('Predict delivery delays', 'ClientToFreelancer', 4, 'Helpful baseline and readable report.'),
    ('Detect unusual account activity', 'ClientToFreelancer', 5, 'Strong comparison of approaches.')
) AS v(ProjectTitle, ReviewerType, Rating, Comment)
INNER JOIN dbo.Projects AS p ON p.Title = v.ProjectTitle
INNER JOIN dbo.ProjectAssignments AS pa ON pa.ProjectID = p.ProjectID
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.Reviews AS r
     WHERE r.AssignmentID = pa.AssignmentID AND r.ReviewerType = v.ReviewerType);
GO

INSERT INTO dbo.Reviews
    (AssignmentID, ReviewerType, ReviewerID, RevieweeID, Rating, Comment)
SELECT pa.AssignmentID, v.ReviewerType,
       CASE WHEN v.ReviewerType = 'ClientToFreelancer' THEN pa.ClientID ELSE pa.FreelancerID END,
       CASE WHEN v.ReviewerType = 'ClientToFreelancer' THEN pa.FreelancerID ELSE pa.ClientID END,
       v.Rating, v.Comment
FROM (VALUES
    ('Forecast regional product demand', 'FreelancerToClient', 5, 'Requirements and feedback were clear.'),
    ('Classify product catalog images', 'FreelancerToClient', 4, 'Provided useful sample data.'),
    ('Analyze patient feedback themes', 'FreelancerToClient', 5, 'Communicated promptly and clearly.'),
    ('Predict delivery delays', 'FreelancerToClient', 4, 'Scope and expectations were well defined.'),
    ('Detect unusual account activity', 'FreelancerToClient', 5, 'Collaborative review process.')
) AS v(ProjectTitle, ReviewerType, Rating, Comment)
INNER JOIN dbo.Projects AS p ON p.Title = v.ProjectTitle
INNER JOIN dbo.ProjectAssignments AS pa ON pa.ProjectID = p.ProjectID
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.Reviews AS r
     WHERE r.AssignmentID = pa.AssignmentID AND r.ReviewerType = v.ReviewerType);
GO

INSERT INTO dbo.AdminUsers (FullName, Email, Password, Role)
SELECT v.FullName, v.Email, 'DEMO_ONLY_NO_LOGIN_HASH', v.Role
FROM (VALUES
    ('Amara Senanayake', 'admin01@neurolance.example.test', 'Administrator'),
    ('Dilan Peris', 'admin02@neurolance.example.test', 'Platform Manager'),
    ('Kavindi Raj', 'admin03@neurolance.example.test', 'Dispute Officer'),
    ('Rohan Dias', 'admin04@neurolance.example.test', 'Decision Maker'),
    ('Meera Fernando', 'admin05@neurolance.example.test', 'Administrator'),
    ('Sam Lee', 'admin06@neurolance.example.test', 'Platform Manager'),
    ('Farah Ali', 'admin07@neurolance.example.test', 'Dispute Officer'),
    ('Daniel Perera', 'admin08@neurolance.example.test', 'Decision Maker'),
    ('Nadeesha Silva', 'admin09@neurolance.example.test', 'Administrator'),
    ('Kiran Patel', 'admin10@neurolance.example.test', 'Platform Manager')
) AS v(FullName, Email, Role)
WHERE NOT EXISTS (SELECT 1 FROM dbo.AdminUsers AS a WHERE a.Email = v.Email);
GO

INSERT INTO dbo.PlatformDisputes
    (AssignmentID, RaisedByID, RaisedByType, Reason, Description, DisputeStatus)
SELECT pa.AssignmentID, pa.ClientID, 'Client', v.Reason,
       'Synthetic demonstration dispute. No real transaction or person is involved.', 'Open'
FROM (VALUES
    ('Forecast regional product demand', 'Demonstration: delivery timing question'),
    ('Classify product catalog images', 'Demonstration: scope clarification'),
    ('Analyze patient feedback themes', 'Demonstration: review request'),
    ('Predict delivery delays', 'Demonstration: milestone clarification'),
    ('Detect unusual account activity', 'Demonstration: acceptance criteria question'),
    ('Build course recommendation model', 'Demonstration: data format question'),
    ('Inspect equipment images', 'Demonstration: delivery question'),
    ('Create a travel support assistant', 'Demonstration: source document question'),
    ('Summarize public service requests', 'Demonstration: output format question'),
    ('Tag media library content', 'Demonstration: delivery scope question')
) AS v(ProjectTitle, Reason)
INNER JOIN dbo.Projects AS p ON p.Title = v.ProjectTitle
INNER JOIN dbo.ProjectAssignments AS pa ON pa.ProjectID = p.ProjectID
WHERE NOT EXISTS
    (SELECT 1 FROM dbo.PlatformDisputes AS d
     WHERE d.AssignmentID = pa.AssignmentID AND d.Reason = v.Reason);
GO

-- Record counts make it easy to confirm that the repeatable sample load ran.
SELECT N'Freelancers' AS TableName, COUNT_BIG(*) AS RowCount FROM dbo.Freelancers
UNION ALL SELECT N'SkillCategories', COUNT_BIG(*) FROM dbo.SkillCategories
UNION ALL SELECT N'AISkills', COUNT_BIG(*) FROM dbo.AISkills
UNION ALL SELECT N'FreelancerSkills', COUNT_BIG(*) FROM dbo.FreelancerSkills
UNION ALL SELECT N'AIServices', COUNT_BIG(*) FROM dbo.AIServices
UNION ALL SELECT N'Clients', COUNT_BIG(*) FROM dbo.Clients
UNION ALL SELECT N'Projects', COUNT_BIG(*) FROM dbo.Projects
UNION ALL SELECT N'ProjectRequirements', COUNT_BIG(*) FROM dbo.ProjectRequirements
UNION ALL SELECT N'Proposals', COUNT_BIG(*) FROM dbo.Proposals
UNION ALL SELECT N'ProjectAssignments', COUNT_BIG(*) FROM dbo.ProjectAssignments
UNION ALL SELECT N'ProjectMilestones', COUNT_BIG(*) FROM dbo.ProjectMilestones
UNION ALL SELECT N'Payments', COUNT_BIG(*) FROM dbo.Payments
UNION ALL SELECT N'Reviews', COUNT_BIG(*) FROM dbo.Reviews
UNION ALL SELECT N'AdminUsers', COUNT_BIG(*) FROM dbo.AdminUsers
UNION ALL SELECT N'PlatformDisputes', COUNT_BIG(*) FROM dbo.PlatformDisputes
ORDER BY TableName;
GO
