config <-     list(
                penalty = 300
                ,insuff_penalty_rate = 3
                ,non_cont_shift_penalty = 5
                ,avail_penalty = 300
                #reg_rate = 15 
                #,ot_rate =  20
                #,cntrct_mult = 1.2
                ,max_hrs = 9
                ,min_hrs = 0
                ,min_shift_hrs = 4
                
                ,tm_pay_scales = data.table(tm = c('Al','Bee','Cal','Dani','Eric','Fred','Ger','Halle',
                                                   'Indy','Jack')
                                                ,rate = c(15,15,18,18,18,15,15,15,18,18))
                
                ,avail = data.table( hour = seq(7,22),
                                      Al = c(rep(0,2),rep(1,9),rep(0,5)),
                                      Bee = c(rep(1,6),rep(0,10)),
                                      Cal = c(rep(0,8),rep(1,5),rep(0,3)),
                                      Dani = c(rep(0,1),rep(1,10),rep(0,5)),
                                      Eric = c(rep(1,8),rep(0,8)),
                                      Fred = c(rep(0,7),rep(1,9)),
                                      Ger = c(rep(1,5),rep(0,5),rep(1,6)),
                                      Halle = rep(1,16),
                                      Indy = c(rep(1,5),rep(0,6),rep(1,5)),
                                      Jack = rep(0,16)
                                     )
                
                ,hrly_dmnd = data.table(hour = seq(7,22),
                                         dmnd = c(1,1,2,2,3,3,3,2,2,2,3,3,3,2,1,1))
            )
