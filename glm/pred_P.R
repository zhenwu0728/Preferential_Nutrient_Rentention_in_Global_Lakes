library(tidyverse)
library(fastDummies)

data_nla <- read.csv('../NLA2012_data.csv')
data_mdl_output <- read.csv('../NLAmodel_output.csv')
data <- cbind(data_nla, data_mdl_output)

cols <- c('P_Load', 'P_EN', 'P_DE', 
          'WRT', 'Vol', 'Area', 'Depth',
          'T')

# remove negative values
data_transformed <- data %>% filter(WRT>0, P_EN>0, Depth>0)

# tranform Chla to TrophicIndex
data_transformed$TrophicIndex <- cut(data_transformed$Chla, 
                                     breaks = c(0, 2, 7, 30, 1000), 
                                     labels = 1:4)
data_transformed$TI <- cut(data_transformed$Chla, 
                           breaks = c(0, 7, 30, 1000), 
                           labels = 1:3)

# data transformation
data_transformed[cols] <- log(data_transformed[cols])
data_transformed <- dummy_cols(data_transformed, 
                               select_columns = c("TI", 
                                                  "TrophicIndex"))
data_transformed <- data_transformed %>% mutate(En_rate = P_EN-P_Load,
                                                De_rate = P_DE-P_Load)


# remove outlier with En/De greater than 5 or smaller than 1/5
abnormal_ratio = 5
data_transformed_en <- data_transformed %>%
  filter(P_EN/P_Load > 1/abnormal_ratio,
         P_EN/P_Load < abnormal_ratio)
data_transformed_de <- data_transformed %>%
  filter(P_DE/P_Load > 1/abnormal_ratio,
         P_DE/P_Load < abnormal_ratio)


# build GLM model
lm_en <- glm(En_rate ~ WRT + Depth + Area + T + 
               TrophicIndex_2 + TrophicIndex_3 + TrophicIndex_4,
             data = data_transformed_en)
summary(lm_en)
r2_en <- with(summary(lm_en), 1 - deviance/null.deviance)

lm_de <- glm(De_rate ~ WRT + Area + 
               TI_2 + TI_3,
             data = data_transformed_de)
summary(lm_de)
r2_de <- with(summary(lm_de), 1 - deviance/null.deviance)

# import global data
data_trans_pred <- read.csv('./combined data/global_data_clean.csv')

# data transformation
cols <- c('WRT', 'T', 'Vol', 'Area', 'Depth')
data_trans_pred[cols] <- log(data_trans_pred[cols])
data_trans_pred <- dummy_cols(data_trans_pred, 
                              select_columns = c("TI", "TrophicIndex"))

# model prediction
en_pred <- predict.lm(lm_en, data_trans_pred,
                      interval = "predict", level = 0.75)
en_pred <- as_tibble(en_pred)
de_pred <- predict.lm(lm_de, data_trans_pred,
                      interval = "predict", level = 0.75)
de_pred <- as_tibble(de_pred)

# export model output
en_pred$ID <- data_trans_pred$ID
de_pred$ID <- data_trans_pred$ID
pred_out <- tibble(ID=en_pred$ID, global_en = en_pred$fit, global_de = de_pred$fit)
write.csv(pred_out, './combined data/global_P.csv')
