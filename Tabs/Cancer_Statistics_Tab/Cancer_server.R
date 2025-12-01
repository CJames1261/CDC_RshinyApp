render_cancer_tab <- function(input, output, session) {
  
  # ---- REACTIVE VALUES ----
  rv <- reactiveValues(filtered_data = cancer_dat)
  resetting <- reactiveVal(FALSE)
  
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
    # Ignore filter logic while resetting
    if (resetting()) return()
    
    qb <- input$widget_filter
    if (is.null(qb)) return()
    
    rules <- qb$r_rules
    
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
        buttons = list("")
      )
    )
  })
  
  # ---- DOWNLOAD FILTERED TABLE ----
  output$download1 <- downloadHandler(
    filename = function() {
      paste0("Cancer_Statistics_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(rv$filtered_data, file, row.names = FALSE)
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
  

  
  
  
  # ---- UPDATED PIVOT TABLE (FELIX VERSION) ----
  output$pivot_table_widget <- renderRpivotTable({
    req(rv$filtered_data)

    rpivotTable(
      data = rv$filtered_data,
      rows = "State",
      cols = "Year",
      vals = "Count",
      aggregatorName = "Sum",
      rendererName = "Heatmap",

      # Full Felix renderer list
      renderers = list(
        "Table"          = htmlwidgets::JS('$.pivotUtilities.renderers["Table"]'),
        "Table Barchart" = htmlwidgets::JS('$.pivotUtilities.renderers["Table Barchart"]'),
        "Heatmap"        = htmlwidgets::JS('$.pivotUtilities.renderers["Heatmap"]'),
        "Line Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Line Chart"]'),
        "Bar Chart"         = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Bar Chart"]'),
        "Stacked Bar Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Stacked Bar Chart"]'),
        "Area Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Area Chart"]')
      ),

      onRefresh = htmlwidgets::JS("
        function() {
          var htmltable = document.getElementsByClassName('pvtRendererArea')[0].innerHTML;
          Shiny.setInputValue('pivot_table_html', htmltable);
        }
      ")
    )
  })

  # ---- PARSE PIVOT HTML → DF ----
  df_for_download <- eventReactive(input$pivot_table_html, {
    req(input$pivot_table_html)

    html <- read_html(input$pivot_table_html)
    html_table_element <- html_element(html, "table")
    if (is.na(html_table_element)) return(NULL)

    df <- html_table(html_table_element)
    df <- as.data.frame(df)

    df <- df[!grepl("Total", df[[1]], ignore.case = TRUE), ]
    df <- df[, !grepl("Total", names(df), ignore.case = TRUE)]

    df
  })

  # ---- DOWNLOAD PIVOT TABLE ----
  output$downloadData <- downloadHandler(
    filename = function() {
      if (input$format == "csv") {
        paste0("Pivot_Table_", Sys.Date(), ".csv")
      } else {
        paste0("Pivot_Table_", Sys.Date(), ".xlsx")
      }
    },
    content = function(file) {
      dataframe <- df_for_download()
      if (is.null(dataframe)) {
        showNotification("No pivot data available.", type = "error")
        return()
      }

      if (input$format == "csv") {
        readr::write_excel_csv(dataframe, file)
      } else {
        writexl::write_xlsx(dataframe, file)
      }
    }
  )
}
