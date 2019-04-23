
# Preparing the main session data based on inputs and filters.

data_filters <- reactive({
  req(input$select_state,
      input$select_target)
  
  dfilters <- raids() %>% 
    filter(state %in% input$select_state, 
           target %in% input$select_target)
  
  req(nrow(dfilters) > 0)

  dfilters
})

#--- reactive values for the trendchart 

trendchart_data <- reactive({
  t_data <- group_by(data_filters(), abbr_name, year) %>%
    summarise(n=n())
  t_data
})

#--- reactive values for state fatalities chart
statefatalities_data <- reactive({
  entities_data <- filter(data_filters(), !(state %in% c("Somaliland", "Banadir")), fatalities > 0) %>% group_by(state) %>% 
    summarise(total=sum(fatalities))  
  entities_data
})



#---- OUTPUTS SECTION

output$total_fatalities <- renderValueBox({
  out <- data_filters()
  valueBox(
    value = sum(out$fatalities),
    subtitle = "Total number of reported deaths",
    icon = icon("crosshairs")
  )
})

output$num_raids <- renderValueBox({
  out <- data_filters()
  valueBox(
    value = nrow(out),
    subtitle = "Number of reported airstrikes",
    icon = icon("fighter-jet")
  )
})

output$unique_locations <- renderValueBox({
  out <- data_filters()
  valueBox(
    #value = lubridate::year(max(out$event_date)) - lubridate::year(min(out$event_date)),
    value = length(unique(out$location)),
    subtitle = "Number of unique locations hit",
    icon = icon("map-marker-alt")
  )
})

#--- MAP OUTPUT

output$map <- renderLeaflet({
  out <- data_filters()
  vanila_map %>% 
    addCircleMarkers(data = out, lng = ~ longitude, lat = ~ latitude, opacity = 0.6, color = "red", fillOpacity = 0.2, radius = ~ 4, layerId = row.names(out))
})


output$trendchart <- renderPlot({
  out <- trendchart_data()
  out %>%   ggplot(aes(x=factor(year), y = n, fill=abbr_name)) + 
    geom_bar(stat = "identity") + scale_fill_manual(values = db_colors) +
    scale_x_discrete(breaks = c(2006, 2008, 2011, 2013, 2015, 2017, 2019)) +
    scale_y_continuous(breaks = function(n) unique(floor(pretty(seq(1, (max(n) + 1) * 1.1))))) +
    ggtitle("Number of Air Raids by Actor") + 
    theme_minimal() + theme(
      plot.title = element_text(hjust = 0.5),
      legend.position = "top",
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_blank(),
      legend.title=element_blank(),
      legend.spacing.x = unit(0.05, 'cm'),
      text =  element_text(size = 13)) + 
    #guides(fill = guide_legend(label.position = "left", nrow = 2)) +
    labs(caption = "Note: No airstrikes reported in 2010. Source: ACLED")

})

output$statefatalitieschart <- renderPlot({
  out <- statefatalities_data()
  out %>% ggplot(aes(x= reorder(state, total), y = total)) +
          geom_col(fill = "#FF5C5C", width = 0.70) + coord_flip() + theme_minimal() + 
          ggtitle(paste("Fatalities by region, ", min(data_filters()$year), "-", max(data_filters()$year)-2000)) + 
          geom_text(aes(label = total), family = "Open Sans", fontface = "bold", size = 3.5, hjust= -0.2, color = "grey30") + 
          scale_y_continuous(expand = c(0, 0),
                             limits = c(0, max(out$total) * 1.25)) +
          theme(plot.title = element_text(size = 13, face="bold", color = "gray10"),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                axis.title = element_blank(), 
                axis.text.x = element_blank(), 
                text =  element_text(size = 15),
                axis.text.y = element_text(size = 12, color = "gray10")) + 
         labs(caption = "Note: Excludes fatalities for 3 airstrikes in Banadir & SL. \n Source: ACLED Data")

})

output$strike_pie <- renderPlot({
  pie_data %>% ggplot(aes(x= reorder(state, n), y = n)) +
    geom_col(fill = "#FF5C5C", width = 0.80) + coord_flip() + theme_minimal() + 
    ggtitle("Number of airstrikes per state") + 
    geom_text(aes(label = paste0(round(value*100), "%")), family = "Open Sans", fontface = "bold", size = 3.5, hjust= -0.2, color = "grey30") + 
    scale_y_continuous(expand = c(0, 0), breaks = c(50, 100, 150, 250),
                       limits = c(0, max(pie_data$n) * 1.25)) +
    theme(plot.title = element_text(size = 13, face="bold", color = "gray10"),
          panel.grid.major.y = element_blank(),
          panel.grid.minor = element_blank(),
          axis.title = element_blank(), 
          axis.text.x = element_text(size = 12, color = "gray10"), 
          text =  element_text(size = 15),
          axis.text.y = element_text(size = 12, color = "gray10")) + 
    labs(caption = "Excludes airstrikes in Banadir & SL. Source: ACLED")  

})



#--------------- Navigation Sidebar

indexer <- reactiveValues(iValue = 1)



observeEvent(data_filters(), {
  indexer$iValue <- 1
})

observeEvent(input$map_marker_click,{
  clicked_marker <- input$map_marker_click
  indexer$iValue <- as.integer(clicked_marker$id)
})

observeEvent(input$nextBtn, {
  
  if(indexer$iValue < nrow(data_filters())){
    indexer$iValue <- indexer$iValue + 1
  } else{
    indexer$iValue <-  1
  }
  
  content <- paste("Location: ", 
                   data_filters()[indexer$iValue,]$location, ",", data_filters()[indexer$iValue,]$district, "<br/>",
                   "Fatalities: ", data_filters()[indexer$iValue,]$fatalities)
  
  leafletProxy("map") %>%
    clearPopups() %>%
    addPopups(lng = data_filters()[indexer$iValue,]$longitude, 
              lat = data_filters()[indexer$iValue,]$latitude, content)
})

observeEvent(input$prevBtn,  {
  if(indexer$iValue == 1){
    indexer$iValue <- nrow(data_filters())
  } else{
    indexer$iValue <- indexer$iValue - 1
  }
  
  content <- paste("Location: ", 
                   data_filters()[indexer$iValue,]$location, ",", data_filters()[indexer$iValue,]$district, "<br/>",
                   "Fatalities: ", data_filters()[indexer$iValue,]$fatalities)
  
  leafletProxy("map") %>%
    clearPopups() %>% 
    addPopups(lng = data_filters()[indexer$iValue,]$longitude, 
              lat = data_filters()[indexer$iValue,]$latitude, content)
  
})

output$eventdate <- renderText({
  out <- data_filters()
  #paste0(as.character(out[indexer$indexValue,]$event_date))
  paste0(strftime(out[indexer$iValue,]$event_date, format="%B %d, %Y"))
})

output$location <- renderText({
  paste0(data_filters()[indexer$iValue,]$location, ", ", data_filters()[indexer$iValue,]$region)
})

output$carried_by <- renderText({
  data_filters()[indexer$iValue,]$strike_by
})


output$target <- renderText({
  data_filters()[indexer$iValue,]$target
})

output$details <- renderText({
  data_filters()[indexer$iValue,]$notes
})

output$source <- renderText({
  data_filters()[indexer$iValue,]$source
})





#---------------- TODO - how to reset all inputs
observeEvent(input$reset, {
  all_filters <- c("dates", "select_state", "select_target")
  for(f in all_filters){
    reset(f)
  }
  
  
})








