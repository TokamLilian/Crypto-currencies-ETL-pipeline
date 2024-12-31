# ETL Pipeline and Power BI Visualization

## Project Overview
This repository contains the code and resources for an end-to-end ETL pipeline implemented using Python, SQL, and SSIS. The pipeline processes and transforms raw data, which is then visualized through a comprehensive Power BI report that provides valuable insights into the data.

## Tools and Technologies Used

- **Python**: Used for scripting the data extraction and transformation logic, with libraries such as pandas and NumPy for data manipulation.
- **SQL**: SQL queries were written for data extraction from relational databases and for processing the data before transformation.
- **SSIS (SQL Server Integration Services)**: Used for automating the ETL tasks, ensuring seamless extraction, transformation, and loading processes.
- **Power BI**: Developed an interactive Power BI report to visualize the data, offering insights that aid in decision-making.

## Features

- **Data Extraction**: Data is extracted from multiple sources (databases, files).
- **Data Transformation**: Using Python and SSIS, the data is cleaned, transformed, and prepared for analysis.
- **Data Loading**: The cleaned data is loaded into a destination system (e.g., SQL Server) for further processing.
- **Power BI Reporting**: A user-friendly, interactive report built in Power BI that visualizes key metrics and trends from the transformed data.

## Getting Started

1. **Clone this repository:**
https://github.com/TokamLilian/Crypto-currencies-ETL-pipeline.git


2. **Install necessary libraries:**
Make sure to install the required Python libraries:
`pip install json`, `pip install ccxt` and `pip install http`


3. **Set up the database:**
Ensure your SQL Server or other database systems are correctly set up and connected.

Prepare the SQL Server Environment  

1. **Validate Access**: Ensure Integration Catalog exists you have read access to the `SSISDB` and `msdb` databases.  
   - You must have access to execute queries on both of these system databases.  

2. **Publish the SQL Scripts**:  
   - In `Integration Services Catalogs`, deploy the SSIS packages under the folder `FinancialData\FD-SSIS` (spelling super important).  
   - Open and publish the provided SQL directory using loaded profile (publish scipt) `SQL.publish.xml` from solution `Financial-Data.sln` in Microsoft Visual Studio or similar application.  

3. **Verify deployed files**:
    - Verify that the SSIS packages are deployed in the SSIS catalog.
    - Check the environment `DEV` in SSIS project directory.
    - Ensure that database `Financial_data` contains required tables.
    - Check the database `Financial_data_etl` is created and steps have no errors.
    - Verify that the SQL Server Agent is running and configured to execute the SSIS packages.

4. **Power BI Report:**
The Power BI file (`Coinbase trading.pbit`) can be opened using Power BI Desktop. Make sure the data source paths are correctly configured in the report file.


## License
This project is licensed under the MIT License
