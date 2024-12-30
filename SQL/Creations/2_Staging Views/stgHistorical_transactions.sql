﻿CREATE TABLE [stg].[stg_Historical_transactions]
(
	[transaction_id] INT NOT NULL
	,[transaction_date] DATETIME2 
	,[symbol] VARCHAR (53) NOT NULL		    -- CURRENCIES INVOLVED
	,[amount] FLOAT (53) NOT NULL			-- AMOUNT OF COIN TRADED
	,[exchange] VARCHAR (53) NOT NULL		-- PLATFORM USED
	,[price] FLOAT (53) NOT NULL			-- COIN PRICE AT TRADE PERIOD
	,[side] VARCHAR (53) NOT NULL			-- TRANSACTION TYPE
	,[sell_side_amount] FLOAT (53) NOT NULL	-- VALUE OF TRADED QUANTITY
	,[fee] FLOAT (53) NOT NULL				-- TRANSACTION FEES
)