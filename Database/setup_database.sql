-- NeuroLance Hub database bootstrap
-- Run this file once using a SQL Server login allowed to create databases.
-- Then run 01_freelancer_module.sql through 05_admin_and_disputes.sql in order,
-- followed by 06_database_objects.sql, 07_sample_data.sql, 08_payment_review_module.sql,
-- and 09_payment_web_support.sql for the Member 4 application.

IF DB_ID(N'NeuroLanceHubDB') IS NULL
BEGIN
    CREATE DATABASE NeuroLanceHubDB;
END;
GO

USE NeuroLanceHubDB;
GO

SELECT N'NeuroLanceHubDB is ready. Run the numbered module scripts next.' AS SetupMessage;
GO
