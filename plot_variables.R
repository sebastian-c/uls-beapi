library(readxl)
library(data.table)
library(ggplot2)
library(ggpmisc)


dir.create("output", showWarnings = FALSE)

#raw_data <- read_xlsx("raw_data/Table_La_Vallee - Copie.xlsx")
raw_data = fread("data/processed_data.csv")

ggplot(raw_data, aes(x = date, y = MLAI, colour = crop)) +
  geom_point() +
  labs(title = "LAI over time for each crop")

ggsave("output/Crop MLAI over time.png", height = 7, width = 10)


ggplot(raw_data, aes(x = MLAI, y = yield)) +
  geom_point() +
  facet_wrap(~crop, scales = "free_y")  

lm_fit <- lm(POTENTIEL ~ MLAI + as.factor(date), data=raw_data)
summary(lm_fit)

raw_data[, lm_pred := predict(lm_fit)]

plot_MLAI = function(yvar){

  
  g <- ggplot(raw_data, aes_string(y = yvar, x = "MLAI")) + 
    geom_point() +
    stat_poly_line() +
    stat_poly_eq() +
    facet_wrap(~date + crop, scales = "free_x") +
    labs(title = sprintf("Plot of %s vs MLAI over time", yvar))
  
  ggsave(sprintf("output/%s.png", yvar), g, height = 7, width = 10)
  return(g)
}

for (var in c("POTENTIEL", "PH_EAU", "CAO", "K2O", "MGO", "CEC", "MAT_ORG")) {
  plot_MLAI(var)
}

  
