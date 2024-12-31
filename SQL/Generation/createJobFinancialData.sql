USE SSISDB;
GO

DECLARE @EnvironmentName NVARCHAR(255) = N'DEV';
DECLARE @FolderName NVARCHAR(255) = N'FinancialData';
DECLARE @VariableName NVARCHAR(255) = N'ConnectionString'; 

BEGIN TRY
    -- Check if the folder exists
    IF NOT EXISTS (
        SELECT 1
        FROM catalog.folders AS f
        WHERE f.name = @FolderName
    )
    BEGIN
        RETURN;
    END

    -- Check if the environment already exists
    IF NOT EXISTS (
        SELECT 1
        FROM catalog.environments AS env
        INNER JOIN catalog.folders AS f ON env.folder_id = f.folder_id
        WHERE env.name = @EnvironmentName
        AND f.name = @FolderName
    )
    BEGIN
        -- Create the environment in the specified project folder
        EXEC catalog.create_environment
            @folder_name = @FolderName,
            @environment_name = @EnvironmentName;

        EXEC catalog.create_environment_reference
            @folder_name = @FolderName,
            @environment_name = @EnvironmentName,
            @project_name = N'FD-SSIS',
            @reference_type = N'R',
            @reference_id = 1 ;
    END

    -- check if variable exists
    IF NOT EXISTS (
        SELECT 1
        FROM catalog.environment_variables AS ev
        INNER JOIN catalog.environments AS e ON ev.environment_id = e.environment_id
        INNER JOIN catalog.folders AS f ON e.folder_id = f.folder_id
        WHERE ev.name = @VariableName
        AND e.name = @EnvironmentName
        AND f.name = @FolderName
    )
    BEGIN
        -- Add the environment variable
        EXEC catalog.create_environment_variable
            @data_type = 'String',
            @folder_name = @FolderName,
            @environment_name = @EnvironmentName,
            @variable_name = @VariableName,
            @sensitive = 0, -- 0 for non-sensitive variables
            @description = N'Connection string for the DEV environment', -- Optional description
            @value = N'Data Source=.;Initial Catalog=Financial_data;Integrated Security=SSPI;'; -- Value
    END
END TRY

BEGIN CATCH

    PRINT 'An error occurred: ' + ERROR_MESSAGE();

END CATCH
GO


----


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
DECLARE @ReferenceID INT;
DECLARE @ServerName NVARCHAR(128);

EXEC Financial_data.powerbi.GetEnvironmentReferenceId
    @ProjectName = N'FD-SSIS',
    @FolderName = N'FinancialData',
    @EnvironmentName = N'DEV',
    @EnvironmentReferenceId = @ReferenceId OUTPUT;

SET @ServerName = N'(local)'; -- Replace "(local)" with your actual SQL Server instance name if needed

-- Add the first SSIS package step
SET @JobCommand = N'/IS "\SSISDB\FinancialData\FD-SSIS\1_Extract_data.dtsx" /SERVER ' + @ServerName + N' /ENVREFERENCE ' + CAST(@ReferenceID AS NVARCHAR(10));
EXEC sp_add_jobstep
    @job_name = N'Financial_data_etl',
    @step_name = N'1_extract_data_from_cb',
    @subsystem = N'SSIS', -- Subsystem type for SSIS package execution
    @command = @JobCommand,
    @retry_attempts = 3,      -- Number of retries on failure
    @retry_interval = 1,      -- Retry interval in minutes
    @database_name = N'msdb', -- Default database
    @on_success_action = 3,   -- Go to the next step on success
    @on_fail_action = 2;      -- Quit on failure

-- Add the second SSIS package step
SET @JobCommand = N'/IS "\SSISDB\FinancialData\FD-SSIS\2_Transform_data.dtsx" /SERVER ' + @ServerName + N' /ENVREFERENCE ' + CAST(@ReferenceID AS NVARCHAR(10));
EXEC sp_add_jobstep
    @job_name = N'Financial_data_etl',
    @step_name = N'2_transform_source_table',
    @subsystem = N'SSIS',
    @command = @JobCommand,
    @retry_attempts = 3,
    @retry_interval = 1,
    @database_name = N'msdb',
    @on_success_action = 3, -- Proceed to the next step
    @on_fail_action = 2;    -- Quit on failure

-- Add the third SSIS package step
SET @JobCommand = N'/IS "\SSISDB\FinancialData\FD-SSIS\3_Load_data.dtsx" /SERVER ' + @ServerName + N' /ENVREFERENCE ' + CAST(@ReferenceID AS NVARCHAR(10));
EXEC sp_add_jobstep
    @job_name = N'Financial_data_etl',
    @step_name = N'3_load_into_final_table',
    @subsystem = N'SSIS',
    @command = @JobCommand,
    @retry_attempts = 3,
    @retry_interval = 1,
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
