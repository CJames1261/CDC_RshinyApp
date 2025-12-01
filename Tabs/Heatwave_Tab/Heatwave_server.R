# Tabs/Heatwave_Tab/Heatwave_server.R

render_heatwave_tab <- function(input, output, session) {
  
  # ---- REACTIVE VALUES ----
  rv <- reactiveValues(filtered_data = heatwave_dat)
  resetting <- reactiveVal(FALSE)
  
  # ---- DT DOWNLOAD CALLBACK (Heatwave-specific) ----
  heatwave_dt_callback <- JS(
    "var a = document.createElement('a');",
    "$(a).attr('id', 'heatwave_dt_download');",
    "$(a).addClass('btn btn-default shiny-download-link dt-button');",
    "$(a).html('<i class=\"fa fa-download\"></i> Download Full Data');",
    "a.href = document.getElementById('heatwave_download_full').href;",
    "$(a).attr('download', '');",
    "$('div.heatwave_dwnld').append(a);",
    "$('#heatwave_download_full').hide();"
  )
  
  # ---- FILTER HANDLING ----
  observe({
    # Ignore filter logic while resetting
    if (resetting()) return()
    
    qb <- input$heatwave_widget_filter
    if (is.null(qb)) return()
    
    rules <- qb$r_rules
    
    df_filtered <- if (is.null(rules)) {
      heatwave_dat
    } else {
      df <- filter_table(heatwave_dat, rules)
      if ("Year" %in% names(df)) {
        df$Year <- suppressWarnings(as.numeric(df$Year))
      }
      df
    }
    
    rv$filtered_data <- df_filtered
    
    # Re-generate filters based on current filtered data
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    updateQueryBuilder(
      inputId = "heatwave_widget_filter",
      setFilters = new_filters,
      setRules = rules
    )
  })
  
  
  # ---- FILTERED DATA TABLE ----
  output$heatwave_filtered_table <- renderDT({
    req(rv$filtered_data)
    datatable(
      rv$filtered_data,
      rownames = FALSE,
      extensions = "Buttons",
      callback = heatwave_dt_callback,
      options = list(
        dom = 'B<"heatwave_dwnld">frtip',
        buttons = list("")  # placeholder; JS adds real button
      )
    )
  })
  
  # ---- DOWNLOAD FILTERED TABLE ----
  output$heatwave_download_full <- downloadHandler(
    filename = function() {
      paste0("Heatwave_Statistics_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(rv$filtered_data, file, row.names = FALSE)
    }
  )
  
  
  # ---- RESET FILTERS ----
  observeEvent(input$heatwave_reset, {
    resetting(TRUE)
    
    rv$filtered_data <- heatwave_dat
    
    updateQueryBuilder(
      inputId = "heatwave_widget_filter",
      reset     = TRUE,
      setFilters = heatwave_base_filters,
      setRules   = NULL
    )
    
    resetting(FALSE)
  })
  
  
  # ---- HEATWAVE PIVOT TABLE ----
  output$heatwave_pivot_table_widget <- renderRpivotTable({
    req(rv$filtered_data)
    
    rpivotTable(
      data = rv$filtered_data,
      rows = "State",
      cols = "Year",
      vals = "hw_tmax_days",   # you can change default metric if you prefer
      aggregatorName = "Sum",
      rendererName = "Heatmap",
      
      renderers = list(
        "Table"             = htmlwidgets::JS('$.pivotUtilities.renderers["Table"]'),
        "Table Barchart"    = htmlwidgets::JS('$.pivotUtilities.renderers["Table Barchart"]'),
        "Heatmap"           = htmlwidgets::JS('$.pivotUtilities.renderers["Heatmap"]'),
        "Line Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Line Chart"]'),
        "Bar Chart"         = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Bar Chart"]'),
        "Stacked Bar Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Stacked Bar Chart"]'),
        "Area Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Area Chart"]')
      ),
      
      onRefresh = htmlwidgets::JS("
        function() {
          var htmltable = document.getElementsByClassName('pvtRendererArea')[0].innerHTML;
          Shiny.setInputValue('heatwave_pivot_table_html', htmltable);
        }
      ")
    )
  })
  
  
  # ---- PARSE PIVOT HTML → DF ----
  df_for_download_heatwave <- eventReactive(input$heatwave_pivot_table_html, {
    req(input$heatwave_pivot_table_html)
    
    html <- read_html(input$heatwave_pivot_table_html)
    html_table_element <- html_element(html, "table")
    if (is.na(html_table_element)) return(NULL)
    
    df <- html_table(html_table_element)
    df <- as.data.frame(df)
    
    # Drop total rows/cols like you did in cancer tab
    df <- df[!grepl("Total", df[[1]], ignore.case = TRUE), ]
    df <- df[, !grepl("Total", names(df), ignore.case = TRUE)]
    
    df
  })
  
  
  # ---- DOWNLOAD PIVOT TABLE ----
  output$heatwave_downloadData <- downloadHandler(
    filename = function() {
      if (input$heatwave_format == "csv") {
        paste0("Heatwave_Pivot_Table_", Sys.Date(), ".csv")
      } else {
        paste0("Heatwave_Pivot_Table_", Sys.Date(), ".xlsx")
      }
    },
    content = function(file) {
      dataframe <- df_for_download_heatwave()
      if (is.null(dataframe)) {
        showNotification("No pivot data available.", type = "error")
        return()
      }
      
      if (input$heatwave_format == "csv") {
        readr::write_excel_csv(dataframe, file)
      } else {
        writexl::write_xlsx(dataframe, file)
      }
    }
  )
}
