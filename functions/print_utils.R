
print_dmnd <- function(config){
  
  ggplot(data = config$hrly_dmnd) + geom_line(aes(x = hour, y = dmnd)) +
    theme_bw() + labs(x = 'hour', y = 'demand')
    
}s