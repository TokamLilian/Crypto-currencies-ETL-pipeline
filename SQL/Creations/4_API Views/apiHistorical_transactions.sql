CREATE VIEW [api].[api_Historical_transactions]
AS
SELECT * FROM [powerbi].[pbi_Historical_transactions]
WHERE transaction_id > 2 -- This is a test comment
GO