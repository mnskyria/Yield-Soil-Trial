This readme file was generated on [YYYY-MM-DD] by Matthew Kyriakides
GENERAL INFORMATION

--------------------

1. Title of Dataset: Agricultural Reclamation: Examining Soil Health Across an Input-Systems Continuum (Data) 

2. Author Information
   
        Name: Matthew Kyriakides
        ORCID:
        Institution: Ecogastronomy Research Group, School of Environmental Studies, University of Victoria
        Address: Turpin B156. 3800 Finnerty Rd, Victoria, BC V8N 4V3
        Email: mnskyria@uvic.ca
   
   Point of Contact
   
        Name: 
        ORCID:
        Institution: 
        Address: 
        Email: 

3. **Date of data collection:**
   
   - T0: 2022-06-23 
   
   - 2022: 2022-11-03 
   
   - 2023: 2023-10-17
   
   - 2024: 2024-10-16

4. **Geographic location of data collection:** 
   Sandown Centre for Regenerative Agriculture. 1810 Glamorgan Road, North Saanich, BC V8L 5S9. 
   (48°39’34.23” N, 123°25’39.28” W). W̱SÍ¸ḴEM traditional territory.

5. **Dataset Description:** 
   This repository documents a multi-year (2022–2024) field trial at the Sandown Centre for Regenerative Agriculture conducted as part of PhD research in the Ecogastronomy Research Group at the University of Victoria. The dataset integrates soil-health indicators, crop yields, and management practices across a five-treatment input-systems gradient. 
   
   All analyses are performed in R using a fully reproducible workflow for data cleaning, linear mixed-effects modeling, post-hoc comparisons, model selection, and visualization.
   **TL;DR to Reproduce Analyses**
   
   1. Put the Excel data in `data/` using the expected filename and sheet names.
   
   2. Open R (or RStudio) at the project root.
   
   3. Run `scripts/run_all.R`. Outputs (models, EMMs, AIC, DHARMa, figures) will appear in `outputs/`.
   
   **Data Management Goals:**
   
   1. Harmonize soil and crop datasets (2022-2024)
   
   2. Fit LMMs for soil indicators and crops
   
   3. Perform Sidak-adjusted post-hocs using emmeans and CLD; upload to CSVs
   
   4. Produce residual diagnostics (DHARMa) to test the different models
   
   5. Produce AIC block scans for crop~soil relationships and then run LMMs on best fitting models
   
   6. Export tidy outputs to a single Excel workbook 
   
   7. Generate publication‑ready figures (forest plots, heatmaps)

-----------------------------------

SHARING/ACCESS INFORMATION
-----------------------------------

1. Licenses/restrictions placed on the data:

2. Links to publications that cite or use the data: 

3. Links to other publicly accessible locations of the data: 

4. Links/relationships to ancillary data sets: 

5. Was data derived from another source? no
    A. If yes, list source(s):

6. Recommended citation for this dataset: Kyriakides, M. (2025). *Agricultural Reclamation: Examining Soil Health Across an Input-Systems Continuum (Data)*. University of Victoria, Ecogastronomy Research Group. https://doi.org/[insert-DOI]

-------------------------

DATA & FILE OVERVIEW
-------------------------

1. **File List:** 
   
   1. **Repository Structure:** 
      
          Sandown Soil GitHub/
          │
          ├── Sandown Soil GitHub.Rproj     # RStudio project (open this)
          ├── README.md                     # Project documentation
          ├── .Rprofile                     # auto-activates renv (keep tiny)
          ├── renv.lock                     # reproducible package versions (keep)
          │
          ├── .github/                      # (workflows, issue templates, etc.)
          ├── data/                         # input data (xlsx/csv), or ignored if private
          ├── outputs/                      # all generated tables/figs/logs
          │   ├── aic/
          │   ├── dharma/
          │   ├── emmeans/
          │   ├── models/
          │   ├── summaries/
          │   └── figs/
          ├── renv/                         # renv infra (activate.R, library/, staging/)
              ├── activate.R       
              ├── library/                  # this leads towards the stored packages
              ├── settings.json
              ├── staging/      
          └── scripts/                      # ALL code lives here (incl. helpers)
              ├── run_all.R
              ├── utils.R
              ├── 01_load_clean.R
              ├── 02_summaries_all_years.R
              ├── 03_models_soil_treatment.R
              ├── 04_models_practices.R
              ├── 05_models_crops.R
              ├── 06_aic_block_scan.R
              ├── 07_aic_blocks_to_excel.R
              ├── 08_emm_heatmap.R
              ├── 09_soil_forest_plot.R
              ├── 10_crop_forest_plot.R
              ├── 11_weather_plot.R
              ├── fit_lmm.R
              ├── emm_helpers.R
              ├── write_excel_helpers.R
              └── plotting_utils.R 
      
      **README for R scripts:**
      
      1. **02_summaries.R:**  summary stats (mean ± SE) for indicators across years/treatments.
      
      2. **03_models_soil_treatment.R:** LMMs for `indicator ~ treatment + (1|bed) + (1|year)`; Type II Wald χ² (`car::Anova(type = 2)`); Sidak-adjusted `emmeans` + pairs + CLD; results to CSV/Excel (one sheet per analysis).
      
      3. **04_models_soil_practices.R:** LMMs for `indicator ~ fertilizer + tillage + covercrop + grazing + (1|bed) + (1|year)`; outputs as above.
      
      4. **05_models_crops.R:** crop yield ~ treatment/practices; outputs as above.
      
      5. **06_dharma.R:** DHARMa outputs for all models; summaries to CSV/Excel
      
      6. **07_aic_blocks.R:** candidate sets for crop~soil; AIC(AICc) selection; best model refit with REML; DHARMa + collinearity checks.
      
      7. **08_emm_heatmap.R:** heatmap of significant `indicator ~ treatment` EMMs.
      
      8. **09_soil_forest_plot.R:** forest plot for soil (T0 vs 2024).
      
      9. **10_crop_forest_plot.R:** forest plots for crop~soil co-efficients
      
      10. **11_weather_plot.R:** climate ribbons (min/max/avg temp) + monthly precip.

2. **Relationship between files, if important:**  `scripts/run_all.R` sources the numbered scripts in order and writes outputs into `outputs/`.  Helper functions in `R/` are imported by analysis scripts.

3. **Additional related data collected that was not included in the current data package:** 

4. **Are there multiple versions of the dataset?** 
    A. If yes, name of file(s) that was updated: 
    B. Why was the file updated? 
    C. When was the file updated? 

---------------------------

METHODOLOGICAL INFORMATION
---------------------------

1. **Description of methods used for collection/generation of data:** 
   Field data were collected from 2022 to 2024 at the Sandown Centre for Regenerative Agriculture (North Saanich, BC, Canada) on former racetrack soils under reclamation. Five agroecological treatments were established along an input-systems (I–S) continuum, replicated four times (n = 20 plots). Each treatment included carrot (_Daucus carota_), kale (_Brassica oleracea_), and bush bean (_Phaseolus vulgaris_) as functional indicator crops. Soils were sampled at 0–15 cm depth from fixed “bed” positions representing consistent sampling points across years. Physical indicators (bulk density, field capacity, aggregate stability) and chemical indicators (pH, EC, nutrients, organic and inorganic carbon) were analyzed using standard laboratory procedures at the Pacific Forestry Centre Chemistry Services Laboratory (PFC) and the UVic Soil Laboratory.
   Field management (tillage, fertilizer, compost, cover crop, grazing) followed the treatment design; operations, dates, and conditions were recorded in logbooks and transferred to digital records. Environmental data (temperature, precipitation) were retrieved from the Victoria International Airport weather station (~3 km away). See materials and methods for further information.
   

2. **Methods for processing the data:**
   Raw laboratory results were collated in Microsoft Excel, then cleaned and standardized in R (≥ 4.5.1) using the `tidyverse`, `janitor`, and `lubridate` packages.  Factor levels for `treatment`, `year`, and `bed` were explicitly set to preserve experimental structure. Missing data were coded as `"na"` and converted to `NA` during import. 
   Analyses used linear mixed-effects models (LMMs; `lmerTest` package) with random effects for `bed` and `year` to control for spatial and temporal autocorrelation. Estimated marginal means and compact letter displays were generated via `emmeans` and `multcompView`. Diagnostic residual checks were conducted using the `DHARMa` package, and model selection employed AICc criteria (`MuMIn`). See materials and methods for further information.
   

3. **Instrument- or software-specific information needed to interpret the data:**
   All data was analyzed on a 2023 ASUS Vivobook laptop (K5504VA) with a 13th Gen Intel(R) Core(TM) i9-13900H (2.60 GHz) processor. All statistical analyses were conducted in RStudio (v.2025.05.0.)for Windows 11 using R (v4.5.1). Analyses employed the following R packages: _tidyverse_, _lmerTest_, _car_, _emmeans_, _multcompView_, _DHARMa_, and _scales_.

4. **Standards and calibration information, if appropriate:** 
   Bulk soil samples were air dried and sieved through 8mm and 2mm screens. Soil pH was measured with a 0.01M calcium chloride (CaCl2) solution using a Fisher Brand Accumet AB150 pH/mv meter. Extractable macro and micronutrients were analyzed with a weak fluoride acid Mehlich-3 extraction and quantified using an Agilent 7900 ICP-MS instrument. Aggregate stability tests followed the SLAKES protocol. Bulk density was determined by the field-composited soil core bulk density and stone volume method. See materials and methods for further information.

5. **Environmental/experimental conditions:** 
   The experiment took place over three years (2022–2024) in a temperate coastal climate (mean annual temperature ≈ 9.5 °C; annual precipitation ≈ 880 mm). The site features coarse-textured Orthic Dystric Brunisol soils on glaciofluvial sands. Field heterogeneity was moderate, and reclamation activities were ongoing throughout the study.  See materials and methods for further information.

6. **Describe any quality-assurance procedures performed on the data:** 
   All data were compiled in a master Excel file and cross-checked with field sheets and laboratory submission forms. Values were reviewed for transcription errors and outliers using descriptive statistics and visual inspection in R. Missing data were coded as `"na"` and handled consistently during analysis. DHARMa residual diagnostics were used to validate model assumptions, and final figures/tables were generated directly from code to ensure reproducibility.

7. **People involved with sample collection, processing, analysis and/or submission:**
   Multiple individuals contributed to field and laboratory work:
   
   - **T0 (2022 baseline):** Matthew Kyriakides, Dr. Charlotte Norris (bulk soil); John Kang and Reid Lukaitis (bulk density & water). Reid completed pH and bulk density; field capacity by unknown staff.  
   - **2022:** Matthew Kyriakides, Dr. Charlotte Norris, Camille Giuliano, Reid Lukaitis. Camille completed pH, bulk density, and SLAKES; field capacity by unknown staff.  
   - **2023:** Matthew Kyriakides, Dr. Charlotte Norris, Camille Giuliano, Nickolas Lee. SLAKES by Matthew, Camille, and Nick; pH and BD jointly by Matthew, Teale Weiss-Gibbons, and Sarah Rebbitt; field capacity by unknown staff.  
   - **2024:** Matthew Kyriakides, Dr. Charlotte Norris, Audrey McPherson, Teale Weiss-Gibbons. SLAKES by Matthew (UVic Soil Lab); pH by Lily Beveridge (UVic Soil Lab); BD and field capacity at PFC by unknown staff.

-------------------------------------------

DATA-SPECIFIC INFORMATION FOR: final data-R.xslx
-------------------------------------------

| **Type of Variable**            | **Type of Data**                          | R Label    | **n** | **Absent Data**                         |
| ------------------------------- | ----------------------------------------- | ---------- | ----- | --------------------------------------- |
| **Fixed Variable**              |                                           |            |       |                                         |
| Treatment                       | Categorical, ordinal (5 levels: 1-5)      | treatment  | 200   | None absent                             |
| Fertilizer application          | Categorical, discrete (2 levels: yes/no)  | fertilizer | 200   | None absent                             |
| Tillage/no tillage              | Categorical, discrete (2 levels: yes/no)  | tillage    | 200   | None absent                             |
| Cover crops                     | Categorical, discrete (2 levels: yes/no)  | covercrop  | 200   | None absent                             |
| Compost application             | Categorical, discrete (2 levels: yes/no)  | compost    | 200   | None absent                             |
| Grazing                         | Categorical, discrete (2 levels: yes/no)  | grazing    | 200   | None absent                             |
| **Randomized Variable**         |                                           |            |       |                                         |
| Bed                             | Categorical, discrete (60 levels: 1-60)   |            | 180   | T0 – all (20)                           |
| Year                            | Categorical, discrete (4 levels: 4 times) |            | 200   | None absent                             |
| **Response Variable**           |                                           |            |       |                                         |
| pH                              | Numerical, continuous                     | pH         | 199   | 2022: 14 (1)                            |
| Electrical conductivity (us/cm) |                                           | ES         |       |                                         |
| Total nitrogen (%)              | Numerical, continuous                     | TotalN     | 140   | 2023: all (60)                          |
| NH4+ mineralization (ppm)       | Numerical, continuous                     | NH4        | 140   | 2023: all (60)                          |
| Bray-1 phosphorus (ppm)         | Numerical, continuous                     | BrayP      | 140   | 2023: all (60)                          |
| MIII phosphorus (ppm)           | Numerical, continuous                     | P          | 139   | T0: treatment 4-3, 2023: all (61)       |
| MIII potassium (ppm)            | Numerical, continuous                     | K          | 139   | T0: treatment 4-3, 2023: all (61)       |
| MIII calcium (ppm)              | Numerical, continuous                     | Ca         | 139   | T0: treatment 4-3, 2023: all (61)       |
| MIII magnesium (ppm)            | Numerical, continuous                     | Mg         | 139   | T0: treatment 4-3, 2023: all (61)       |
| MIII copper (ppm)               | Numerical, continuous                     | Cu         | 139   | T0: treatment 4-3, 2023: all (61)       |
| MIII iron (ppm)                 | Numerical, continuous                     | Fe         | 139   | T0: treatment 4-3, 2023: all (61)       |
| MIII manganese (ppm)            | Numerical, continuous                     | Mn         | 139   | T0: treatment 4-3, 2023: all (61)       |
| MIII zinc (ppm)                 | Numerical, continuous                     | Zn         | 139   | T0: treatment 4-3, 2023: all (61)       |
| Bulk density (g/cm3)            | Numerical, continuous                     | BD         | 200   | None absent                             |
| Aggregate stability (STAB10)    | Numerical, continuous                     | STAB       | 180   | T0: all (20)                            |
| Field capacity (%)              | Numerical, continuous                     | FC         | 194   | 2022: 28. 2024: 41, 45, 48, 58, 59 (6)  |
| Sand (%)                        | Numerical, continuous                     | sand       | 194   | 2022, 2023, 2024: 1, 31 (6)             |
| Silt (%)                        | Numerical, continuous                     | silt       | 194   | 2022, 2023, 2024: 1, 31 (6)             |
| Clay (%)                        | Numerical, continuous                     | clay       | 194   | 2022, 2023, 2024: 1, 31 (6)             |
| Soil organic carbon (%)         | Numerical, continuous                     | orgC       | 200   | None absent.                            |
| Carbon (%)                      | Numerical, continuous                     | C          | 200   | None absent                             |
| POX-C (mg/kg)                   | Numerical, continuous                     | POXC       | 139   | T0: treatment 4-3. 2023: all (61)       |
| Bean harvest (g)                | Numerical, continuous                     | bean       | 60    | T0: all. 2022, 2023, 2024: all non bean |
| Carrot gr. 1 harvest (g)        | Numerical, continuous                     | carrot1    | 60    | T0: all. 2022, 2023, 2024: all non carr |
| Carrot gr. 2 harvest (g)        | Numerical, continuous                     | carrot2    | 60    | T0: all. 2022, 2023, 2024: all non carr |
| Carrot top harvest (g)          | Numerical, continuous                     | carrotTop  | 60    | T0: all. 2022, 2023, 2024: all non carr |
| Kale harvest (g)                | Numerical, continuous                     | kale       | 60    | T0: all. 2022, 2023, 2024: all non kale |

There is another sheet which covers weather data (Weather (R)). This includes daily information for Average Temp, Minimum Temp, Maximum Temp, and Precipitation. There are 884 entries.

**Missing data codes**:  NAs listed above; all labelled as na in the document and then coded to mean NA in R using na = "na".

**Specialized formats or other abbreviations used:** The formats follow those used in the raw data that was compiled to make this. 
