# 📊 CDC Data Extraction & Public Health Visualization Project

# 💻 Running the App Locally (Important)

This R Shiny application is **large and resource-intensive**, and it loads multiple CDC datasets directly into memory. Because of this, it **cannot be hosted for free** on services like shinyapps.io, which have strict CPU and RAM limits.

If you would like to explore the full application, you will need to run it **locally** on your own machine.

### ▶️ Requirements

**Software**

* **R (≥ 4.1)**
* **RStudio** (recommended for proper working directory handling)


### ▶️ How to Run the App

1. Open the project folder in **RStudio**
2. Open the global.R file and click “Install Packages” when prompted
RStudio automatically detects missing libraries.
When you open global.R, RStudio will highlight any packages not yet installed and offer to install them for you.
3. Open **ui.R**, **server.R**, or **global.R**
4. Click **Run App** (top-right button in RStudio)

RStudio automatically loads all modular files inside:

```
Tabs/
  ├── Cancer_Statistics_Tab/
  ├── Heatwave_Tab/
  └── Overview_Tab/
```

The full Shiny application will open in your browser.

---

# 🔍 Project Motivation

This project began as an effort to deploy an R Shiny app capable of visualizing public health data from the CDC. While exploring the CDC website to understand what datasets were publicly available, I quickly realized that accessing and working with the data is far more complicated than it should be. The CDC’s interface can be confusing, the data formats are inconsistent, and the exported tables are not intuitive for the average user—especially those without a data science background.

Public health data may be publicly available, but it is not always transparent or accessible.

## 🔍 Why This Project Exists

After navigating the CDC’s data tools, I decided to build a set of Python-based extraction methods that:

* Follow CDC WONDER API/form submission rules
* Automate retrieval of public datasets
* Clean and restructure them into analysis-ready tables
* Standardize naming, typing, and schema
* Make the data easier for both analysts and non-technical users

My goal is to make public health data easier to access, understand, and visualize.

---

🚀 Current Progress

I’ve completed full extraction pipelines for the following CDC datasets:

1️⃣ Number of Heat Wave Days in May–September (1981–2010)

This pipeline automatically:

Sends proper API/form requests

Parses XML responses

Cleans raw values

Extracts county/state information

Fixes data types

Stores results in PostgreSQL and SQLite

Prepares the dataset for visualization in R Shiny

2️⃣ Cancer Statistics (1999–2022)

This dataset includes counts, populations, crude rates, cancer sites, demographics, and state-level metrics.
The pipeline:

Standardizes naming and data types

Cleans numeric fields and resolves formatting issues

Aligns demographic categories

Outputs analysis-ready tables for visualization

Loads efficiently into the R Shiny app with full filtering, pivoting, and charting support
---

# 🎯 Next Steps

### ✔ Extract all publicly available CDC WONDER datasets

Each dataset has unique schemas and quirks.

### ✔ Standardize all datasets into one unified schema

Including geography, demographics, numeric fields, and metadata.

### ✔ Integrate everything into a single R Shiny application

Users will be able to:

* Select any dataset
* Explore interactively
* View charts, tables, heatmaps, and pivots
* Filter by geography, time, and demographic fields

This will turn complex, inconsistent CDC tables into a user-friendly interface.

---

# 📈 Long-Term Vision

The long-term goal is to provide:

* A unified API layer for CDC public datasets
* Clean, analysis-ready tables
* Accessible visualizations for researchers and the public
* A more transparent way to interact with data that impacts public health

Public health data belongs to everyone—and accessing it shouldn’t require specialized expertise.


