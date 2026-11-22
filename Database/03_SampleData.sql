-- ============================================================================
-- SCRIPT: 03_SampleData.sql
-- PROJECT: NeuroLance Hub - AI Projects & Services Freelancing Platform
-- MODULE: PUSL2019 – Information Management & Retrieval (Coursework C1)
-- TARGET RDBMS: Microsoft SQL Server 2019 / 2022
-- DESCRIPTION: High-quality, meaningful sample dataset for all 15 tables.
--              Every applicable table contains at least 10 realistic AI-domain records.
-- ============================================================================

USE NeuroLanceHubDB;
GO

-- ============================================================================
-- 1. Table: AdminUsers (10 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.AdminUsers ON;
INSERT INTO dbo.AdminUsers (AdminID, FullName, Email, PasswordHash, Role, ContactNumber, IsActive, CreatedAt)
VALUES
(1, N'Dr. Samantha Vance', N'samantha.vance@neurolance.ai', N'HASH_SECURE_ADMIN_VANCE', N'Administrator', N'+44 20 7946 0910', 1, '2026-01-10 08:30:00'),
(2, N'Alexander Wright', N'alex.wright@neurolance.ai', N'HASH_SECURE_ADMIN_WRIGHT', N'Platform Manager', N'+44 20 7946 0911', 1, '2026-01-11 09:15:00'),
(3, N'Kavinda Jayasinghe', N'kavinda.j@neurolance.ai', N'HASH_SECURE_ADMIN_KAVINDA', N'Decision Maker', N'+94 77 123 4567', 1, '2026-01-12 10:00:00'),
(4, N'Elena Rostova', N'elena.rostova@neurolance.ai', N'HASH_SECURE_ADMIN_ELENA', N'Dispute Officer', N'+1 415 555 0142', 1, '2026-01-14 11:20:00'),
(5, N'Tariq Mansoor', N'tariq.m@neurolance.ai', N'HASH_SECURE_ADMIN_TARIQ', N'Platform Manager', N'+971 4 312 8900', 1, '2026-01-15 14:00:00'),
(6, N'Mei-Ling Zhou', N'mei.zhou@neurolance.ai', N'HASH_SECURE_ADMIN_MEI', N'Dispute Officer', N'+65 6789 0123', 1, '2026-01-18 09:40:00'),
(7, N'Carlos Mendez', N'carlos.m@neurolance.ai', N'HASH_SECURE_ADMIN_CARLOS', N'Administrator', N'+34 91 123 4567', 1, '2026-01-20 16:10:00'),
(8, N'Amara Okafor', N'amara.o@neurolance.ai', N'HASH_SECURE_ADMIN_AMARA', N'Decision Maker', N'+234 1 234 5678', 1, '2026-01-22 13:25:00'),
(9, N'Lucas Schmidt', N'lucas.s@neurolance.ai', N'HASH_SECURE_ADMIN_LUCAS', N'Dispute Officer', N'+49 30 1234567', 1, '2026-01-25 10:50:00'),
(10, N'Sarah Jenkins', N'sarah.j@neurolance.ai', N'HASH_SECURE_ADMIN_SARAH', N'Decision Maker', N'+1 212 555 0199', 1, '2026-01-28 15:30:00');
SET IDENTITY_INSERT dbo.AdminUsers OFF;
GO

-- ============================================================================
-- 2. Table: Clients (10 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.Clients ON;
INSERT INTO dbo.Clients (ClientID, FullName, Email, PasswordHash, CompanyName, Industry, Country, BillingAddress, ContactNumber, TotalSpent, ClientRating, IsActive, CreatedAt)
VALUES
(1, N'Julian Sterling', N'jsterling@biomedvision.io', N'HASH_CLIENT_01', N'BioMed Vision AI', N'Healthcare & Life Sciences', N'United Kingdom', N'72 Harley St, London W1G 7HJ', N'+44 20 7111 0001', 0.00, 5.00, 1, '2026-02-01 09:00:00'),
(2, N'Claire Montclair', N'claire@fintechcognition.com', N'HASH_CLIENT_02', N'FinTech Cognition Inc', N'Financial Technology', N'United States', N'100 Wall Street, New York, NY 10005', N'+1 212 555 1002', 0.00, 4.90, 1, '2026-02-03 10:15:00'),
(3, N'Vikram Singhania', N'vikram@neuroretail.in', N'HASH_CLIENT_03', N'NeuroRetail Systems', N'E-Commerce & Retail', N'India', N'45 MG Road, Bengaluru, Karnataka 560001', N'+91 80 4123 4567', 0.00, 4.85, 1, '2026-02-05 11:30:00'),
(4, N'Sophie Dubois', N'sophie@autonomobility.fr', N'HASH_CLIENT_04', N'AutonoMobility Robotics', N'Automotive & Robotics', N'France', N'12 Rue de la Paix, 75002 Paris', N'+33 1 42 68 55 00', 0.00, 5.00, 1, '2026-02-08 14:00:00'),
(5, N'Kenji Takahashi', N'kenji@omnispeak.jp', N'HASH_CLIENT_05', N'OmniSpeak NLP Technologies', N'Conversational AI', N'Japan', N'1-1 Chiyoda, Tokyo 100-8111', N'+81 3 3214 0001', 0.00, 4.75, 1, '2026-02-10 16:45:00'),
(6, N'Lars Lindqvist', N'lars@nordicagri.se', N'HASH_CLIENT_06', N'Nordic AgriSense Labs', N'Smart Agriculture', N'Sweden', N'Kungsgatan 44, 111 35 Stockholm', N'+46 8 123 45 67', 0.00, 5.00, 1, '2026-02-12 08:30:00'),
(7, N'Hassan Al-Fayez', N'hassan@desertsmart.ae', N'HASH_CLIENT_07', N'DesertSmart Grid AI', N'Energy & Utilities', N'United Arab Emirates', N'Sheikh Zayed Rd, Dubai', N'+971 4 222 3344', 0.00, 4.95, 1, '2026-02-15 13:10:00'),
(8, N'Chloe Campbell', N'chloe@eduaipath.ca', N'HASH_CLIENT_08', N'EduAI Learning Pathways', N'EdTech', N'Canada', N'250 Yonge St, Toronto, ON M5B 2L7', N'+1 416 555 9876', 0.00, 4.80, 1, '2026-02-18 10:20:00'),
(9, N'Dmitri Volkov', N'dmitri@cyberguardai.ch', N'HASH_CLIENT_09', N'CyberGuard AI Defense', N'Cybersecurity', N'Switzerland', N'Bahnhofstrasse 10, 8001 Zurich', N'+41 44 211 0011', 0.00, 5.00, 1, '2026-02-20 15:50:00'),
(10, N'Isabella Rossi', N'isabella@luxuryaigen.it', N'HASH_CLIENT_10', N'ModaGen AI Studios', N'Creative & Fashion Tech', N'Italy', N'Via Montenapoleone 8, 20121 Milano', N'+39 02 7600 1234', 0.00, 4.90, 1, '2026-02-22 17:00:00');
SET IDENTITY_INSERT dbo.Clients OFF;
GO

-- ============================================================================
-- 3. Table: Freelancers (10 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.Freelancers ON;
INSERT INTO dbo.Freelancers (FreelancerID, FullName, Email, PasswordHash, ProfessionalTitle, Bio, HourlyRate, YearsOfExperience, Country, TotalEarnings, AverageRating, CompletedProjectsCount, AvailabilityStatus, IsActive, CreatedAt)
VALUES
(1, N'Dr. Ethan Cole', N'ethan.cole@freelance.ai', N'HASH_FREE_01', N'Principal Generative AI & LLM Architect', N'Ex-DeepMind contributor specialising in Large Language Model fine-tuning, RLHF, and enterprise RAG pipelines.', 95.00, 9, N'United Kingdom', 0.00, 5.00, 0, N'Available', 1, '2026-02-01 10:00:00'),
(2, N'Aarav Sharma', N'aarav.sharma@freelance.ai', N'HASH_FREE_02', N'Senior Computer Vision & Edge AI Engineer', N'Expert in real-time object detection (YOLOv8/v10), PyTorch, TensorRT, and embedded robotics deployments.', 80.00, 7, N'India', 0.00, 4.90, 0, N'Available', 1, '2026-02-02 11:30:00'),
(3, N'Hannah Mueller', N'hannah.mueller@freelance.ai', N'HASH_FREE_03', N'NLP & Speech Technology Specialist', N'PhD in Computational Linguistics. Focus on Transformer architectures, Whisper fine-tuning, and multilingual NER.', 85.00, 8, N'Germany', 0.00, 4.95, 0, N'Available', 1, '2026-02-04 09:15:00'),
(4, N'David Zhang', N'david.zhang@freelance.ai', N'HASH_FREE_04', N'Lead MLOps & Distributed Deep Learning Engineer', N'Specialist in Kubeflow, MLflow, Triton Inference Server, distributed GPU training, and cloud scale pipelines.', 90.00, 6, N'United States', 0.00, 4.85, 0, N'Available', 1, '2026-02-06 14:00:00'),
(5, N'Fatima Zahra', N'fatima.zahra@freelance.ai', N'HASH_FREE_05', N'Healthcare AI & Medical Imaging Researcher', N'Experience in 3D CT/MRI segmentation, UNet, MONAI, and HIPAA-compliant predictive diagnostic models.', 75.00, 5, N'Morocco', 0.00, 5.00, 0, N'Available', 1, '2026-02-08 16:30:00'),
(6, N'Mateo Fernandez', N'mateo.f@freelance.ai', N'HASH_FREE_06', N'Reinforcement Learning & Quantitative AI Specialist', N'Developing algorithmic decision systems, Deep Q-Networks, and financial time-series forecasting models.', 110.00, 8, N'Spain', 0.00, 4.80, 0, N'Available', 1, '2026-02-10 12:00:00'),
(7, N'Amina Al-Nuaimi', N'amina.nuaimi@freelance.ai', N'HASH_FREE_07', N'Diffusion Models & Generative Media Developer', N'Specialist in Stable Diffusion XL LoRA training, ControlNet, ComfyUI workflows, and 3D NeRF generation.', 70.00, 4, N'United Arab Emirates', 0.00, 4.90, 0, N'Available', 1, '2026-02-12 15:45:00'),
(8, N'Liam O''Connor', N'liam.oconnor@freelance.ai', N'HASH_FREE_08', N'Data Analytics & Predictive Modeling Scientist', N'Expert in tabular machine learning, XGBoost, LightGBM, customer churn forecasting, and Tableau visualization.', 65.00, 6, N'Ireland', 0.00, 4.75, 0, N'Available', 1, '2026-02-14 10:10:00'),
(9, N'Min-Soo Park', N'minsoo.park@freelance.ai', N'HASH_FREE_09', N'Autonomous Perception & LiDAR Fusion Engineer', N'Autonomous vehicle sensor fusion, point cloud processing, ROS 2, and Kalman filter localization.', 85.00, 7, N'South Korea', 0.00, 5.00, 0, N'Available', 1, '2026-02-16 11:50:00'),
(10, N'Jessica Taylor', N'jessica.taylor@freelance.ai', N'HASH_FREE_10', N'AI Safety, Alignment & Red-Teaming Consultant', N'Evaluating LLM vulnerability, prompt injection mitigation, red-teaming guardrails, and compliance audits.', 95.00, 6, N'Canada', 0.00, 5.00, 0, N'Available', 1, '2026-02-18 13:20:00');
SET IDENTITY_INSERT dbo.Freelancers OFF;
GO

-- ============================================================================
-- 4. Table: SkillCategories (10 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.SkillCategories ON;
INSERT INTO dbo.SkillCategories (CategoryID, CategoryName, Description, CreatedAt)
VALUES
(1, N'Generative AI & LLMs', N'Large language models, prompt engineering, RAG, and foundation model alignment.', '2026-01-01 00:00:00'),
(2, N'Computer Vision', N'Image processing, object detection, semantic segmentation, and optical flow.', '2026-01-01 00:00:00'),
(3, N'Natural Language Processing', N'Speech synthesis, conversational agents, entity extraction, and machine translation.', '2026-01-01 00:00:00'),
(4, N'MLOps & Cloud AI Infrastructure', N'Production AI pipelines, model registry, monitoring, scaling, and containerization.', '2026-01-01 00:00:00'),
(5, N'Deep Learning Frameworks', N'Underlying tensor engines, backpropagation optimizations, and neural architectures.', '2026-01-01 00:00:00'),
(6, N'Data Analytics & Predictive AI', N'Statistical learning, regression, classification, and business intelligence.', '2026-01-01 00:00:00'),
(7, N'Reinforcement Learning', N'Policy gradients, reward modeling, multi-agent systems, and simulation environments.', '2026-01-01 00:00:00'),
(8, N'Audio & Speech AI', N'Speech-to-text, acoustic modeling, voice cloning, and audio source separation.', '2026-01-01 00:00:00'),
(9, N'Edge AI & Embedded Systems', N'Model quantization, pruning, ONNX, and micro-controller neural acceleration.', '2026-01-01 00:00:00'),
(10, N'AI Ethics & Cybersecurity', N'Adversarial robustness, bias evaluation, red-teaming, and model governance.', '2026-01-01 00:00:00');
SET IDENTITY_INSERT dbo.SkillCategories OFF;
GO

-- ============================================================================
-- 5. Table: AISkills (15 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.AISkills ON;
INSERT INTO dbo.AISkills (SkillID, CategoryID, SkillName, Description, CreatedAt)
VALUES
(1, 1, N'RAG Architecture & LangChain', N'Designing Retrieval-Augmented Generation workflows using vector stores and orchestrators.', '2026-01-05 00:00:00'),
(2, 1, N'LLM Fine-Tuning (LoRA / QLoRA)', N'Parameter-efficient fine-tuning of Llama 3, Mistral, and DeepSeek models on custom data.', '2026-01-05 00:00:00'),
(3, 2, N'YOLO Object Detection (v8/v10)', N'High-accuracy real-time object detection and instance segmentation models.', '2026-01-05 00:00:00'),
(4, 2, N'Image Segmentation (UNet / SAM)', N'Segment Anything Model and pixel-level diagnostic medical or satellite segmentation.', '2026-01-05 00:00:00'),
(5, 3, N'Transformers & Hugging Face', N'Tokenization, attention mechanisms, BERT, and sequence classification pipelines.', '2026-01-05 00:00:00'),
(6, 4, N'MLflow & Model Governance', N'Experiment tracking, artifact logging, model versioning, and staging promotion.', '2026-01-05 00:00:00'),
(7, 4, N'Kubeflow & Docker Containerization', N'Building reproducible cloud-native Kubernetes machine learning workflows.', '2026-01-05 00:00:00'),
(8, 5, N'PyTorch', N'Dynamic computational graph engineering and custom neural network implementation.', '2026-01-05 00:00:00'),
(9, 5, N'TensorFlow / Keras', N'End-to-end open source platform for machine learning and graph compilation.', '2026-01-05 00:00:00'),
(10, 6, N'Predictive Modeling (XGBoost / CatBoost)', N'Gradient boosting on decision trees for high-dimensional tabular datasets.', '2026-01-05 00:00:00'),
(11, 7, N'Deep Q-Networks & PPO', N'Proximal Policy Optimization and reinforcement learning agent training.', '2026-01-05 00:00:00'),
(12, 8, N'OpenAI Whisper Speech-to-Text', N'Robust automatic speech recognition and timestamped audio transcription.', '2026-01-05 00:00:00'),
(13, 9, N'TensorRT & Model Quantization (INT8)', N'High-throughput deep learning inference optimization for NVIDIA hardware.', '2026-01-05 00:00:00'),
(14, 10, N'LLM Red-Teaming & Guardrails', N'Defending generative models against jailbreaks, prompt leaks, and toxic outputs.', '2026-01-05 00:00:00'),
(15, 1, N'Vector Databases (Milvus / Pinecone / Chroma)', N'Indexing high-dimensional embeddings for low-latency similarity search.', '2026-01-05 00:00:00');
SET IDENTITY_INSERT dbo.AISkills OFF;
GO

-- ============================================================================
-- 6. Table: FreelancerSkills (25 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.FreelancerSkills ON;
INSERT INTO dbo.FreelancerSkills (FreelancerSkillID, FreelancerID, SkillID, ProficiencyLevel, YearsExperience, AcquiredAt)
VALUES
(1, 1, 1, N'Expert', 5, '2021-06-01'),
(2, 1, 2, N'Expert', 4, '2022-01-15'),
(3, 1, 15, N'Expert', 4, '2022-03-20'),
(4, 2, 3, N'Expert', 6, '2020-04-10'),
(5, 2, 8, N'Expert', 7, '2019-02-15'),
(6, 2, 13, N'Intermediate', 3, '2023-01-10'),
(7, 3, 5, N'Expert', 8, '2018-09-01'),
(8, 3, 12, N'Expert', 4, '2022-10-01'),
(9, 3, 8, N'Intermediate', 5, '2021-05-12'),
(10, 4, 6, N'Expert', 6, '2020-08-15'),
(11, 4, 7, N'Expert', 5, '2021-02-20'),
(12, 4, 13, N'Expert', 4, '2022-06-18'),
(13, 5, 4, N'Expert', 5, '2021-01-10'),
(14, 5, 8, N'Expert', 5, '2021-03-15'),
(15, 6, 11, N'Expert', 6, '2020-11-05'),
(16, 6, 8, N'Expert', 7, '2019-06-01'),
(17, 7, 1, N'Intermediate', 3, '2023-04-10'),
(18, 7, 8, N'Intermediate', 4, '2022-08-20'),
(19, 8, 10, N'Expert', 6, '2020-05-14'),
(20, 8, 9, N'Intermediate', 5, '2021-07-22'),
(21, 9, 3, N'Expert', 6, '2020-03-12'),
(22, 9, 13, N'Expert', 5, '2021-09-10'),
(23, 10, 14, N'Expert', 5, '2021-12-01'),
(24, 10, 1, N'Intermediate', 3, '2023-02-15'),
(25, 10, 2, N'Intermediate', 3, '2023-05-10');
SET IDENTITY_INSERT dbo.FreelancerSkills OFF;
GO

-- ============================================================================
-- 7. Table: AIServices (12 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.AIServices ON;
INSERT INTO dbo.AIServices (ServiceID, FreelancerID, CategoryID, ServiceTitle, Description, DeliveryDays, StartingPrice, RevisionsIncluded, IsActive, CreatedAt)
VALUES
(1, 1, 1, N'Enterprise RAG Pipeline Setup', N'Turnkey production Retrieval-Augmented Generation pipeline using LangChain, Pinecone, and custom chunking strategies.', 14, 3500.00, 2, 1, '2026-02-10 10:00:00'),
(2, 1, 1, N'Open-Source LLM Fine-Tuning (QLoRA)', N'Domain adaptation of Llama 3 or Mistral on your proprietary dataset with benchmarking.', 10, 2800.00, 2, 1, '2026-02-11 11:30:00'),
(3, 2, 2, N'Custom YOLOv8 Object Detection Model', N'Dataset annotation auditing, model training, accuracy evaluation (mAP50-95), and ONNX export.', 7, 1800.00, 3, 1, '2026-02-12 14:00:00'),
(4, 2, 9, N'Edge AI TensorRT Engine Optimization', N'Quantize FP32 PyTorch models to INT8/FP16 for deployment on NVIDIA Jetson or T4 servers.', 5, 1500.00, 1, 1, '2026-02-13 16:15:00'),
(5, 3, 3, N'Multilingual Sentiment & Entity Extraction Engine', N'Custom transformer sequence tagging pipeline tuned for financial and legal reports.', 8, 2200.00, 2, 1, '2026-02-14 09:30:00'),
(6, 3, 8, N'Audio Transcription & Diarization Pipeline', N'Whisper fine-tuning with speaker diarization for noisy call center recordings.', 12, 2600.00, 2, 1, '2026-02-15 13:00:00'),
(7, 4, 4, N'Automated MLOps Pipeline Setup with MLflow', N'Complete CI/CD for machine learning: automated training triggers, registry, and drift detection.', 14, 4000.00, 2, 1, '2026-02-16 10:45:00'),
(8, 5, 2, N'Medical Image Segmentation Model (UNet / MONAI)', N'High-precision pixel segmentation for medical ultrasound and radiographic scans.', 20, 5000.00, 3, 1, '2026-02-17 12:20:00'),
(9, 6, 7, N'Reinforcement Learning Trading Agent Prototype', N'Custom Gym environment modeling, policy evaluation, and backtesting on market data.', 21, 6000.00, 2, 1, '2026-02-18 15:10:00'),
(10, 8, 6, N'Customer Churn & Lifetime Value Predictor', N'End-to-end tabular predictive modeling using XGBoost with SHAP explainability dashboard.', 10, 2400.00, 2, 1, '2026-02-19 11:00:00'),
(11, 9, 2, N'Autonomous Vehicle Point Cloud Perception Pipeline', N'LiDAR 3D bounding box detection and sensor fusion module ready for ROS 2 integration.', 25, 7500.00, 3, 1, '2026-02-20 16:30:00'),
(12, 10, 10, N'LLM Security Audit & Red-Teaming Report', N'Systematic adversarial testing, prompt injection fuzzing, and compliance mitigation guide.', 7, 3200.00, 1, 1, '2026-02-21 14:00:00');
SET IDENTITY_INSERT dbo.AIServices OFF;
GO

-- ============================================================================
-- 8. Table: Projects (12 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.Projects ON;
INSERT INTO dbo.Projects (ProjectID, ClientID, Title, Description, Scope, Budget, DurationWeeks, ProjectStatus, DeadlineDate, CreatedAt)
VALUES
(1, 1, N'Automated Pathology Slide Segmentation Engine', N'Build and validate a deep learning model to segment cancerous tissue boundaries from gigapixel whole-slide images.', N'Large', 9500.00, 8, N'Open', '2026-06-30', '2026-02-20 09:00:00'),
(2, 2, N'Financial Regulatory Compliance RAG Assistant', N'Develop an internal enterprise RAG system to answer complex compliance queries across 20,000 regulatory PDF filings.', N'Large', 8000.00, 6, N'Open', '2026-05-15', '2026-02-21 10:30:00'),
(3, 3, N'In-Store Retail Shelf Inventory Scanner (Edge AI)', N'Deploy a lightweight real-time object detection model on edge cameras to detect out-of-stock items on supermarket shelves.', N'Medium', 4500.00, 4, N'Open', '2026-04-20', '2026-02-22 11:15:00'),
(4, 4, N'Autonomous Delivery Robot Sensor Fusion Module', N'Integrate LiDAR point clouds and stereo camera streams for real-time obstacle avoidance in dynamic pedestrian pathways.', N'Large', 12000.00, 10, N'Open', '2026-07-31', '2026-02-23 13:45:00'),
(5, 5, N'Real-Time Multilingual Customer Support Audio AI', N'Fine-tune Whisper models for accented speech transcription and integrate low-latency sentiment scoring.', N'Medium', 5000.00, 5, N'Open', '2026-05-01', '2026-02-24 14:20:00'),
(6, 6, N'Satellite Crop Disease & Yield Estimation Model', N'Analyze multispectral Sentinel-2 satellite imagery to detect early blight in wheat fields across Scandinavia.', N'Medium', 6000.00, 6, N'Open', '2026-06-15', '2026-02-25 09:10:00'),
(7, 7, N'Smart Grid Predictive Energy Demand Forecasting', N'Implement XGBoost and LSTM models to forecast hourly peak electricity consumption for solar-powered microgrids.', N'Medium', 5500.00, 5, N'Open', '2026-05-30', '2026-02-26 15:00:00'),
(8, 8, N'Adaptive Learning Content Recommendation System', N'Build a collaborative filtering and embedding-based recommendation engine for individualized student curriculum paths.', N'Small', 3000.00, 3, N'Open', '2026-04-10', '2026-02-27 10:40:00'),
(9, 9, N'Adversarial LLM Guardrail & Red-Teaming Suite', N'Stress-test our internal coding co-pilot to identify prompt leaks, security flaws, and enforce strict system bounds.', N'Small', 3800.00, 3, N'Open', '2026-04-15', '2026-02-28 12:00:00'),
(10, 10, N'Virtual Garment Try-On Diffusion Pipeline', N'Develop high-fidelity image conditioning workflows using Stable Diffusion and ControlNet for fashion e-commerce.', N'Large', 8500.00, 8, N'Open', '2026-07-15', '2026-03-01 16:20:00'),
(11, 2, N'Algorithmic High-Frequency Arbitrage Policy', N'Train a Deep Q-Network on order book dynamics to optimize execution slippage across multiple currency corridors.', N'Large', 11000.00, 8, N'Open', '2026-06-25', '2026-03-02 11:30:00'),
(12, 1, N'Clinical Trial Patient-Matching NLP Pipeline', N'Extract inclusion/exclusion criteria from medical notes and cross-match against active oncology clinical trials.', N'Medium', 6500.00, 5, N'Open', '2026-05-20', '2026-03-03 14:15:00');
SET IDENTITY_INSERT dbo.Projects OFF;
GO

-- ============================================================================
-- 9. Table: ProjectRequirements (25 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.ProjectRequirements ON;
INSERT INTO dbo.ProjectRequirements (ProjectRequirementID, ProjectID, SkillID, RequiredLevel)
VALUES
(1, 1, 4, N'Expert'),
(2, 1, 8, N'Expert'),
(3, 2, 1, N'Expert'),
(4, 2, 15, N'Expert'),
(5, 2, 2, N'Intermediate'),
(6, 3, 3, N'Expert'),
(7, 3, 13, N'Intermediate'),
(8, 4, 3, N'Expert'),
(9, 4, 13, N'Expert'),
(10, 4, 8, N'Expert'),
(11, 5, 12, N'Expert'),
(12, 5, 5, N'Intermediate'),
(13, 6, 4, N'Intermediate'),
(14, 6, 8, N'Intermediate'),
(15, 7, 10, N'Expert'),
(16, 7, 6, N'Intermediate'),
(17, 8, 10, N'Intermediate'),
(18, 8, 15, N'Beginner'),
(19, 9, 14, N'Expert'),
(20, 9, 1, N'Intermediate'),
(21, 10, 8, N'Expert'),
(22, 10, 1, N'Intermediate'),
(23, 11, 11, N'Expert'),
(24, 11, 8, N'Expert'),
(25, 12, 5, N'Expert');
SET IDENTITY_INSERT dbo.ProjectRequirements OFF;
GO

-- ============================================================================
-- 10. Table: Proposals (20 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.Proposals ON;
INSERT INTO dbo.Proposals (ProposalID, ProjectID, FreelancerID, CoverLetter, BidAmount, EstimatedDays, ProposalStatus, SubmittedAt)
VALUES
(1, 1, 5, N'I have 5 years of medical imaging experience with MONAI and UNet on histopathology gigapixel images. Ready to begin immediately.', 9200.00, 50, N'Pending', '2026-02-21 10:00:00'),
(2, 1, 2, N'Experienced in deep learning segmentation models. Can deliver high mAP with PyTorch implementation.', 9500.00, 55, N'Pending', '2026-02-22 14:30:00'),
(3, 2, 1, N'Specialist in production RAG systems with LangChain and vector stores. Handled similar scale compliance systems.', 7800.00, 38, N'Pending', '2026-02-22 11:00:00'),
(4, 2, 10, N'Will build the RAG architecture with built-in hallucination guardrails and security auditing.', 8000.00, 42, N'Pending', '2026-02-23 09:15:00'),
(5, 3, 2, N'Trained numerous YOLO models with TensorRT optimization for retail camera feeds. Fast turnaround guaranteed.', 4200.00, 25, N'Pending', '2026-02-23 15:00:00'),
(6, 3, 9, N'Extensive edge AI perception background. Can optimize for low-power edge gateways.', 4500.00, 28, N'Pending', '2026-02-24 10:20:00'),
(7, 4, 9, N'Perception and sensor fusion is my core engineering focus. Will deliver ROS 2 ready LiDAR-camera fusion.', 11500.00, 65, N'Pending', '2026-02-24 16:00:00'),
(8, 4, 2, N'Can build the visual detection component and assist with sensor synchronization.', 12000.00, 70, N'Pending', '2026-02-25 11:45:00'),
(9, 5, 3, N'PhD computational linguist with extensive Whisper fine-tuning and streaming acoustic modeling experience.', 4800.00, 32, N'Pending', '2026-02-25 14:10:00'),
(10, 6, 5, N'Satellite multispectral segmentation is very similar to multi-channel medical imaging. Can deliver robust UNet models.', 5800.00, 38, N'Pending', '2026-02-26 13:00:00'),
(11, 7, 8, N'Specialized in time-series predictive modeling using XGBoost with extensive energy domain datasets.', 5200.00, 30, N'Pending', '2026-02-27 09:30:00'),
(12, 7, 6, N'Can apply reinforcement learning & predictive models to dynamically balance demand spikes.', 5500.00, 35, N'Pending', '2026-02-27 16:40:00'),
(13, 8, 8, N'Experience building collaborative filtering recommender systems with fast response times.', 2900.00, 18, N'Pending', '2026-02-28 11:15:00'),
(14, 9, 10, N'Industry standard LLM red-teaming, jailbreak evaluation, and OWASP Top 10 for LLMs compliance test suite.', 3600.00, 18, N'Pending', '2026-03-01 10:00:00'),
(15, 9, 1, N'Can conduct architectural security reviews and implement semantic firewall layers.', 3800.00, 20, N'Pending', '2026-03-01 15:30:00'),
(16, 10, 7, N'Specialist in LoRA, ControlNet pose conditioning, and high-fidelity photorealistic clothing synthesis.', 8200.00, 50, N'Pending', '2026-03-02 12:45:00'),
(17, 11, 6, N'Deep Q-Network and Actor-Critic algorithm engineering for quantitative order execution.', 10500.00, 52, N'Pending', '2026-03-03 10:20:00'),
(18, 12, 3, N'Clinical trial NLP entity recognition and ontology linking using BioBERT models.', 6200.00, 32, N'Pending', '2026-03-04 11:00:00'),
(19, 12, 1, N'Can deploy a secure LLM semantic extraction pipeline with medical ontology lookup.', 6500.00, 35, N'Pending', '2026-03-04 14:50:00'),
(20, 3, 4, N'Can build the complete MLOps packaging and automated retraining pipeline for edge retail cameras.', 4400.00, 26, N'Pending', '2026-02-25 09:00:00');
SET IDENTITY_INSERT dbo.Proposals OFF;
GO

-- ============================================================================
-- 11. Table: ProjectAssignments (10 Records - Creating via Stored Procedure or Direct Insert)
-- ============================================================================
-- Note: Direct insert with trigger active will automatically update Project status to 'Assigned',
-- Proposal status to 'Accepted', and other proposals to 'Rejected'!
SET IDENTITY_INSERT dbo.ProjectAssignments ON;
INSERT INTO dbo.ProjectAssignments (AssignmentID, ProjectID, ProposalID, FreelancerID, ClientID, AgreedPrice, StartDate, ExpectedCompletionDate, ActualCompletionDate, AssignmentStatus)
VALUES
(1, 1, 1, 5, 1, 9200.00, '2026-02-25 10:00:00', '2026-04-20', NULL, N'Active'),
(2, 2, 3, 1, 2, 7800.00, '2026-02-26 11:30:00', '2026-04-10', NULL, N'Active'),
(3, 3, 5, 2, 3, 4200.00, '2026-02-27 09:00:00', '2026-03-25', NULL, N'Active'),
(4, 4, 7, 9, 4, 11500.00, '2026-02-28 14:00:00', '2026-05-10', NULL, N'Active'),
(5, 5, 9, 3, 5, 4800.00, '2026-03-01 10:15:00', '2026-04-05', NULL, N'Active'),
(6, 6, 10, 5, 6, 5800.00, '2026-03-02 13:00:00', '2026-04-15', NULL, N'Active'),
(7, 7, 11, 8, 7, 5200.00, '2026-03-03 11:00:00', '2026-04-08', NULL, N'Active'),
(8, 8, 13, 8, 8, 2900.00, '2026-03-04 15:30:00', '2026-03-25', NULL, N'Active'),
(9, 9, 14, 10, 9, 3600.00, '2026-03-05 10:00:00', '2026-03-28', NULL, N'Active'),
(10, 10, 16, 7, 10, 8200.00, '2026-03-06 14:20:00', '2026-05-01', NULL, N'Active');
SET IDENTITY_INSERT dbo.ProjectAssignments OFF;
GO

-- ============================================================================
-- 12. Table: ProjectMilestones (15 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.ProjectMilestones ON;
INSERT INTO dbo.ProjectMilestones (MilestoneID, AssignmentID, MilestoneTitle, Description, Amount, DueDate, MilestoneStatus, CreatedAt)
VALUES
(1, 1, N'Milestone 1: Data Preprocessing & Annotation Quality Review', N'Filter Whole Slide Images, extract tissue patches, and build normalization pipeline.', 3000.00, '2026-03-15', N'Approved', '2026-02-25 10:05:00'),
(2, 1, N'Milestone 2: Model Architecture & Training Validation', N'Train UNet/MONAI segmentation model reaching baseline Dice score > 0.85.', 3500.00, '2026-04-05', N'In Progress', '2026-02-25 10:05:00'),
(3, 1, N'Milestone 3: Final Deployment & Documentation', N'Deliver Docker container with inference pipeline and technical validation report.', 2700.00, '2026-04-20', N'Pending', '2026-02-25 10:05:00'),
(4, 2, N'Milestone 1: Document Ingestion & Chunking Architecture', N'Parse 20k PDF files, generate embeddings, and populate Pinecone vector database.', 3800.00, '2026-03-18', N'Approved', '2026-02-26 11:35:00'),
(5, 2, N'Milestone 2: RAG Orchestration & Guardrail Tuning', N'Integrate LangChain query chain, citations, and evaluation metrics.', 4000.00, '2026-04-10', N'In Progress', '2026-02-26 11:35:00'),
(6, 3, N'Milestone 1: Custom Dataset Training & Validation', N'Train YOLOv8 on shelf products and evaluate mAP@50.', 2100.00, '2026-03-12', N'Approved', '2026-02-27 09:10:00'),
(7, 3, N'Milestone 2: Edge TensorRT Optimization & Delivery', N'Export to INT8 TensorRT engine running at >30 FPS on Jetson Xavier.', 2100.00, '2026-03-25', N'In Progress', '2026-02-27 09:10:00'),
(8, 4, N'Milestone 1: LiDAR-Camera Calibration & Sync', N'Establish intrinsic/extrinsic sensor calibration and timing synchronization.', 5000.00, '2026-03-30', N'In Progress', '2026-02-28 14:10:00'),
(9, 4, N'Milestone 2: 3D Bounding Box Obstacle Fusion', N'Sensor fusion Kalman filter tracking and ROS 2 obstacle avoidance message nodes.', 6500.00, '2026-05-10', N'Pending', '2026-02-28 14:10:00'),
(10, 5, N'Milestone 1: Whisper Fine-Tuning & Evaluation', N'Acoustic adaptation on client accented call dataset with WER < 7%.', 2400.00, '2026-03-20', N'Approved', '2026-03-01 10:20:00'),
(11, 5, N'Milestone 2: Streaming Deployment & Sentiment Tagging', N'Deploy low-latency gRPC service with streaming transcription.', 2400.00, '2026-04-05', N'In Progress', '2026-03-01 10:20:00'),
(12, 6, N'Milestone 1: Sentinel-2 Multispectral Processing', N'Atmospheric correction, vegetation indices calculation, and ground-truth pairing.', 2900.00, '2026-03-25', N'In Progress', '2026-03-02 13:10:00'),
(13, 7, N'Milestone 1: Feature Engineering & Time-Series Models', N'Develop XGBoost lag models and baseline demand forecast.', 2600.00, '2026-03-20', N'Approved', '2026-03-03 11:10:00'),
(14, 8, N'Milestone 1: Collaborative Recommendation Algorithm', N'Embeddings calculation and recommendation API prototype.', 2900.00, '2026-03-25', N'In Progress', '2026-03-04 15:35:00'),
(15, 9, N'Milestone 1: Adversarial LLM Red-Teaming Report', N'Exhaustive penetration testing, prompt injection suite, and remediation guide.', 3600.00, '2026-03-28', N'Approved', '2026-03-05 10:05:00');
SET IDENTITY_INSERT dbo.ProjectMilestones OFF;
GO

-- ============================================================================
-- 13. Table: Payments (12 Records - Including Escrow & Released Payments)
-- ============================================================================
-- Note: Platform fee calculated according to tiered fn_CalculatePlatformFee:
-- < 2000 -> 10%, 2000-10000 -> 8%, > 10000 -> 5%
-- For Gross = 3000: Fee = 240.00, Net = 2760.00
-- For Gross = 3800: Fee = 304.00, Net = 3496.00
-- For Gross = 2100: Fee = 168.00, Net = 1932.00
-- For Gross = 2400: Fee = 192.00, Net = 2208.00
-- For Gross = 2600: Fee = 208.00, Net = 2392.00
-- For Gross = 3600: Fee = 288.00, Net = 3312.00
-- For Gross = 4000: Fee = 320.00, Net = 3680.00
-- For Gross = 5000: Fee = 400.00, Net = 4600.00
SET IDENTITY_INSERT dbo.Payments ON;
INSERT INTO dbo.Payments (PaymentID, AssignmentID, MilestoneID, ClientID, FreelancerID, GrossAmount, PlatformFee, NetAmount, PaymentMethod, PaymentStatus, TransactionReference, PaymentDate, ReleasedDate)
VALUES
(1, 1, 1, 1, 5, 3000.00, 240.00, 2760.00, N'Credit Card', N'Released', N'TXN-NL-2026-001', '2026-02-26 14:00:00', '2026-03-15 16:30:00'),
(2, 2, 4, 2, 1, 3800.00, 304.00, 3496.00, N'Bank Transfer', N'Released', N'TXN-NL-2026-002', '2026-02-27 10:30:00', '2026-03-18 11:45:00'),
(3, 3, 6, 3, 2, 2100.00, 168.00, 1932.00, N'Stripe Escrow', N'Released', N'TXN-NL-2026-003', '2026-02-28 09:15:00', '2026-03-12 14:20:00'),
(4, 5, 10, 5, 3, 2400.00, 192.00, 2208.00, N'PayPal', N'Released', N'TXN-NL-2026-004', '2026-03-02 12:00:00', '2026-03-20 17:10:00'),
(5, 7, 13, 7, 8, 2600.00, 208.00, 2392.00, N'Bank Transfer', N'Released', N'TXN-NL-2026-005', '2026-03-04 15:40:00', '2026-03-20 18:00:00'),
(6, 9, 15, 9, 10, 3600.00, 288.00, 3312.00, N'Credit Card', N'Released', N'TXN-NL-2026-006', '2026-03-06 11:00:00', '2026-03-28 15:00:00'),
(7, 1, 2, 1, 5, 3500.00, 280.00, 3220.00, N'Credit Card', N'Held in Escrow', N'TXN-NL-2026-007', '2026-03-16 09:30:00', NULL),
(8, 2, 5, 2, 1, 4000.00, 320.00, 3680.00, N'Bank Transfer', N'Held in Escrow', N'TXN-NL-2026-008', '2026-03-19 14:15:00', NULL),
(9, 3, 7, 3, 2, 2100.00, 168.00, 1932.00, N'Stripe Escrow', N'Held in Escrow', N'TXN-NL-2026-009', '2026-03-13 10:00:00', NULL),
(10, 4, 8, 4, 9, 5000.00, 400.00, 4600.00, N'Bank Transfer', N'Held in Escrow', N'TXN-NL-2026-010', '2026-03-01 16:45:00', NULL),
(11, 5, 11, 5, 3, 2400.00, 192.00, 2208.00, N'PayPal', N'Held in Escrow', N'TXN-NL-2026-011', '2026-03-21 11:20:00', NULL),
(12, 6, 12, 6, 5, 2900.00, 232.00, 2668.00, N'Crypto / Web3', N'Held in Escrow', N'TXN-NL-2026-012', '2026-03-03 13:30:00', NULL);
SET IDENTITY_INSERT dbo.Payments OFF;
GO

-- Synchronize Freelancers and Clients with released payments
UPDATE f
SET f.TotalEarnings = f.TotalEarnings + p_sum.NetSum,
    f.CompletedProjectsCount = f.CompletedProjectsCount + p_sum.ReleaseCount
FROM dbo.Freelancers f
INNER JOIN (
    SELECT FreelancerID, SUM(NetAmount) AS NetSum, COUNT(*) AS ReleaseCount
    FROM dbo.Payments
    WHERE PaymentStatus = 'Released'
    GROUP BY FreelancerID
) p_sum ON f.FreelancerID = p_sum.FreelancerID;

UPDATE c
SET c.TotalSpent = c.TotalSpent + p_sum.GrossSum
FROM dbo.Clients c
INNER JOIN (
    SELECT ClientID, SUM(GrossAmount) AS GrossSum
    FROM dbo.Payments
    WHERE PaymentStatus = 'Released'
    GROUP BY ClientID
) p_sum ON c.ClientID = p_sum.ClientID;
GO

-- ============================================================================
-- 14. Table: Reviews (12 Records)
-- ============================================================================
SET IDENTITY_INSERT dbo.Reviews ON;
INSERT INTO dbo.Reviews (ReviewID, AssignmentID, ReviewerType, ReviewerID, RevieweeID, Rating, Comment, CreatedAt)
VALUES
(1, 1, N'ClientToFreelancer', 1, 5, 5, N'Exceptional quality on tissue segmentation! Fatima exceeded our expectations with her medical image expertise.', '2026-03-16 09:00:00'),
(2, 1, N'FreelancerToClient', 5, 1, 5, N'BioMed Vision provided high quality annotated gigapixel slides and prompt feedback throughout.', '2026-03-16 11:20:00'),
(3, 2, N'ClientToFreelancer', 2, 1, 5, N'Ethan built an outstanding RAG pipeline for our compliance documents. High technical precision and accuracy.', '2026-03-19 10:15:00'),
(4, 2, N'FreelancerToClient', 1, 2, 5, N'Fantastic client to work with. Clear architectural specifications and timely payment releases.', '2026-03-19 12:40:00'),
(5, 3, N'ClientToFreelancer', 3, 2, 5, N'Aarav is a master of YOLO and edge inference. Product recognition accuracy in retail shelves is top-notch.', '2026-03-13 16:00:00'),
(6, 3, N'FreelancerToClient', 2, 3, 4, N'Good collaboration with the retail engineering team. Minor initial delays in video feed access.', '2026-03-14 09:30:00'),
(7, 5, N'ClientToFreelancer', 5, 3, 5, N'Hannah tuned Whisper perfectly to handle multi-accented speech recordings. Impressive performance.', '2026-03-21 14:00:00'),
(8, 5, N'FreelancerToClient', 3, 5, 5, N'Clear acoustic datasets provided and very pleasant team to interact with.', '2026-03-21 16:30:00'),
(9, 7, N'ClientToFreelancer', 7, 8, 5, N'Liam produced high accuracy XGBoost forecasting models for our microgrids. Highly recommended.', '2026-03-21 10:10:00'),
(10, 7, N'FreelancerToClient', 8, 7, 5, N'Prompt communication and solid energy infrastructure dataset. Great experience.', '2026-03-21 11:45:00'),
(11, 9, N'ClientToFreelancer', 9, 10, 5, N'Jessica uncovered critical prompt vulnerability vectors and provided rock-solid security mitigations.', '2026-03-29 09:30:00'),
(12, 9, N'FreelancerToClient', 10, 9, 5, N'CyberGuard takes AI safety seriously. Seamless red-teaming engagement.', '2026-03-29 11:00:00');
SET IDENTITY_INSERT dbo.Reviews OFF;
GO

-- Trigger review sync for ratings
UPDATE f
SET f.AverageRating = ISNULL(sub.AvgRating, 5.00)
FROM dbo.Freelancers f
INNER JOIN (
    SELECT RevieweeID, ROUND(AVG(CAST(Rating AS DECIMAL(4,2))), 2) AS AvgRating
    FROM dbo.Reviews
    WHERE ReviewerType = 'ClientToFreelancer'
    GROUP BY RevieweeID
) sub ON f.FreelancerID = sub.RevieweeID;

UPDATE c
SET c.ClientRating = ISNULL(sub.AvgRating, 5.00)
FROM dbo.Clients c
INNER JOIN (
    SELECT RevieweeID, ROUND(AVG(CAST(Rating AS DECIMAL(4,2))), 2) AS AvgRating
    FROM dbo.Reviews
    WHERE ReviewerType = 'FreelancerToClient'
    GROUP BY RevieweeID
) sub ON c.ClientID = sub.RevieweeID;
GO

-- ============================================================================
-- 15. Table: PlatformDisputes (10 Records - Audit & Quality Oversight)
-- ============================================================================
SET IDENTITY_INSERT dbo.PlatformDisputes ON;
INSERT INTO dbo.PlatformDisputes (DisputeID, AssignmentID, RaisedByID, RaisedByType, Reason, Description, DisputeStatus, ResolutionNotes, ResolvedByAdminID, CreatedAt, ResolvedAt)
VALUES
(1, 1, 1, N'Client', N'Scope Clarification on Patch Resolution', N'Requesting clarification whether 20x magnification or 40x whole slide images should be standard for patch extraction.', N'Resolved', N'Mediated between parties. Agreement reached that 20x patches are sufficient for baseline training.', 4, '2026-03-01 11:00:00', '2026-03-02 15:30:00'),
(2, 2, 1, N'Freelancer', N'Delay in Vector DB API Access Key Provisioning', N'Freelancer requested official enterprise Pinecone index credentials which took 4 days to receive.', N'Resolved', N'Admin assisted in provisioning credentials and granted 4-day milestone extension.', 2, '2026-03-03 09:15:00', '2026-03-04 14:00:00'),
(3, 3, 3, N'Client', N'Camera Lens Distortion Calibration Query', N'Client enquired if wide-angle distortion correction should be handled within YOLO preprocessing or firmware.', N'Resolved', N'Agreed that undistortion matrix should be applied in camera firmware before inference.', 6, '2026-03-05 14:20:00', '2026-03-06 10:00:00'),
(4, 4, 9, N'Freelancer', N'Hardware Test Bench Delay', N'Awaiting physical delivery of LiDAR test hardware unit from client robotics lab.', N'Under Investigation', N'Platform officer contacted client shipping department to expedite hardware delivery.', 4, '2026-03-08 16:00:00', NULL),
(5, 5, 5, N'Client', N'Audio Sampling Rate Compatibility', N'Client telephony systems use 8kHz whereas model requires 16kHz resampled audio.', N'Resolved', N'Freelancer added automatic real-time Polyphase resampling module to inference pipeline.', 2, '2026-03-10 11:30:00', '2026-03-11 16:45:00'),
(6, 6, 6, N'Client', N'Cloud Masking Algorithm Thresholds', N'Dispute over cloud occlusion percentage threshold in Scandinavian Sentinel-2 imagery.', N'Resolved', N'Set maximum cloud cover threshold to 15% and interpolated missing pixels using multi-temporal composites.', 6, '2026-03-12 13:00:00', '2026-03-13 17:00:00'),
(7, 7, 7, N'Client', N'Weather API Integration Data Cost', N'Client questioned third-party weather API subscription costs needed for temperature covariates.', N'Resolved', N'Switched to Open-Meteo non-commercial open data API, eliminating subscription fees.', 4, '2026-03-14 10:10:00', '2026-03-15 12:30:00'),
(8, 8, 8, N'Client', N'Cold Start Problem for New Curriculum Users', N'Client noted recommendation engine had lower accuracy for users with zero past assessment history.', N'Resolved', N'Freelancer incorporated popular-item fallback and diagnostic baseline assessment heuristics.', 2, '2026-03-16 15:40:00', '2026-03-17 14:00:00'),
(9, 9, 9, N'Client', N'Adversarial Benchmark Standard Verification', N'Client enquired whether OWASP Top 10 for LLMs was fully satisfied in test report.', N'Resolved', N'Freelancer provided itemized mapping matrix proving coverage for all 10 vulnerability categories.', 4, '2026-03-22 09:20:00', '2026-03-23 11:15:00'),
(10, 10, 7, N'Freelancer', N'GPU Cloud Compute Budget Extension', N'Diffusion LoRA training on high resolution 1024x1024 images required additional A100 GPU compute hours.', N'Open', N'Under review with client management team to approve compute stipend.', NULL, '2026-03-25 14:00:00', NULL);
SET IDENTITY_INSERT dbo.PlatformDisputes OFF;
GO

PRINT 'Sample data inserted successfully across all 15 tables with >= 10 records per table.';
GO
