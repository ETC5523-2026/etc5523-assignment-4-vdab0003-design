library(shiny)
library(bslib)
library(ggplot2)
library(haiexplorer)

# Format big numbers with commas, e.g. 213525 -> "213,525"
comma <- function(x) format(round(x), big.mark = ",", scientific = FALSE)

# 1 -> "1st", 2 -> "2nd", 3 -> "3rd", 4 -> "4th"
ordinal <- function(n) {
  suffix <- if (n %% 100 %in% 11:13) "th" else
    c("th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th")[n %% 10 + 1]
  paste0(n, suffix)
}

# Plain-language names for each measure, used in titles and sentences
measure_label <- c(
  Cases  = "new cases per year",
  Deaths = "deaths per year",
  DALYs  = "healthy years lost (DALYs) per year"
)

# Colours: one highlight for the top infection, grey for the rest
highlight <- "#C8102E"
muted     <- "grey65"

# UI: what the user sees and can do -
ui <- page_sidebar(
  title = "Which hospital infections should we prioritise?",
  fillable = FALSE,
  theme = bs_theme(version = 5, primary = "#1F5F8B"),
  # Make validate() messages stand out in red and bold
  tags$style(HTML(".shiny-output-error-validation { color: #C8102E; font-weight: 600; font-size: 1.1rem; }")),

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

  # The answer at a glance
  layout_columns(
    value_box(
      title = "Highest burden",
      value = textOutput("vb_top"),
      showcase = icon("hospital"),
      theme = "primary"
    ),
    value_box(
      title = "Its share of the total",
      value = textOutput("vb_share"),
      showcase = icon("chart-pie"),
      theme = "primary"
    ),
    value_box(
      title = "Its rank by number of cases",
      value = textOutput("vb_case_rank"),
      showcase = icon("shuffle"),
      theme = "primary"
    )
  ),

  card(
    card_header(textOutput("plot_title")),
    p(strong(textOutput("headline", inline = TRUE))),
    plotOutput("rank_plot", height = "420px"),
    p(strong("How to read this chart:"), "each bar is the best estimate for",
      "one infection; longer bars mean a larger burden. The red bar is the",
      "largest, and the percentage under each name is its share of the total.",
      "The thin line across each bar is the 95% uncertainty range. Where",
      "the lines of two infections overlap, the data cannot show with",
      "confidence which is larger. Switch between Number of cases and",
      "Healthy years lost to see whether the priority order changes."),
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

# Server: how outputs respond to inputs -
server <- function(input, output, session) {

  # Turn the on/off switch into the scale name used in the data
  scale <- reactive({
    if (input$per_100k) "Per 100,000 people" else "Total"
  })

  # Is nothing ticked? Several outputs check this
  none_selected <- reactive(length(input$infections) == 0)

  # One shared calculation: every output below uses ranked(), so they
  # can never disagree (Week 11). validate() stops here with a clear
  # message if nothing is selected.
  ranked <- reactive({
    validate(need(
      !none_selected(),
      "No infections selected. Tick at least one infection in the sidebar to see the ranking."
    ))
    rank_infections(
      hai_burden,
      measure    = input$measure,
      country    = input$country,
      scale      = scale(),
      infections = input$infections
    )
  })

  # Where the top infection would sit if ranked by number of cases
  case_rank <- reactive({
    by_cases <- rank_infections(hai_burden, "Cases", input$country,
                                scale(), input$infections)
    by_cases$rank[by_cases$infection == ranked()$infection[1]]
  })

  # Value boxes: show a dash when nothing is selected, so the empty-state
  # message appears once (in the chart) rather than in every box
  output$vb_top <- renderText({
    if (none_selected()) return("-")
    ranked()$infection[1]
  })
  output$vb_share <- renderText({
    if (none_selected()) return("-")
    paste0(sprintf("%.1f", ranked()$share[1]), "%")
  })
  output$vb_case_rank <- renderText({
    if (none_selected()) return("-")
    paste(ordinal(case_rank()), "of", nrow(ranked()))
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
    if (none_selected()) return("")

    # Weak state: one infection cannot be ranked against anything
    if (nrow(ranked()) == 1) {
      return(paste("Only one infection is selected, so there is nothing to",
                   "rank it against. Tick at least two to compare."))
    }

    top <- ranked()[1, ]
    country_name <- if (input$country == "Europe") "the European average" else "Germany"
    finding <- paste0(
      "In ", country_name, ", ", top$infection, " ranks first by ",
      measure_label[[input$measure]], ", with ",
      sprintf("%.1f", top$share), "% of the total for the selected infections."
    )

    if (input$measure != "Cases") {
      finding <- paste0(finding, " Ranked by number of cases, it would be ",
                        ordinal(case_rank()), " of ", nrow(ranked()), ".")
    }
    finding
  })

  output$rank_plot <- renderPlot({
    plot_data <- ranked()
    plot_data$is_top <- plot_data$rank == 1
    # Name and share together on the axis, so error bars never cover the
    # share and meaning does not rely on colour alone
    plot_data$label <- paste0(plot_data$infection, "\n",
                              sprintf("%.1f", plot_data$share), "% of total")

    ggplot(plot_data, aes(x = median, y = reorder(label, median))) +
      geom_col(aes(fill = is_top), width = 0.7) +
      geom_errorbar(aes(xmin = lower, xmax = upper), width = 0.2,
                    colour = "grey20") +
      scale_fill_manual(values = c(`TRUE` = highlight, `FALSE` = muted),
                        guide = "none") +
      scale_x_continuous(labels = comma, expand = expansion(mult = c(0, 0.05))) +
      labs(x = measure_label[[input$measure]], y = NULL) +
      theme_minimal(base_size = 15) +
      theme(panel.grid.major.y = element_blank(),
            panel.grid.minor   = element_blank())
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
