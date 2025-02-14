# Stock Market Porfolio Analysis and Optimization 

## Overview

This project performs stock market analysis using R, connecting to a PostgreSQL database to load, transform, and analyze stock data. The analysis calculates returns, explores tabular and graphical analytics, and performs mean-variance portfolio optimization. This project was completed as part of the coursework for "Business Data Transformation" during my Master of Information Systems degree in 2024.

## Data Sources

*   Data is primarily sourced from a PostgreSQL database named `stockmarket_GP`, as defined in `Stock_Market_Portfolio_Optimization.sql`.
*   Key tables include `custom_calendar` and `eod_quotes`, as well as data loaded from external CSV files.
*   External data files used for initial database setup include: `daily_returns_2016_2021.csv`, `daily_prices_2016_2021.csv`, `eod.csv`, `companylist_amex.csv`, `companylist_nasdaq.csv`, `companylist_nyse.csv`, `custom_calendar.csv`, and `SP500TR.csv`.

## Files

*   `Stock_Market_Portfolio_Optimization.R`: R script containing the data analysis code, including database connection, data loading, transformation, return calculations, and portfolio optimization.
*   `Stock_Market_Portfolio_Optimization.sql`: SQL script for setting up the PostgreSQL database `stockmarket_GP`, creating tables (stock_mkt, company_list, eod_quotes, custom_calendar), and loading company listing data. This script also creates the `v_company_list` view.

## Technologies Used

*   R: For data analysis, transformation, visualization, and portfolio optimization.
*   RPostgres package: Used to connect to the PostgreSQL database.
*   PerformanceAnalytics package: For calculating returns and performance metrics.
*   PortfolioAnalytics package: For mean-variance portfolio optimization.
*   zoo package: For handling time series data and missing value imputation (using `na.locf`).
*   reshape2 package: For data transformation (using `dcast` for pivoting).
*   xts package: For working with extensible time series data.
*   ROI and ROI.plugin.quadprog packages: For portfolio optimization.
*   PostgreSQL: Database for storing and managing stock market data, version 5432.

## Setup Instructions

1.  **Clone the repository:**

    ```
    git clone https://github.com/sheetalp97/stock-market-portfolio-optimization
    cd stock-market-portfolio-optimization
    ```

2.  **Set up the PostgreSQL database:**

    *   Create a database named `stockmarket_GP` on `localhost`.
    *   Run the `Stock_Market_Portfolio_Optimization.sql` script to create the necessary tables and load initial company listing data.
    *   Import `eod.csv`, `custom_calendar.csv`, and `SP500TR.csv` data into the appropriate tables (e.g., `eod_quotes`, `custom_calendar`) within the `stockmarket_GP` database.
    *   Ensure the database user `stockmarketreadergp` has the password `read123` and the appropriate permissions, as defined in the R script.

3.  **Install R packages:**

    *   Install the required R packages by running the following code in R:

    ```
    install.packages(c("RPostgres", "DBI", "reshape2", "zoo", "PerformanceAnalytics", "PortfolioAnalytics", "ROI", "ROI.plugin.quadprog", "xts"))
    ```

4.  **Configure the R script:**

    *   Modify the `Stock_Market_Portfolio_Optimization.R` script to ensure the database connection parameters (user, password, host, port, dbname) match your PostgreSQL setup.  The script uses `stockmarketreadergp`, `read123`, `localhost`, `5432`, and `stockmarket_GP` by default.

5.  **Run the R script:**

    *   Execute the `Stock_Market_Portfolio_Optimization.R` script to perform the stock market analysis.

## Usage

*   The R script `Stock_Market_Portfolio_Optimization.R` performs the following main steps:
    *   Connects to the PostgreSQL database.
    *   Loads data from the `custom_calendar` and `eod_quotes` tables.
    *   Calculates percentage of completeness
    *   Pivots the `eod_quotes` table to create a time series of adjusted closing prices for each stock (using `dcast`).
    *   Merges pivoted data with `custom_calendar`.
    *   Performs missing data imputation using `na.locf`.
    *   Calculates returns using `CalculateReturns` from the `PerformanceAnalytics` package.
    *   Performs tabular and graphical return data analytics.
    *   Performs MV (Mean-Variance) Portfolio Optimization.
    *   Charts hypothetical Portfolio Returns.
*   Review the code comments in the `Stock_Market_Portfolio_Optimization.R` script for detailed explanations.

## Contributing

Feel free to contribute to this project by opening issues or submitting pull requests with suggestions for improvements, bug fixes, or new analyses.
