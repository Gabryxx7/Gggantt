#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
library(plotly)
library(htmlwidgets)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    output$distPlot <- renderPlotly({
        plot_ly(type = "scatter", mode = "markers") %>%
            layout(showlegend  = TRUE) %>% onRender(js, data = "TraceMapping") 

    })
    
    mainPlot <- reactiveValues(
        plot = plot_ly() %>%
           add_trace(
               x = c(20, 14, 23),
               y = c("giraffes", "orangutans", "monkeys"),
               name = "SF Zoo",
               type = "bar") %>%
           add_trace(
               x = c(20, 14, 23),
               y = c("giraffes", "orangutans", "monkeys"),
               name = "SF Zoo2",
               type = "bar") %>%
           layout(xaxis = list(fixedrange = TRUE), yaxis = list(fixedrange = TRUE)) %>%
           config(editable = TRUE))
    
    
    output$p <- renderPlotly({
        mainPlot$plot
    })
    
    
    output$bars <- renderUI({
        numBars <- length(mainPlot$plot$x$attrs)
        if(numBars > 1){
            lapply(2:numBars, function(i) {
                isolate({
                fluidRow(textInput("Whut", paste0(mainPlot$plot$x$attrs[[i]]$name)),
                         shiny::actionButton(paste0("removeBtn_",i), "Remove"))
                })
                         
            })
        }
    })
    
    observe({
        info(paste0("removed "))
        barsList <- lapply(2:isolate(length(mainPlot$plot$x$attrs)), function(i) {
            input[[paste0("removeBtn_",i)]]
        }) 
    })
    
    # I am trying to remember how this works. IIRC event_data would create a hook so that
    # Whenever that event happens rernderPrint() gets called
    output$click_info <- renderPrint({
        click <- event_data("plotly_click")
        # relayout <- event_data("plotly_relayout")
        # paste0("Relayout: ", paste(relayout, collapse=","), ", Click: ", paste(click, collapse=","))
        # paste0("Click: ", str(click), str(output$x$attrs[click$curveNumber+2]))
        isolate(paste0("Click: ", str(click), str(mainPlot$plot$x$attrs)))
        # isolate(
        # mainPlot$plot <- add_trace(mainPlot$plot,
        #     x = c(20, 14, 23),
        #     y = c("giraffes", "orangutans", "monkeys"),
        #     name = paste0("SF Zoo ",length(mainPlot$plot$x$attrs)+1),
        #     type = "bar")
        # )
        # p$x$attrs[click$curveNumber+2]
        # output$p %<%
            
    })
    
    output$hover_info <- renderPrint({
        hover <- event_data("plotly_hover")
        paste0("Hover: ", paste(hover, collapse=","), " - ", str(hover))
    })
    
    output$relayout_info <- renderPrint({
        relayout <- event_data("plotly_relayout")
        paste0("Relayout: ", paste(relayout, collapse=","), " - ", str(relayout))
    })
    
    
    output$drag_info <- renderPrint({
        drag <- event_data("plotly_selected")
        paste0("Drag: ", str(drag))
    })
    onevent("click", "p", function(x){
        info(x$offsetX)
        isolate(
            mainPlot$plot <- add_trace(mainPlot$plot,
                           x = c(20, 14, 23),
                           y = c("giraffes", "orangutans", "monkeys"),
                           name = paste0("SF Zoo ",length(mainPlot$plot$x$attrs)),
                           type = "bar")
        )
    });
    
    
    onevent("click", "distPlot", function(x){
        plotlyProxy("distPlot", session) %>%
        plotlyProxyInvoke("addTraces", list(x = rnorm(10),y = rnorm(10),
                                        type = "scatter",mode = "markers",
                                        name = input$TraceName))
    });
    
    # # NOT WORKING
    # onevent("mousedown","p", function(x){
    #     from <<- x$offsetX
    # });
    # 
    # onevent("mouseup","p", function(x){
    #     to <<- x$offsetX
    #     info(paste(from, ",", to))
    #     isolate(
    #         mainPlot$plot <- add_trace(mainPlot$plot,
    #                                    x = c(from, to),
    #                                    y = c("From", "To"),
    #                                    name = "SF Zoo",
    #                                    type = "bar")
    #     )
    # });
    

})



