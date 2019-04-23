library(shiny)

header <- dashboardHeader(
  title = "Eyes on Airstrikes: The War on Terror in Somalia",
  titleWidth = 450
  
)

sidebar <- dashboardSidebar(
  
  sidebarMenu(id = "sidebarMenu",
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Data Table", tabName = "table", icon = icon("table")),
    menuItem("About & Sources", tabName = "sources", icon = icon("info-circle"))

  ),
  
  conditionalPanel(
    "input.sidebarMenu=='dashboard'",
    class = "shiny-input-container",
    
    tags$b("Explore Airstrikes"),
    shinyWidgets::actionGroupButtons(inputIds = c("prevBtn", "nextBtn"),
                                     labels = c("PREV", "NEXT"),
                                     direction = "horizontal", size = "normal"),

    br(),
    br(),
    tags$b("Airstrike Date"),
    verbatimTextOutput("eventdate"),
    br(),
    tags$b("Location"),
    textOutput("location"),
    br(),
    tags$b("Airstrike Carried Out By:"),
    textOutput(outputId="carried_by"),
    
    
    br(),
    tags$b("Airstrike Target"),
    textOutput(outputId="target"),
    
    
    br(),
    tags$b("Details"),
    textOutput(outputId="details"),
    
    br(),
    tags$b("Source"),
    
    br(),
    textOutput(outputId="source")
    
  )
  
)

body <- dashboardBody(
  useShinyjs(),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    includeHTML(("google-analytics.html"))
  ),
  
  tabItems(
    source("ui/dashboard-ui.R", local = TRUE)$value,
    
    tabItem(
      tabName = "table",
      fluidRow(box(width = 12, DT::dataTableOutput("strike_tbl")))
    ),
    
    tabItem(
      tabName = "sources",
      fluidRow(
        
        box(width = 12,
                   h4("Eyes on Airstrikes: The War on Terror in Somalia"),
                   br(),
                   tags$b("About:"),
                   p("This is a basic online interactive mapping tool and data explorer to help track and document 
                     the decade old - and still ongoing air raids against terror groups in Somalia. To learn more or contribute to this project, please email [mohamed at abdimalik dot com]. We look forward to hearing from you!"),
                   br(),
                   tags$b("Data Source:"),
                   br(),
                   br(),
                   p("This app uses data collected by the Armed Conflict Location & Event Data Project (ACLED) - 'a disaggregated conflict analysis and crisis mapping project'. You can read more about ACLED data collection methodologies and quality assuarance approaches", 
                          a("here.", href="https://www.acleddata.com/wp-content/uploads/2017/12/Methodology-Overview_FINAL.pdf"), "If you want to access the dataset used in the app, click on the data table tab above and press the download button, and there it is for your own use. 
                     Alternatively, you can access the full datasets, which is freely available at ACLED's data download page ", a("here.", href="https://www.acleddata.com/data/"))
        
               )
               
               )
    )
  )
  
)



ui <- dashboardPage(
  header,
  sidebar,
  body,
  skin = "black"
)