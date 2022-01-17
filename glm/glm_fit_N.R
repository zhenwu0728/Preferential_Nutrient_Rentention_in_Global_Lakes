library(tidyverse)
library(fastDummies)

data_nla <- read.csv('../NLA2012_data.csv')
data_mdl_output <- read.csv('../NLAmodel_output.csv')
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

# data transformation
data_transformed[cols] <- log(data_transformed[cols])
data_transformed <- dummy_cols(data_transformed, 
                               select_columns = c("TI", 
                                                  "TrophicIndex"))
data_transformed <- data_transformed %>% mutate(En_rate = N_EN-N_Load,
                                                De_rate = N_DE-N_Load)

# remove outlier with En/De greater than 5 or smaller than 1/5
abnormal_ratio = 5
data_transformed_en <- data_transformed %>%
  filter(N_EN/N_Load > 1/abnormal_ratio,
         N_EN/N_Load < abnormal_ratio)
data_transformed_de <- data_transformed %>%
  filter(N_DE/N_Load > 1/abnormal_ratio,
         N_DE/N_Load < abnormal_ratio)

# build GLM model
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

# plot true~pred
pred_en <- predict.lm(lm_en, data_transformed_en)
ggplot() + 
  geom_point(aes(data_transformed_en$En_rate, pred_en), 
             color='orangered') + 
  geom_abline(slope = 1, intercept = 0, lwd=1, 
              color='blue', alpha=0.5) + 
  geom_text(
    aes(-5, 4.5, 
        label = str_c('R^2==', format(r2_en, digits = 5))),
    parse = TRUE,
    ) + 
  theme(legend.position = "none") + 
  xlab("En ratio True") + ylab("En ratio Predicted") + 
  coord_fixed(ratio = 1) +
  xlim(min(data_transformed_en$En_rate, pred_en), 
       max(data_transformed_en$En_rate, pred_en)) + 
  ylim(min(data_transformed_en$En_rate, pred_en), 
       max(data_transformed_en$En_rate, pred_en)) + 
  ggsave("./fit plots/dm_En_N.png", width = 5, height = 4, dpi = 600)

pred_de <- predict.lm(lm_de, data_transformed_de)
ggplot() + 
  geom_point(aes(data_transformed_de$De_rate, pred_de), 
             color='orangered') + 
  geom_abline(slope = 1, intercept = 0, lwd=1, 
              color='blue', alpha=0.5) + 
  geom_text(
    aes(-3, 4.5, 
        label = str_c('R^2==', format(r2_de, digits = 5))),
    parse = TRUE,
  ) +
  theme(legend.position = "none") + 
  xlab("De ratio True") + ylab("De ratio Predicted") + 
  coord_fixed(ratio = 1) +
  xlim(min(data_transformed_de$De_rate, pred_de), 
       max(data_transformed_de$De_rate, pred_de)) + 
  ylim(min(data_transformed_de$De_rate, pred_de), 
       max(data_transformed_de$De_rate, pred_de)) + 
  ggsave("./fit plots/dm_De_N.png", width = 5, height = 4, dpi = 600)

# output statistics
write.csv(coef(summary(lm_en))[,c(1, 4)], 
          './coef tables/En_N.csv')
write.csv(coef(summary(lm_de))[,c(1, 4)], 
          './coef tables/De_N.csv')

