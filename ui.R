

css_navbar <- tags$style(HTML(
  '
  /* Navbar background color */
  .navbar-default {
    background-color: #024d70 !important;
  }
  
  /* Styling for all tabs */
  .navbar-default .navbar-nav > li > a {
    color: white !important;
    font-weight: bold !important;
  }

  /* Styling for active tabs */
  .navbar-default .navbar-nav > .active > a,
  .navbar-default .navbar-nav > .active > a:focus,
  .navbar-default .navbar-nav > .active > a:hover {
    color: black !important;
    background-color: white !important;
  }
  '
))



JS_navbar <- tags$script(HTML('
  $(document).ready(function() {
    var githubURL = "https://github.com/CJames1261/CDC_RshinyApp.git";

    // Append the GitHub logo and overlay text
    $(".github-container").append(\'<div style="position: relative; width: 100px; height: 40px; margin-right: 0px;">\' +
                  // GitHub logo
                  \'<a href="\' + githubURL + \'" target="_blank" style="display: block; width: 100%; height: 100%;"><img src="github_logo.png" alt="GitHub" style="width:100%; height:100%;"></a>\' +
                  // Text overlay centered on the image
                  \'<a href="\' + githubURL + \'" target="_blank" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; color: white; font-weight: bold; text-align: center; text-decoration: none; line-height: 50px; background-color: rgba(0, 0, 0, 0.4); font-size: 9px;">Follow me on GitHub</a>\' +
                  \'</div>\');
  });
'))



fluidPage( useWaiter() ,waiter_show_on_load(
  color = "#5cb85c",  # Overlay background color
  html = tagList(
    spin_3k(),        # Loading spinner
    h3("Loading CDC Analysis Tool...")  # Loading text
  ),
), useShinyjs(),
# Banner styling
tags$head(
  tags$style(HTML("
      .banner {
        width: 100%;
        background-color: #5cb85c;
        color: #FFFFFF;
        padding: 10px;
        font-size: 18px;
        font-weight: bold;
        display: flex;
        justify-content: space-between;
        align-items: center;
        height: 40px;
        position: relative;  /* Add this to make it a reference for positioning */
      }
      .title-container {
        flex-grow: 1;
        text-align: center;
      }
      .button-container {
        position: absolute;  /* Anchors to the banner container */
        top: 40px;              /* Aligns with top of banner */
        right: 15px;         /* Keeps it at the right side */
        z-index: 1001;       /* Keeps it above navbar */
      }
      .navbar-brand { 
        display: none !important; /* Use !important to ensure it overrides */
      }
      #open_modal {  /* Targeting the action button */
        font-size: 16px;      /* Increases text size */
        padding: 14px 24px;   /* Increases padding */
        height: auto;         /* Adjusts height */
        width: auto;          /* Adjusts width */
      }
    "))
),

# Banner div with version on the left, title centered, and GitHub link on the right
tags$div(
  class = "banner",
  tags$div(
    class = "title-container",
    style = "display: flex; flex-direction: column; align-items: center; font-size: 15px;",
    tags$div(span("CDC ANALYSIS TOOL")),
    tags$div(style = "font-size: 10px; margin-top: 0px;", glue::glue("v1.0"))
  ),
  tags$div(class = "github-container")
),


# Navbar with tabs
navbarPage(
  id = 'tabs',
  title = 'CDC Data Exploration Tool',
  Overview_tab,
  cancer_tab,
  heatwave_tab,
  JS_navbar,
  css_navbar
)
)