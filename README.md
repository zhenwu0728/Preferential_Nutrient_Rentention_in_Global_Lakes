# Preferential_Nutrient_Rentention_in_Global_Lakes
This repo contains the data and code used in the paper "Preferential Phosphorus Retention in Lakes Exacerbates the Imbalance of Global Nutrient Cycles"

## 1. NLA2012 Nutrient Budget Model
`NLAmodel.stan` is the `stan` code for NLA2012 model.

`NLA2012_data.csv` contains the data used in NLA2012 model.

`NLAmodel.ipynb` runs the `stan` code in `NLAmodel.stan` using data in `NLA2012_data.csv` and generate model output in `NLAmodel_output.csv`.

## 2. Generalized Linear Model

`HydroLAKES_data.csv` contains the data collected from HydroLAKES database and the water temperature data fitted by air temperature data.

`glm_fit_N.R` and `glm_fit_P.R` are code for GLM model to  relate EN and DE of N and P with multiple explanatory variables including water residential time, surface water temperature, water depth, area and trophic index. Fit plots are generated in the folder `fit plots/`; statistics are generated in the folder `coef tables/`.

`global_data_clean.R` is used for the data cleaning and density plots for the comparison between NLA2012 data and the global data. Cleaned data is in folder `combined data/`; density plots are generated in the folder `dist plots/`.

`pred_N.R` and `pred_P.R` are code for the prediction of the global data using the GLM models built in `glm_fit_N.R` and `glm_fit_P.R`. The prediction is placed in the folder `combined data/`.

`quadrant_plot.R` is used for the scatter plot of **Ln(En/De) of P** versus **Ln(En/De) of N**. Scatter plots are output in the folder `quadrant plots/`.

`All_data.csv` is constructed manually using `NLA2012_data.csv`, `HydroLAKES_data.csv` and the output of `global_N.csv` and `global_P.csv`.

## 3. Global Up-scaling