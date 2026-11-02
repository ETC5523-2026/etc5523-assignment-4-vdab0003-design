library(shiny)
library(bslib)
library(ggplot2)
library(haiexplorer)

# Format big numbers with commas, e.g. 213525 -> "213,525"
comma <- function(x) format(round(x), big.mark = ",", scientific = FALSE)

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
    ),
    selectInput(
      "country",
      "Country",
      choices = c("Germany" = "Germany", "European average" = "Europe")
    ),
    input_switch("per_100k", "Show per 100,000 people", value = FALSE),
    checkboxGroupInput(
      "infections",
      "Infections to compare",
      choices  = sort(unique(hai_burden$infection)),
      selected = unique(hai_burden$infection)
    )
  ),
  card(
    plotOutput("rank_plot")
  ),
  card(
    tableOutput("rank_table")
  )
)

# Server: how outputs respond to inputs -----------------------------------
server <- function(input, output, session) {

  # One shared calculation: every output below uses ranked(), so the
  # chart and table can never disagree (Week 11: one source of truth)
  ranked <- reactive({
    rank_infections(
      hai_burden,
      measure    = input$measure,
      country    = input$country,
      scale      = if (input$per_100k) "Per 100,000 people" else "Total",
      infections = input$infections
    )
  })

  output$rank_plot <- renderPlot({
    ggplot(ranked(), aes(x = median, y = reorder(infection, median))) +
      geom_col() +
      # Error bars show the 95% uncertainty range around each estimate
      geom_errorbar(aes(xmin = lower, xmax = upper), width = 0.2) +
      scale_x_continuous(labels = comma) +
      labs(x = input$measure, y = NULL)
  })

  output$rank_table <- renderTable({
    data.frame(
      Rank                 = ranked()$rank,
      Infection            = ranked()$infection,
      Estimate             = comma(ranked()$median),
      `Uncertainty range`  = paste(comma(ranked()$lower), "to", comma(ranked()$upper)),
      `Share of total (%)` = sprintf("%.1f", ranked()$share),
      check.names = FALSE
    )
  })
}

shinyApp(ui, server)
