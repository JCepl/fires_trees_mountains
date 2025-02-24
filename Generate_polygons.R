library(shiny)
library(terra)
library(sf)
library(dplyr)
library(smoothr)
library(lwgeom)
library(colourpicker)
# install.packages("Cairo")
library(Cairo)
###############################################
# 1) CREATE OR LOAD YOUR DATA (dummy example) #
###############################################
setwd("/Users/jaroslavcepl/Documents/Projekty/logo_noze/Ohen_Final/SlicesOutput")
slices <- dir()

slices <- slices[grepl("slice", slices)]

scices_list <- list()
for (i in seq_along(slices)) {
  scices_list[[i]] <- as.matrix(read.table(slices[i], sep = ","))
}

###############################################
# 2) DEFINE THE UI #
###############################################
ui <- fluidPage(
  titlePanel("Dynamic Contour Viewer with Customizable Segment Colors"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "frameIndex",
        label = "Select Frame:",
        min = 1,
        max = length(scices_list),
        value = 1,
        step = 1
      ),
      
      # Dynamic sliders for boundaries
      colourInput("color1", "Color for Segment [0, b1)", value = "white"),
      sliderInput("b1", "Boundary 1", min = 1, max = 1499, value = 300, step = 1),
      colourInput("color2", "Color for Segment [b1, b2)", value = "black"),
      sliderInput("b2", "Boundary 2", min = 2, max = 1499, value = 700, step = 1),
      colourInput("color3", "Color for Segment [b2, b3)", value = "white"),
      sliderInput("b3", "Boundary 3", min = 3, max = 1499, value = 1200, step = 1),
      colourInput("color4", "Color for Segment [b3, b4)", value = "black"),
      sliderInput("b4", "Boundary 4", min = 4, max = 1500, value = 1500, step = 1),
      colourInput("color5", "Color for Segment [b4, 2000)", value = "white"),
      
      # colourInput("color1", "Color for Segment [0, b1)", value = "blue"),
      # sliderInput("b1", "Boundary 1", min = 1, max = 1499, value = 300, step = 1),
      # colourInput("color2", "Color for Segment [b1, b2)", value = "green"),
      # sliderInput("b2", "Boundary 2", min = 2, max = 1499, value = 700, step = 1),
      # colourInput("color3", "Color for Segment [b2, b3)", value = "yellow"),
      # sliderInput("b3", "Boundary 3", min = 3, max = 1499, value = 1200, step = 1),
      # colourInput("color4", "Color for Segment [b3, b4)", value = "orange"),
      # sliderInput("b4", "Boundary 4", min = 4, max = 1500, value = 1500, step = 1),
      # colourInput("color5", "Color for Segment [b4, 2000)", value = "red"),
      # 
      # Download button for saving plot as SVG
      downloadButton("downloadSVG", "Save Plot as SVG")
    ),
    mainPanel(
      plotOutput("contourPlot", width = "600px", height = "600px"),
      h4("Boundaries and Colors:"),
      tableOutput("boundariesTable")
    )
  )
)

###############################################
# 3) DEFINE THE SERVER #
###############################################
server <- function(input, output, session) {
  
  # Enforce strictly ordered boundaries
  observeEvent(input$b1, {
    updateSliderInput(session, "b2", min = input$b1 + 1, value = max(input$b2, input$b1 + 1))
  })
  
  observeEvent(input$b2, {
    updateSliderInput(session, "b3", min = input$b2 + 1, value = max(input$b3, input$b2 + 1))
    updateSliderInput(session, "b1", max = input$b2 - 1, value = min(input$b1, input$b2 - 1))
  })
  
  observeEvent(input$b3, {
    updateSliderInput(session, "b4", min = input$b3 + 1, value = max(input$b4, input$b3 + 1))
    updateSliderInput(session, "b2", max = input$b3 - 1, value = min(input$b2, input$b3 - 1))
  })
  
  observeEvent(input$b4, {
    updateSliderInput(session, "b3", max = input$b4 - 1, value = min(input$b3, input$b4 - 1))
  })
  
  # Reactive levels based on the boundaries
  levels <- reactive({
    c(0, input$b1, input$b2, input$b3, input$b4, 2000)
  })
  
  # Reactive colors based on user selection
  colors <- reactive({
    c(input$color1, input$color2, input$color3, input$color4, input$color5)
  })
  
  # Generate polygons for contours
  contour_polygons <- reactive({
    req(input$frameIndex)
    frameIndex <- input$frameIndex
    mat <- scices_list[[frameIndex]]
    
    mat <- mat[nrow(mat):1, ]
    mat <- cbind(rep(20, nrow(mat)), mat, rep(20, nrow(mat)))
    mat <- rbind(rep(20, ncol(mat)), mat, rep(20, ncol(mat)))
    
    raster <- rast(mat)
    contour_levels <- levels()
    contours <- as.contour(raster, levels = contour_levels)
    sf_contours <- st_as_sf(contours)
    
    sf_polygons <- sf_contours %>%
      group_by(level) %>%
      summarise(do_union = TRUE) %>%
      st_cast("POLYGON") %>%
      st_make_valid() %>%
      st_buffer(0)
    
    return(sf_polygons)
  })
  
  # Plot the contours
  output$contourPlot <- renderPlot({
    sf_polygons <- contour_polygons()
    contour_levels <- levels()
    segment_colors <- colors()
    
    plot(
      sf_polygons,
      col = segment_colors[findInterval(sf_polygons$level, contour_levels)],
      border = NA,
      main = paste("Frame:", input$frameIndex)
    )
  })
  
  # Download SVG
  output$downloadSVG <- downloadHandler(
    filename = function() {
      paste("contour_plot_frame_", input$frameIndex, ".svg", sep = "")
    },
    content = function(file) {
      svg(file)
      sf_polygons <- contour_polygons()
      contour_levels <- levels()
      segment_colors <- colors()
      
      plot(
        sf_polygons,
        col = segment_colors[findInterval(sf_polygons$level, contour_levels)],
        border = NA,
        # main = paste("Frame:", input$frameIndex)
      )
      dev.off()
    }
  )
  
  # Display boundaries and corresponding colors in a table
  output$boundariesTable <- renderTable({
    levels <- levels()
    colors <- colors()
    data.frame(
      Segment = c("[0, b1)", "[b1, b2)", "[b2, b3)", "[b3, b4)", "[b4, 2000)"),
      Boundary = paste0(
        "(", levels[-length(levels)], ", ", levels[-1], ")"
      ),
      Color = colors
    )
  }, striped = TRUE, hover = TRUE)
}

shinyApp(ui, server)