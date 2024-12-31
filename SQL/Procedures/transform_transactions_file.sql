CREATE PROCEDURE src.transform_transactions_file
    @ProjectPath NVARCHAR(MAX)
AS
BEGIN
DECLARE @SQL nvarchar(max) = 

N'INSERT INTO src.src_Historical_transactions ([transaction], load_date)
SELECT BulkColumn, SYSDATETIME()
FROM OPENROWSET(BULK '''+ @ProjectPath + '\\register\\data.json'', SINGLE_BLOB) JSON;'

EXECUTE sp_executesql @SQL
END;