library(tidyverse)

data_nla <- read.csv('../data/NLA2012_data.csv')
data_mdl_output <- read.csv('../NLAmodel/NLAmodel_output.csv')
data_fit <- cbind(data_nla, data_mdl_output)
data_pred <- read.csv('../data/Global_data.csv', na.strings=c("#N/A"))
data_fit <- drop_na(data_fit)
data_pred <- drop_na(data_pred)
cols <- c('ID', 'Chla', 'Depth', 'Area', 'WRT', 'Vol', 'T')

colnames(data_pred) <-  cols

# remove negative values
data_trans_fit <- data_fit %>% filter(WRT>0, N_EN>0, Chla>0)
data_trans_pred <- data_pred %>% filter(Chla>0, Depth>0, 
                                        Area>0, WRT>0)
# tranform Chla to TrophicIndex
data_trans_fit$TrophicIndex <- cut(data_trans_fit$Chla, 
                                    breaks = c(0, 2, 7, 30, 1000), 
                                    labels = 1:4)
data_trans_fit$TI <- cut(data_trans_fit$Chla, 
                          breaks = c(0, 7, 30, 1000), 
                          labels = 1:3)

data_trans_pred$TrophicIndex <- cut(data_trans_pred$Chla, 
                          breaks = c(0, 2, 7, 30, 1000), 
                          labels = 1:4)
data_trans_pred$TI <- cut(data_trans_pred$Chla, 
                           breaks = c(0, 7, 30, 1000), 
                           labels = 1:3)

# tranform the data to the same units of the data of NLA2012
data_trans_pred$Area <- data_trans_pred$Area
data_trans_pred$Vol <- data_trans_pred$Vol * 1e6

# combine global data from two sources
data_trans_pred <- rbind(data_trans_fit[c(cols, "TI", "TrophicIndex")],
                         data_trans_pred[c(cols, "TI", "TrophicIndex")])

# export data for further analysis
write.csv(data_trans_pred, './global results/global_data_clean.csv')
