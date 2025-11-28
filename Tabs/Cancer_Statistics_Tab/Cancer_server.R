

render_cancer_tab <- 
  function(input, output,session) {
    
    ### create reactive values
    cancer_global_reactive <- reactiveValues(
      data = cancer_dat
      
    )
    
    #numeric columns
    cancer_numeric_cols <- names(cancer_dat)[sapply(cancer_dat, is.numeric)]
    
    # 2. Binary columns (0/1 or "0"/"1")
    cancer_binary_cols <- names(cancer_dat)[sapply(cancer_dat, function(x) {
      vals <- unique(na.omit(x))      # ignore NA
      # numeric 0/1 OR character "0"/"1"
      (is.numeric(x)  && length(vals) > 0 && all(vals %in% c(0, 1))) ||
        (is.character(x) && length(vals) > 0 && all(vals %in% c("0", "1")))
    })]
    
    # 3. String / factor columns (good for grouping, filters, etc.)
    cancer_string_factor_cols <- names(cancer_dat)[sapply(cancer_dat, function(x) {
      is.character(x) || is.factor(x)
    })]
    
    # 4. If you want a generic "groupable" set: string/factor + binary
    cancer_groupable_cols <- union(cancer_string_factor_cols, cancer_binary_cols)
    
    
    # Optional: continuous numeric (numeric but NOT binary)
    cancer_continuous_cols <- setdiff(cancer_numeric_cols, cancer_binary_cols)
    
    observeEvent(input$group_var, {
      # If nothing or "None selected", clear the values picker
      if (is.null(input$group_var) || input$group_var == "None selected") {
        updatePickerInput(
          session,
          inputId = "group_var_values",
          choices = NULL,
          selected = NULL
        )
      } else {
        # Get unique values from the chosen grouping column
        vals <- sort(unique(cancer_dat[[input$group_var]]))
        
        updatePickerInput(
          session,
          inputId = "group_var_values",
          choices = vals,
          selected = vals   # default: all selected
        )
      }
    })
    
  
  }