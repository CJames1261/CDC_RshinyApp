# Tabs/Heatwave_Tab/Heatwave_ui.R

# ---- Heatwave Query Builder UI ----
heatwave_queryBuilder_ui <- tagList(
  fluidRow(
    column(
      6,
      h4("Query Builder"),
      queryBuilderInput(
        inputId        = "heatwave_widget_filter",
        filters        = heatwave_base_filters,
        rules          = rules_widgets,
        display_errors = TRUE,
        return_value   = "all"
      ),
      br(),
      actionButton("heatwave_reset", "Reset Filters", class = "btn-danger")
    ),
    column(
      6,
      h4("Filtered Data"),
      withSpinner(
        DTOutput("heatwave_filtered_table"),
        type  = 1,
        color = "#0dc5c1"
      )
    )
  ),
  hr()
)


# ---- Heatwave Pivot Table UI ----
heatwave_pivot_ui <- fluidRow(
  column(
    1,
    h4("Pivot Table Download Options"),
    radioButtons(
      inputId = "heatwave_format",
      label   = NULL,
      choices = c("excel", "csv"),
      inline  = TRUE,
      selected = "excel"
    ),
    downloadButton(
      outputId = "heatwave_downloadData",
      class    = "btn-primary",
      label    = "Download Pivot Table"
    )
  ),
  
  column(
    11,
    div(
      class = "panel panel-default",
      
      # ---- BLACK HEADING ----
      div(
        class = "panel-heading",
        style = "background:#000000; color:white; font-weight:bold;",
        "Pivot Table"
      ),
      
      div(
        class = "panel-body",
        withSpinner(
          rpivotTableOutput("heatwave_pivot_table_widget", height = "100%"),
          type  = 1,
          color = "#0dc5c1"
        )
      )
    )
  )
)


# ---- Main Heatwave Tab ----
heatwave_tab <- tabPanel(
  title = "Heatwave (1981–2010)",
  
  fluidPage(
    useShinyjs(),
    useQueryBuilder(bs_version = "5"),
    
    # reuse the same CSS/JS you defined in Cancer files
    css_body,
    jss_body,
    
    # ---- Query Builder UI ----
    heatwave_queryBuilder_ui,
    
    hr(),
    
    # ---- Pivot Table UI ----
    heatwave_pivot_ui,
    
    # Hidden download button used by DT callback
    downloadButton("heatwave_download_full", label = "")
  )
)
