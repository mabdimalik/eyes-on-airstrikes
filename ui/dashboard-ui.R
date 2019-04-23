tabItem(
  "dashboard",
  fluidRow(
    column(
      width = 9,
      fluidRow(
        valueBoxOutput("total_fatalities"),
        valueBoxOutput("num_raids"),
        valueBoxOutput("unique_locations")
      ),
      fluidRow(
        box(
          width = 12,
          leafletOutput(
            "map",
            height = 380
            )
        ),
        box(
          width = 12,
          plotOutput(
            "trendchart",
            height = 310
            )
        )
      )
    ),
    box(
      width = 3,
      title = "Filter Airstrikes",
      dateRangeInput(
        inputId="dates", 
        label = "Select by dates", 
        start="2006-12-23", end = max(air_raids$event_date), 
        min = "2006-12-23", max = max(air_raids$event_date), startview = "year"
        ), 
  
      shinyWidgets::pickerInput(
        inputId = "select_target", 
        label = "By Target Organization", 
        choices = target_choices, 
        options = list(`actions-box` = TRUE), 
        multiple = TRUE,
        selected = target_choices
      ),
      
      selectizeInput(
        inputId = "select_state", 
        label = "By Regional States", 
        choices = state_choices, 
        options = list(`actions-box` = TRUE), 
        multiple = TRUE,
        selected = state_choices
      ),
      
      shinyWidgets::actionBttn(
        inputId = "reset",
        label = "Reset",
        icon = icon("refresh"),
        size = "sm",
        color = "primary",
        style = "material-flat"
      )
    ),
    
   # --
   box(
     width = 3,
     plotOutput("statefatalitieschart", height = 230)
   ),
   
   box(
     width = 3,
     plotOutput("strike_pie", height = 217)
   )
   
  )
)

