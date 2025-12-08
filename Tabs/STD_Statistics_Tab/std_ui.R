# ============================================================
#  STD UI — Modified From Cancer UI
# ============================================================

# ---- REUSE YOUR EXISTING CSS AND JS ----
css_body <- tags$head(
  tags$style(
    HTML(" 
    $(document).ready(function() {
      $('button[data-add=\"rule\"]').contents().last()[0].textContent = 'Add Filter';
    });

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

    hr {
      border-top: 1px solid #000000;
    }

    .iframe-border {
      border: 2px solid #000000;
    }

    .slides > slide > htroup > h1 {
      display: none;
    }

    .increase-fontsize-text {
      font-size: 20px;
    }

    .custom-tab-scrollbar {
      height: 50vh;
      overflow-y: auto;
      padding: 10px;
    }

    .full-screen {
      position: fixed;
      height: 98vh !important;
      width: 98vw !important;
      left: 0;
      top: 0;
      z-index: 9999;
      overflow: hidden;
    }

    .vertical-dotted-line {
      border-left: 2px dotted #28b78d;
      height: 100vh;
    }

    .selectize-input input[type='text'] {
      width: 300px !important;
    }

    .rule-value-container {
      border-left: 1px solid #ddd;
      padding-left: 5px;
      width: 300px;
    }

    .tooltip {
      position: absolute;
      z-index: 1070;
      display: none;
      font-size: 12px;
      color: #ffffff;
      background-color: #000000;
      bottom: 15px;
    }

    #download_cancer_data {
      display: none !important;
    }
  ")
  )
)

# ---------------- JavaScript (same as your original) ----------------
jss_body <- tags$head(
  tags$script(HTML("
    $(document).on('click', '.box-header .fa-minus', function() {
        var box = $(this).parents('.box').first();
        box.find('.box-body, .box-footer').slideUp();
        box.find('.box-header .fa-minus').removeClass('fa-minus').addClass('fa-plus');
    });

    $(document).on('click', '.box-header .fa-plus', function() {
        var box = $(this).parents('.box').first();
        box.find('.box-body, .box-footer').slideDown();
        box.find('.box-header .fa-plus').removeClass('fa-plus').addClass('fa-minus');
    });

    $(document).ready(function(){
        $('.box-header .fa-minus').click();
    });

    $(document).ready(function() {
      var box = $('#Test');
      if (box.hasClass('collapsed-box')) {
        box.removeClass('collapsed-box');
        box.find('.fa-plus').removeClass('fa-plus').addClass('fa-minus');
        box.find('.box-body, .box-footer').show();
      }
    });
  "))
)

# ============================================================
#  QUERY BUILDER UI BLOCK
# ============================================================

queryBuilder_std_ui <- tagList(
  fluidRow(
    column(6,
           h4("STD Query Builder"),
           queryBuilderInput(
             inputId = "widget_filter_std",
             filters = std_base_filters,   # define similar to cancer_base_filters
             rules = rules_widgets,        # can reuse your rules
             display_errors = TRUE,
             return_value = "all"
           ),
           br(),
           actionButton("reset_std", "Reset Filters", class = "btn-danger")
    ),
    column(6,
           h4("Filtered STD Data"),
           withSpinner(DTOutput("filtered_std_table"), type = 1, color = "#0dc5c1")
    )
  ),
  hr()
)


# ============================================================
#  PIVOT TABLE UI BLOCK
# ============================================================

pivot_std_ui <- fluidRow(
  column(1,
         h4("Pivot Options"),
         radioButtons(
           inputId = "std_format",
           choices = c("excel", "csv"),
           label = NULL,
           inline = TRUE,
           selected = "excel"
         ),
         downloadButton(
           outputId = "download_std_pivot",
           class = "btn-primary",
           label = "Download Pivot Table"
         )
  ),
  
  column(11,
         div(class = "panel panel-default",
             
             div(
               class = "panel-heading",
               style = "background:#000000; color:white; font-weight:bold;",
               "STD Pivot Table"
             ),
             
             div(class = "panel-body",
                 withSpinner(
                   rpivotTableOutput("std_pivot_widget", height = "100%"),
                   type = 1, color = "#0dc5c1"
                 )
             )
         )
  )
)


# ============================================================
#  MAIN STD TAB UI
# ============================================================

std_tab <- tabPanel(
  title = "STD Statistics (1996–2014)",
  
  fluidPage(
    useShinyjs(),
    useQueryBuilder(bs_version = "5"),
    
    css_body,
    jss_body,
    
    queryBuilder_std_ui,
    hr(),
    pivot_std_ui,
    
    downloadButton("download_std", label = "")
  )
)
