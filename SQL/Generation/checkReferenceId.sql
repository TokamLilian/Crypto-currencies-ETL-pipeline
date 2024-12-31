CREATE PROCEDURE GetEnvironmentReferenceId
    @ProjectName NVARCHAR(255),
    @FolderName NVARCHAR(255),
    @EnvironmentName NVARCHAR(255),
    @EnvironmentReferenceId INT OUTPUT
AS
BEGIN
    -- Retrieve the environment reference ID based on the provided parameters
    SELECT @EnvironmentReferenceId = environment_reference_id
    FROM SSISDB.catalog.environment_references
    WHERE project_name = @ProjectName
      AND folder_name = @FolderName
      AND environment_name = @EnvironmentName;

    -- If no matching reference is found, set the output parameter to NULL
    IF @EnvironmentReferenceId IS NULL
    BEGIN
        SET @EnvironmentReferenceId = NULL;
    END
END;
GO
