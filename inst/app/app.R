library(shiny)
library(bslib)
library(ggplot2)
library(haiexplorer)

# Format big numbers with commas, e.g. 213525 -> "213,525"
comma <- function(x) format(round(x), big.mark = ",", scientific = FALSE)

# Plain-language names for each measure, used in titles and sentences
measure_label <- c(
  Cases  = "new cases per year",
  Deaths = "deaths per year",
  DALYs  = "healthy years lost (DALYs) per year"
)

# UI: what the user sees and can do --------------------------------------
ui <- page_sidebar(
  title = "Which hospital infections should we prioritise?",
  fillable = FALSE,

  sidebar = sidebar(
    width = 320,

    radioButtons(
      "measure", "Rank infections by",
      choices = c(
        "Number of cases"            = "Cases",
        "Deaths"                     = "Deaths",
        "Healthy years lost (DALYs)" = "DALYs"
      ),
      selected = "DALYs"
    ),
    helpText("Cases show how often an infection occurs. DALYs show how much",
             "harm it causes. Compare the two to see if the order changes."),

    selectInput(
      "country", "Country",
      choices = c("Germany" = "Germany", "European average" = "Europe")
    ),
    helpText("Germany is based on 46 hospitals; the European average on",
             "hospitals across the EU and EEA, 2011-12."),

    input_switch("per_100k", "Show per 100,000 people", value = FALSE),
    helpText("Turn on to compare Germany and Europe fairly. Totals depend",
             "on population size."),

    checkboxGroupInput(
      "infections", "Infections to compare",
      choices  = sort(unique(hai_burden$infection)),
      selected = unique(hai_burden$infection)
    ),
    helpText("Untick infections to focus on those your hospital can act on.",
             "Shares are recalculated for the infections selected."),

    accordion(
      open = FALSE,
      accordion_panel(
        "Key terms",
        p(strong("Hospital-acquired infection (HAI):"), "an infection a",
          "patient develops during a hospital stay that was not present",
          "on admission."),
        p(strong("Cases:"), "estimated new infections per year."),
        p(strong("Deaths:"), "estimated deaths caused by the infection",
          "per year."),
        p(strong("DALY (disability-adjusted life year):"), "one year of",
          "healthy life lost, counting both early death and time lived in",
          "poor health. It allows infections to be compared by harm rather",
          "than by frequency."),
        p(strong("Per 100,000 people:"), "the figure divided by the",
          "population and multiplied by 100,000, so countries of different",
          "sizes can be compared."),
        p(strong("Uncertainty range:"), "the range within which the true",
          "value lies with 95% probability, based on 1,000 simulations."),
        p(strong("Infections:"),
          "Pneumonia (lung infection, often linked to ventilators);",
          "Surgical site (infection of a surgical wound);",
          "Bloodstream (infection of the blood, often from catheters);",
          "Urinary tract (often linked to urinary catheters);",
          "C. difficile (bacterial gut infection, often after antibiotics).")
      )
    )
  ),

  # Problem statement: who the app is for and what it helps them decide
  card(
    card_header("Who this tool is for"),
    p(strong("User:"), "infection-prevention managers deciding where to",
      "focus a limited prevention budget."),
    p(strong("Question:"), "which hospital-acquired infections cause the",
      "most harm, and does the priority order change depending on how",
      "harm is measured?"),
    p(strong("Why it matters:"), "the most common infection is not always",
      "the most harmful. Ranking by case numbers alone can direct",
      "resources away from infections that cause more deaths and more",
      "lost years of healthy life.")
  ),

  card(
    card_header(textOutput("plot_title")),
    p(strong(textOutput("headline", inline = TRUE))),
    plotOutput("rank_plot"),
    p(strong("How to read this chart:"), "each bar is the best estimate for",
      "one infection; longer bars mean a larger burden. The thin line",
      "across each bar is the 95% uncertainty range. Where the lines of",
      "two infections overlap, the data cannot show with confidence which",
      "is larger. Switch between Number of cases and Healthy years lost to",
      "see whether the priority order changes."),
    card_footer(
      "Source: Zacher et al. (2019), Eurosurveillance 24(46), via the BHAI",
      "R package; ECDC point prevalence survey 2011-12.",
      strong("Limitation:"), "estimates are scaled up from a one-day survey",
      "and rely on limited evidence about infection outcomes, so deaths",
      "and DALYs have wide uncertainty ranges."
    )
  ),

  card(
    card_header("Exact figures for the selected infections"),
    tableOutput("rank_table")
  )
)

# Server: how outputs respond to inputs -----------------------------------
server <- function(input, output, session) {

  # Turn the on/off switch into the scale name used in the data
  scale <- reactive({
    if (input$per_100k) "Per 100,000 people" else "Total"
  })

  # One shared calculation: every output below uses ranked(), so the
  # chart, headline and table can never disagree (Week 11)
  ranked <- reactive({
    rank_infections(
      hai_burden,
      measure    = input$measure,
      country    = input$country,
      scale      = scale(),
      infections = input$infections
    )
  })

  # Chart title reflects the current selection (Week 9)
  output$plot_title <- renderText({
    country_name <- if (input$country == "Europe") "European average" else "Germany"
    per <- if (input$per_100k) ", per 100,000 people" else ""
    paste0("Ranked by ", measure_label[[input$measure]], per,
           ": ", country_name, ", 2011-12")
  })

  # Headline: states the finding and links it back to the question
  output$headline <- renderText({
    top <- ranked()[1, ]
    country_name <- if (input$country == "Europe") "the European average" else "Germany"
    finding <- paste0(
      "In ", country_name, ", ", top$infection, " ranks first by ",
      measure_label[[input$measure]], ", with ",
      sprintf("%.1f", top$share), "% of the total for the selected infections."
    )

    # Compare with the case-count ranking to show whether priorities change
    if (input$measure != "Cases" && nrow(ranked()) >= 2) {
      by_cases <- rank_infections(hai_burden, "Cases", input$country,
                                  scale(), input$infections)
      case_rank <- by_cases$rank[by_cases$infection == top$infection]
      finding <- paste0(finding, " Ranked by number of cases, it would be ",
                        case_rank, " of ", nrow(by_cases), ".")
    }
    finding
  })

  output$rank_plot <- renderPlot({
    ggplot(ranked(), aes(x = median, y = reorder(infection, median))) +
      geom_col() +
      geom_errorbar(aes(xmin = lower, xmax = upper), width = 0.2) +
      scale_x_continuous(labels = comma) +
      labs(x = measure_label[[input$measure]], y = NULL)
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
