render_cancer_tab <- function(input, output, session) {
  
  # ---- REACTIVE VALUES ----
  rv <- reactiveValues(filtered_data = cancer_dat)
  
  # ---- DT DOWNLOAD CALLBACK ----
  
  callback <- JS(
    
    "var a = document.createElement('a');",
    "$(a).attr('id', 'dt_download');",
    "$(a).addClass('btn btn-default shiny-download-link dt-button');",
    "$(a).html('<i class=\"fa fa-download\"></i> Download Full Data');",
    
    
    "a.href = document.getElementById('download1').href;",
    "$(a).attr('download', '');",
    
    
    "$('div.dwnld').append(a);",
    
    
    "$('#download1').hide();"
  )
  
  # ---- FILTER HANDLING ----
  observe({
    qb <- input$widget_filter
    if (is.null(qb)) return()
    
    rules <- qb$r_rules
    
    # Apply filtering logic
    df_filtered <- if (is.null(rules)) {
      cancer_dat
    } else {
      df <- filter_table(cancer_dat, rules)
      if ("Year" %in% names(df)) {
        df$Year <- suppressWarnings(as.numeric(df$Year))
      }
      df
    }
    
    rv$filtered_data <- df_filtered
    
    # Auto-regenerate filters
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    updateQueryBuilder(
      inputId = "widget_filter",
      setFilters = new_filters,
      setRules = rules
    )
  })
  
  
  # ---- FILTERED DATA TABLE ----
  output$filtered_table <- renderDT({
    req(rv$filtered_data)
    
    datatable(
      rv$filtered_data,
      rownames = FALSE,
      extensions = "Buttons",
      callback = callback,
      options = list(
        dom = 'B<"dwnld">frtip',
        buttons = list("copy")  # optional
      )
    )
  })
  
  
  # ---- DOWNLOAD HANDLER FOR FILTERED DATA ----
  output$download1 <- downloadHandler(
    filename = function() {
      paste0("Cancer_Statistics_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- rv$filtered_data
      
      if (is.null(data)) {
        showNotification("No data available to download.", type = "error")
        return()
      }
      
      write.csv(data, file, row.names = FALSE)
    }
  )
  
  
  # ---- RESET FILTERS ----
  observeEvent(input$reset, {
    rv$filtered_data <- cancer_dat
    
    updateQueryBuilder(
      inputId = "widget_filter",
      reset = TRUE,
      setFilters = cancer_base_filters,
      setRules = NULL
    )
  })
  
  
  # ---- PIVOT TABLE ----
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
  
  
  # ---- PARSE PIVOT TABLE HTML → DATAFRAME ----
  df_for_download <- eventReactive(input$pivot_table_html, {
    html <- read_html(input$pivot_table_html)
    html_table_element <- html_element(html, "table")
    
    if (is.na(html_table_element)) return(NULL)
    
    df <- html_table(html_table_element)
    df <- as.data.frame(df)
    
    # Remove Totals
    df <- df[!grepl("Total", df[[1]], ignore.case = TRUE), ]
    
    df
  })
}
