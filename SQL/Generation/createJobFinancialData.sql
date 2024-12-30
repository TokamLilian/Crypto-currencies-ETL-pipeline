﻿-- Not working (i try to get environment id from SSISDB and use it in job creation)
-- USE SSISDB;
-- GO

-- -- Declare variables for SSISDB lookup
-- DECLARE @EnvironmentID INT;
-- DECLARE @EnvironmentName NVARCHAR(255) = N'DEV';
-- DECLARE @FolderName NVARCHAR(255) = N'FinancialData';

-- -- Lookup Environment ID from SSISDB
-- SELECT @EnvironmentID = env.environment_id
-- FROM catalog.environments AS env
-- INNER JOIN catalog.folders AS f ON env.folder_id = f.folder_id
-- WHERE env.name = @EnvironmentName AND f.name = @FolderName;

-- -- Ensure Environment ID is found
-- IF @EnvironmentID IS NULL
-- BEGIN
--     PRINT 'Error: Environment ID not found.';
--     RETURN;
-- END;

-- -- Now switch to msdb and create the job

USE msdb;
GO

-- Check if the job already exists, and drop it if necessary
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Financial_data_etl')
BEGIN
    EXEC sp_delete_job @job_name = N'Financial_data_etl';
END
GO

-- Create the SQL Server Agent Job
EXEC sp_add_job
    @job_name = N'Financial_data_etl', -- Name of the job
    @enabled = 1,                      -- Enable the job
    @description = N'Automated job created during Visual Studio deployment.',
    @start_step_id = 1,                -- Specify the starting step ID
    @category_name = N'Data collector'; -- Specify the category
GO

DECLARE @JobCommand NVARCHAR(300);
DECLARE @EnvironmentID INT;
DECLARE @ServerName NVARCHAR(128);
SET @EnvironmentID = 1;
SET @ServerName = N'(local)'; -- Replace "(local)" with your actual SQL Server instance name if needed

-- Add the first SSIS package step
SET @JobCommand = N'/IS "\SSISDB\FinancialData\FD-SSIS\1_Extract_data.dtsx" /SERVER ' + @ServerName + N' /ENVREFERENCE ' + CAST(@EnvironmentID AS NVARCHAR(10));
EXEC sp_add_jobstep
    @job_name = N'Financial_data_etl',
    @step_name = N'1_extract_data_from_cb',
    @subsystem = N'SSIS', -- Subsystem type for SSIS package execution
    @command = @JobCommand,
    @retry_attempts = 3,      -- Number of retries on failure
    @retry_interval = 5,      -- Retry interval in minutes
    @database_name = N'msdb', -- Default database
    @on_success_action = 3,   -- Go to the next step on success
    @on_fail_action = 2;      -- Quit on failure

-- Add the second SSIS package step
SET @JobCommand = N'/IS "\SSISDB\FinancialData\FD-SSIS\2_Transform_data.dtsx" /SERVER ' + @ServerName + N' /ENVREFERENCE ' + CAST(@EnvironmentID AS NVARCHAR(10));
EXEC sp_add_jobstep
    @job_name = N'Financial_data_etl',
    @step_name = N'2_transform_source_table',
    @subsystem = N'SSIS',
    @command = @JobCommand,
    @retry_attempts = 3,
    @retry_interval = 5,
    @database_name = N'msdb',
    @on_success_action = 3, -- Proceed to the next step
    @on_fail_action = 2;    -- Quit on failure

-- Add the third SSIS package step
SET @JobCommand = N'/IS "\SSISDB\FinancialData\FD-SSIS\3_Load_data.dtsx" /SERVER ' + @ServerName + N' /ENVREFERENCE ' + CAST(@EnvironmentID AS NVARCHAR(10));
EXEC sp_add_jobstep
    @job_name = N'Financial_data_etl',
    @step_name = N'3_load_into_final_table',
    @subsystem = N'SSIS',
    @command = @JobCommand,
    @retry_attempts = 3,
    @retry_interval = 5,
    @database_name = N'msdb',
    @on_success_action = 1, -- Exit with success
    @on_fail_action = 2;    -- Quit on failure

-- Set the schedule for the job
EXEC sp_add_jobschedule
    @job_name = N'Financial_data_etl',
    @name = N'DailySchedule',          -- Schedule name
    @freq_type = 4,                    -- Frequency type (4 = Daily)
    @freq_interval = 1,                -- Every 1 day
    @active_start_time = 090000;       -- Start time in HHMMSS format (9:00 AM)

-- Add the job to a specific target (SQL Server Agent server)
EXEC sp_add_jobserver
    @job_name = N'Financial_data_etl',
    @server_name = @ServerName;        -- Target server name (use "(local)" for current instance)
