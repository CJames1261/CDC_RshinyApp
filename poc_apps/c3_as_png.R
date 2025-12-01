library(shiny)
library(rpivotTable)
library(DBI)
library(RSQLite)

# ---- Load cancer data from SQLite ----
cancer_con <- dbConnect(SQLite(), dbname = "./Rshiny_Data_Bases/cancer_statistics_1999_2022.db")
cancer_dat <- dbGetQuery(cancer_con, "SELECT DISTINCT * FROM cancer_statistics_1999_2022")
dbDisconnect(cancer_con)

# ---- UI ----
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      /* Ensure axis lines are black */
      .c3-axis-x .domain, .c3-axis-y .domain {
        stroke: black !important;
        fill: none !important;
        stroke-width: 1.5px;
      }

      /* Keep grid lines light */
      .c3 line {
        stroke: #ccc;
      }

      /* Remove interactive hover rects */
      rect.c3-event-rect {
        fill: transparent !important;
      }

      /* Remove fill from paths and lines */
      .c3 path, .c3 line {
        fill: none !important;
      }
    ")),
    
    # JavaScript for export to PNG
    tags$script(HTML("
      function inlineAllStyles(svgElem) {
        const allElems = svgElem.querySelectorAll('*');
        svgElem.setAttribute('font-family', 'Arial, sans-serif');
        svgElem.setAttribute('font-size', '12px');

        allElems.forEach(el => {
          const tag = el.tagName.toLowerCase();
          const styles = window.getComputedStyle(el);

          el.setAttribute('font-family', styles.fontFamily);
          el.setAttribute('font-size', styles.fontSize);

          if (tag === 'text') {
            el.setAttribute('fill', styles.fill);
          }

          if (['line', 'path', 'circle', 'rect'].includes(tag)) {
            el.setAttribute('stroke', styles.stroke || 'black');
            el.setAttribute('stroke-width', styles.strokeWidth || '1');

            if (styles.fill && styles.fill !== 'none' && styles.fill !== 'rgba(0, 0, 0, 0)') {
              el.setAttribute('fill', styles.fill);
            } else {
              el.setAttribute('fill', 'none');
            }
          }
        });
      }

      async function exportC3ToPNG() {
        const svgElem = document.querySelector('.pvtRendererArea svg');
        if (!svgElem) {
          alert('No C3 chart found to export.');
          return;
        }

        const clonedSvg = svgElem.cloneNode(true);
        const svgNS = 'http://www.w3.org/2000/svg';

        const bg = document.createElementNS(svgNS, 'rect');
        bg.setAttribute('x', 0);
        bg.setAttribute('y', 0);
        bg.setAttribute('width', '100%');
        bg.setAttribute('height', '100%');
        bg.setAttribute('fill', '#ffffff');
        clonedSvg.insertBefore(bg, clonedSvg.firstChild);

        // Remove event rects
        clonedSvg.querySelectorAll('rect.c3-event-rect').forEach(r => r.remove());

        // Force area fills white
        clonedSvg.querySelectorAll('path.c3-area').forEach(p => p.setAttribute('fill', '#ffffff'));

        inlineAllStyles(clonedSvg);

        const svgData = new XMLSerializer().serializeToString(clonedSvg);
        const svgSize = svgElem.getBoundingClientRect();

        const canvas = document.createElement('canvas');
        canvas.width = svgSize.width;
        canvas.height = svgSize.height;

        const ctx = canvas.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        const img = new Image();
        const blob = new Blob([svgData], { type: 'image/svg+xml;charset=utf-8' });
        const url = URL.createObjectURL(blob);

        img.onload = function() {
          ctx.drawImage(img, 0, 0);
          URL.revokeObjectURL(url);

          const pngImg = canvas.toDataURL('image/png');
          const a = document.createElement('a');
          a.download = 'pivot_chart.png';
          a.href = pngImg;
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
        };

        img.src = url;
      }

      $(document).on('click', '#save_pivot_png', function() {
        exportC3ToPNG();
      });
    "))
  ),
  
  titlePanel("Cancer Statistics Pivot Chart Export"),
  
  sidebarLayout(
    sidebarPanel(
      actionButton("save_pivot_png", "Save Chart as PNG", class = "btn-primary"),
      br(), br(),
      helpText("Exports the current pivot chart as a PNG image with full styling.")
    ),
    mainPanel(
      rpivotTableOutput("pivot_table")
    )
  )
)

# ---- Server ----
server <- function(input, output, session) {
  output$pivot_table <- renderRpivotTable({
    rpivotTable(
      data = cancer_dat,
      rows = c("State"),
      cols = c("Year"),
      vals = "Count",
      aggregatorName = "Sum",
      rendererName = "Line Chart",
      renderers = list(
        "Table" = htmlwidgets::JS('$.pivotUtilities.renderers["Table"]'),
        "Heatmap" = htmlwidgets::JS('$.pivotUtilities.renderers["Heatmap"]'),
        "Table Barchart" = htmlwidgets::JS('$.pivotUtilities.renderers["Table Barchart"]'),
        "Row Heatmap" = htmlwidgets::JS('$.pivotUtilities.renderers["Row Heatmap"]'),
        "Col Heatmap" = htmlwidgets::JS('$.pivotUtilities.renderers["Col Heatmap"]'),
        "Bar Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Bar Chart"]'),
        "Line Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Line Chart"]'),
        "Stacked Bar Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Stacked Bar Chart"]'),
        "Area Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Area Chart"]'),
        "Scatter Chart" = htmlwidgets::JS('$.pivotUtilities.c3_renderers["Scatter Chart"]')
      )
    )
  })
}

# ---- Run App ----
shinyApp(ui = ui, server = server)
