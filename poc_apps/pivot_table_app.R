# title: R Shiny Pivot Table with Excel/CSV Export
# author: FelixAnalytix.com
# notes: for more templates see: felixanalytix.com/templates


# Load R packages ---------------------------------------------------------

library(rpivotTable) # install.packages("rpivotTable")
library(htmlwidgets) # install.packages("htmlwidgets")
library(rvest) # install.packages("rvest")
library(writexl) # install.packages("writexl")
library(readr) # install.packages("readr")
library(shiny) # install.packages("shiny")
library(bslib) # install.packages("bslib")
# dplyr only to access the starwars dataset
library(dplyr)  # install.packages("dplyr")
library(dplyr)
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

# If you get an issue due to R package versioning, 
# you can use renv::restore() with the "renv.lock" file in your working dir.
# Learn more here: https://rstudio.github.io/renv/
#renv::restore()


# Add your datasets -------------------------------------------------------
cancer_con <- dbConnect(SQLite(), dbname = "./Rshiny_Data_Bases/cancer_statistics_1999_2022.db")
print(dbListTables(cancer_con))

# Replace "your_table_name" with the actual name of the table you want to query
cancer_dat <- dbGetQuery(cancer_con, "SELECT DISTINCT * FROM cancer_statistics_1999_2022")

# Add your own data frames in the list
DATASETS <- list(
  "starwars" = starwars[,1:11], # only columns 1 to 11
  "iris" = iris,
  "mtcars" = mtcars,
  'cancer' = cancer_dat
)
# change pre-selected row and column variables in lines 85-86


# User Interface ----------------------------------------------------------

ui <- page_sidebar(
  # change color
  #tags$style(type="text/css",".pvtRows, .pvtCols { background: #000000 none repeat scroll 0 0; }" ),
  title = "Pivot Table with Excel Export",
  sidebar = sidebar(
    selectInput(
      inputId = "dataset", 
      label = "Choose a dataset:", 
      choices = names(DATASETS), 
      selected = names(DATASETS)[4]
    ),
    radioButtons(inputId = "format",
                 choices = c(
                   "excel", 
                   #"csv2", # for some European countries, comma as decimal point and a semicolon for separator
                   "csv"
                 ),
                 label = NULL,
                 inline = TRUE,
                 selected = "excel"),
    downloadButton(
      outputId = "downloadData", 
      class = "btn-primary",
      label = "Download table")
  ),
  card(
    fill = TRUE, 
    card_header("Pivot Table", class = "bg-dark"),
    card_body(
      div(
        style = "overflow-x: auto;", # make pivot table scrollable
        rpivotTableOutput("pivot", height = "100%")
      )
    ),
    card_footer(
      align = "right",
      markdown("More R templates: [felixanalytix.com/templates](https://felixanalytix.com/templates)")
    )
  )
)


# Server ------------------------------------------------------------------

server <- function(input, output){
  data_selected <- eventReactive(input$dataset, {
    DATASETS[[input$dataset]]
  })
  
  output$pivot <- renderRpivotTable(
    rpivotTable(
      data = data_selected(), 
      rows = names(data_selected())[5], # 5th variable selected by default
      cols = names(data_selected())[4], # 4th variable selected by default
      rendererName = "Heatmap", # heatmap selected by default
      # allow users to only choose table renderers
      renderers = list(
        
        # Standard renderers
        "Table"          = htmlwidgets::JS('$.pivotUtilities.renderers["Table"]'),
        "Table Barchart" = htmlwidgets::JS('$.pivotUtilities.renderers["Table Barchart"]'),
        "Heatmap"        = htmlwidgets::JS('$.pivotUtilities.renderers["Heatmap"]'),
        
        # C3 chart renderers
        "Line Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Line Chart"]'),
        "Bar Chart"         = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Bar Chart"]'),
        "Stacked Bar Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Stacked Bar Chart"]'),
        "Area Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Area Chart"]'),
        "Pie Chart"          = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Pie Chart"]'),
        "Donut Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Donut Chart"]')
      ),
      onRefresh = htmlwidgets::JS("function() {
            var htmltable=document.getElementsByClassName('pvtRendererArea')[0].innerHTML;
            Shiny.setInputValue('pivot_table', htmltable);
            }")
    )
  )
  
  df <- eventReactive(input$pivot_table, {
    html <- read_html(input$pivot_table)
    html <- html_element(html, "table")
    html <- html_table(html)
    df <- as.data.frame(html)
    df <- df[-nrow(df),] # remove last row, containing totals
    df <- df[1:ncol(df)-1] # remove last column, containing totals
    df
  })
  
  output$datatable <- DT::renderDT(
    data_selected(),
    rownames = FALSE,
    options = list(searchHighlight = TRUE)
  )
  
  output$downloadData <- downloadHandler(
    filename = function() {
      if (input$format == "csv") {
        paste0(input$dataset, "_", gsub("-", "", Sys.Date()), ".csv")
      } else if (input$format == "csv2") {
        paste0(input$dataset, "_", gsub("-", "", Sys.Date()), ".csv")
      } else if (input$format == "excel") {
        paste0(input$dataset, "_", gsub("-", "", Sys.Date()), ".xlsx")
      }
    },
    content = function(file) {
      dataframe <- df()
      if (input$format == "csv") {
        readr::write_excel_csv(dataframe, file = file)
      }  else if (input$format == "csv2") {
        readr::write_excel_csv2(dataframe, path = file)
      } else if (input$format == "excel") {
        writexl::write_xlsx(dataframe, path = file)
      }
    }
  )
} 


# Launch app --------------------------------------------------------------

# lauch in your browser
runApp(list(ui = ui, server = server), launch.browser = TRUE)

#shinyApp(ui = ui, server = server)
