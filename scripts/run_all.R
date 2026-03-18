# scripts/run_all.R
suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(car)
  library(emmeans)
  library(MuMIn)
  library(scales)
  library(patchwork)
  library(openxlsx)
  library(broom)
})

CONFIG <- list(
  data_file   = file.path("data", "final data-R.xlsx"),
  sheet       = "Soil Data (R)",
  na_val      = "na",
  out_root    = "outputs",
  diag_dir    = file.path("outputs", "Residual Diagnostics"),
  model_dir   = file.path("outputs", "Model Summaries"),
  aic_dir     = file.path("outputs", "AIC"),
  figs_dir    = file.path("outputs", "Final Figures"),
  summ_dir    = file.path("outputs", "Data Summaries"),
  outputs_dir = file.path("outputs", "Model with Raw Outputs")
)

# ensure output folders
dirs <- CONFIG[c(
  "out_root", "diag_dir", "model_dir", 
  "aic_dir", "figs_dir", "outputs_dir", "summ_dir"
)]

invisible(
  lapply(dirs, function(d) dir.create(d, recursive = TRUE, showWarnings = FALSE))
)

# 1) load + clean
source(file.path("scripts","01_Load_Clean.R"))
source(file.path("scripts","utils.R"))

# 2) summaries
source(file.path("scripts","02_Summaries.R"))

# 3) LMs
source(file.path("scripts","03_Models_Soil.R"))
source(file.path("scripts","04_Models_Yield.R"))
source(file.path("scripts","05_Models_Balanced-Verification.R"))

# 4) AIC blocks
source(file.path("scripts","06_AIC_Crop-Soil.R"))

# 5) Residual Diagnostics
source(file.path("scripts","07_Residual-Diagnostics.R"))

# 6) Figures - Model outputs
source(file.path("scripts","08_Figure_Model-Outputs.R"))
source(file.path("scripts","09_Figure_Model-Outputs-Balanced-vs-Raw.R"))

# 7) Forest plots
source(file.path("scripts","10_Figure_Forest-Plot-Fertility.R"))
source(file.path("scripts","11_Figure_Forest-Plot-Soil-Condition.R"))

# 8) Fertility thresholds
source(file.path("scripts","12_Figure_Fertility-Threshold-Macro.R"))
source(file.path("scripts","13_Figure_Fertility-Threshold-Micro.R"))
