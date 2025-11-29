
# Tabs/Cancer_Statistics_Tab/Cancer_server.R

render_cancer_tab <- function(input, output, session) {

  # Reactive filtered dataset
  rv <- reactiveValues(filtered_data = cancer_dat)
  
  observe({
    qb <- input$widget_filter
    if (is.null(qb)) return()
    
    rules <- qb$r_rules
    print("Rules changed:")
    print(rules)
    
    # Apply filtering logic
    df_filtered <- if (is.null(rules)) {
      cancer_dat
    } else {
      df <- filter_table(cancer_dat, rules)
      
      # Ensure 'Year' stays numeric so sliders work
      if ("Year" %in% names(df)) {
        df$Year <- suppressWarnings(as.numeric(df$Year))
      }
      
      df
    }
    
    # Update reactive value
    rv$filtered_data <- df_filtered
    
    # Print column types for debugging
    print("Column classes after filtering:")
    print(sapply(rv$filtered_data, class))
    
    # Regenerate filters
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    updateQueryBuilder(
      inputId = "widget_filter",
      setFilters = new_filters,
      setRules = rules
    )
  })
  
  # Render filtered data table
  output$filtered_table <- renderDT({
    req(rv$filtered_data)
    DT::datatable(rv$filtered_data)
  })
  
  # Reset filters
  observeEvent(input$reset, {
    rv$filtered_data <- cancer_dat
    
    updateQueryBuilder(
      inputId = "widget_filter",
      reset = TRUE,
      setFilters = cancer_base_filters,
      setRules = NULL
    )
  })
  
  # Render rpivotTable widget
  output$pivot_table_widget <- renderRpivotTable({
    req(rv$filtered_data)
    
    rpivotTable(
      data = rv$filtered_data,
      rows = c("State"),
      cols = c("Year"),
      vals = "Count",
      aggregatorName = "Sum",
      rendererName = "Table Barchart",
      onRefresh = htmlwidgets::JS("
        function() {
          var htmltable = document.getElementsByClassName('pvtRendererArea')[0].innerHTML;
          Shiny.setInputValue('pivot_table_html', htmltable);
        }
      ")
    )
  })
  
  # Extract pivot table HTML and convert to dataframe
  df_for_download <- eventReactive(input$pivot_table_html, {
    html <- read_html(input$pivot_table_html)
    html_table_element <- html_element(html, "table")
    
    if (is.na(html_table_element)) return(NULL)
    
    df <- html_table(html_table_element)
    df <- as.data.frame(df)
    
    # Remove 'Total' rows/columns if present
    df <- df[!grepl("Total", df[[1]], ignore.case = TRUE), ]
    
    df
  })
  
  # Download handler
  output$downloadData <- downloadHandler(
    filename = function() {
      suffix <- format(Sys.Date(), "%Y%m%d")
      if (input$format == "csv") {
        paste0("pivot_table_", suffix, ".csv")
      } else {
        paste0("pivot_table_", suffix, ".xlsx")
      }
    },
    content = function(file) {
      data <- df_for_download()
      if (is.null(data)) {
        showNotification("No data to download.", type = "error")
        return(NULL)
      }
      
      if (input$format == "csv") {
        readr::write_excel_csv(data, file = file)
      } else {
        writexl::write_xlsx(data, path = file)
      }
    }
  )
}
