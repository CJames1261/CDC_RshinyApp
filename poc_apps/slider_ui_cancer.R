# Tabs/Cancer_Statistics_Tab/Cancer_ui.R

css_body <- tags$head(
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
  ))
jss_body <- tags$head(
  tags$style(HTML("
    // put style tags here
  ")),
  tags$script(HTML("

    

    // JavaScript function to handle box minimization
    $(document).on('click', '.box-header .fa-minus', function() {
        var box = $(this).parents('.box').first();
        box.find('.box-body, .box-footer').slideUp();
        box.find('.box-header .fa-minus').removeClass('fa-minus').addClass('fa-plus');
    });

    // JavaScript function to handle box restoration
    $(document).on('click', '.box-header .fa-plus', function() {
        var box = $(this).parents('.box').first();
        box.find('.box-body, .box-footer').slideDown();
        box.find('.box-header .fa-plus').removeClass('fa-plus').addClass('fa-minus');
    });

    // Code to automatically click the minimize options on all sections in the app that can be minimized
    $(document).ready(function(){
        // Simulate a click on the collapse button
        $('.box-header .fa-minus').click();
    });

    // Additional JavaScript code for custom options
    // Add your custom JavaScript code here
    
    
    // expand the button by defualt in the Causal analysis tab
    $(document).ready(function() {
      var box = $('#Test');
      if (box.hasClass('collapsed-box')) {
        // Expand the box
        box.removeClass('collapsed-box');
        box.find('.fa-plus').removeClass('fa-plus').addClass('fa-minus');
        box.find('.box-body, .box-footer').show();
      }
    });
    
    
    
  "))
)

cancer_tab <- tabPanel(
  title = "Cancer Statistics",
  fluidPage(
    shinyjs::useShinyjs(),
    useQueryBuilder(bs_version = "5"),
    css_body,jss_body,
    
    fluidRow(
      column(6,
             h4("Query Builder"),
             queryBuilderInput(
               inputId = "widget_filter",
               filters = cancer_base_filters,
               rules = rules_widgets,
               display_errors = TRUE,
               return_value = "all"
             ),
             br(),
             actionButton("reset", "Reset Filters", class = "btn-danger")
      ),
      column(6,
             h4("Filtered Data"),
             DTOutput("filtered_table")
      )
    ),
    
    hr(),
    
    fluidRow(
      column(6,
             h4("Pivot Table Options"),
             selectInput("agg_func", "Aggregation Function:",
                         choices = c("Sum" = "sum", "Average" = "mean")),
             selectInput("y_var", "Y Variable (Aggregated):",
                         choices = c("Count"), selected = "Count"),
             uiOutput("x_var_ui"),
             selectizeInput("group_by", "Group By (Select Multiple):",
                            choices = c("Year", "State", "CancerSite", "AgeGroup", "Sex", "Race"),
                            multiple = TRUE)
      ),
      column(6,
             h4("Aggregated Data"),
             DTOutput("pivot_table")
      )
    )
  )
)
