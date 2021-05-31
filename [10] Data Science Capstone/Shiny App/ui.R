library(shiny)
library(wordcloud2)
library(shinybusy, include.only = "add_busy_spinner")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application setup
    titlePanel("Smoothing Comparison for N-Gram Text Prediction"),
    shinyjs::useShinyjs(),
    withMathJax(),
    
    add_busy_spinner(timeout = 1500, position = "top-right"),
    
    sidebarLayout(
        
        ###################
        #  Sidebar Panel  #
        ###################
        
        sidebarPanel(width = 3,
            
            ##############################
            #  Model & Input Parameters  #
            ##############################
            
            selectInput("model", 
                        "Smoothing Method:", 
                        choices = c("Maximum Likelihood", 
                                    "Laplace",
                                    "Good-Turing",
                                    "Jelinek-Mercer",
                                    "Katz Backoff",
                                    "Kneser-Ney",
                                    "Stupid Backoff"),
                        selected = "Stupid Backoff"),
            
            numericInput("lambda",
                         "$$\\lambda$$",
                         value = 0.1,
                         min = 0,
                         max = 1,
                         step = 0.1),
            
            numericInput("delta",
                         "$$\\delta$$",
                         value = 0.5,
                         min = 0,
                         max = 1,
                         step = 0.1),
            
            numericInput("alpha",
                         "$$\\alpha$$",
                         value = 0.4,
                         min = 0,
                         max = 1,
                         step = 0.1),
            
            
            ##########################
            #  Filtering Parameters  #
            ##########################
            
            numericInput("max_n",
                         "Max n (1:n):",
                         value = 5,
                         min = 2,
                         max = 5),
            
            numericInput("min_threshold",
                         "Minimum frequency:",
                         value = 3,
                         min = 3,
                         max = 10),
            
            checkboxInput("truncate_rows",
                          "Exclude low frequency predictions?",
                          value = FALSE),
            
            numericInput("max_rank",
                         paste("Throw away elements that are not in the top",
                               "___ for their history:"),
                         value = 5,
                         min = 1,
                         max = 10),
            
            ########################
            #  Display Parameters  #
            ########################
            
            numericInput("num_results",
                         "Number of results to display:",
                         value = 10,
                         min = 1),
            
            tags$b("Total memory consumption: "),
            textOutput("mem_utilization")
        ),
        
        ################
        #  Main Panel  #
        ################
        
        mainPanel (
            tabsetPanel(
                tabPanel("Predictions",
                    fluidRow(
                        column(1),
                        column(10,
                               textInput("history",
                                         "",
                                         value = paste("The quick brown fox",
                                                       "jumped over the lazy"),
                                         width = "100%")
                        ),
                        column(1)
                    ),
                    
                    fluidRow(
                        column(1),
                        tabsetPanel(id = "output_format", type = "hidden",
                            tabPanel("Table",
                                column(10, align = "center",
                                       tableOutput("prediction_table"))
                            ),
                            
                            tabPanel("Plot",
                                column(10, align = "center",
                                       plotOutput("prediction_plot"))
                            ),
                            
                            tabPanel("Wordcloud",
                                column(10, align = "center",
                                       wordcloud2Output("prediction_cloud"))
                            )
                        ),
                        column(1, align = "right",
                            actionButton("show_table", "Table"),
                            actionButton("show_plot", "Plot"),
                            actionButton("show_cloud", "Wordcloud")
                        )
                    )
                ),
                
                tabPanel("Description", uiOutput("smoothing_description")),
                
                tabPanel("References",
                    tags$ol(
                        tags$li(
                            paste0(
                                "Daniel Jurafsky and James H. Martin. ",
                                "\"Speech and Language Processing\" Draft of ",
                                "December 30, 2020. Chapter 3. ",
                                "https://web.stanford.edu/~jurafsky/slp3/",
                                "ed3book_dec302020.pdf"
                            )
                        ),
                        tags$li(
                            paste0(
                                "Jon Dehdari. \"A Short Overview of ",
                                "Statistical Language Models.\" Workshop on ",
                                "Data Mining and its Use and Usability for ",
                                "Linguistic Analysis, March 2015. ",
                                "https://jon.dehdari.org/tutorials/",
                                "lm_overview.pdf"
                            )
                        ),
                        tags$li(
                            paste0(
                                "Bill MacCartney. \"NLP Lunch Tutorial: ",
                                "Smoothing\". 21 April 2005. ",
                                "https://nlp.stanford.edu/~wcmac/papers/",
                                "20050421-smoothing-tutorial.pdf"
                            )
                        ),
                        tags$li(
                            paste0(
                                "I. J. Good. \"The population frequencies of ",
                                "species and the estimation of population ",
                                "parameters.\" Biometrika, vol. 40, no. 3 ",
                                "and 4, pp. 237-264, 1953. ",
                                "https://www.ling.upenn.edu/courses/cogs502/",
                                "GoodTuring1953.pdf"
                            )
                        ),
                        tags$li(
                            paste0(
                                "William A. Gale.  \"Good-Turing Smoothing ",
                                "Without Tears\". Journal of Quantitative ",
                                "Linguistics, 1995. ",
                                "http://deanfoster.net/teaching/data_mining/",
                                "good_turing.pdf."
                            )
                        ),
                        tags$li(
                            paste0(
                                "F. Jelinek and R. L. Mercer. \"Interpolated ",
                                "estimation of Markov source parameters from ",
                                "sparse data\" in Pattern Recognition in ",
                                "Practice. E. S. Gelsema and L. N. Kana. ",
                                "Eds. Amsterdam: North-Holland, 1980."
                            )
                        ),
                        tags$li(
                            paste0(
                                "S. Katz. \"Estimation of probabilities from ",
                                "sparse data for the language model component ",
                                "of a speech recognizer\" in IEEE ",
                                "Transactions on Acoustics, Speech, and ",
                                "Signal Processing, vol. 35, no. 3. ",
                                "pp. 400-401. March 1987, doi: ",
                                "10.1109/TASSP.1987.1165125. ",
                                "https://citeseerx.ist.psu.edu/viewdoc/",
                                "download?doi=10.1.1.449.4772&rep=rep1&type=pdf"
                            )
                        ),
                        tags$li(
                            paste0(
                                "R. Kneser and H. Ney, \"Improved backing-off ",
                                "for M-gram language modeling\". 1995 ",
                                "International Conference on Acoustics, ",
                                "Speech, and Signal Processing, Detroit, MI, ",
                                "USA, 1995, pp. 181-184 vol.1, doi: ",
                                "10.1109/ICASSP.1995.479394. ",
                                "http://www-i6.informatik.rwth-aachen.de/",
                                "publications/download/951/",
                                "Kneser-ICASSP-1995.pdf"
                            )
                        ),
                        tags$li(
                            paste0(
                                "Thorsten Brants, Ashok C. Popat, Peng Xu, ",
                                "Franz J. Och and Jeffrey Dean. \"Large ",
                                "Language Models in Machine Translation.\" ",
                                "http://www.aclweb.org/anthology/D07-1090.pdf"
                            )
                        ),
                        tags$li(
                            paste0(
                                "Stanley F. Chen and Joshua Goodman. \"An ",
                                "Empirical Study of Smoothing Techniques for ",
                                "Language Modeling\". Center for Research ",
                                "in Computing Technology, Harvard University, ",
                                "TR-10-98. August 1998. ",
                                "https://people.eecs.berkeley.edu/~klein/",
                                "cs294-5/chen_goodman.pdf"
                            )
                        )
                    )
                )
            )
        )
    ),
    
    ############
    #  Footer  #
    ############
    
    tags$footer(title = "Contact Info", 
                style = "position:absolute; bottom:50; width:90%; height:50px;",
                column(3),
                column(5, align = "center", offset = 2,
                       tags$h3("Contact"),
                       tags$p("Eric Erkela",
                              tags$br(),
                              "eerkela42@gmail.com"),
                       tags$p("JHU Coursera Data Science",
                              "Specialization Capstone Project"))
    )           
))
