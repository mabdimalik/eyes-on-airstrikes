
# initialize leaflet map
vanila_map <-  leaflet(options = leafletOptions(minZoom = 5)) %>%
  addProviderTiles(providers$CartoDB)  %>% 
  setView(lng = 46.746826, lat = 5.211306, zoom = 5) %>%
  setMaxBounds(lng1 = 40.18798828, lat1 = -2.064982496,
               lng2 = 53.305664, lat2 =12.40438895)


server <- function(input, output){
  
  
  raids <- reactive({
    air_raids %>% filter(event_date >= 
            lubridate::as_date(input$dates[1]), 
            event_date <= lubridate::as_date(input$dates[2])) %>% 
            arrange(event_date)
  })
  
  source("server/dash-server.R", local = TRUE)
  
  
  ### table tab
  output$strike_tbl <- DT::renderDataTable({
    out <- air_raids %>% dplyr::select(-event, -notes, -latitude, -longitude, -civilian_casualties)
    datatable(
      out,
      rownames = FALSE,
      colnames = show_names(names(out)),
      extensions = "Buttons",
      filter = 'top',
      options = list(
        dom = 'Bfrtip',
        scrollX = TRUE,
        buttons = list(
          'colvis', 
          list(
            extend = 'collection',
            buttons = c('csv', 'excel', 'pdf'),
            text = 'Download'
          )
        )
      )
    )
  }, server = FALSE)
  

  
  
    
}