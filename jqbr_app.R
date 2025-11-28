library(shiny)
library(jqbr)
library(dplyr)
library(DT)

set.seed(123)

#---------------------------
# 1. Dummy data
#---------------------------
n_rows <- 825

dates <- seq(as.Date("2022-01-01"), Sys.Date(), by = "day")
n_rows <- length(dates)

binary_cols <- matrix(
  sample(0:1, n_rows * 2, replace = TRUE),
  nrow = n_rows, ncol = 2,
  dimnames = list(NULL, paste0("binary_", 1:2))
)

continuous_vars <- data.frame(
  continuous_1 = rnorm(n_rows, mean = 50, sd = 10),
  continuous_2 = rnorm(n_rows, mean = 100, sd = 20),
  continuous_3 = rnorm(n_rows, mean = 25, sd = 5)
)

categorical_cols <- data.frame(
  categorical_1 = sample(c("A", "B", "C"), n_rows, replace = TRUE),
  categorical_2 = sample(c("X", "Y", "Z"), n_rows, replace = TRUE)
)

dummy_data <- data.frame(
  date = dates,
  binary_cols,
  continuous_vars,
  categorical_cols,
  check.names = FALSE
)

is.Date <- function(x) inherits(x, "Date")

#---------------------------
# 2. Filter generator
#    IMPORTANT: always use `data`, not `dummy_data`
#---------------------------
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
  
  # Continuous numeric columns (non-binary)
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
  
  # Categorical columns (characters)
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
        valueField  = "id",
        labelField  = "name",
        searchField = "name",
        sortField   = "name",
        options     = options
      )
    )
    widget_filters <- c(widget_filters, list(filter))
  }
  
  widget_filters
}

# Initial filters based on full data
base_filters <- generate_widget_filters(dummy_data)

# No initial rules
rules_widgets <- NULL

#---------------------------
# 3. UI
#---------------------------

jqbr_styles <- tags$head(
  tags$style(
    HTML(" 
    $(document).ready(function() {
      $('button[data-add=\"rule\"]').contents().last()[0].textContent = 'Add Filter';
    });
    
    /* Custom styles for notifications */
    .shiny-notification {  
      position: fixed;
      top: calc(50%);  
      left: calc(50%);  
      transform: translate(-50%, 0%);
      height: 100%;
      max-height: 40px;
      width: 100%;
      max-width: 480px;
      font-size: 24px;
      font-weight: bold;
      color: black;
    }
    
    /* darker font for break line */
    hr {
      border-top: 1px solid #000000;
    }
    
    /* border for iframe */
    iframe-border {
      border: 2px solid #000000;
    }
    
    /* hide slide header numbersin presentation */
    .slides > slide > htroup > h1 {
      display: none;
    }
    
    /* hide slide headers */
    .increase-fontsize-text {
      font-size: 20px;
    }
    
    /* creating a class '.custom-tab-scrollbar' to add a scroll bar to the contents displayed in tabs */
    .custom-tab-scrollbar {
      height: 50vh;
      overflow-y: auto;
      padding: 10px;
    }
    
    /* creating a class name '.full_screen' */
    .full-screen {
      position: fixed;
      height: 98vh !important;
      width: 98vw !important;
      left: 0;
      top: 0;
      z-index: 9999;
      overflow: hidden;
    }
    
    /* Creating custom vertical dotted line */
    .vertical-dotted-line {
      border-left: 2px dotted #28b78d; /* Adjust color and thickness as needed */
      height: 100vh; /* Adjust height as needed */
    }
    
    
    
    
    /* Need both of the following two sections: .selectize-input & .rule-value-container widths set so that the selection options are seable */
    .selectize-input input[type='text'] {
      width: 300px !important; /* Adjust the width as needed */
    }
    .rule-value-container {
    border-left: 1px solid #ddd;
    padding-left: 5px;
    width: 300px;
    }
    
    
    
    
    
    
    }
  ")
),
tags$style(
  HTML("
         /* enabling tooltip for the Jquery slider selcections */
    .tooltip {
    position: absolute;
    z-index: 1070;
    display: none; /* Initially hide tooltip */
    font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
    font-style: normal;
    font-weight: 400;
    line-height: 1.42857143;
    line-break: auto;
    text-align: left;
    text-align: start;
    text-decoration: none;
    text-shadow: none;
    text-transform: none;
    letter-spacing: normal;
    word-break: normal;
    word-spacing: normal;
    word-wrap: normal;
    white-space: normal;
    font-size: 12px;
    filter: alpha(opacity = 100); /* For older versions of IE */
    opacity: 1; /* Make the tooltip fully visible */
    color: #ffffff; /* Text color */
    background-color: #000000; /* Background color */
    
    /* Lower the position of the tooltip */
    bottom: 15px; /* Adjust the value as needed */
    }
  ")
)
)


ui <- fluidPage(
  theme = bslib::bs_theme(version = "3"),
  jqbr_styles,
  useQueryBuilder(bs_version = "5"),
  
  fluidRow(
    column(
      width = 8,
      h2("jqbr with interdependent filters"),
      p("Each time you add/change rules, the available values for all filters ",
        "are recomputed from the currently filtered data.")
    )
  ),
  fluidRow(
    column(
      width = 6,
      h4("Builder"),
      queryBuilderInput(
        inputId        = "widget_filter",
        filters        = base_filters,
        rules          = rules_widgets,
        display_errors = TRUE,
        return_value   = "all"
      ),
      br(),
      actionButton("reset", "Reset", class = "btn-danger")
    ),
    column(
      width = 6,
      h4("Filtered data"),
      DTOutput("test")
    )
  )
)

#---------------------------
# 4. Server
#---------------------------
server <- function(input, output, session) {
  
  rv <- reactiveValues(
    filtered_data = dummy_data
  )
  
  # Main interdependent logic
  observe({
    qb <- input$widget_filter
    if (is.null(qb)) return()
    
    rules <- qb$r_rules
    
    # 1) Filter the data according to current rules
    if (is.null(rules)) {
      rv$filtered_data <- dummy_data
    } else {
      rv$filtered_data <- filter_table(dummy_data, rules)
    }
    
    # 2) Rebuild filters from the *filtered* data
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    # 3) Update queryBuilder with new filters + current rules
    updateQueryBuilder(
      inputId    = "widget_filter",
      setFilters = new_filters,
      setRules   = rules
    )
  })
  
  # Show filtered data
  output$test <- renderDT({
    datatable(rv$filtered_data)
  })
  
  # Reset: restore original filters & data
  observeEvent(input$reset, {
    rv$filtered_data <- dummy_data
    
    updateQueryBuilder(
      inputId    = "widget_filter",
      reset      = TRUE,
      setFilters = base_filters,
      setRules   = NULL
    )
  })
}

shinyApp(ui, server)