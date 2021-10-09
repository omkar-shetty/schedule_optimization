rm(list = ls()); gc(); cat('\f')

# Initiating libraries

library(data.table)
library(GA)
library(ggplot2)
library(doParallel)

# Sourcing functions & config

source('configs/init_config.R')
source('functions/util.R')


# Hand_crafted
asgn <- readRDS(file = "C:/Data_Science/Common_Data/schedule_optimization/tm_10_2535.rds")
init_x <- t(as.matrix(asgn$x))

GA <- ga(type = "binary", fitness = cost, 
         nBits = length(config$tm_pay_scales$tm) * length(config$hrly_dmnd$hour),
          maxiter = 1500, run = 200, popSize = 50, elitism = 5, suggestions = init_x)

summary(GA)



x_opt <- data.table(t(GA@solution))

x <- x_opt$V2

asgn <- setDT(merge(config$tm_pay_scales$tm,config$avail$hour,cartesian = T))
setnames(asgn,c('tm','hour'))
asgn <- asgn[order(tm,hour)]

asgn <- merge(asgn, config$tm_pay_scales, by = 'tm',all.x = T)
asgn <- cbind(asgn,x)

opt_result <- asgn[,.(assigned_hrs = sum(x)), by = hour]

opt_result <- merge(opt_result, config$hrly_dmnd, by = 'hour')

ggplot(data = opt_result) + 
  geom_line(aes(x = hour, y = dmnd), color = 'red') +
  geom_line(aes(x = hour, y = assigned_hrs), color = 'blue') + theme_bw()

tm_avail <- melt(config$avail,id.vars = 'hour')
setnames(tm_avail,c('hour','tm','avail'))
avail_asgn <- tm_avail[asgn, on = c('hour','tm')]

ggplot(data = avail_asgn) + geom_area(aes(x = hour, y = x), fill = 'black', alpha = 0.8) + 
  geom_area(aes(x = hour, y = avail), fill = 'green', alpha = 0.5) +
  theme_bw() +
  theme(axis.text.y = element_blank()) +  
  facet_grid(tm~.)


