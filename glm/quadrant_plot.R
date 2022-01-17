library(tidyverse)

dat <- read.csv('../All_data.csv')

dat_plot <- dat[, c("TrophicIndex", "ln.En.De..of.N", "ln.En.De..of.P")]
colnames(dat_plot) <- c("TI", "ENDEN", "ENDEP")
dat_plot$TI = as.factor(dat_plot$TI)
dat_plot$ENDEN <- as.numeric(dat_plot$ENDEN)
dat_plot$ENDEP <- as.numeric(dat_plot$ENDEP)

ggplot() +
  geom_point(data = dat_plot, aes(x = ENDEN, y = ENDEP, color = TI), 
             alpha = 0.8, size = 1.5) +
  geom_vline(xintercept = 0, color = "grey", size = 1) +
  geom_hline(yintercept = 0, color = "grey", size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  scale_color_manual(values = c("#00B050", "#001D5E", "#FFC000", "#C00000")) +
  geom_text(aes(4.3, 5, label = "1:1")) + 
  geom_text(aes(1, 3.8, label = "A"), size = 6) + 
  geom_text(aes(-4, 3.8, label = "B"), size = 6) + 
  geom_text(aes(-8.2, -2, label = "C"), size = 6) + 
  geom_text(aes(4, -8.2, label = "D"), size = 6) + 
  xlab("Ln(En/De) of N") + ylab("Ln(En/De) of P") +
  scale_x_continuous(breaks = seq(-10, 5, by = 2), limits = c(-10, 5)) + 
  scale_y_continuous(breaks = seq(-10, 5, by = 2), limits = c(-10, 5)) + 
  coord_fixed(ratio = 1) +
  theme_bw() +
  theme(legend.position=c(0.2, 0.9), legend.direction='horizontal', 
        legend.background = element_blank(), legend.key = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  ggsave("./quadrant plots/quadrant4.png", width = 6.5, height = 6.5, dpi = 600)

ggplot() +
  geom_point(data = dat_plot, aes(x = ENDEN, y = ENDEP, color = factor(TI)), 
             alpha = 0.8, size = 1) +
  facet_wrap(~ TI, ncol = 2) +
  scale_color_manual(values = c("#00B050", "#001D5E", "#FFC000", "#C00000"))+
  geom_vline(xintercept = 0, color = "grey", size = 1) +
  geom_hline(yintercept = 0, color = "grey", size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed")+
  xlab("Ln(En/De) of N") + ylab("Ln(En/De) of P")+
  scale_x_continuous(breaks = seq(-10, 5, by = 2), limits = c(-10, 5)) +
  scale_y_continuous(breaks = seq(-10, 5, by = 2), limits = c(-10, 5)) +
  labs(color = "TI")+
  coord_fixed(ratio = 1) +
  theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  ggsave("./quadrant plots/quadrant_facets.png", width = 5, height = 5, dpi = 600)

