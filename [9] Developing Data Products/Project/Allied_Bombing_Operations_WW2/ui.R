library(shiny)
library(plotly)

shinyUI(fluidPage(

    titlePanel("Allied Bombing Operations in WWII"),
    
    tabsetPanel(type = "tabs",
                tabPanel("Help", 
                         br(),
                         h3("This app visualizes the geographic and 
                            chronological distribution of bombing runs performed 
                            by the Allies against each country involved in 
                            World War II."),
                         br(),
                         h4("Directions:"),
                         p("The app is controlled mostly through the 2-sided 
                           \"Date Range\" slider below. When it is set, the map 
                           displays the geographical distribution of bombing 
                           runs that were performed by the Allies between the 
                           two selected dates.  The results are color-coded 
                           according to the number of raids that were recorded 
                           in that window, with redder colors indicating higher
                           activity."),
                         p("You can set a standardized date range by using the 
                           \"Exact Date Ranges\" buttons, which set the upper 
                           limit of your date range window to exactly one 
                           week/month (30 days)/year above the manually-selected 
                           lower limit."),
                         p("Once a desired window has been set, you can press 
                           the play button to the lower right of the date range 
                           slider to begin animating the map.  In this mode,
                           your selected date range is looped across the entire
                           history of the war day-by-day, with the map 
                           reflecting the distribution of allied bombing runs 
                           that are captured within that moving window.  For 
                           example, if you've set a one-week date range, then 
                           pressing play will show you a rolling, 1-week window
                           into allied bombing activity over the entire history 
                           of the war."),
                         p("If you are interested in only one particular theater 
                           of the war, you can select it with the buttons in the 
                           \"Theater\" section.  This will crop the map to 
                           display only the selected theater, allowing you to 
                           observe bombing activity on a more localized 
                           scale."),
                         p("When you're ready to get started, navigate to the 
                           \"Interactive Map\" tab to watch the war unfold!"),
                         p("Note: once a theater has been selected, the map must 
                           be re-rendered by hitting play or otherwise 
                           manipulating the date range before it will crop to 
                           the selected theater."),
                         br(),
                         h4("Data:"),
                         p("The data for this project come from the Theater 
                           History of Operations database, available on 
                           data.world at the following link:"),
                         a(href="https://data.world/datamil/world-war-ii-thor-data",
                           "https://data.world/datamil/world-war-ii-thor-data"),
                         br(),
                         br(),
                         p("Theater History of Operations (THOR), is a 
                           painstakingly cultivated database of historic aerial 
                           bombings from World War I through Vietnam. The value 
                           of THOR is immense, and has already proven useful in 
                           finding unexploded ordinance in Southeast Asia and 
                           improving Air Force combat tactics. This dataset 
                           combines digitized paper mission reports from WWII. 
                           It can be searched by date, conflict, geographic 
                           location and more than 60 other data elements to form 
                           a live-action sequence of the air war from 1939 to 
                           1945. The records include U.S. and Royal Air Force 
                           data, as well as some Australian, New Zealand and 
                           South African air force missions.")),
                tabPanel("Interactive Map", 
                         plotlyOutput("raidMap", height = "650px"))),
    
    hr(),
    fluidRow(
        column(1),
        column(4,
               h3("Date Range"),
               sliderInput("date",
                           "(Press the Play Button!)",
                           min = as.Date("9/1/1939", format = "%m/%d/%Y"),
                           max = as.Date("9/2/1945", format = "%m/%d/%Y"),
                           value = c(as.Date("9/1/1939", format = "%m/%d/%Y"),
                                     as.Date("9/2/1945", format = "%m/%d/%Y")),
                           timeFormat = "%m/%d/%Y",
                           animate = animationOptions(
                               interval = 100),
                           width = "100%")),
        column(1),
        column(3,
               h3("Exact Date Ranges"),
               actionButton("oneWeek", "One Week"),
               actionButton("oneMonth", "One Month"),
               actionButton("oneYear", "One Year")),
        column(3,
               h3("Theaters"),
               actionButton("WLD", "World"),
               actionButton("EUR", "Europe"),
               actionButton("ASI", "Pacific"),
               actionButton("AFR", "North Africa"))
    ),
    
    hr(),
    h3("Author:"),
    p("Eric Erkela"),
    p("github.com/eerkela"),
    p("11/26/2020")
))
