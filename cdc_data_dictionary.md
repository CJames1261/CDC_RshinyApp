# CDC Public Health Data Dictionary

This repository will eventually contain **data dictionaries for all CDC public datasets** extracted through this project.  
Each section below describes a dataset, its purpose, and a detailed explanation of the fields contained within it.

---

# 1. Heat Wave Days (D104)
**Dataset Name:** Number of Heat Wave Days in May–September (1981–2010)  
**Source:** CDC WONDER – Climate and Health Indicators  
**Description:**  
This dataset measures the number of heat-wave days per U.S. county across several heat metrics including maximum temperature, heat index, and net heat stress.

### **Data Fields**

| Column Name        | Description |
|--------------------|-------------|
| **County**         | Full county name and state abbreviation (e.g., “Baldwin County, AL”) |
| **Year**           | Calendar year of measurement |
| **hw_tmax_days**   | Number of heat-wave days based on daily maximum temperature (Tmax) |
| **hw_tmax_avg**    | Average heat-wave days based on Tmax |
| **hw_hi_days**     | Number of heat-wave days based on daily maximum heat index (temp + humidity) |
| **hw_hi_avg**      | Average heat-wave days based on daily maximum heat index |
| **hw_nhs_days**    | Number of heat-wave days in a year based on net heat stress (temp + humidity + radiation + wind) |
| **hw_nhs_avg**     | Average heat-wave days based on net heat stress |
| **Population**     | Total county population for the given year |
| **State_abrv**     | Two-letter state abbreviation extracted from the County field |
| **CountyName**     | Cleaned county name without the word “County” |

---

# 2. Additional CDC Datasets (Coming Soon)

Below is the full list of publicly available CDC WONDER datasets that will be incorporated into this project.  
Each dataset will be extracted, cleaned, documented, and made available for interactive exploration in the R Shiny application.

---

## ▸ AIDS / Infectious Disease
- **AIDS Public Use Data**

---

## ▸ Birth & Infant Health
- **Births**
- **Fetal Deaths**
- **Infant Deaths**

---

## ▸ Cancer Statistics
- **Cancer Statistics** (various sub-tables)

---

## ▸ Mortality (All Ages)
- **Underlying Cause of Death**
- **Multiple Cause of Death**
- **U.S.–Mexico Border Area Mortality**
- **Compressed Mortality**

---

## ▸ Environment & Climate
- **Heat Wave Days May–September** *(completed — D104)*  
- **Daily Air Temperatures & Heat Index**  
- **Daily Land Surface Temperatures**  
- **Daily Fine Particulate Matter (PM2.5)**  
- **Daily Sunlight**  
- **Daily Precipitation**  
- **Online Tuberculosis Information System**

---

## ▸ Population & Demographics
- **Bridged-Race Population**
- **Single-Race Population (Census)**
- **Population Projections (Census)**
- **Sexually Transmitted Disease Morbidity**
- **Vaccine Adverse Event Reporting System (VAERS)**

---

## ▸ National Notifiable Diseases Surveillance System (NNDSS)
- **NNDSS Annual Summary Data Query**
- **NNDSS Annual Tables**
- **NNDSS Weekly Tables**

---

## ▸ Other Query Systems
Additional systems and datasets provided through CDC WONDER or affiliated public health APIs will be added here as they are integrated.

---

# 3. Format for Future Entries

Each dataset will follow this documentation structure:

```
## Dataset Name
Source:
Description:
Purpose:

### Data Fields
| Column Name | Description |
|-------------|-------------|
| field_1     | explanation |
| field_2     | explanation |
| ...         | ...         |
```

---

# 4. Project Purpose

The goal of this repository is to build **clean, transparent, analysis-ready versions of CDC public datasets**, along with clear, plain-language documentation.  
This enables data scientists, researchers, and everyday citizens to explore U.S. public health data without needing to decipher complex CDC WONDER tables.

---

*This file will continue expanding as additional CDC datasets are integrated into the project.*
