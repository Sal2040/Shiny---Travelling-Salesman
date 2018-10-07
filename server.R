library(shiny)
library(leaflet)
library(TSP)
library(geosphere)

shinyServer(function(input, output, session) {
   
  output$map <- renderLeaflet({
    leaflet() %>% addTiles() %>% setView(lat = 49.195267, lng = 16.608323, zoom = 5)
    })
  
  observe({
    
    leafletProxy("map") %>% addMarkers(lng = FinalData()$LNG, lat = FinalData()$LAT, 
                 label = paste("ID:", FinalData()$ID), labelOptions = labelOptions(noHide = TRUE))
  })
    
  observeEvent(input$go,{
    leafletProxy("map") %>% clearMarkers()
      
      leafletProxy("map") %>% addMarkers(lng = way()$LNG, 
                  lat = way()$LAT, label = (paste(paste("ID:", way()$ID), ",", paste("ORDER:", way()$ORDER))),
                  labelOptions = labelOptions(noHide = TRUE))
  })
  
  
  
  TestData <- data.frame("LNG" = numeric(), "LAT" = numeric())
  
  FinalData <- reactive({
    TestData <<- rbind(TestData, data.frame("LNG" = input$map_click$lng, "LAT" = input$map_click$lat))
    data.frame("ID" = seq_len(nrow(TestData)), TestData)
  })
  
    output$rows <- renderUI({
    if(nrow(FinalData())==0) {
      return(NULL)
    }
    else{
    len <- seq_len(nrow(FinalData()))
    radioButtons(inputId = "id", label = NULL, choices = len)}
    
                  })
  
    
    makematrix <- function(places) {
      
      x <- matrix(nrow = nrow(places), ncol = nrow(places), dimnames = list(places$ID, places$ID))
      
      for(i in 1:nrow(places)) {
        for(j in 1:nrow(places)) {
          x[i,j] <-  distGeo(places[i,c("LNG", "LAT")], places[j,c("LNG", "LAT")])/1000
        }
      }
      x
    }
    
   tour <- eventReactive(input$go, {
    set.seed(456)
    x <- makematrix(FinalData())
    y <- TSP(x)
    solve_TSP(y, method = input$method, start = as.integer(input$id))
    
  })
   
  way <- eventReactive(input$go,{data.frame("ORDER" = seq_len(nrow(FinalData())), FinalData()[as.integer(tour()),])})
  

 observeEvent(input$reset, {session$reload()}) 
 
  output$table <- renderTable(FinalData(), colnames = TRUE)
  output$way <- renderTable(way(), colnames = TRUE)
  output$length <- renderText(paste(round(tour_length(tour()), digits = 2), " km"))
  
})
