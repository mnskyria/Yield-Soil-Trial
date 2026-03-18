This readme file was generated on 2026-03-18 by Matthew Kyriakides

--------------------

# Quick Start

1. Place the Excel data file in `data/` using the expected filename and sheet names.

2. Open `Chapter 2 - Soil-Yields.Rproj` in RStudio

3. Run `scripts/run_all.R` - outputs (models, figures, summaries) will appear in `outputs/`
   Note: the raw data file is not included in this repository. Contact the author for access.

--------------------

# General Information

1. Title of Dataset: Sustaining Yields and Increasing Soil Carbon in Reduced-Input Systems: Evidence from a Three-Year Agricultural Reclamation Trial (Data) 
   
   

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
   
   - T0 (baseline): 2022-06-23 
   
   - 2022: 2022-11-03 
   
   - 2023: 2023-10-17
   
   - 2024: 2024-10-16

4. **Geographic location of data collection:** 
   Sandown Centre for Regenerative Agriculture. 1810 Glamorgan Road, North Saanich, BC V8L 5S9. 
   (48°39’34.23” N, 123°25’39.28” W). W̱SÍ¸ḴEM traditional territory.

5. **Dataset Description:** 
   This repository documents a multi-year (2022–2024) field trial at the Sandown Centre for Regenerative Agriculture conducted as part of PhD research in the Ecogastronomy Research Group at the University of Victoria. The dataset integrates soil health indicators, crop yields, and management practices across a five-treatment input-systems (I-S) continuum gradient. All analyses are performed in R using a fully reproducible pipeline.

-----------------------------------

SHARING/ACCESS INFORMATION
-----------------------------------

1. Licenses/restrictions placed on the data: TBC

2. Links to publications that cite or use the data: TBC

3. Links to other publicly accessible locations of the data: N/A

4. Links/relationships to ancillary data sets: No

5. Was data derived from another source? no
    A. If yes, list source(s):

6. Recommended citation for this dataset: Kyriakides, M. (2026). *Sustaining Yields and Increasing Soil Carbon in Reduced-Input Systems: Evidence from a Three-Year Agricultural Reclamation Trial (Data)*. University of Victoria, Ecogastronomy Research Group. 

-------------------------

DATA & FILE OVERVIEW
-------------------------

1. **File List:** 
   
   1. **Repository Structure:** 
      
          Yield-Soil-Trial/
          │
          ├── Chapter 2 - Soil.Rproj         # RStudio project (open this)
          ├── README.md                       # Project documentation
          ├── .Rprofile                       # auto-activates renv
          ├── renv.lock                       # reproducible package versions
          │
          ├── data/                           # input data (not included — private)
          ├── outputs/                        # all generated tables, figures, logs
          │   ├── AIC/                        # AIC model rankings and candidate models
          │   ├── Data Summaries/             # mean ± SE summaries by year and treatment
          │   ├── Model Summaries/            # LM outputs and emmeans contrasts (Excel)
          │   ├── Model with Raw Outputs/     # model prediction plots with raw data
          │   ├── Residual Diagnostics/       # QQ plots, histograms, Shapiro-Wilk results
          │   └── Final Figures/              # publication-ready figures
          │       ├── Balanced Model Verification/  # balanced vs raw sensitivity figures
          │       ├── Fertility Threshold Plots/    # macro and micronutrient threshold figures
          │       ├── Forest Plots/                 # standardized change forest plots
          │       └── LM Outputs/                   # model prediction figures
          │           ├── AIC Models/               # bean ~ NH4 and carrot ~ Mg plots
          │           ├── Kale Model/               # kale yield model (Years 2-3)
          │           ├── Slakes Model/             # aggregate stability model
          │           ├── Soil Models (Balanced)/   # soil indicators, balanced dataset
          │           ├── Soil Models (Full)/       # soil indicators, raw dataset
          │           └── Yield Models/             # crop yield models (Years 1-3)
          └── scripts/                        # all analysis code
              ├── run_all.R                   # master pipeline runner
              ├── utils.R                     # shared data objects and helper functions
              ├── 01_Load_Clean.R
              ├── 02_Summaries.R
              ├── 03_Models_Soil.R
              ├── 04_Models_Yield.R
              ├── 05_Models_Balanced-Verification.R
              ├── 06_AIC_Crop-Soil.R
              ├── 07_Residual-Diagnostics.R
              ├── 08_Figure_Model-Outputs.R
              ├── 09_Figure_Model-Outputs-Balanced-vs-Raw.R
              ├── 10_Figure_Forest-Plot-Fertility.R
              ├── 11_Figure_Forest-Plot-Soil-Condition.R
              ├── 12_Figure_Fertility-Threshold-Macro.R
              └── 13_Figure_Fertility-Threshold-Micro.R
      
      **README for R scripts:**
      
      1. **run_all.R:**  Master pipeline - sources all scripts in order
      
      2. **utils.R:** Shared datasets, variable definitions, and plotting functions
      
      3. **01_Load_Clean.R:** Loads and cleans raw Excel data; creates dat
      
      4. **02_Summaries.R:** Mean ± SE summaries by year and treatment
      
      5. **03_Models_Soil.R:** LMs for soil indicators ~ treatment × year (balanced and raw datasets); exports to Excel
      
      6. **04_Models_Yield.R:** LMs for crop yield ~ treatment × year; exports to Excel
      
      7. **05_Models_Balanced-Verification.R:** Sensitivity analysis comparing balanced vs raw datasets; 500 random subsample iterations
      
      8. **06_AIC_Crop-Soil.R:** Pre-specified candidate AIC models for crop ~ soil indicator relationships
      
      9. **07_Residual-Diagnostics.R:** Residual diagnostic plots and Shapiro-Wilk tests for all models
      
      10. **08_Figure_Model-Outputs.R:** Model prediction plots with raw data for all indicators
      
      11. **09_Figure_Model-Outputs-Balanced-vs-Raw.R:** Side-by-side comparison figures for balanced vs raw models
      
      12. **10_Figure_Forest-Plot-Fertility.R:** Forest plot of standardized soil fertility changes (T0 to Year 3)
      
      13. **11_Figure_Forest-Plot-Soil-Condition.R:** Forest plot of standardized soil condition changes (T0 to Year 3)
      
      14. **12_Figure_Fertility-Threshold-Macro.R:** Macronutrient threshold figures (NH4, P, K, Mg)
      
      15. **13_Figure_Fertility-Threshold-Micro.R:** Micronutrient threshold figures (Cu, Mn, Zn)

2. **Relationship between files, if important:**  `scripts/run_all.R` sources the numbered scripts in order and writes outputs into `outputs/`.  Helper functions in `utils` are imported by analysis scripts.

3. **Additional related data collected that was not included in the current data package:** 

4. **Are there multiple versions of the dataset?** 
    A. If yes, name of file(s) that was updated: no
    B. Why was the file updated? 
    C. When was the file updated? 

---------------------------

METHODOLOGICAL INFORMATION
---------------------------

1. **Description of methods used for collection/generation of data:** 
   Field data were collected from 2022 to 2024 at the Sandown Centre for Regenerative Agriculture (North Saanich, BC, Canada) on former racetrack soils under reclamation. Five management treatments were established along an input-systems (I-S) continuum, replicated four times (n = 20 plots). Each treatment included carrot (_Daucus carota_), kale (_Brassica oleracea_), and bush bean (_Phaseolus vulgaris_) as functional indicator crops. Soils were sampled at 0–15 cm depth. Soil fertility (pH, EC, macro- and micronutrients)  and condition (bulk density, aggregate stability, SOC, POX-C) indicators  were analyzed at the Pacific Forestry Centre Chemistry Services Laboratory and the UVic Soil Laboratory. Field management operations, dates, and conditions were recorded in logbooks and transferred to digital records. See dissertation Chapter 2 for full methods.

2. **Methods for processing the data:**
   Raw laboratory results were collated in Microsoft Excel, then cleaned and standardized in R (v4.5.1) using the `tidyverse` package. Factor levels for `treatment`, `year`, and `replicate` were explicitly set to preserve experimental structure. Missing data were coded as `"na"` and converted to `NA` during import.
   Analyses used linear models (LMs) with treatment and year as fixed effects (`lm()`). Because T0 (n = 20) and Year 3 (n = 60) differed in sample size, Year 3 observations were averaged within treatment replicates to generate a balanced dataset (n = 40) for T0–Year 3 comparisons, treating the bed as the primary experimental unit. Sensitivity analyses comparing balanced and raw datasets are provided in `outputs/Final Figures/Balanced Model Verification/`. Estimated marginal means and pairwise contrasts were generated via `emmeans` with Tukey adjustment. AIC-based model selection used a pre-specified candidate set approach (`MuMIn`). Residual diagnostics used visual inspection and Shapiro-Wilk tests. See dissertation Chapter 2 for full statistical methods.

3. **Instrument- or software-specific information needed to interpret the data:**
   All analyses were conducted in RStudio (v.2025.05.0) on Windows 11 using R (v4.5.1) on a 2023 ASUS Vivobook (K5504VA, Intel Core i9-13900H). R packages used: `tidyverse`, `car`, `emmeans`, `MuMIn`, `scales`, `patchwork`, `openxlsx`, `broom`.

4. **Standards and calibration information, if appropriate:** 
   Bulk soil samples were air dried and sieved through 8 mm and 2 mm screens. Baseline (T0) samples were collected June 2022 (0–15 cm depth); follow-up sampling occurred each autumn from 2022–2024. One composite sample per treatment replicate was collected at T0 (n = 20); three subsamples per replicate were collected in subsequent years (n = 60 per year). Soil pH was measured in 0.01M CaCl2 using a Fisher Brand Accumet AB150 pH/mV meter. Electrical conductivity was determined in a 1:2 soil:water solution. Ammonium mineralization was quantified via 7-day anaerobic incubation followed by colorimetric analysis. Total nitrogen and organic carbon were measured by dry combustion using an Elementar SoliToc cube. Extractable macro and micronutrients (P, K, Ca, Mg, Cu, Fe, Mn, Zn) were analyzed with a Mehlich-3 extraction and quantified using an Agilent 7900 ICP-MS. Permanganate oxidizable carbon (POX-C) was measured colorimetrically. Aggregate stability followed the SLAKES protocol. Bulk density (0–8 cm) used the field-composited soil core method with stone correction. Full fertility and condition analyses were conducted at T0, 2022, and 2024; 2023 included a subset of condition analyses only.

5. **Environmental/experimental conditions:** 
   The experiment took place in a warm-summer Mediterranean climate (Csb; mean annual temperature ≈ 9.5°C; annual precipitation ≈ 880 mm). The site features sandy loam soils (57.6% sand, 23.2% silt, 19.2% clay) derived from Brunisolic, Gleysolic, and Anthropogenic series.

6. **Describe any quality-assurance procedures performed on the data:** 
   All data were cross-checked against field sheets and laboratory submission forms. Values were reviewed for transcription errors and outliers using descriptive statistics and visual inspection in R. Final figures and tables were generated directly from code to ensure reproducibility.

7. **People involved with sample collection, processing, analysis and/or submission:**
   Multiple individuals contributed to field and laboratory work:
   
   - **T0 (2022 baseline):** Matthew Kyriakides, Dr. Charlotte Norris (bulk soil); John Kang and Reid Lukaitis (bulk density & water). Reid completed pH and bulk density; field capacity by unknown staff.  
   - **2022:** Matthew Kyriakides, Dr. Charlotte Norris, Camille Giuliano, Reid Lukaitis. Camille completed pH, bulk density, and SLAKES; field capacity by unknown staff.  
   - **2023:** Matthew Kyriakides, Dr. Charlotte Norris, Camille Giuliano, Nickolas Lee. SLAKES by Matthew, Camille, and Nick; pH and BD jointly by Matthew, Teale Weiss-Gibbons, and Sarah Rebbitt; field capacity by unknown staff.  
   - **2024:** Matthew Kyriakides, Dr. Charlotte Norris, Audrey McPherson, Teale Weiss-Gibbons. SLAKES by Matthew (UVic Soil Lab); pH by Lily Beveridge (UVic Soil Lab); BD and field capacity at PFC by unknown staff.

-------------------------------------------

DATA-SPECIFIC INFORMATION FOR: final data-R.xslx
-------------------------------------------

**Missing data codes:** All missing values coded as `na` in Excel and converted to `NA` in R via `na = "na"` in `read_excel()`.

| **Type of Variable**            | **Type of Data**                          | R Label    | **n** | **Absent Data**                           |
| ------------------------------- | ----------------------------------------- | ---------- | ----- | ----------------------------------------- |
| Treatment                       | Categorical, ordinal (5 levels: 1-5)      | treatment  | 200   | None absent                               |
| Bed                             | Categorical, discrete (60 levels: 1-60)   |            | 180   | T0 – all (20)                             |
| Year                            | Categorical, discrete (4 levels: 4 times) |            | 200   | None absent                               |
| **Response Variable**           |                                           |            |       |                                           |
| pH                              | Numerical, continuous                     | pH         | 199   | 2022: 14 (1)                              |
| Electrical conductivity (us/cm) | Numerical, continuous                     | EC         | 140   | 2023: all (60)                            |
| Total nitrogen (%)              | Numerical, continuous                     | TotalN     | 140   | 2023: all (60)                            |
| NH4+ mineralization (ppm)       | Numerical, continuous                     | NH4        | 140   | 2023: all (60)                            |
| Bray-1 phosphorus (ppm)         | Numerical, continuous                     | BrayP      | 140   | 2023: all (60)                            |
| MIII phosphorus (ppm)           | Numerical, continuous                     | P          | 139   | T0: treatment 4-3, 2023: all (61)         |
| MIII potassium (ppm)            | Numerical, continuous                     | K          | 139   | T0: treatment 4-3, 2023: all (61)         |
| MIII calcium (ppm)              | Numerical, continuous                     | Ca         | 139   | T0: treatment 4-3, 2023: all (61)         |
| MIII magnesium (ppm)            | Numerical, continuous                     | Mg         | 139   | T0: treatment 4-3, 2023: all (61)         |
| MIII copper (ppm)               | Numerical, continuous                     | Cu         | 139   | T0: treatment 4-3, 2023: all (61)         |
| MIII iron (ppm)                 | Numerical, continuous                     | Fe         | 139   | T0: treatment 4-3, 2023: all (61)         |
| MIII manganese (ppm)            | Numerical, continuous                     | Mn         | 139   | T0: treatment 4-3, 2023: all (61)         |
| MIII zinc (ppm)                 | Numerical, continuous                     | Zn         | 139   | T0: treatment 4-3, 2023: all (61)         |
| Bulk density (g/cm3)            | Numerical, continuous                     | BD         | 200   | None absent                               |
| Aggregate stability (STAB10)    | Numerical, continuous                     | STAB       | 180   | T0: all (20)                              |
| Field capacity (%)              | Numerical, continuous                     | FC         | 194   | 2022: 28. 2024: 41, 45, 48, 58, 59 (6)    |
| Sand (%)                        | Numerical, continuous                     | sand       | 194   | 2022, 2023, 2024: 1, 31 (6)               |
| Silt (%)                        | Numerical, continuous                     | silt       | 194   | 2022, 2023, 2024: 1, 31 (6)               |
| Clay (%)                        | Numerical, continuous                     | clay       | 194   | 2022, 2023, 2024: 1, 31 (6)               |
| Soil organic carbon (%)         | Numerical, continuous                     | orgC       | 200   | None absent.                              |
| Carbon (%)                      | Numerical, continuous                     | C          | 200   | None absent                               |
| POX-C (mg/kg)                   | Numerical, continuous                     | POXC       | 139   | T0: treatment 4-3. 2023: all (61)         |
| Bean harvest (g)                | Numerical, continuous                     | bean       | 60    | T0: all. 2022, 2023, 2024: all non bean   |
| Carrot gr. 1 harvest (g)        | Numerical, continuous                     | carrot1    | 60    | T0: all. 2022, 2023, 2024: all non carrot |
| Carrot gr. 2 harvest (g)        | Numerical, continuous                     | carrot2    | 60    | T0: all. 2022, 2023, 2024: all non carrot |
| Carrot top harvest (g)          | Numerical, continuous                     | carrotTop  | 60    | T0: all. 2022, 2023, 2024: all non carrot |
| Kale harvest (g)                | Numerical, continuous                     | kale       | 60    | T0: all. 2022, 2023, 2024: all non kale   |
| Total harvest (g)               | Numerical, continuous                     | TotalYield | 180   | T0: all                                   |

**Specialized formats or other abbreviations used:** The formats follow those used in the raw data that was compiled to make this. 
