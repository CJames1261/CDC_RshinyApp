# Tabs/Cancer_Statistics_Tab/Cancer_server.R

render_cancer_tab <- function(input, output, session) {
  
  # This holds the filtered data
  rv <- reactiveValues(filtered_data = cancer_dat)
  
 
  # Whenever filters change in jqbr
  observe({
    qb <- input$widget_filter
    
    if (is.null(qb)) return()
    
    rules <- qb$r_rules
    
    # Debug print
    print("Rules changed:")
    print(rules)
    
    # Update the filtered data reactively
    rv$filtered_data <- if (is.null(rules)) {
      cancer_dat
    } else {
      filter_table(cancer_dat, rules)
    }
    
    # Regenerate filter options based on filtered data
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    # Update the builder UI with the new filters and current rules
    updateQueryBuilder(
      inputId = "widget_filter",
      setFilters = new_filters,
      setRules = rules
    )
  })
  
  # Render the filtered table
  output$filtered_table <- renderDT({
    print("Rendering filtered table...")
    DT::datatable(rv$filtered_data)
  })
  
  # Handle Reset Button
  observeEvent(input$reset, {
    rv$filtered_data <- cancer_dat
    
    updateQueryBuilder(
      inputId = "widget_filter",
      reset = TRUE,
      setFilters = cancer_base_filters,
      setRules = NULL
    )
  })
}
