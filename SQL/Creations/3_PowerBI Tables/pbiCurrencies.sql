CREATE TABLE [powerbi].[Currencies]
(
	product_id VARCHAR(100),
    price DECIMAL(18, 4), 
    price_percentage_change_24h DECIMAL(18, 4), 
    volume_24h DECIMAL(18, 4), 
    volume_percentage_change_24h DECIMAL(18, 4), 
    base_name VARCHAR(100),
    quote_name VARCHAR(100),
    status VARCHAR(100),
    price_increment DECIMAL(18, 4), 
    display_name VARCHAR(100),
    product_venue VARCHAR(100),
    approximate_quote_24h_volume DECIMAL(18, 4),
    load_date DATETIME

)
