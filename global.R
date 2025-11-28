# global.R

# Load libraries
library(shiny)
library(shinyWidgets)
library(DBI)
library(RSQLite)
library(dplyr)
library(DT)
library(waiter)
library(shinyjs)
library(shinydashboard)
library(shinycssloaders)
library(plotly)


# ---- Sourcing tab modules here ----
source("Tabs/Overview_Tab/Overview_ui.R")

source("Tabs/Cancer_Statistics_Tab/Cancer_ui.R")
source("Tabs/Cancer_Statistics_Tab/Cancer_server.R")

source("Tabs/Heatwave_Tab/Heatwave_ui.R")
source("Tabs/Heatwave_Tab/Heatwave_server.R")

 
#### read in data bases ###
  
#### HEATWAVE 1981-2010 DATA #### 
heatwave_con <- dbConnect(SQLite(), dbname = "./Rshiny_Data_Bases/cdc_heatwave.db")
#print(dbListTables(heatwave_con))
  
# Replace "your_table_name" with the actual name of the table you want to query
heatwave_dat <- dbGetQuery(heatwave_con, "SELECT distinct * FROM heatwave_d104")
  
cancer_con <- dbConnect(SQLite(), dbname = "./Rshiny_Data_Bases/cancer_statistics_1999_2022.db")
print(dbListTables(cancer_con))
  
# Replace "your_table_name" with the actual name of the table you want to query
cancer_dat <- dbGetQuery(cancer_con, "SELECT DISTINCT * FROM cancer_statistics_1999_2022")
  
  
#### Initiate Global Variable ####
global_cancer <- reactiveValues(
  #inputed data
  data = NULL,
  selected_x_vars = NULL,
  
  )

