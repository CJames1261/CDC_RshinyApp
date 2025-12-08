# ============================================================
#  STD SERVER — Modified from Cancer Server
# ============================================================

render_std_tab <- function(input, output, session) {
  
  # ---- REACTIVE VALUES ----
  rv <- reactiveValues(filtered_data = std_dat)
  resetting <- reactiveVal(FALSE)
  
  # ---- DT DOWNLOAD CALLBACK ----
  callback <- JS(
    "var a = document.createElement('a');",
    "$(a).attr('id', 'dt_download');",
    "$(a).addClass('btn btn-default shiny-download-link dt-button');",
    "$(a).html('<i class=\"fa fa-download\"></i> Download Full Data');",
    "a.href = document.getElementById('download_std').href;",
    "$(a).attr('download', '');",
    "$('div.dwnld').append(a);",
    "$('#download_std').hide();"
  )
  
  
  # ============================================================
  #  FILTER HANDLING
  # ============================================================
  observe({
    
    if (resetting()) return()
    
    qb <- input$widget_filter_std
    if (is.null(qb)) return()
    
    rules <- qb$r_rules
    
    df_filtered <- if (is.null(rules)) {
      std_dat
    } else {
      df <- filter_table(std_dat, rules)
      
      # If your STD dataset includes a column named "Year"
      if ("Year" %in% names(df)) {
        df$Year <- suppressWarnings(as.numeric(df$Year))
      }
      
      df
    }
    
    rv$filtered_data <- df_filtered
    
    # Regenerate filters dynamically
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    updateQueryBuilder(
      inputId = "widget_filter_std",
      setFilters = new_filters,
      setRules = rules
    )
  })
  
  
  # ============================================================
  #  FILTERED DATA TABLE
  # ============================================================
  output$filtered_std_table <- renderDT({
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
  
  
  # ============================================================
  #  DOWNLOAD FILTERED STD DATA
  # ============================================================
  output$download_std <- downloadHandler(
    filename = function() {
      paste0("STD_Statistics_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(rv$filtered_data, file, row.names = FALSE)
    }
  )
  
  
  # ============================================================
  #  RESET FILTERS
  # ============================================================
  observeEvent(input$reset_std, {
    rv$filtered_data <- std_dat
    
    updateQueryBuilder(
      inputId = "widget_filter_std",
      reset = TRUE,
      setFilters = std_base_filters,   # ← you'll define these like cancer_base_filters
      setRules = NULL
    )
  })
  
  
  # ============================================================
  #  PIVOT TABLE (FELIX STYLE)
  # ============================================================
  output$std_pivot_widget <- renderRpivotTable({
    req(rv$filtered_data)
    
    rpivotTable(
      data = rv$filtered_data,
      rows = names(rv$filtered_data)[1],
      cols = names(rv$filtered_data)[2],
      vals = names(rv$filtered_data)[3],
      aggregatorName = "Sum",
      rendererName = "Heatmap",
      
      renderers = list(
        "Table"            = htmlwidgets::JS('$.pivotUtilities.renderers["Table"]'),
        "Table Barchart"   = htmlwidgets::JS('$.pivotUtilities.renderers["Table Barchart"]'),
        "Heatmap"          = htmlwidgets::JS('$.pivotUtilities.renderers["Heatmap"]'),
        "Line Chart"       = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Line Chart"]'),
        "Bar Chart"        = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Bar Chart"]'),
        "Stacked Bar Chart"= htmlwidgets::JS('$.pivotUtilities.c3_renderers["Stacked Bar Chart"]'),
        "Area Chart"       = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Area Chart"]')
      ),
      
      onRefresh = htmlwidgets::JS("
        function() {
          var htmltable = document.getElementsByClassName('pvtRendererArea')[0].innerHTML;
          Shiny.setInputValue('std_pivot_html', htmltable);
        }
      ")
    )
  })
  
  
  # ============================================================
  #  PARSE PIVOT HTML → DF
  # ============================================================
  std_pivot_df <- eventReactive(input$std_pivot_html, {
    req(input$std_pivot_html)
    
    html <- read_html(input$std_pivot_html)
    html_table_element <- html_element(html, "table")
    if (is.na(html_table_element)) return(NULL)
    
    df <- html_table(html_table_element)
    df <- as.data.frame(df)
    
    df <- df[!grepl("Total", df[[1]], ignore.case = TRUE), ]
    df <- df[, !grepl("Total", names(df), ignore.case = TRUE)]
    
    df
  })
  
  
  # ============================================================
  #  DOWNLOAD PIVOT TABLE
  # ============================================================
  output$download_std_pivot <- downloadHandler(
    filename = function() {
      if (input$std_format == "csv") {
        paste0("STD_Pivot_", Sys.Date(), ".csv")
      } else {
        paste0("STD_Pivot_", Sys.Date(), ".xlsx")
      }
    },
    content = function(file) {
      dataframe <- std_pivot_df()
      
      if (is.null(dataframe)) {
        showNotification("No pivot data available.", type = "error")
        return()
      }
      
      if (input$std_format == "csv") {
        readr::write_excel_csv(dataframe, file)
      } else {
        writexl::write_xlsx(dataframe, file)
      }
    }
  )
  
}
