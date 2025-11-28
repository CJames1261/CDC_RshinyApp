# 📊 CDC Data Extraction & Public Health Visualization Project

This project began as an effort to deploy an R Shiny app capable of visualizing public health data from the CDC. While exploring the CDC website to understand what datasets were publicly available, I quickly realized that accessing and working with the data is far more complicated than it should be. The CDC’s interface can be confusing, the data formats are inconsistent, and the exported tables are not intuitive for the average user—especially those without a data science background.

Public health data may be publicly available, but it is not always transparent or accessible.

## 🔍 Project Motivation

After navigating the CDC’s data tools and discovering how challenging they can be for everyday users, I decided to build a set of Python-based extraction methods that:

* Follow the official CDC WONDER API/form submission guidelines
* Automate retrieval of public datasets
* Clean and restructure the data into analysis-ready tables
* Standardize naming, data types, and schema formats
* Make the data usable for both analysts and non-technical users

My goal is to lower the barrier of entry for exploring public health data. Even though the data is public, it should be far easier to access, understand, and visualize.

## 🚀 Current Progress

I’ve completed my first full extraction pipeline for the dataset:

**“Number of Heat Wave Days in May–September (1981–2010)”**

This pipeline automatically:

* Sends CDC-compliant API/form requests
* Parses XML responses
* Cleans the raw data
* Extracts counties, state abbreviations, and full state names
* Fixes data types
* Stores the results in PostgreSQL and SQLite for querying
* Prepares the dataset for downstream visualization tools like R Shiny

## 🎯 Next Steps

The next phase of the project is to:

### ✔ Extract **all publicly available CDC datasets**

I plan to automate retrieval for every available CDC WONDER dataset, each of which comes with its own schema, structure, and quirks.

### ✔ Standardize all datasets under a unified schema

This includes:

* Normalized naming conventions
* Consistent data types
* Standardized geographic columns (County, FIPS, State, etc.)
* Cleaned numerical fields
* Consolidated formats for time, demographics, measures, and metadata

### ✔ Integrate all standardized datasets into an R Shiny application

The vision for the application is to allow any end user to:

* Select the CDC dataset they are interested in
* Explore the data interactively
* View charts, maps, and statistical summaries
* Slice and filter by state, county, time, or demographic fields
* Access meaningful public health insights without needing technical expertise

This will transform complex CDC data tables into a simple, user-friendly interface that anyone can explore.

## 📈 Long-Term Vision

Ultimately, this project aims to provide:

* A unified API layer for CDC public datasets
* Clean, analysis-ready public health tables
* Accessible visualizations for communities, researchers, and citizens
* A more transparent way to interact with the data that affects public health decisions

Public health data belongs to everyone—and accessing it shouldn’t require specialized expertise.

