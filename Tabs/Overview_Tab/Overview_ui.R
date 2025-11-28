# Tabs/Overview_Tab/Overview_ui.R

Overview_tab <- tabPanel(
  title = "Overview",
  
  fluidRow(
    column(
      width = 10, offset = 1,
      
      br(),
      h2("📊 CDC Data Extraction & Public Health Visualization Project"),
      p(
        "This project began as an effort to deploy an R Shiny application capable of visualizing public health data from the CDC. ",
        "While exploring the CDC website to understand what datasets were publicly available, it became clear that accessing and working with the data is far more complicated than it should be. ",
        "The CDC’s interface can be confusing, the data formats are inconsistent, and the exported tables are not intuitive for the average user—especially those without a data science background."
      ),
      p(
        strong("Public health data may be publicly available, but it is not always transparent or accessible.")
      ),
      
      tags$hr(),
      h3("🔍 Project Motivation"),
      p(
        "After navigating the CDC’s data tools and discovering how challenging they can be for everyday users, this project was created to build a set of ",
        strong("Python-based extraction methods"),
        " that:"
      ),
      tags$ul(
        tags$li("Follow the official CDC WONDER API and form submission guidelines"),
        tags$li("Automate retrieval of public datasets"),
        tags$li("Clean and restructure the data into analysis-ready tables"),
        tags$li("Standardize naming, data types, and schema formats"),
        tags$li("Make the data usable for both analysts and non-technical users")
      ),
      p(
        "The goal is to lower the barrier of entry for exploring public health data. ",
        "Even though the data is public, it should be far easier to access, understand, and visualize."
      ),
      
      tags$hr(),
      h3("🚀 Current Progress"),
      p("So far, two complete extraction pipelines have been developed:"),
      tags$ul(
        tags$li(
          tags$b("Heat Wave Days in May–September (1981–2010)"),
          " — a fully automated pipeline that retrieves, parses, cleans, and stores heatwave data at the county level."
        ),
        tags$li(
          tags$b("Cancer Incidence 1999–2022"),
          " — extracted and standardized into an analysis-ready table for use within this R Shiny application."
        )
      ),
      
      p("These pipelines:"),
      tags$ul(
        tags$li("Send CDC-compliant API/form requests"),
        tags$li("Parse XML responses"),
        tags$li("Clean and validate raw data"),
        tags$li("Extract counties, states, and demographic attributes"),
        tags$li("Correct and standardize data types"),
        tags$li("Store the results in PostgreSQL and SQLite for querying"),
        tags$li("Prepare datasets for downstream visualization within R Shiny")
      ),
      
      tags$hr(),
      h3("⚠️ Data Limitations & API Restrictions"),
      p(
        strong("The CDC WONDER API restricts the number of grouping levels (group-bys) a user may request in a single query."),
        " These limits are almost certainly in place to protect individual privacy, particularly in datasets where small population counts could inadvertently reveal sensitive information."
      ),
      p(
        "Because of these restrictions, it is ",
        strong("not possible to extract extremely granular data"),
        " (e.g., multiple demographic breakdowns combined with rare conditions, small counties, or narrow time ranges)."
      ),
      p(
        "As a result, the datasets included in this application come ",
        strong("directly from the CDC WONDER API"),
        " but do not contain every possible column or demographic level. ",
        "What you see represents the maximum level of detail that the API legally allows for public release."
      ),
      p(
        "This ensures that the data remains accurate, privacy-preserving, and fully compliant with CDC guidelines."
      ),
      
      tags$hr(),
      h3("🎯 Next Steps"),
      tags$ul(
        tags$li(
          strong("Extract all publicly available CDC datasets"),
          tags$br(),
          "Automate retrieval for every available CDC WONDER dataset, each with its own schema, structure, and quirks."
        ),
        tags$li(
          strong("Standardize all datasets under a unified schema"),
          tags$br(),
          "Including normalized naming conventions, consistent data types, standardized geographic fields (County, FIPS, State), cleaned numeric fields, ",
          "and unified formats for time, demographics, measures, and metadata."
        ),
        tags$li(
          strong("Integrate all datasets into the R Shiny application"),
          tags$br(),
          "Allowing users to explore, filter, and visualize any CDC dataset through an intuitive interface."
        )
      ),
      
      tags$ul(
        tags$li("Explore datasets interactively"),
        tags$li("View charts, maps, and statistical summaries"),
        tags$li("Slice and filter by state, county, time, or demographic fields"),
        tags$li("Access meaningful public health insights without needing technical expertise")
      ),
      
      tags$hr(),
      h3("📈 Long-Term Vision"),
      p("Ultimately, this project aims to provide:"),
      tags$ul(
        tags$li("A unified API layer for CDC public datasets"),
        tags$li("Clean, standardized public health tables"),
        tags$li("Accessible visualizations for communities, researchers, and citizens"),
        tags$li("A transparent way to interact with data that influences public health decisions")
      ),
      
      tags$hr(),
      h3("🔗 Data Source & Transparency"),
      p(
        strong("All datasets included in this application come directly from the CDC WONDER API."),
        " The API requests, cleaning steps, and table transformations are all performed in Python."
      ),
      p(
        "If you want to inspect or validate how the data was gathered, you can review the complete extraction pipeline in the ",
        strong("Data_Extraction"),
        " folder. ",
        "These Python scripts document every API call and transformation from raw XML to the final standardized tables used here in R Shiny."
      ),
      
      br(), br()
    )
  )
)
