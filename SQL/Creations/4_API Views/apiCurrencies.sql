CREATE VIEW [api].[api_Currencies]
AS

WITH RankedProducts AS (
    SELECT 
        product_id,
        price,
        base_name,
        quote_name,
        approximate_quote_24h_volume,
        load_date,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY load_date DESC) AS rn
    FROM 
        powerbi.Currencies
)

SELECT 
   product_id,
   price,
   base_name,
   quote_name,
   approximate_quote_24h_volume,
   load_date
FROM 
	RankedProducts
WHERE 
	rn = 1;

GO
