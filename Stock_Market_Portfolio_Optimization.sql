--------------------------------------------------------------
-- First, created a database "stockmarket_GP" under "Databases" 
--------------------------------------------------------------

--------------------------------------------------------------
-- Let us create the actual tables to transfer data there
--------------------------------------------------------------

-- DROP TABLE public.stock_mkt;
CREATE TABLE public.stock_mkt
(
    stock_mkt_name character varying(16) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT stock_mkt_pkey PRIMARY KEY (stock_mkt_name)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.stock_mkt
    OWNER to postgres;

-- DROP TABLE public.company_list;
CREATE TABLE public.company_list
(
    symbol character varying(16) COLLATE pg_catalog."default" NOT NULL,
    stock_mkt_name character varying(16) COLLATE pg_catalog."default" NOT NULL,
    company_name character varying(255) COLLATE pg_catalog."default",
    market_cap double precision,
	country character varying(255) COLLATE pg_catalog."default",
	ipo_year integer,
	sector character varying(255) COLLATE pg_catalog."default",
    industry character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT company_list_pkey PRIMARY KEY (symbol, stock_mkt_name)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.company_list
    OWNER to postgres;

-- We have PK and other entity integrity constraints, now let us set the referential integrity (FK) constraints
ALTER TABLE public.company_list
    ADD CONSTRAINT company_list_fkey FOREIGN KEY (stock_mkt_name)
    REFERENCES public.stock_mkt (stock_mkt_name) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX fki_company_list_fkey
    ON public.company_list(stock_mkt_name);



----------------------------------------------
-- Populate the final tables with data
-----------------------------------------------

DELETE FROM stock_mkt;

-- Insert NASDAQ data with proper casting (type conversion)
-- Create a temporary table and import data
-- DROP TABLE public._temp_company_list;
CREATE TABLE public._temp_company_list
(
    symbol character varying(255) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    last_sale character varying(255) COLLATE pg_catalog."default",
    net_change character varying(255) COLLATE pg_catalog."default",
	pct_change character varying(255) COLLATE pg_catalog."default",
	market_cap character varying(255) COLLATE pg_catalog."default",
	country character varying(255) COLLATE pg_catalog."default",
    ipo_year character varying(255) COLLATE pg_catalog."default",
    volume character varying(255) COLLATE pg_catalog."default",
    sector character varying(255) COLLATE pg_catalog."default",
    industry character varying(255) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public._temp_company_list
    OWNER to postgres;

-- Once created import data from csv companylist_nasdaq.csv

-- Check if we have data in the correct format
SELECT * FROM _temp_company_list LIMIT 10;
SELECT COUNT(*) from _temp_company_list;

-- Insert Market Name in table
INSERT INTO stock_mkt (stock_mkt_name) VALUES ('NASDAQ');

-- Check!
SELECT * FROM stock_mkt;

-- We will load the company_list with data stored in _temp_company_list
INSERT INTO company_list
SELECT symbol, 'NASDAQ' AS stock_mkt_name, name company_name, market_cap::double precision ,country, ipo_year::integer, sector,industry 
FROM _temp_company_list;

-- Insert NYSE data with proper casting (type conversion)
-- Create a temporary table and import data
DROP TABLE public._temp_company_list;
CREATE TABLE public._temp_company_list
(
    symbol character varying(255) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    last_sale character varying(255) COLLATE pg_catalog."default",
    net_change character varying(255) COLLATE pg_catalog."default",
	pct_change character varying(255) COLLATE pg_catalog."default",
	market_cap character varying(255) COLLATE pg_catalog."default",
	country character varying(255) COLLATE pg_catalog."default",
    ipo_year character varying(255) COLLATE pg_catalog."default",
    volume character varying(255) COLLATE pg_catalog."default",
    sector character varying(255) COLLATE pg_catalog."default",
    industry character varying(255) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public._temp_company_list
    OWNER to postgres;

-- Once created import data from csv companylist_nyse.csv

-- Check if we have data in the correct format
SELECT * FROM _temp_company_list LIMIT 10;
SELECT COUNT(*) from _temp_company_list;

-- Insert Market Name in table
INSERT INTO stock_mkt (stock_mkt_name) VALUES ('NYSE');

-- Check!
SELECT * FROM stock_mkt;

-- We will load the company_list with data stored in _temp_company_list
INSERT INTO company_list
SELECT symbol, 'NYSE' AS stock_mkt_name, name company_name, market_cap::double precision ,country, ipo_year::integer, sector,industry 
FROM _temp_company_list;

-- Insert AMEX data with proper casting (type conversion)
-- Create a temporary table and import data --
DROP TABLE public._temp_company_list;
CREATE TABLE public._temp_company_list
(
    symbol character varying(255) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    last_sale character varying(255) COLLATE pg_catalog."default",
    net_change character varying(255) COLLATE pg_catalog."default",
	pct_change character varying(255) COLLATE pg_catalog."default",
	market_cap character varying(255) COLLATE pg_catalog."default",
	country character varying(255) COLLATE pg_catalog."default",
    ipo_year character varying(255) COLLATE pg_catalog."default",
    volume character varying(255) COLLATE pg_catalog."default",
    sector character varying(255) COLLATE pg_catalog."default",
    industry character varying(255) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public._temp_company_list
    OWNER to postgres;

-- Once created import data from csv companylist_amex.csv

-- Check if we have data in the correct format
SELECT * FROM _temp_company_list LIMIT 10;
SELECT COUNT(*) from _temp_company_list;

-- Insert Market Name in table
INSERT INTO stock_mkt (stock_mkt_name) VALUES ('AMEX');

-- Check!
SELECT * FROM stock_mkt;

-- We will load the company_list with data stored in _temp_company_list
INSERT INTO company_list
SELECT symbol, 'AMEX' AS stock_mkt_name, name company_name, market_cap::double precision ,country, ipo_year::integer, sector,industry 
FROM _temp_company_list;

-- Check
SELECT * FROM company_list LIMIT 10;
SELECT COUNT(*) FROM company_list;



-----------------------------------------------------------------
-- Dealing with unwanted values  and leading/trailing blanks ----
-----------------------------------------------------------------

SELECT * FROM company_list order by market_cap LIMIT 100;
UPDATE company_list SET market_cap=NULL WHERE market_cap=0;
SELECT * FROM company_list order by market_cap LIMIT 100;

UPDATE stock_mkt SET stock_mkt_name=TRIM(stock_mkt_name);

UPDATE company_list SET 
	stock_mkt_name=TRIM(stock_mkt_name)
	,company_name=TRIM(company_name)
	,country=TRIM(country)	
	,sector=TRIM(sector)
	,industry=TRIM(industry);

SELECT * FROM company_list LIMIT 10;



----------------------------------------------
----------------- Create a View --------------
----------------------------------------------

-- Let us create a view v_company_list using the select statement with numeric market cap
CREATE OR REPLACE VIEW public.v_company_list AS
 SELECT company_list.symbol,
    company_list.stock_mkt_name,
    company_list.company_name,
    company_list.market_cap,
    company_list.country,	
    company_list.sector,
    company_list.industry
   FROM company_list;

ALTER TABLE public.v_company_list
    OWNER TO postgres;

-- Check!
SELECT * FROM v_company_list;



----------------------------------------------------------
----------------- Import EOD (End of Day) Quotes ---------
----------------------------------------------------------
-- Create table eod_quotes
-- NOTE: ticker and date will be the PK; volume numeric, and other numbers real (4 bytes)
-- NOTE: double precision and bigint will result in an import error on Windows
-- DROP TABLE public.eod_quotes;
CREATE TABLE public.eod_quotes
(
    ticker character varying(16) COLLATE pg_catalog."default" NOT NULL,
    date date NOT NULL,
    adj_open real,
    adj_high real,
    adj_low real,
    adj_close real,
    adj_volume numeric,
    CONSTRAINT eod_quotes_pkey PRIMARY KEY (ticker, date)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.eod_quotes
    OWNER to postgres;

-- Import eod.csv to the table - it will take some time (approx. 17 million rows)

-- Check!
SELECT * FROM eod_quotes LIMIT 10;
SELECT COUNT(*) FROM eod_quotes; -- 16,891,814


-- And let us join the view with the table, extract the "NULL" sector in NASDAQ, store the results in a separate table
SELECT ticker,date,company_name,market_cap,country,adj_open,adj_high,adj_low,adj_close,adj_volume
INTO eod_quotes_nasdaq_null_sector
FROM v_company_list C INNER JOIN eod_quotes Q ON C.symbol=Q.ticker 
WHERE C.sector IS NULL AND C.stock_mkt_name='NASDAQ';

-- And let us join the view with the table, extract the "NULL" sector in NYSE, store the results in a separate table
SELECT ticker,date,company_name,market_cap,country,adj_open,adj_high,adj_low,adj_close,adj_volume
INTO eod_quotes_nyse_null_sector
FROM v_company_list C INNER JOIN eod_quotes Q ON C.symbol=Q.ticker 
WHERE C.sector IS NULL AND C.stock_mkt_name='NYSE';

-- And let us join the view with the table, extract the "NULL" sector in AMEX, store the results in a separate table
SELECT ticker,date,company_name,market_cap,country,adj_open,adj_high,adj_low,adj_close,adj_volume
INTO eod_quotes_amex_null_sector
FROM v_company_list C INNER JOIN eod_quotes Q ON C.symbol=Q.ticker 
WHERE C.sector IS NULL AND C.stock_mkt_name='AMEX';

-- Check!
SELECT * FROM eod_quotes_nasdaq_null_sector;
SELECT * FROM eod_quotes_nyse_null_sector;
SELECT * FROM eod_quotes_amex_null_sector;

-- Adjust the PK by adding a constraint - properties will not work!
ALTER TABLE public.eod_quotes_nasdaq_null_sector
    ADD CONSTRAINT eod_quotes_nasdaq_null_sector_pkey PRIMARY KEY (ticker, date);

ALTER TABLE public.eod_quotes_nyse_null_sector
    ADD CONSTRAINT eod_quotes_nyse_null_sector_pkey PRIMARY KEY (ticker, date);

ALTER TABLE public.eod_quotes_amex_null_sector
    ADD CONSTRAINT eod_quotes_amex_null_sector_pkey PRIMARY KEY (ticker, date);



-------------------------------------------------------------
-- Let us check the stock market data we have --------
-------------------------------------------------------------

-- What is the date range?
SELECT min(date),max(date) FROM eod_quotes;

-- Really? How many companies have full data in each year?
SELECT date_part('year',date), COUNT(*)/252 FROM eod_quotes GROUP BY date_part('year',date);

-- Let's decide on some practical time range (e.g. 2016-2021)
SELECT ticker, date, adj_close FROM eod_quotes WHERE date BETWEEN '2016-01-01' AND '2021-03-26';

-- And create a (simple version of) view v_eod_quotes_2016_2021
-- DROP VIEW public.v_eod_quotes_2016_2021;
CREATE OR REPLACE VIEW public.v_eod_quotes_2016_2021 AS
 SELECT eod_quotes.ticker,
    eod_quotes.date,
    eod_quotes.adj_close
   FROM eod_quotes
  WHERE eod_quotes.date >= '2016-01-01'::date AND eod_quotes.date <= '2021-03-26'::date;

ALTER TABLE public.v_eod_quotes_2016_2021
    OWNER TO postgres;

-- Check
SELECT min(date),max(date) FROM v_eod_quotes_2016_2021;

-- Let's download 2016-2021 of SP500TR from Yahoo https://finance.yahoo.com/quote/%5ESP500TR/history?p=^SP500TR

-- An analysis of the CSV indicated that to make it compatible with eod
-- - all unusual formatting has to be removed
-- - a "ticker" column with the value SP500TR need to be added 
-- - the volume column has to be updated (zeros are fine)
-- Import the (modified) CSV to a (new) data table eod_indices which reflects the original file's structure
-- DROP TABLE public.eod_indices;
CREATE TABLE public.eod_indices
(
    symbol character varying(16) COLLATE pg_catalog."default" NOT NULL,
    date date NOT NULL,
    open real,
    high real,
    low real,
    close real,
    adj_close real,
    volume double precision,
    CONSTRAINT eod_indices_pkey PRIMARY KEY (symbol, date)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.eod_indices
    OWNER to postgres;

-- Import the csv SP500TR.csv

-- Check
SELECT * FROM eod_indices LIMIT 10;

-- Create a view analogous to our quotes view: v_eod_indices_2016_2021
-- DROP VIEW public.v_eod_indices_2016_2020;
CREATE OR REPLACE VIEW public.v_eod_indices_2016_2021 AS
 SELECT eod_indices.symbol,
    eod_indices.date,
    eod_indices.adj_close
   FROM eod_indices
   WHERE eod_indices.date >= '2016-01-01'::date AND eod_indices.date <= '2021-03-26'::date;

ALTER TABLE public.v_eod_indices_2016_2021
    OWNER TO postgres;

-- CHECK
SELECT MIN(date),MAX(date) FROM v_eod_indices_2016_2021;

-- We can combine the two views using UNION which help us later (this will take a while)
SELECT * FROM v_eod_quotes_2016_2021 
UNION 
SELECT * FROM v_eod_indices_2016_2021;



-------------------------------------------------------------------------
-- Next, let's prepare a custom calendar (using a spreadsheet) --------
-------------------------------------------------------------------------
-- We need a stock market calendar to check our data for completeness
-- https://www.nyse.com/markets/hours-calendars
-- Because it is faster, we will use Excel (we need market holidays to do that)
-- We will use NETWORKDAYS.INTL function
-- date, y,m,d,dow,trading (format date and dow!)
-- Save as custom_calendar.csv and import to a new table
-- DROP TABLE public.custom_calendar;
CREATE TABLE public.custom_calendar
(
    date date NOT NULL,
    y integer,
    m integer,
    d integer,
    dow character varying(3) COLLATE pg_catalog."default",
    trading smallint,
    CONSTRAINT custom_calendar_pkey PRIMARY KEY (date)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.custom_calendar
    OWNER to postgres;

-- Import the csv custom_calendar.csv

-- CHECK:
SELECT * FROM custom_calendar LIMIT 10;

-- Let's add some columns to be used later: eom (end-of-month) and prev_trading_day
ALTER TABLE public.custom_calendar
    ADD COLUMN eom smallint;

ALTER TABLE public.custom_calendar
    ADD COLUMN prev_trading_day date;

-- CHECK:
SELECT * FROM custom_calendar LIMIT 10;

-- Now let's populate these columns
-- Identify trading days
SELECT * FROM custom_calendar WHERE trading=1;

-- Identify previous trading days via a nested query
-- Update the table with new data 
UPDATE custom_calendar
SET prev_trading_day = PTD.ptd
FROM (SELECT date, (SELECT MAX(CC.date) FROM custom_calendar CC WHERE CC.trading=1 AND CC.date<custom_calendar.date) ptd FROM custom_calendar) PTD
WHERE custom_calendar.date = PTD.date;

-- CHECK
SELECT * FROM custom_calendar ORDER BY date;

-- Identify the end of the month
-- Update the table with new data
UPDATE custom_calendar
SET eom = EOMI.endofm
FROM (SELECT CC.date,CASE WHEN EOM.y IS NULL THEN 0 ELSE 1 END endofm FROM custom_calendar CC LEFT JOIN
(SELECT y,m,MAX(d) lastd FROM custom_calendar WHERE trading=1 GROUP by y,m) EOM
ON CC.y=EOM.y AND CC.m=EOM.m AND CC.d=EOM.lastd) EOMI
WHERE custom_calendar.date = EOMI.date;

-- CHECK
SELECT * FROM custom_calendar ORDER BY date;



------------------------------------------------------------------
-- Determine the completeness of price or index data -------------
------------------------------------------------------------------

-- Incompleteness may be due to when the stock was listed/delisted or due to errors
-- First, let's see how many trading days were there between 2016 and 2021
SELECT COUNT(*) 
FROM custom_calendar 
WHERE trading=1 AND date BETWEEN '2016-01-01' AND '2021-03-26';

-- Now, let us check how many price items we have for each stock in the same date range
SELECT ticker,min(date) as min_date, max(date) as max_date, count(*) as price_count
FROM v_eod_quotes_2016_2021
GROUP BY ticker
ORDER BY price_count DESC;

-- Let's calculate the percentage of complete trading day prices for each stock and identify 99%+ complete
-- Let's store the excluded tickers (less than 99% complete in a table)
SELECT ticker, 'More than 1% missing' as reason
INTO exclusions_2016_2021
FROM v_eod_quotes_2016_2021
GROUP BY ticker
HAVING count(*)::real/(SELECT COUNT(*) FROM custom_calendar WHERE trading=1 AND date BETWEEN '2016-01-01' AND '2021-03-26')::real<0.99;

-- Also define the PK constraint for exclusions_2016_2021
ALTER TABLE public.exclusions_2016_2021
    ADD CONSTRAINT exclusions_2016_2021_pkey PRIMARY KEY (ticker);

-- Apply the same procedure for the indices and store exclusions (if any) in the same table: exclusions_2016_2021
INSERT INTO exclusions_2016_2021
SELECT symbol, 'More than 1% missing' as reason
FROM v_eod_indices_2016_2021
GROUP BY symbol
HAVING count(*)::real/(SELECT COUNT(*) FROM custom_calendar WHERE trading=1 AND date BETWEEN '2016-01-01' AND '2021-03-26')::real<0.99;

-- CHECK
SELECT * FROM exclusions_2016_2021;

-- Let combine everything we have (it will take some time to execute)
SELECT * FROM v_eod_indices_2016_2021 WHERE symbol NOT IN  (SELECT DISTINCT ticker FROM exclusions_2016_2021)
UNION
SELECT * FROM v_eod_quotes_2016_2021 WHERE ticker NOT IN  (SELECT DISTINCT ticker FROM exclusions_2016_2021);

-- Let's create a materialized view mv_eod_2015_2020
-- DROP MATERIALIZED VIEW public.mv_eod_2016_2021;
CREATE MATERIALIZED VIEW public.mv_eod_2016_2021
TABLESPACE pg_default
AS
 SELECT v_eod_indices_2016_2021.symbol,
    v_eod_indices_2016_2021.date,
    v_eod_indices_2016_2021.adj_close
   FROM v_eod_indices_2016_2021
  WHERE NOT (v_eod_indices_2016_2021.symbol::text IN ( SELECT DISTINCT exclusions_2016_2021.ticker
           FROM exclusions_2016_2021))
UNION
 SELECT v_eod_quotes_2016_2021.ticker AS symbol,
    v_eod_quotes_2016_2021.date,
    v_eod_quotes_2016_2021.adj_close
   FROM v_eod_quotes_2016_2021
  WHERE NOT (v_eod_quotes_2016_2021.ticker::text IN ( SELECT DISTINCT exclusions_2016_2021.ticker
           FROM exclusions_2016_2021))
WITH NO DATA;

ALTER TABLE public.mv_eod_2016_2021
    OWNER TO postgres;

-- We must refresh it (it will take time but it is one-time or infrequent)
REFRESH MATERIALIZED VIEW mv_eod_2016_2021 WITH DATA;

-- CHECK
SELECT * FROM mv_eod_2016_2021 LIMIT 10; -- faster
SELECT DISTINCT symbol FROM mv_eod_2016_2021; -- fast



--------------------------------------------------------
-- Calculate daily returns or changes ------------------
--------------------------------------------------------

-- We will assume the following definition R_1=(P_1-P_0)/P_0=P_1/P_0-1.0 (P:price, i.e., adj_close)
-- First let us join the calendar with the prices (and indices)
SELECT EOD.*, CC.* 
FROM mv_eod_2016_2021 EOD INNER JOIN custom_calendar CC ON EOD.date=CC.date;

-- Let's make another materialized view - this time with the returns
-- DROP MATERIALIZED VIEW public.mv_ret_2016_2021;
CREATE MATERIALIZED VIEW public.mv_ret_2016_2021
TABLESPACE pg_default
AS
 SELECT eod.symbol,
    eod.date,
    eod.adj_close / prev_eod.adj_close - 1.0::double precision AS ret
   FROM mv_eod_2016_2021 eod
     JOIN custom_calendar cc ON eod.date = cc.date
     JOIN mv_eod_2016_2021 prev_eod ON prev_eod.symbol::text = eod.symbol::text AND prev_eod.date = cc.prev_trading_day
WITH NO DATA;

ALTER TABLE public.mv_ret_2016_2021
    OWNER TO postgres;

-- We must refresh it (it will take time but it is one-time or infrequent)
REFRESH MATERIALIZED VIEW mv_ret_2016_2021 WITH DATA;

-- CHECK
SELECT * FROM mv_ret_2016_2021 LIMIT 10;



------------------------------------------------------------------
-- Identify potential errors and expand the exlusions list --------
------------------------------------------------------------------

-- Let's explore first
SELECT min(ret),avg(ret),max(ret) from mv_ret_2016_2021;

-- Make an arbitrary decision how much daily return is too much (e.g. 100%), identify such symbols
-- and add them to exclusions_2016_2021
INSERT INTO exclusions_2016_2021
SELECT DISTINCT symbol, 'Return higher than 100%' as reason FROM mv_ret_2016_2021 WHERE ret>1.0;

-- IMPORTANT: we have stored (materialized) views, we need to refresh them IN A SEQUENCE!
REFRESH MATERIALIZED VIEW mv_eod_2016_2021 WITH DATA;
REFRESH MATERIALIZED VIEW mv_ret_2016_2021 WITH DATA;

-- We can continue adding exclusions for various reasons - remember to refresh the stored views



---------------------------------------------------------------------------
-- Format price and return data for export to the analytical tool  --------
---------------------------------------------------------------------------

-- In order to export all data we will left-join custom_calendar with materialized views
-- This way we will not miss a trading day even if there is not a single record available
-- It is very important when data is updated daily
-- Daily prices export
SELECT PR.* 
INTO export_daily_prices_2016_2021
FROM custom_calendar CC LEFT JOIN mv_eod_2016_2021 PR ON CC.date=PR.date
WHERE CC.trading=1;

-- Daily returns export
SELECT PR.* 
INTO export_daily_returns_2016_2021
FROM custom_calendar CC LEFT JOIN mv_ret_2016_2021 PR ON CC.date=PR.date
WHERE CC.trading=1;

-- Export the csv daily_prices_2016_2021.csv and daily_returns_2016_2021.csv

-- Remove temporary (export_) tables because they are not refreshed
DROP TABLE export_daily_prices_2016_2021;
DROP TABLE export_daily_returns_2016_2021;



-------------------------------------------
-- Create a role for the database  --------
-------------------------------------------
-- rolename: stockmarketreadergp
-- password: read123
-- REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM stockmarketreader;
-- DROP USER stockmarketreadergp;
CREATE USER stockmarketreadergp WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'read123';

-- Grant read rights (on existing tables and views)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO stockmarketreadergp;

-- Grant read rights (for future tables and views)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT ON TABLES TO stockmarketreadergp;


-- Returns and portfolio will be analysed in R --