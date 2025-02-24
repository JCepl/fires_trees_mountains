# Install and load plotly
# if (!require("plotly")) install.packages("plotly", dependencies = TRUE)
library(plotly)

# Define log coordinates
log1 <- list(x = c(0.4, 0.53), y = c(0.5, 0.5), z = c(0, 0.1))      
log2 <- list(x = c(0.43, 0.5), y = c(0.57, 0.5), z = c(0, 0.1))     
log3 <- list(x = c(0.5, 0.5), y = c(0.4, 0.53), z = c(0, 0.1))       
log4 <- list(x = c(0.43, 0.5), y = c(0.43, 0.5), z = c(0, 0.1))    
log5 <- list(x = c(0.6, 0.47), y = c(0.5, 0.5), z = c(0, 0.1))      
log6 <- list(x = c(0.57, 0.5), y = c(0.43, 0.5), z = c(0, 0.1))    
log7 <- list(x = c(0.5, 0.5), y = c(0.57, 0.47), z = c(0, 0.1))     
log8 <- list(x = c(0.57, 0.5), y = c(0.57, 0.5), z = c(0, 0.1))     

# Create a 3D plot
fig <- plot_ly()

# Add logs to the plot
fig <- fig %>%
  add_trace(x = log1$x, y = log1$y, z = log1$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 1") %>%
  add_trace(x = log2$x, y = log2$y, z = log2$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 2") %>%
  add_trace(x = log3$x, y = log3$y, z = log3$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 3") %>%
  add_trace(x = log4$x, y = log4$y, z = log4$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 4") %>%
  add_trace(x = log5$x, y = log5$y, z = log5$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 5") %>%
  add_trace(x = log6$x, y = log6$y, z = log6$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 6") %>%
  add_trace(x = log7$x, y = log7$y, z = log7$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 7") %>%
  add_trace(x = log8$x, y = log8$y, z = log8$z, 
            type = "scatter3d", mode = "lines", line = list(color = "brown", width = 8),
            name = "Log 8")

# Customize layout
fig <- fig %>%
  layout(scene = list(
    xaxis = list(title = "X-axis"),
    yaxis = list(title = "Y-axis"),
    zaxis = list(title = "Z-axis"),
    aspectmode = "cube"
  ))

# Show the plot
fig