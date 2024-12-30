USE SSISDB;
GO

DECLARE @EnvironmentName NVARCHAR(255) = N'DEV';
DECLARE @FolderName NVARCHAR(255) = N'FinancialData';
DECLARE @VariableName NVARCHAR(255) = N'ConnectionString'; 

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

-- Add variables to the environment (if needed)
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
