library(shiny)
library(leaflet)
library(TSP)
library(geosphere)

shinyUI(fluidPage(
      titlePanel("Travelling Salesman Problem"),
      h3("Choose places to go by clicking on the map:"),          
      leafletOutput("map", height = 600),
      
      hr(),
       
      fluidRow(column (2, h4 ("Places to travel:"), tableOutput("table")),
               column (3, h4 ("Select a Point of Departure:"), uiOutput("rows")),
                column(3, h4 ("Select Algorithm:"),
                       selectInput(inputId = "method", label = NULL, 
                                   choices = c("Nearest Neighbors" = "nn",
                                              "Repetitive Nearest Neighbors" = "repetitive_nn",
                                              "Two edge exchange improvement procedure" = "two_opt"),
                                   selected = "nn"),
                       fluidRow(column(7, actionButton("go", "Show the Way!")), column(2,actionButton("reset", "Reset"))),
                       h5("Length:"),
                       textOutput("length"),
                       hr()
                       ),
                column(3, h4 ("Route:"), tableOutput("way"))
      
      ))
    )
