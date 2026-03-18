# ============================================================
# R/01_Load_Clean.R
# ============================================================

load_data <- function(cfg = CONFIG){
  raw <- readxl::read_excel(cfg$data_file, sheet = cfg$sheet, na = cfg$na_val)
  
  d <- raw |>
    mutate(
      treatment  = factor(`Treatment`, levels = c("1","2","3","4","5")),
      replicate  = factor(`Replicate`, levels = c("1", "2", "3", "4")),
      trt_rep    = factor(paste0(treatment, "-", replicate)),
      bed        = factor(`Bed`),
      year       = factor(as.character(Year), levels = c("T0","2022","2023","2024")),
      SOC        = `TOC (%)`,
      POXC       = `POX-C (mg/kg)`,
      C          = `C (%)`,
      pH         = `pH`,
      EC         = `ES (us/cm)`/1000,
      totalN     = `N (%)`,
      NH4        = `NH4+ (ppm)`,
      P          = `MIII P (ppm)`,
      BrayP      = `Bray P (ppm)`,
      Ca         = `MIII Ca (ppM)`,
      Cu         = `MIII Cu (ppm)`,
      Fe         = `MIII Fe (ppm)`,
      K          = `MIII K (ppm)`,
      Mg         = `MIII Mg (ppm)`,
      Mn         = `MIII Mn (ppm)`,
      Na         = `MIII Na (ppm)`,
      Zn         = `MIII Zn (ppm)`,
      BD         = `Bulk Density`,
      SLAKES     = `STAB10`,
      clay       = `Clay (%)`,
      bean       = `Bean Harvest (g)`,
      totalYield = `Total Harvest (g)`,
      carrot1    = `Carrot Harvest Gr 1 (g)`,
      carrot2    = `Carrot Harvest Gr 2 (g)`,
      carrotTop  = `Carrot Harvest Tops (g)`,
      kale       = `Kale Harvest (g)`,
      CN         = C/totalN
    ) |>
    dplyr::select(
      treatment:kale, pH, totalYield, CN
    )
  
  d
}

dat <- load_data(CONFIG)
