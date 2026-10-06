library(shiny)
library(datasets)
library(ggplot2)

data(mtcars)

# Fit linear model for MPG prediction
fit <- lm(mpg ~ hp + wt + factor(cyl) + factor(am), data = mtcars)

shinyServer(function(input, output) {
  
  # Reactive expression to build data frame from inputs
  user_data <- reactive({
    data.frame(
      hp = as.numeric(input$hp),
      wt = as.numeric(input$wt),
      cyl = factor(as.numeric(input$cyl), levels = c(4, 6, 8)),
      am = factor(as.numeric(input$am), levels = c(0, 1))
    )
  })
  
  # Reactive calculation of predicted MPG
  predicted_mpg <- reactive({
    pred <- predict(fit, newdata = user_data())
    round(pred, 2)
  })
  
  # Output prediction text
  output$mpg_pred <- renderText({
    paste(predicted_mpg(), "MPG")
  })
  
  output$pred_details <- renderText({
    trans_str <- ifelse(input$am == 1, "Manual", "Automatic")
    paste0("Based on ", input$hp, " HP, ", input$wt, "k lbs, ", input$cyl, " Cylinders, ", trans_str, " Transmission.")
  })
  
  output$config_summary <- renderUI({
    trans_str <- ifelse(input$am == 1, "Manual", "Automatic")
    HTML(paste0(
      "<b>Horsepower:</b> ", input$hp, " hp<br/>",
      "<b>Weight:</b> ", input$wt, " (1000 lbs)<br/>",
      "<b>Cylinders:</b> ", input$cyl, "<br/>",
      "<b>Transmission:</b> ", trans_str
    ))
  })
  
  # Scatter plot of hp vs mpg with user prediction highlighted
  output$mpg_plot <- renderPlot({
    p <- ggplot(mtcars, aes(x = hp, y = mpg))
    
    if (input$show_points) {
      p <- p + geom_point(aes(color = factor(cyl)), size = 3, alpha = 0.8) +
        labs(color = "Cylinders")
    }
    
    if (input$show_pred) {
      pred_val <- predicted_mpg()
      p <- p + geom_point(aes(x = input$hp, y = pred_val), 
                          color = "red", shape = 8, size = 6, stroke = 2) +
        annotate("text", x = input$hp, y = pred_val + 1.5, 
                 label = paste0("Predicted: ", pred_val, " MPG"), 
                 color = "red", fontface = "bold", size = 4.5)
    }
    
    p + theme_minimal(base_size = 14) +
      labs(title = "Miles Per Gallon vs. Gross Horsepower",
           x = "Gross Horsepower (hp)",
           y = "Miles Per Gallon (mpg)",
           subtitle = "Red star represents current custom input prediction")
  })
  
  # Filtered table showing matching vehicles in mtcars
  output$filtered_table <- renderTable({
    sub_df <- mtcars[mtcars$cyl == input$cyl & mtcars$am == input$am, c("mpg", "hp", "wt", "cyl", "am", "gear")]
    sub_df$am <- ifelse(sub_df$am == 1, "Manual", "Automatic")
    sub_df
  }, rownames = TRUE)
  
})
