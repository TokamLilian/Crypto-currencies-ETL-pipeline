CREATE VIEW [stg].[stg_Currencies]
AS
SELECT * FROM [src].[Currencies]
WHERE currency > 1 -- just to test the view
GO
