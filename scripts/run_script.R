 # toy example
# 
# p <- c(6, 5, 8, 9, 6, 7, 3) 
# w <- c(2, 3, 6, 7, 5, 9, 4) 
# W <- 9
# 
# knapsack <- function(x) { 
#   f <- sum(x * p) 
#   penalty <- sum(w) * abs(sum(x * w)-W) 
#   f - penalty 
#   }
# 
# GA <- ga(type = "binary", fitness = knapsack, nBits = length(w),
#          maxiter = 1000, run = 200, popSize = 20)
# summary(GA)

rm(list = ls()); gc(); cat('\f')

# Initiating libraries

library(data.table)
library(GA)
library(ggplot2)
library(doParallel)

# Sourcing functions & config

source('configs/init_config.R')
source('functions/util.R')

GA <- ga(type = "binary", fitness = cost, 
         nBits = length(config$tm_pay_scales$tm) * length(config$hrly_dmnd$hour),
          maxiter = 1500, run = 500, popSize = 20)

summary(GA)

x_opt <- data.table(t(GA@solution))
setnames(x_opt,'x')

x <- x_opt


asgn <- setDT(merge(config$tm_pay_scales$tm,config$avail$hour,cartesian = T))
setnames(asgn,c('tm','hour'))
asgn <- asgn[order(tm,hour)]

asgn <- merge(asgn, config$tm_pay_scales, by = 'tm',all.x = T)
asgn <- cbind(asgn,x_opt)

opt_result <- asgn[,.(assigned_hrs = sum(x)), by = hour]

opt_result <- merge(opt_result, config$hrly_dmnd, by = 'hour')

ggplot(data = opt_result) + 
  geom_line(aes(x = hour, y = dmnd), color = 'red') +
  geom_line(aes(x = hour, y = assigned_hrs), color = 'blue') + theme_bw()

ggplot(data = asgn) + geom_area(aes(x = hour, y = x)) + theme_bw() +
  theme(axis.text.y = element_blank()) +  
  facet_grid(tm~.)


