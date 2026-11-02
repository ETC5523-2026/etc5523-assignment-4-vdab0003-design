library(shiny)
library(bslib)
library(ggplot2)
library(haiexplorer)

# UI: what the user sees and can do --------------------------------------
ui <- page_sidebar(
  title = "Which hospital infections should we prioritise?",
  sidebar = sidebar(
    radioButtons(
      "measure",
      "Rank infections by",
      choices = c(
        "Number of cases"            = "Cases",
        "Deaths"                     = "Deaths",
        "Healthy years lost (DALYs)" = "DALYs"
      ),
      selected = "DALYs"
    )
  ),
  card(
    plotOutput("rank_plot")
  )
)

# Server: how outputs respond to inputs -----------------------------------
server <- function(input, output, session) {
  output$rank_plot <- renderPlot({
    ranked <- rank_infections(hai_burden, measure = input$measure)

    ggplot(ranked, aes(x = median, y = reorder(infection, median))) +
      geom_col() +
      labs(x = input$measure, y = NULL)
  })
}

shinyApp(ui, server)
