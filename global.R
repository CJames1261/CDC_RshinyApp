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
library(jqbr)
library(bslib)
library(rpivotTable)
library(htmlwidgets)
library(rvest)
library(writexl)
library(readr)
library(openxlsx)





#### HEATWAVE 1981–2010 DATA ####
heatwave_con <- dbConnect(SQLite(), dbname = "./Rshiny_Data_Bases/cdc_heatwave.db")

heatwave_dat <- dbGetQuery(heatwave_con, "SELECT DISTINCT * FROM heatwave_d104")

dbDisconnect(heatwave_con)  # ✅ safely disconnect when done


#### CANCER STATISTICS 1999–2022 ####
cancer_con <- dbConnect(SQLite(), dbname = "./Rshiny_Data_Bases/cancer_statistics_1999_2022.db")

print(dbListTables(cancer_con))

cancer_dat <- dbGetQuery(cancer_con, "SELECT DISTINCT * FROM cancer_statistics_1999_2022")

dbDisconnect(cancer_con)  # ✅ safely disconnect here too

  
#### Global Plotly graph functions ####
# This code creates a full screen button and a download csv button in the poltly/ggplotly plot menu
# SVG icons
icons <- list()
# Fullscreen (source : https://fontawesome.com/icons/expand?f=classic&s=solid)
icons$expand <- "M32 32C14.3 32 0 46.3 0 64v96c0 17.7 14.3 32 32 32s32-14.3 32-32V96h64c17.7 0 32-14.3 32-32s-14.3-32-32-32H32zM64 352c0-17.7-14.3-32-32-32s-32 14.3-32 32v96c0 17.7 14.3 32 32 32h96c17.7 0 32-14.3 32-32s-14.3-32-32-32H64V352zM320 32c-17.7 0-32 14.3-32 32s14.3 32 32 32h64v64c0 17.7 14.3 32 32 32s32-14.3 32-32V64c0-17.7-14.3-32-32-32H320zM448 352c0-17.7-14.3-32-32-32s-32 14.3-32 32v64H320c-17.7 0-32 14.3-32 32s14.3 32 32 32h96c17.7 0 32-14.3 32-32V352z"
# Download Data CSV (source : https://fontawesome.com/icons/file-csv?f=classic&s=solid)
icons$csv <- "M0 64C0 28.7 28.7 0 64 0H224V128c0 17.7 14.3 32 32 32H384V304H176c-35.3 0-64 28.7-64 64V512H64c-35.3 0-64-28.7-64-64V64zm384 64H256V0L384 128zM200 352h16c22.1 0 40 17.9 40 40v8c0 8.8-7.2 16-16 16s-16-7.2-16-16v-8c0-4.4-3.6-8-8-8H200c-4.4 0-8 3.6-8 8v80c0 4.4 3.6 8 8 8h16c4.4 0 8-3.6 8-8v-8c0-8.8 7.2-16 16-16s16 7.2 16 16v8c0 22.1-17.9 40-40 40H200c-22.1 0-40-17.9-40-40V392c0-22.1 17.9-40 40-40zm133.1 0H368c8.8 0 16 7.2 16 16s-7.2 16-16 16H333.1c-7.2 0-13.1 5.9-13.1 13.1c0 5.2 3 9.9 7.8 12l37.4 16.6c16.3 7.2 26.8 23.4 26.8 41.2c0 24.9-20.2 45.1-45.1 45.1H304c-8.8 0-16-7.2-16-16s7.2-16 16-16h42.9c7.2 0 13.1-5.9 13.1-13.1c0-5.2-3-9.9-7.8-12l-37.4-16.6c-16.3-7.2-26.8-23.4-26.8-41.2c0-24.9 20.2-45.1 45.1-45.1zm98.9 0c8.8 0 16 7.2 16 16v31.6c0 23 5.5 45.6 16 66c10.5-20.3 16-42.9 16-66V368c0-8.8 7.2-16 16-16s16 7.2 16 16v31.6c0 34.7-10.3 68.7-29.6 97.6l-5.1 7.7c-3 4.5-8 7.1-13.3 7.1s-10.3-2.7-13.3-7.1l-5.1-7.7c-19.3-28.9-29.6-62.9-29.6-97.6V368c0-8.8 7.2-16 16-16z"

dirty_js <- function(x) {
  structure(x, class = unique(c("JS_EVAL", oldClass(x))))
}

button_fullscreen <- function() {
  list(
    name = "fullscreen",
    title = "Toggle fullscreen",
    icon = list(
      path = icons$expand,
      transform = 'matrix(1 0 0 1 0 -1) scale(0.03571429)'
    ),
    attr = "full_screen",
    val = "false",
    click = dirty_js(
      "function(gd, ev) {
         var button = ev.currentTarget;
         var astr = button.getAttribute('data-attr');
         var val = button.getAttribute('data-val') || false;

         if(astr === 'full_screen') {
           if(val === 'false') {
             button.setAttribute('data-val', 'true');
             gd.classList.add('full-screen');
             Plotly.Plots.resize(gd);
           } else {
             button.setAttribute('data-val', 'false');
             gd.classList.remove('full-screen');
             Plotly.Plots.resize(gd);
           }
         }
      }"
    )
  )
}


dirty_csv <- function(data) {
  c(
    paste0(colnames(data), collapse = ","),
    apply(data, 1, paste0, collapse = ",")
  ) |> paste0(collapse = "\n") |> utils::URLencode(reserved = TRUE)
}


# button_download <- function(data, plot_name) {
#   # Concatenate multiple plot names into a single string separated by underscores
#   
#   list(
#     name = "datacsv",
#     title = "Download plot data as csv",
#     icon = list(
#       path = icons$csv,
#       transform = 'matrix(1 0 0 1 0 0) scale(0.03125)'
#     ),
#     click = dirty_js(
#       sprintf(
#         "function(gd, ev) {
#            var el = document.createElement('a');
#            el.setAttribute('href', 'data:text/plain;charset=utf-8,%s');
#            el.setAttribute('download', '%s.csv');
#            el.click();
#         }",
#         dirty_csv(data),
#         plot_name  # Use the concatenated plot name
#       )
#     )
#   )
# }
button_download <- function(data, plot_name) {
  js_code <- sprintf(
    "function(gd, ev) {
       var el = document.createElement('a');
       el.setAttribute('href', 'data:text/plain;charset=utf-8,%s');
       el.setAttribute('download', '%s.csv');
       el.click();
    }",
    dirty_csv(data),
    plot_name
  )
  
  list(
    name = "datacsv",
    title = "Download plot data as csv",
    icon = list(
      path = icons$csv,
      transform = 'matrix(1 0 0 1 0 0) scale(0.03125)'
    ),
    click = dirty_js(js_code)
  )
}

is.Date <- function(x) inherits(x, "Date")

generate_widget_filters <- function(data) {
  widget_filters <- list()
  # Binary columns
  binary_cols <- names(data)[sapply(data, function(x)
    (is.numeric(x) && all(unique(x) %in% c(0, 1))) ||
      all(unique(x) %in% c("0", "1"))
  )]
  if (length(binary_cols)) {
    data <- data %>%
      mutate(across(all_of(binary_cols), as.numeric))
  }
  for (col in binary_cols) {
    filter <- list(
      id = col,
      label = col,
      type = "integer",
      validation = list(min = 0, max = 1),
      plugin = "slider",
      plugin_config = list(min = 0, max = 1, value = 0)
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  # Continuous numeric columns
  continuous_cols <- names(data)[sapply(data, function(x) {
    is.numeric(x) && !all(unique(x) %in% c(0, 1))
  })]
  for (col in continuous_cols) {
    min_val <- round(min(data[[col]], na.rm = TRUE), 0)
    max_val <- round(max(data[[col]], na.rm = TRUE), 0)
    filter <- list(
      id = col,
      label = col,
      type = "integer",
      validation = list(min = min_val, max = max_val),
      plugin = "slider",
      plugin_config = list(min = min_val, max = max_val, value = min_val)
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  # Date columns
  date_cols <- names(data)[sapply(data, is.Date)]
  for (col in date_cols) {
    min_date <- min(data[[col]], na.rm = TRUE)
    max_date <- max(data[[col]], na.rm = TRUE)
    filter <- list(
      id = col,
      label = col,
      type = "date",
      validation = list(format = "YYYY/MM/DD"),
      plugin = "datepicker",
      plugin_config = list(
        format = "yyyy/mm/dd",
        todayBtn = "linked",
        todayHighlight = TRUE,
        autoclose = TRUE,
        startDate = min_date,
        endDate = max_date
      )
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  # Character columns
  categorical_cols <- names(data)[sapply(data, is.character)]
  for (col in categorical_cols) {
    unique_values <- sort(unique(data[[col]]))
    options <- lapply(unique_values, function(value) list(id = value, name = value))
    filter <- list(
      id = col,
      label = col,
      type = "string",
      input = "select",
      multiple = TRUE,
      plugin = "selectize",
      plugin_config = list(
        valueField = "id",
        labelField = "name",
        searchField = "name",
        sortField = "name",
        options = options
      )
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  widget_filters
}

# Initial filters
cancer_base_filters <- generate_widget_filters(cancer_dat)
# No initial rules
rules_widgets <- NULL


# ---- Sourcing tab modules here ----
source("Tabs/Overview_Tab/Overview_ui.R")

source("Tabs/Cancer_Statistics_Tab/Cancer_ui.R")
source("Tabs/Cancer_Statistics_Tab/Cancer_server.R")

source("Tabs/Heatwave_Tab/Heatwave_ui.R")
source("Tabs/Heatwave_Tab/Heatwave_server.R")
