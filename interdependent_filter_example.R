library(shiny)
library(jqbr)
library(dplyr)
library(DT)

# Assume cancer_dat is globally defined with:
# Year, State, CancerSite, AgeGroup, Sex, Race, Count, Population, CrudeRatePer100k

# ===== Custom Styles =====
jqbr_styles <- tags$head(
  tags$style(HTML("
    $(document).ready(function() {
      $('button[data-add=\"rule\"]').contents().last()[0].textContent = 'Add Filter';
    });

    .shiny-notification {
      position: fixed;
      top: calc(50%);
      left: calc(50%);
      transform: translate(-50%, 0%);
      max-height: 40px;
      max-width: 480px;
      font-size: 24px;
      font-weight: bold;
      color: black;
    }

    .selectize-input input[type='text'] {
      width: 300px !important;
    }

    .rule-value-container {
      border-left: 1px solid #ddd;
      padding-left: 5px;
      width: 300px;
    }
  ")),
  
  tags$style(HTML("
    .tooltip {
      position: absolute;
      z-index: 1070;
      display: none;
      font-size: 12px;
      color: #fff;
      background-color: #000;
      bottom: 15px;
    }
  "))
)

# ===== Dynamic Filter Generator =====
generate_widget_filters <- function(data) {
  filters <- list()
  
  # Numeric columns
  numeric_cols <- names(data)[sapply(data, is.numeric)]
  for (col in numeric_cols) {
    range_vals <- range(data[[col]], na.rm = TRUE)
    filters[[length(filters) + 1]] <- list(
      id = col,
      label = col,
      type = "integer",
      validation = list(min = range_vals[1], max = range_vals[2]),
      plugin = "slider",
      plugin_config = list(min = range_vals[1], max = range_vals[2], value = range_vals[1])
    )
  }
  
  # Character / categorical columns
  cat_cols <- names(data)[sapply(data, is.character) | sapply(data, is.factor)]
  for (col in cat_cols) {
    choices <- sort(unique(data[[col]]))
    filter_opts <- lapply(choices, function(val) list(id = val, name = val))
    
    filters[[length(filters) + 1]] <- list(
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
        options = filter_opts
      )
    )
  }
  
  filters
}

# ===== UI =====
ui <- fluidPage(
  jqbr_styles,
  useQueryBuilder(bs_version = "5"),
  
  fluidRow(
    column(8,
           h2("Cancer Data — Filter Builder"),
           p("Use the rules below to filter. Filters will dynamically update each other.")
    )
  ),
  
  fluidRow(
    column(6,
           h4("Dynamic Filters (jqbr)"),
           queryBuilderInput(
             inputId = "widget_filter",
             filters = generate_widget_filters(cancer_dat),
             rules = NULL,
             display_errors = TRUE,
             return_value = "all"
           ),
           br(),
           actionButton("reset", "Reset Filters", class = "btn-danger")
    ),
    
    column(6,
           h4("Filtered Table"),
           DTOutput("filtered_table")
    )
  )
)

# ===== SERVER =====
server <- function(input, output, session) {
  rv <- reactiveValues(filtered_data = cancer_dat)
  
  observe({
    qb_input <- input$widget_filter
    if (is.null(qb_input)) return()
    
    rules <- qb_input$r_rules
    
    if (is.null(rules)) {
      rv$filtered_data <- cancer_dat
    } else {
      rv$filtered_data <- filter_table(cancer_dat, rules)
    }
    
    # Recalculate options based on filtered data
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    updateQueryBuilder(
      inputId = "widget_filter",
      setFilters = new_filters,
      setRules = rules
    )
  })
  
  output$filtered_table <- renderDT({
    datatable(rv$filtered_data)
  })
  
  observeEvent(input$reset, {
    rv$filtered_data <- cancer_dat
    updateQueryBuilder(
      inputId = "widget_filter",
      reset = TRUE,
      setFilters = generate_widget_filters(cancer_dat),
      setRules = NULL
    )
  })
}

# ===== Run App =====
shinyApp(ui = ui, server = server)
