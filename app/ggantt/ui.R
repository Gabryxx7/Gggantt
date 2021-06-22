#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(shinyjs)
library(shinyWidgets)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    useShinyjs(),

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            fluidRow(
                column(7, radioGroupButtons("plotStyle", choices=c("ggplotly", "plotly"), selected="plotly", direction = "horizontal")),
                column(5, actionBttn("updateButton", "Update Graph",icon = shiny::icon("sync"),color="primary", style="simple", size="sm"), style="text-align: right;")),
            uiOutput("bars"),
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30),
            verbatimTextOutput("click_info"),
            verbatimTextOutput("hover_info"),
            verbatimTextOutput("drag_info"),
            verbatimTextOutput("relayout_info")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotlyOutput("distPlot"),
            # plotlyOutput("distPlot", click = "plot_click"),
            plotlyOutput("p")
        )
    )
))
