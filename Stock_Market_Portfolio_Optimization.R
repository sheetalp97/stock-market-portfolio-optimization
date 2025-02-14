# Stock Market Case in R
rm(list=ls(all=T)) 

#We are going to perform most of the transformation tasks in R


# Connect to PostgreSQL ---------------------------------------------------

require(RPostgres) # did you install this package?
require(DBI)
conn <- dbConnect(RPostgres::Postgres()
                  ,user="stockmarketreadergp"
                  ,password="read123"
                  ,host="localhost"
                  ,port=5432
                  ,dbname="stockmarket_GP"
)

#custom calendar
qry<-"SELECT * FROM custom_calendar WHERE date BETWEEN '2015-12-31' AND '2021-03-26' ORDER by date"
ccal<-dbGetQuery(conn,qry)

#eod prices and indices
qry1="SELECT symbol,date,adj_close FROM eod_indices WHERE date BETWEEN '2015-12-31' AND '2021-03-26'"
qry2="SELECT ticker,date,adj_close FROM eod_quotes WHERE date BETWEEN '2015-12-31' AND '2021-03-26' 
AND ticker IN ('ENS', 'PCTY', 'FCNCA', 'CBFV', 'MPW', 'ORAN', 'FWONK', 'LHCG', 'POR', 'AGM', 'MIELY', 'BURL', 'SMTOY', 'ESLOY', 'MLVF')"
eod<-dbGetQuery(conn,paste(qry1,'UNION',qry2))
dbDisconnect(conn)
rm(conn)

# Check
#Explore
head(ccal)
tail(ccal)
nrow(ccal)

head(eod)
tail(eod)
nrow(eod)

head(eod[which(eod$symbol=='SP500TR'),])

#We may need one more data item (for 2015-12-31)
eod_row<-data.frame(symbol='SP500TR',date=as.Date('2015-12-31'),adj_close=3821.60)
eod<-rbind(eod,eod_row)
tail(eod)


# Use Calendar --------------------------------------------------------

tdays<-ccal[which(ccal$trading==1),,drop=F]
head(tdays)
nrow(tdays)-1 #trading days between 2016 and 2021

# Completeness ----------------------------------------------------------
# Percentage of completeness
pct<-table(eod$symbol)/(nrow(tdays)-1)
selected_symbols_daily<-names(pct)[which(pct>=0.99)]
eod_complete<-eod[which(eod$symbol %in% selected_symbols_daily),,drop=F]

#check
head(eod_complete)
tail(eod_complete)
nrow(eod_complete)


# Transform (Pivot) -------------------------------------------------------

require(reshape2)
eod_pvt<-dcast(eod_complete, date ~ symbol,value.var='adj_close',fun.aggregate = mean, fill=NULL)
#check
eod_pvt[1:10,] #first 10 rows and all columns 
ncol(eod_pvt) # column count
nrow(eod_pvt)


# Merge with Calendar -----------------------------------------------------
eod_pvt_complete<-merge.data.frame(x=tdays[,'date',drop=F],y=eod_pvt,by='date',all.x=T)

#check
eod_pvt_complete[1:10,] #first 10 rows and all columns 
ncol(eod_pvt_complete)
nrow(eod_pvt_complete)

#use dates as row names and remove the date column
rownames(eod_pvt_complete)<-eod_pvt_complete$date
eod_pvt_complete$date<-NULL #remove the "date" column

#re-check
eod_pvt_complete[1:10] #first 10 rows and all columns 
ncol(eod_pvt_complete)
nrow(eod_pvt_complete)


# Missing Data Imputation -----------------------------------------------------
# We can replace a few missing (NA or NaN) data items with previous data
# Let's say no more than 3 in a row...
require(zoo)
eod_pvt_complete<-na.locf(eod_pvt_complete,na.rm=F,fromLast=F,maxgap=3)
#re-check
eod_pvt_complete[1:10,] #first 10 rows and all columns 
ncol(eod_pvt_complete)
nrow(eod_pvt_complete)


# Calculating Returns -----------------------------------------------------
require(PerformanceAnalytics)
eod_ret<-CalculateReturns(eod_pvt_complete)

#check
eod_ret[1:10,] #first 10 rows and all columns 
ncol(eod_ret)
nrow(eod_ret)

#remove the first row
eod_ret<-tail(eod_ret,-1) #use tail with a negative value
#check
eod_ret[1:10,] #first 10 rows and all columns 
ncol(eod_ret)
nrow(eod_ret)


# Check for extreme returns -------------------------------------------
# There is colSums, colMeans but no colMax so we need to create it
colMax <- function(data) sapply(data, max, na.rm = TRUE)
# Apply it
max_daily_ret<-colMax(eod_ret)
max_daily_ret #first 10 max returns
# And proceed just like we did with percentage (completeness)
selected_symbols_daily<-names(max_daily_ret)[which(max_daily_ret<=1.00)]
length(selected_symbols_daily)


#subset eod_ret
eod_ret<-eod_ret[,which(colnames(eod_ret) %in% selected_symbols_daily),drop=F]
#check
eod_ret[1:10,] #first 10 rows and all columns 
ncol(eod_ret)
nrow(eod_ret)


# Tabular Return Data Analytics -------------------------------------------

# We will select 'SP500TR' and selected 15 tickers assigned to group members
# We need to convert data frames to xts (extensible time series)
Ra<-as.xts(eod_ret[,c('ENS', 'PCTY', 'FCNCA', 'CBFV', 'MPW', 'ORAN', 'FWONK', 'LHCG', 'POR', 'AGM', 'MIELY', 'BURL', 'SMTOY', 'ESLOY', 'MLVF'),drop=F])
Rb<-as.xts(eod_ret[,'SP500TR',drop=F]) #benchmark

head(Ra)
tail(Ra)
head(Rb)

# And now we can use the analytical package...

# Stats
table.Stats(Ra)

# Distributions
table.Distributions(Ra)

# Returns
table.AnnualizedReturns(cbind(Rb,Ra),scale=252)
# Annualized Sharpe - Risk adjusted return (higher the better)(higher return lower risk)

# Accumulate Returns
acc_Ra<-Return.cumulative(Ra);acc_Ra
acc_Rb<-Return.cumulative(Rb);acc_Rb

# Capital Assets Pricing Model
table.CAPM(Ra,Rb)
# Beta (measure of risk - slope parameter of SLR between asset and market), alpha is intercept


# Graphical Return Data Analytics -----------------------------------------

# Cumulative returns chart
chart.CumReturns(Ra,legend.loc = 'topleft')
chart.CumReturns(Rb,legend.loc = 'topleft')

#Box plots
chart.Boxplot(cbind(Rb,Ra))
chart.Drawdown(Ra,legend.loc = 'bottomleft')


# MV Portfolio Optimization -----------------------------------------------

# withhold the last 58 trading days (all of 2021 data)
Ra_training<-head(Ra,-58)
Rb_training<-head(Rb,-58)

# Cummulative returns for Range 1
acc_Ra_training<-Return.cumulative(Ra_training);acc_Ra_training
chart.CumReturns(Ra_training,legend.loc = 'topleft')

# use the last 58 trading days for testing (all of 2021 data)
Ra_testing<-tail(Ra,58)
Rb_testing<-tail(Rb,58)

#optimize the MV (Markowitz 1950s) portfolio weights based on training
table.AnnualizedReturns(Rb_training)
mar<-mean(Rb_training) #we need daily minimum acceptable return


require(PortfolioAnalytics)
require(ROI) # make sure to install it
require(ROI.plugin.quadprog)  # make sure to install it
pspec<-portfolio.spec(assets=colnames(Ra_training))
pspec<-add.objective(portfolio=pspec,type="risk",name='StdDev')
pspec<-add.constraint(portfolio=pspec,type="full_investment")
pspec<-add.constraint(portfolio=pspec,type="return",return_target=mar)
#pspec<-add.constraint(portfolio=pspec,type="long_only")

#optimize portfolio
opt_p<-optimize.portfolio(R=Ra_training,portfolio=pspec,optimize_method = 'ROI')

#extract weights (negative weights means shorting)
opt_w<-opt_p$weights

# Weights for Range 1 (2016-2020)
round(opt_w, 4)

# Sum of weights for Range 1 (2016-2020)
sum(round(opt_w, 4))

#apply weights to test returns
Rp<-Rb_testing
#define new column that is the dot product of the two vectors
Rp$ptf<-Ra_testing %*% opt_w

#check
head(Rp)
tail(Rp)

#Compare basic metrics
table.AnnualizedReturns(Rp)
#std dev is sqrt(var) that corresponds to risk, less vairiance less risk

# Chart Hypothetical Portfolio Returns ------------------------------------

chart.CumReturns(Rp,legend.loc = 'bottomright')
