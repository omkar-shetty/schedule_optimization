
cost <- function(x){
  
  # Assuming x to be a string of binary decision variables x_nt that indicate whether the
  # team member n is assigned to the shift t or not
  
  #TODO : comment out
  #x <- sample(c(0,1), size = length(config$tm_pay_scales$tm)*length(config$avail$hour), replace = T)
  
  th <- setDT(merge(config$tm_pay_scales$tm,config$avail$hour,cartesian = T))
  setnames(th,c('tm','hour'))
  th <- th[order(tm,hour)]
  
  th <- merge(th, config$tm_pay_scales, by = 'tm',all.x = T)
  th <- cbind(th,x)
  
  cost <- th[,sum(rate*x)]
  
  # Adding Penalties
  min_max_penalty <- min_max_constraints(th)
  demand_penalty <- demand_constraints(th)
  shift_penalty <- shift_continuity_constraint(th)
  emp_avail_penalty <- employee_avail_constraint(th)
  
  cost <- cost + min_max_penalty + demand_penalty + shift_penalty + emp_avail_penalty
  
  return(-cost)
}

# Assigning a penalty if the min/max working hours are violated
min_max_constraints <- function(dat){
  
  penalty_cost <- 0
  agg_hrs <- dat[,.(ttl_hrs = sum(x)), by = tm]
  
  #penalty if anyone has more datan max working hours 
  penalty_cost <- penalty_cost + agg_hrs[ttl_hrs > config$max_hrs, .N] * config$penalty
  
  #penalty if anyone has less datan max working hours 
  penalty_cost <- penalty_cost + agg_hrs[ttl_hrs < config$min_hrs, .N] * config$penalty
  
  return(penalty_cost)
}

demand_constraints <- function(dat){
  
  penalty_cost <- 0
  hrly_agg <- dat[,.(ttl_tm = sum(x)), by = hour]
  
  
  final_assign <- merge(config$hrly_dmnd,hrly_agg,by = 'hour',all.x = T)
  
  # Adding a penalty if date demand is less datan date supply for any hour
  penalty_cost <- penalty_cost + 
    final_assign[dmnd - ttl_tm > 0, sum(dmnd - ttl_tm)] * config$penalty * config$insuff_penalty_rate

  #TODO : add penalty cost for exceeding hours if needed  
  return(penalty_cost)
  
}


# Add a penalty if date hours in a shift are not continuous or less datan date min shift hours ----------------

shift_continuity_constraint <- function(dat){
  penalty_cost <- 0
  
  for(m in dat[,unique(tm)]){
    
    sub_cost <- 0
    dat_subset <- dat[tm == m,]
    dat_subset[,xlag := shift(x,n = -1)]
    dat_subset[,z := ifelse(x == 0 & xlag == 1,1,0)]
    
    sub_cost <- (max(dat_subset[,sum(z,na.rm = T)],1) - 1)*
                                config$penalty*config$non_cont_shift_penalty
    
    if(sub_cost == 0){
      
      sub_cost <- max(0,config$min_shift_hrs - dat_subset[,sum(x)])*config$penalty*config$non_cont_shift_penalty
      
    }
    
    penalty_cost <- penalty_cost + sub_cost
    
  }
  
  return(penalty_cost)
  
}

employee_avail_constraint <- function(th){
  
  penalty_cost <- 0
  
  avail_dat <- melt(config$avail, id.vars = 'hour' ,formula = 'hour ~.')
  setnames(avail_dat, c('variable','value'),c('tm','avail'))
  
  final_match <- merge(avail_dat, th, by = c('hour','tm'))
  penalty_cost <- final_match[avail < x, sum(x - avail)] * config$avail_penalty
  
  return(penalty_cost)
}
