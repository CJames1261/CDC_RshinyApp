# Tabs/Cancer_Statistics_Tab/Cancer_ui.R

cancer_tab <- tabPanel(
  title = "Cancer Statistics",
  
  fluidPage(
    
    # ---- Top: Filter section in a box ----
    fluidRow(
      box(
        title = "Filters",
        collapsible = FALSE,
        width = 12,
        
        fluidRow(
          # Y variable (single select)
          column(
            width = 3,
            pickerInput(
              inputId = "y_sel",
              label = "Select y variable",
              choices = cancer_numeric_cols,   # to be filled dynamically in server
              options = list(
                `actions-box` = TRUE,
                `live-search` = TRUE,
                `selected-text-format` = "count > 3",
                `count-selected-text` = "{0} items selected",
                `deselect-all-text` = "Clear All",
                `select-all-text` = "Select All",
                `none-selected-text` = "None selected"
              ),
              multiple = FALSE   # <-- only one Y variable
            )
          ),
          
          # X variables (multi-select)
          column(
            width = 3,
            pickerInput(
              inputId = "x_sel",
              label = "Select x variables",
              choices = cancer_numeric_cols,   # to be filled dynamically
              options = list(
                `actions-box` = TRUE,
                `live-search` = TRUE,
                `selected-text-format` = "count > 2",
                `count-selected-text` = "{0} items selected",
                `deselect-all-text` = "Clear All",
                `select-all-text` = "Select All",
                `none-selected-text` = "None selected"
              ),
              multiple = TRUE    # <-- allow multiple X vars
            )
          ),
          
          # Grouping variable + possible values
          column(
            width = 3,
            pickerInput(
              inputId = "group_var",
              label = "Choose color grouping variable",
              choices = cancer_groupable_cols,
              options = list(
                `actions-box` = TRUE,
                `live-search` = TRUE,
                `count-selected-text` = "{0} items selected",
                `deselect-all-text` = "Clear All",
                `select-all-text` = "Select All",
                `none-selected-text` = "None selected"
              ),
              multiple = FALSE
            ),
            conditionalPanel(
              condition = "input.group_var != 'None selected'",
              pickerInput(
                inputId = "group_var_values",
                label = "Select values",
                choices = NULL,
                options = list(
                  `actions-box` = TRUE,
                  `live-search` = TRUE,
                  `selected-text-format` = "count > 3",
                  `count-selected-text` = "{0} items selected",
                  `deselect-all-text` = "Clear All",
                  `select-all-text` = "Select All",
                  `none-selected-text` = "None selected"
                ),
                multiple = TRUE
              )
            )
          ),
          
          # Year slider
          column(
            width = 3,
            sliderInput(
              inputId = "cancer_filter_year",
              label = "Year Range:",
              min = 1999,
              max = 2022,
              value = c(2010, 2022),
              step = 1,
              sep = ""   # no thousands separator
            )
          )
        )
      )
    ),
    
    br(),
    
    # ---- Bottom: two boxes side-by-side ----
    fluidRow(
      # Left box: visualizations
      column(
        width = 6,
        wellPanel(
          h4("Visualizations"),
          p("Plots and charts reacting to your filters will appear here."),
          plotOutput("cancer_main_plot", height = "300px"),
          br(),
          plotOutput("cancer_secondary_plot", height = "250px")
        )
      ),
      
      # Right box: live data view
      column(
        width = 6,
        wellPanel(
          h4("Filtered Data"),
          p("This table shows the current view of the cancer dataset based on the filters above."),
          DT::dataTableOutput("cancer_table")
        )
      )
    ),
    
    br()
  )
)
