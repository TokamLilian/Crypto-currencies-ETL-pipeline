CREATE PROCEDURE stg.transformSrcTransactions
AS
BEGIN

    DECLARE @JsonData NVARCHAR(MAX);

    -- Read JSON data from source table
    SELECT @JsonData = [transaction]
    FROM src.src_Historical_transactions
    ORDER BY [load_date] ASC;

    -- Parse JSON array and insert each transaction into the destination table
    INSERT INTO stg.stg_Historical_transactions(
        [transaction_id],
        [transaction_date],
        [symbol],
        [amount],
        [exchange],
        [price],
        [side],
        [sell_side_amount],
        [fee]
    )
    SELECT
        JSON_VALUE(transactions.value, '$.transaction_id'),
        TRY_CONVERT(DATETIME2, JSON_VALUE(transactions.value, '$.transaction_date')),
        JSON_VALUE(transactions.value, '$.symbol'),
        JSON_VALUE(transactions.value, '$.amount'),
        JSON_VALUE(transactions.value, '$.exchange'),
        JSON_VALUE(transactions.value, '$.price'),
        JSON_VALUE(transactions.value, '$.side'),
        JSON_VALUE(transactions.value, '$.sell_side_amount'),
        JSON_VALUE(transactions.value, '$.fee')
    FROM OPENJSON(@JsonData, '$.transactions') AS transactions
END;