library(shiny)
library(dplyr)
library(tidyr)
library(plotly)
library(zoo)

lonaxis <- list(range = list(-180, 180))
lataxis <- list(range = list(-90, 90))

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    thor_data <- read.csv("THOR_WWII_DATA_CLEAN.csv")
    thor_data$MSNDATE <- as.Date(thor_data$MSNDATE, format = "%m/%d/%Y")
    country_names <- c("ALBANIA", "ALEUTIAN ISLANDS", "ALGERIA", 
                       "ANDAMAN ISLANDS", "AUSTRALIA", "AUSTRIA", "BALI", 
                       "BELGIUM", "BISMARK ARCHIPELAGO", "BORNEO", 
                       "BOUGAINVILLE", "BULGARIA", "BURMA", "CAROLINE ISLANDS",
                       "CELEBES ISLANDS", "CHINA", "CHINA MINING", 
                       "CORAL SEA AREA", "CORSICA", "CRETE", "CYPRUS", 
                       "CZECHOSLOVAKIA", "DENMARK", "EGYPT", "ERITREA",
                       "ETHIOPIA", "ETHIOPIA/ABSINNYA", "FORMOSA",
                       "FORMOSA AND RYUKYU ISLANDS", "FRANCE", 
                       "FRENCH INDO CHINA", "FRENCH INDO CHINA MINING", 
                       "FRENCH WEST AFRICA", "GERMANY", "GILBERT ISLANDS", 
                       "GREAT BRITAIN", "GREECE", "HOLLAND OR NETHERLANDS", 
                       "HUNGARY", "INDIA", "INDIAN OCEAN", "INDONESIA", "IRAQ", 
                       "ITALY", "JAPAN", "JAPAN MINING", "JAVA", 
                       "KOREA OR CHOSEN", "KOREA OR CHOSEN MINING", 
                       "KURILE ISLANDS", "LEBANON", "LIBYA", "LUXEMBOURG",
                       "MADAGASCAR", "MALAY STATES", "MALAY STATES MINING",
                       "MANCHURIA", "MARCUS ISLANDS", "MARIANAS ISLANDS",
                       "MARSHALL ISLANDS", "MOROCCO", "NETHERLANDS EAST INDIES",
                       "NEW GUINEA", "NEW IRELAND", "NORWAY", "PALAU ISLANDS",
                       "PANTELLARIA", "PHILIPPINE ISLANDS", "POLAND", "ROMANIA",
                       "SARDINIA", "SICILY", "SOLOMON ISLANDS", "SOMALIA", 
                       "SUDAN", "SUMATRA", "SUMATRA MINING", "SWITZERLAND", 
                       "SYRIA", "THAILAND OR SIAM", "THAILAND OR SIAM MINING", 
                       "TIMOR", "TUNISIA", "TURKEY", 
                       "VOLCANO AND BONIN ISLANDS", "WAKE ISLAND", "YUGOSLAVIA")
    country_codes <- c("AFG", "USA", "DZA", "IND", "AUS", "AUT", "IDN", "BEL",
                       "PNG", "IDN", "PNG", "BGR", "MMR", "FSM", "IDN", "CHN",
                       "CHN", "AUS", "FRA", "GRC", "CYP", "CZE", "DNK", "EGY",
                       "ERI", "ETH", "ETH", "TWN", "TWN", "FRA", "VNM", "VNM",
                       "CIV", "DEU", "FSM", "GBR", "GRC", "NLD", "HUN", "IND",
                       "IOT", "IDN", "IRQ", "ITA", "JPN", "JPN", "IDN", "KOR",
                       "KOR", "RUS", "LBN", "LBY", "LUX", "MDG", "MYS", "MYS",
                       "CHN", "JPN", "GUM", "MHL", "MAR", "IDN", "PNG", "PNG",
                       "NOR", "PLW", "ITA", "PHL", "POL", "ROU", "ITA", "ITA",
                       "SLB", "SOM", "SDN", "IDN", "IDN", "CHE", "SYR", "THA",
                       "THA", "TLS", "TUN", "TUR", "JPN", "USA", "SRB")
    country_conv <- data.frame(name = country_names,
                               code = country_codes)
    thor_data$TGT_COUNTRY_CODE <- as.factor(
        unlist(
            sapply(thor_data$TGT_COUNTRY, function(i) {
                if (i %in% country_conv$name) {
                    country_conv[country_conv$name == i, 2]
                } else {
                    NA
                }
            })
        )
    )
    
    output$raidMap <- renderPlotly({
        raids_by_target <- thor_data %>%
            filter(MSNDATE >= input$date[1] & MSNDATE <= input$date[2]) %>%
            mutate(INDEX = 1) %>%
            group_by(TGT_COUNTRY_CODE) %>%
            summarize(NUM_RAIDS = sum(INDEX),
                      ORDNANCE = sum(TOTAL_TONS, na.rm = TRUE),
                      .groups = "drop") %>%
            mutate(TEXT = paste0("Total Raids: <br>", NUM_RAIDS))
        
        plot_ly(raids_by_target, 
                type = "choropleth", 
                locations = raids_by_target$TGT_COUNTRY_CODE,
                z = raids_by_target$NUM_RAIDS,
                text = raids_by_target$TEXT,
                colorscale = "reds",
                marker = list(line = list(color = toRGB("gray30"))),
                hoverinfo = "name+location+text",
                showlegend = FALSE,
                showscale = FALSE,
                source = "raidMap") %>%
            layout(geo = list(showframe = FALSE,
                              lonaxis = lonaxis,
                              lataxis = lataxis
                              ))
    })
    
    observeEvent(input$oneWeek, {
        updateSliderInput(session, 
                          inputId = "date", 
                          value = c(input$date[1], input$date[1] + 7))
    })
    
    observeEvent(input$oneMonth, {
        updateSliderInput(session, 
                          inputId = "date", 
                          value = c(input$date[1], input$date[1] + 30))
    })
    
    observeEvent(input$oneYear, {
        updateSliderInput(session, 
                          inputId = "date", 
                          value = c(input$date[1], input$date[1] + 365))
    })
    
    observeEvent(input$WLD, {
        lonaxis <<- list(range = list(-180, 180))
        lataxis <<- list(range = list(-90, 90))
    })
    
    observeEvent(input$EUR, {
        lonaxis <<- list(range = list(-10, 50))
        lataxis <<- list(range = list(28, 75))
    })
    
    observeEvent(input$ASI, {
        lonaxis <<- list(range = list(65, 180))
        lataxis <<- list(range = list(-18, 55))
    })
    
    observeEvent(input$AFR, {
        lonaxis <<- list(range = list(-20, 65))
        lataxis <<- list(range = list(2, 45))
    })
})
