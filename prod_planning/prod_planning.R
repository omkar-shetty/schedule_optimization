

# Clear Up ----------------------------------------------------------------
rm(list = ls()); gc(); cat('\f')


# Libraries ---------------------------------------------------------------

library(lpSolve)
library(data.table)


# Define Config -----------------------------------------------------------

config <- list(
  
  # store params
  sku_cnt = 1, #no of BBQ chicken SKUs
  open_hr = 10, #starting time for sales
  close_hr = 18, #closing time for sales
  batch = 10, #how many chooks can be processed in an oven/rotisserie at a time
  oven_cnt = 1, #how many ovens
  
  # revenue params
  item_price = 10, #price of each unit in dollars, assuminf uniform
  item_cost = 6, #cost of each unit in dollars, assuminf uniform
  batch_cost = 20, #cost of running the oven for 1 batch of chooks
  
  #demand params
  min_demand = 0, #min hourly demand for product
  max_demand = 5 #max hourly demand for product
  
)

config[['window_cnt']] <- length(seq(config$open_hr, config$close_hr))

# generate dataset --------------------------------------------------------
set.seed(123)

dmnd_dat <- data.table(
  SALES_HR = rep(seq(config$open_hr, config$close_hr), config$sku_cnt),
  SKU = rep(sample(LETTERS, size = config$sku_cnt), each = config$window_cnt),
  FCAST = sample(size = config$window_cnt * config$sku_cnt, x = seq(config$min_demand, config$max_demand), replace = T),
  CAPACITY = config$batch * config$oven_cnt
)

dmnd_dat[,CUM_FCAST := cumsum(FCAST), SKU]
dmnd_dat[,CUM_MAX_PROD := cumsum(CAPACITY), SKU]

const1_diag <- data.table(diag(x = 1, nrow = config$window_cnt, ncol = config$window_cnt, names = TRUE))

const2_diag <- lower.tri(diag(config$window_cnt),diag = T)
const2_diag <- data.table(ifelse(as.matrix(const2_diag),1,0))


# Setting up optimization -------------------------------------------------

f.obj <- rep(x = config$item_cost, each = config$window_cnt)

f.con <- as.matrix(rbind(const1_diag, const1_diag, const2_diag))

f.dir <- c(rep('>=',config$window_cnt), rep('<=',config$window_cnt),rep('>=',config$window_cnt))

f.rhs <- c(rep(0, config$window_cnt), dmnd_dat$CAPACITY, dmnd_dat$CUM_FCAST)

lp_sol <- lp("min", f.obj, f.con, f.dir, f.rhs, int.vec = 1:config$window_cnt)
lp_sol$solution
