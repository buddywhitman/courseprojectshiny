library(shiny)
library(datasets)
library(ggplot2)

data(mtcars)

shinyUI(fluidPage(
  titlePanel("mtcars MPG Predictor & Performance Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Input Vehicle Specifications"),
      p("Adjust the controls below to calculate predicted Miles Per Gallon (MPG) and filter the comparison dataset."),
      
      sliderInput("hp", 
                  "Gross Horsepower (hp):", 
                  min = min(mtcars$hp), 
                  max = max(mtcars$hp), 
                  value = 150, 
                  step = 5),
      
      sliderInput("wt", 
                  "Weight (1000 lbs):", 
                  min = round(min(mtcars$wt), 1), 
                  max = round(max(mtcars$wt), 1), 
                  value = 3.2, 
                  step = 0.1),
      
      radioButtons("cyl", 
                   "Number of Cylinders:", 
                   choices = c("4 Cylinders" = 4, "6 Cylinders" = 6, "8 Cylinders" = 8), 
                   selected = 6),
      
      radioButtons("am", 
                   "Transmission Type:", 
                   choices = c("Automatic" = 0, "Manual" = 1), 
                   selected = 0),
      
      checkboxInput("show_points", "Show Data Points on Plot", value = TRUE),
      checkboxInput("show_pred", "Show Prediction Point on Plot", value = TRUE),
      
      hr(),
      h4("Quick Guide"),
      tags$ul(
        tags$li("Use sliders & radio buttons to set vehicle specs."),
        tags$li("View predicted MPG dynamically calculated in the summary panel."),
        tags$li("Compare your prediction against historic 1974 Motor Trend data in the plot and dataset table.")
      )
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Prediction & Visualization",
                 br(),
                 fluidRow(
                   column(6, 
                          div(style = "background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 15px; border-radius: 5px;",
                              h4("Predicted Fuel Efficiency"),
                              h2(textOutput("mpg_pred"), style = "color: #007bff; font-weight: bold;"),
                              p(textOutput("pred_details"))
                          )
                   ),
                   column(6,
                          div(style = "background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 15px; border-radius: 5px;",
                              h4("Selected Configuration"),
                              htmlOutput("config_summary")
                          )
                   )
                 ),
                 br(),
                 plotOutput("mpg_plot"),
                 hr(),
                 h4("Matching Vehicles in `mtcars` Dataset"),
                 p("Vehicles with the selected cylinder count and transmission type:"),
                 tableOutput("filtered_table")
        ),
        
        tabPanel("Documentation",
                 br(),
                 h3("Application Documentation & User Guide"),
                 p("Welcome to the ", strong("mtcars MPG Predictor & Performance Explorer"), "! This application uses a multivariate linear regression model built on the 1974 Motor Trend ", code("mtcars"), " dataset to predict vehicle fuel efficiency (Miles Per Gallon)."),
                 
                 h4("1. How to Use the Application"),
                 tags$ol(
                   tags$li(strong("Set Horsepower:"), " Adjust the Gross Horsepower slider to set the engine output."),
                   tags$li(strong("Set Weight:"), " Adjust the Weight slider (in 1,000s of lbs)."),
                   tags$li(strong("Select Cylinders:"), " Pick 4, 6, or 8 cylinders using the radio buttons."),
                   tags$li(strong("Select Transmission:"), " Choose between Automatic or Manual transmission."),
                   tags$li(strong("Toggle Plot Display:"), " Check or uncheck boxes to customize the scatter plot visualization.")
                 ),
                 
                 h4("2. Underlying Model Details"),
                 p("The statistical model is fitted dynamically using R's ", code("lm()"), " function:"),
                 pre("lm(mpg ~ hp + wt + factor(cyl) + factor(am), data = mtcars)"),
                 p("The prediction recalculates in real-time as you adjust any widget input."),
                 
                 h4("3. Visual Exploration"),
                 p("The plot displays Horsepower vs. MPG, color-coded by cylinder count. A red star marks your custom vehicle prediction, allowing instant comparison with actual historical models.")
        )
      )
    )
  )
))
