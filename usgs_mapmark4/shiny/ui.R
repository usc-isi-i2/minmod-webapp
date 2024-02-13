library(MapMark4)
library(purrr)
library(shiny)
library(shinybusy)
library(stringr)

#define ui
ui <- fluidPage(
  #browser tab label
  tags$head(HTML("<title>MapMark4</title>")),
  
  #app title
  titlePanel(title = div(
    img(src = "usgsR2.PNG", style = "width:80px; height:auto;"),
    # Adjust the width as needed
    "MapMark4 Shiny"
  )),
  
  #sidebar layout
  sidebarLayout(
    #sidebar panel
    sidebarPanel(
      # Add a horizontal line for separation
      tags$hr(),
      
      # Text area for SQL query input
      textAreaInput(
        inputId = "sqlQuery",
        label = "Enter SPARQL Query",
        placeholder = "Type your SPARQL query here...",
        value = "SELECT ?mineralInventory ?tonnage  ?grade ?inventoryName ?category
                          WHERE {
                              ?mineralInventory a            :MineralInventory .
                              ?mineralInventory :id          ?inventoryName .

                              ?mineralInventory :date        '09-19-2017' .

                              ?mineralInventory :ore         ?ore .
                              ?ore              :ore_value   ?tonnage .

                              ?mineralInventory :grade       ?gradeInfo .
                              ?gradeInfo        :grade_value ?grade .

                              ?mineralInventory :commodity   ?Commodity .
                              ?Commodity        :name        'Zinc'@en .

                              ?mineralInventory :category    ?category .
                          }",
        rows = 18
      ),
      
      selectInput(
        inputId = "sample_queries", 
        label = "Select Sample Query",  
        choices = NULL,
        width = '100%',
      ),
      
      # Button to execute the SQL query
      actionButton(
        inputId = "executeQuery",
        label = "Execute Query",
        icon = icon("play"),
        width = '100%'
      ),
      
      
      #horizontal line
      tags$hr(),
      
      #upload grade-tonnage model
      fileInput(
        inputId = "gtcsv",
        label = "Upload Grade-Tonnage Model",
        multiple = F,
        accept = c(".csv"),
        width = '100%',
        buttonLabel = 'Browse...',
        placeholder = "Upload your data..."
      ),
      
      #horizontal line
      tags$hr(),
      
      #checkbox for specifying if the grade-tonnage model dataframe includes column headers
      checkboxInput(
        inputId = "headergtcsv",
        label = "Header",
        value = T,
        width = '100%'
      ),
      
      #horizontal line
      tags$hr(),
      
      #checkbox for specifying view of grade-tonnage model dataframe (preview or all)
      radioButtons(
        inputId = "dispgtcsv",
        label = "Display",
        choices = c(Preview = "preview", All = "all"),
        selected = "preview",
        inline = F,
        width = '100%'
      ),
      
      #horizontal line
      tags$hr(),
      
      #upload deposit estimates
      fileInput(
        inputId = "depcsv",
        label = "Upload Deposit Estimates",
        multiple = F,
        accept = c(".csv"),
        width = '100%',
        buttonLabel = 'Browse...',
        placeholder = "Upload your data..."
      ),
      
      #horizontal line
      tags$hr(),
      
      #checkbox for specifying if the deposit dataframe includes column headers
      checkboxInput(
        inputId = "headerdepcsv",
        label = "Header",
        value = T,
        width = '100%'
      ),
      
      #horizontal line
      tags$hr(),
      
      #checkbox for specifying view of deposit dataframe (preview or all)
      radioButtons(
        inputId = "dispdepcsv",
        label = "Display",
        choices = c(Preview = "preview", All = "all"),
        selected = "preview",
        inline = F,
        width = '100%'
      ),
      
      hr(),
      
      #tract id
      textInput("tract_id", label = NULL, value = "Enter Tract ID..."),
      
      #select output folder
      #textInput("output_folder", label = NULL, value = "Select Download Folder..."),
      
      #insert action button to run analysis
      actionButton(
        inputId = 'RUNanalysis',
        label = 'Run Resource Assessment',
        icon = NULL,
        width = '100%'
      ),
      
      #download mapmark4 results
      downloadButton(outputId = 'download_results', 'Download Mapmark4 Results'),
      
      #write mapmark4 results
      #actionButton(inputId = 'download_results', label = 'Download Mapmark4 Results', icon = NULL, width = '100%'),
      
      add_busy_spinner(spin = "fading-circle")
      #add_busy_bar(color = "#FF0000")
      #conditionalPanel(
      #    condition="($('html').hasClass('shiny-busy'))",
      #    img(src = "cat.gif")
      #)
    ),
    
    #main panel for displaying outputs
    mainPanel(
      tabPanel("2 columns",
               fluidRow(
                 column(
                   width = 12,
                   uiOutput("query_output_header"),
                   tableOutput(outputId = "query_output"),
                   uiOutput("download_query_result_button")
                 ),
               )),
      
      
      
      
      tabPanel("2 columns",
               fluidRow(column(
                 width = 12,
                 uiOutput("gradeTonnageHeader"),
                 uiOutput("plots")
               ),)),
      
      
      #horizontal line
      tags$hr(),
      
      #display grade-tonnage model dataframe and relevant correlation information side-by-side
      tabPanel("2 columns",
               fluidRow(
                 column(width = 6,
                        h2(""),
                        tableOutput(outputId = "contentsgt")),
                 column(
                   width = 6,
                   h2(""),
                   plotOutput(outputId = "correlation_matrix"),
                   textOutput(outputId = "text_out")
                 )
               )),
      
      #horizontal line
      tags$hr(),
      
      #display deposit number estimate and summary information side-by-side
      tabPanel("2 columns",
               fluidRow(
                 column(width = 6,
                        h2(""),
                        tableOutput(outputId = "contentsdep")),
                 column(width = 6,
                        h2(""),
                        tableOutput(outputId = "dep_sum"))
               )),
      
      plotOutput(outputId = "dep_plot"),
      
      
      plotOutput(outputId = "tonnage_plot"),
      plotOutput(outputId = "grade_plot"),
      plotOutput((outputId = "total_tonnage_plot")),
      plotOutput((outputId = "marginals_plot"))
    )
  )
)