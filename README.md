# Preferential_Nutrient_Rentention_in_Global_Lakes
This repo contains the data and code used in the paper "Preferential Phosphorus Retention in Lakes Exacerbates the Imbalance of Global Nutrient Cycles"

## 1. NLA2012 Nutrient Budget Model
`NLAmodel.stan` is the `stan` code for NLA2012 model.

`NLA2012_data.csv` contains the data used in NLA2012 model.

`NLAmodel.ipynb` runs the `stan` code in `NLAmodel.stan` using data in `NLA2012_data.csv` and generate model output in `NLAmodel_output.csv`.

## 2. Generalized Linear Model

`HydroLAKES_data.csv` contains the data collected from HydroLAKES database and the water temperature data fitted by air temperature data.

`global_data_clean.R` is used for the data cleaning and density plots for the comparison between NLA2012 data and the global data. Cleaned data is in folder `global results/` named as `global_data_clean.csv`.

`glm_N.R` and `glm_P.R` are code for GLM models to  relate EN and DE of N and P with multiple explanatory variables including water residential time, surface water temperature, water depth, area and trophic index. Statistics are generated in the folder `fitting statistics/`. Then cleaned global data is used to predict the EN and DE of N and P of the global lakes and placed in the folder `global results/`, namely `global_N.csv` and `global_P.csv` respectively.

## 3. Global Up-scaling