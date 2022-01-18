library(tidyverse)
library(fastDummies)

## data reading
data_nla <- read.csv('../NLA2012_data.csv')
data_mdl_output <- read.csv('../NLAmodel_output.csv')
data_global <- read.csv('./global results/global_data_clean.csv')

## data cleaning
data <- cbind(data_nla, data_mdl_output)

cols <- c('N_Load', 'N_EN', 'N_DE', 
          'WRT', 'Vol', 'Area', 'Depth',
          'T')

# remove negative values
data_transformed <- data %>% filter(WRT>0, N_EN>0, Depth>0)

# remove NA
data_transformed <- drop_na(data_transformed)

# tranform Chla to TrophicIndex
data_transformed$TrophicIndex <- cut(data_transformed$Chla, 
                                    breaks = c(0, 2, 7, 30, 1000), 
                                    labels = 1:4)
data_transformed$TI <- cut(data_transformed$Chla, 
                          breaks = c(0, 7, 30, 1000), 
                          labels = 1:3)

# data transformation of fitting data
data_transformed[cols] <- log(data_transformed[cols])
data_transformed <- dummy_cols(data_transformed, 
                               select_columns = c("TI", 
                                                  "TrophicIndex"))
data_transformed <- data_transformed %>% mutate(En_rate = N_EN-N_Load,
                                                De_rate = N_DE-N_Load)
# data transformation of predicting data
cols <- c('WRT', 'T', 'Vol', 'Area', 'Depth')
data_global[cols] <- log(data_global[cols])
data_global <- dummy_cols(data_global, 
                          select_columns = c("TI", "TrophicIndex"))

# remove outlier with En/De greater than 5 or smaller than 1/5
abnormal_ratio = 5
data_transformed_en <- data_transformed %>%
  filter(N_EN/N_Load > 1/abnormal_ratio,
         N_EN/N_Load < abnormal_ratio)
data_transformed_de <- data_transformed %>%
  filter(N_DE/N_Load > 1/abnormal_ratio,
         N_DE/N_Load < abnormal_ratio)


## GLM fitting
# build GLM model with all variables
lm_en <- glm(En_rate ~ WRT + T + Depth + Area + 
              TrophicIndex_2 + TrophicIndex_3 + TrophicIndex_4,
            data = data_transformed_en)
summary(lm_en)
r2_en <- with(summary(lm_en), 1 - deviance/null.deviance)

lm_de <- glm(De_rate ~ WRT + T + Depth + Area + 
               TrophicIndex_2 + TrophicIndex_3 + TrophicIndex_4,
            data = data_transformed_de)
summary(lm_de)
r2_de <- with(summary(lm_de), 1 - deviance/null.deviance)

# export fitting statistics
write.csv(coef(summary(lm_en))[,c(1, 4)], 
          './fitting statistics/En_N.csv')
write.csv(coef(summary(lm_de))[,c(1, 4)], 
          './fitting statistics/De_N.csv')

## GLM predicting
# build GLM model with significant predictors
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

# model predictions
en_pred <- predict.lm(lm_en, data_global,
                      interval = "predict", level = 0.75)
en_pred <- as_tibble(en_pred)
de_pred <- predict.lm(lm_de, data_global,
                      interval = "predict", level = 0.75)
de_pred <- as_tibble(de_pred)

# export global model predictions
en_pred$ID <- data_global$ID
de_pred$ID <- data_global$ID
pred_out <- tibble(ID=en_pred$ID, global_en = en_pred$fit, global_de = de_pred$fit)
write.csv(pred_out, './global results/global_N.csv')
