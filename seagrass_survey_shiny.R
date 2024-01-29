library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)

# Sample data (replace this with your actual data)
zmDensity <- read.csv("output/seagrass_density_survey.csv")
# Define UI
ui <- fluidPage(
  titlePanel("Yearly Continuous View"),
  
  sidebarLayout(
    sidebarPanel(
      # Add input controls for year and yVar
      sliderInput("year_input", "Select year", min = min(year(zmDensity$date)),
                   max = max(year(zmDensity$date)), value = 2023, step = 1,
                  timeFormat = "%Y"),
      selectInput("yVar_input", "Select Y variable", 
                  choices = colnames(zmDensity)[-c(1,2)], selected = "value"),
      selectInput("facetVar_input", "Select facet variable",
                  choices = colnames(zmDensity)[-c(1,2)], selected = "value")
    ),
    
    mainPanel(
      # Display the continuous view plot
      plotOutput("continuous_plot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Create a reactive function for plotting
  output$continuous_plot <- renderPlot({
    zmDensity %>%
      filter(year(date) == input$year_input) %>%
      ggplot(aes_string(x = input$year_input, y = input$yVar_input)) +
      geom_boxplot(outlier.colour = "red") +
      facet_grid(. ~ get(input$facetVar_input)) +
      labs(title = as.character(input$year_input)) +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
}


# 
# server <- function(input, output) {
#   
#   # Create a reactive function for plotting
#   output$continuous_plot <- renderPlot({
#     zmDensity %>%
#       filter(year(date) == input$year_input) %>%
#       ggplot(aes_string(x = input$year_input, y = input$yVar_input)) +
#       geom_boxplot(outlier.colour = "red") +
#       #facet_grid(~ month(date)) +
#       labs(title = as.character(input$year_input)) +
#       theme_classic() +
#       theme(axis.text.x = element_text(angle = 45, hjust = 1))
#   })
# }

# Run the Shiny app
shinyApp(ui, server)
