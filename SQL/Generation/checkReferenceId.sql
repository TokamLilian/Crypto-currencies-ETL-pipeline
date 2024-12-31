CREATE PROCEDURE powerbi.GetEnvironmentReferenceId
    @ProjectName NVARCHAR(255),
    @FolderName NVARCHAR(255),
    @EnvironmentName NVARCHAR(255),
    @EnvironmentReferenceId INT OUTPUT
AS
BEGIN
    -- Retrieve the environment reference ID based on the provided parameters
    SELECT @EnvironmentReferenceId = er.reference_id

    FROM    
        SSISDB.catalog.folders AS F
        INNER JOIN SSISDB.catalog.environments AS E ON E.folder_id = F.folder_id
        INNER JOIN SSISDB.catalog.environment_references AS ER ON 
            (ER.reference_type = 'A' AND ER.environment_folder_name = F.name AND ER.environment_name = E.name)
            OR
            (ER.reference_type = 'R' AND ER.environment_name = E.name)
        INNER JOIN SSISDB.catalog.projects AS PJ ON PJ.folder_id = F.folder_id AND PJ.project_id = ER.project_id
        INNER JOIN SSISDB.catalog.packages AS PK ON PK.project_id = PJ.project_id
        INNER JOIN SSISDB.catalog.folders AS F2 ON F2.folder_id = PJ.folder_id
    WHERE
        E.name = @EnvironmentName
        AND F.name = @FolderName
        AND PJ.name = @ProjectName
    -- If no matching reference is found, set the output parameter to NULL
    IF @EnvironmentReferenceId IS NULL
    BEGIN
        SET @EnvironmentReferenceId = NULL;
    END
END;
GO
