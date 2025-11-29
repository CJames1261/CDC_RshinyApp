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
    
    rv$filtered_data <- if (is.null(rules)) {
      cancer_dat
    } else {
      filter_table(cancer_dat, rules)
    }
    
    # Regenerate filters dynamically
    new_filters <- generate_widget_filters(rv$filtered_data)
    
    updateQueryBuilder(
      inputId = "widget_filter",
      setFilters = new_filters,
      setRules = rules
    )
  })
  
  output$filtered_table <- renderDT({
    print("Rendering filtered table...")
    DT::datatable(rv$filtered_data)
  })
  
  observeEvent(input$reset, {
    rv$filtered_data <- cancer_dat
    
    updateQueryBuilder(
      inputId = "widget_filter",
      reset = TRUE,
      setFilters = cancer_base_filters,
      setRules = NULL
    )
  })
  
  # Dynamic X-axis selection based on columns
  output$x_var_ui <- renderUI({
    req(rv$filtered_data)
    selectInput("x_var", "X Variable:", choices = names(rv$filtered_data))
  })
  
  # Render pivot table
  output$pivot_table <- renderDT({
    req(input$agg_func, input$y_var, input$x_var, input$group_by)
    
    data <- rv$filtered_data
    
    # Symbols for grouping and Y var
    group_syms <- syms(input$group_by)
    y_sym <- sym(input$y_var)
    
    if (length(group_syms) == 0) {
      return(DT::datatable(data.frame(Message = "Please select at least one group by column.")))
    }
    
    aggregated <- data %>%
      group_by(!!!group_syms) %>%
      summarise(
        Aggregated = match.fun(input$agg_func)(!!y_sym, na.rm = TRUE),
        .groups = "drop"
      )
    
    DT::datatable(aggregated)
  })
  
  
  
}
