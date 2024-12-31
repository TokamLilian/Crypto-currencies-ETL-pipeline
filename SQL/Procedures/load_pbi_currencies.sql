CREATE PROCEDURE powerbi.loadCurrencies
    @ProjectPath NVARCHAR(MAX)
AS
BEGIN

    DECLARE @SQL nvarchar(max) = 
        N'DECLARE @productData VARCHAR(MAX)
        SELECT @productData = BulkColumn FROM 

        OPENROWSET(BULK '''+ @ProjectPath + '\\register\\products.json'', SINGLE_BLOB) JSON
        INSERT 

        INTO powerbi.Currencies(
            product_id,
            price,
            price_percentage_change_24h,
            volume_24h,
            volume_percentage_change_24h,
            base_name,
            quote_name,
            status,
            price_increment,
            display_name,
            product_venue,
            approximate_quote_24h_volume,
            load_date
        )
        SELECT
            product_id,
            TRY_CAST(price AS DECIMAL(18, 4)),
            TRY_CAST(price_percentage_change_24h AS DECIMAL(18, 4)),
            TRY_CAST(volume_24h AS DECIMAL(18, 4)),
            TRY_CAST(volume_percentage_change_24h AS DECIMAL(18, 4)),
            base_name,
            quote_name,
            status,
            TRY_CAST(price_increment AS DECIMAL(18, 4)),
            display_name,
            product_venue,
            TRY_CAST(approximate_quote_24h_volume AS DECIMAL(18, 4)),
            SYSDATETIME() -- use current date from sys

            FROM OPENJSON(@productData, ''$.products'') 
                WITH(
                product_id VARCHAR(100) ''$.product_id'',
                price NVARCHAR(100) ''$.price'',
                price_percentage_change_24h NVARCHAR(100) ''$.price_percentage_change_24h'',
                volume_24h NVARCHAR(100) ''$.volume_24h'',
                volume_percentage_change_24h NVARCHAR(100) ''$.volume_percentage_change_24h'',
                base_name VARCHAR(100) ''$.base_name'',
                quote_name VARCHAR(100) ''$.quote_name'',
                status VARCHAR(100) ''$.status'',
                price_increment NVARCHAR(100) ''$.price_increment'',
                display_name VARCHAR(100) ''$.display_name'',
                product_venue VARCHAR(100) ''$.product_venue'',
                approximate_quote_24h_volume NVARCHAR(100) ''$.approximate_quote_24h_volume''
            )'
       EXECUTE sp_executesql @SQL
END;
