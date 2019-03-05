
library(shinydashboard)
library(data.table)
library(shinycssloaders)
library(h2o)
library(magrittr)
library(iml)
h2o.init()

# Start up stuff ############################################################################

#### import benodigde model

huismodel        = h2o.loadModel("data/DRF_model_R_1550832441075_2")
huismodel_omg    = h2o.loadModel("data/DRF_model_R_1551255540205_3")
predictor.rf     = readRDS( "data/iml_precitor.RDS")
predictor_omg.rf = readRDS("data/iml_precitor_omgeving.RDS")
PC_lookup        = readRDS("data/PC_lookup.RDs")


### huistypes 
wtypes = c( 
  "Benedenwoning"                                  , "Bovenwoning"                         ,                               
  "BungalowGeschakeldeWoning"                      , "BungalowVrijstaandeWoning"           ,                   
  "DubbelBenedenhuis"                              , "EengezinswoningEindwoning"           ,                  
  "EengezinswoningGeschakeldeTweeOnderEenKapWoning", "EengezinswoningGeschakeldeWoning"    ,               
  "EengezinswoningHalfvrijstaandeWoning"           , "EengezinswoningHoekwoning"           ,              
  "EengezinswoningTussenwoning"                    , "EengezinswoningTweeOnderEenKapWoning",           
  "EengezinswoningVrijstaandeWoning"               , "Galerijflat"                         ,          
  "HerenhuisHoekwoning"                            , "HerenhuisTussenwoning"               ,         
  "HerenhuisTweeOnderEenKapWoning"                 , "HerenhuisVrijstaandeWoning"          ,        
  "Maisonnette"                                    , "Penthouse"                           ,       
  "Portiekflat"                                    , "Portiekwoning"                       ,      
  "Tussenverdieping"                               , "VillaTweeOnderEenKapWoning"          ,     
  "VillaVrijstaandeWoning"                         , "Other")     

# UI PART of the app #######################################################################################

ui <- dashboardPage(
  dashboardHeader(title = "Huiswaarde model voor Nederlandse huizen", titleWidth = 450),
  dashboardSidebar(width=300,
    sidebarMenu(
      menuItem("Inleiding", tabName = "introduction", icon = icon("dashboard")),
      menuItem("Huiswaarde voorspelling en verklaring", tabName = "imagestab", icon = icon("th")),
      menuItem("Uitleg model", tabName = "uitleg", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "introduction",
        h3("Inleiding"),
        list(
            h4("Voorspeller van de huiswaarde op basis van een aantal kenmerken. Predcitie model is
              gebasseerd op een random forest model met data van woningtransacties van 2018. "),
            h4("In de kenmerken zijn ook CBS nabijheidsdata meegenomen zoals aantal restaurants, hotels en bioscopen in de buurt"),
            
            h4("Uitleg van de voorspelling per huis m.b.v. Shapley values. Duurt ~7 sec"),
            h4(" "),
            h4("* Klik op de link: " , strong("Huiswaarde en verklaring")),
            h4("* Vul waarden in en klik op de knop: ", strong("Bereken prijs")),
            h4(" "),
            h4(strong("NB."), "Er kunnen geen rechten worden ontleend aan deze shiny app!!"),
            h4("Cheers, Longhow"),
            h4(" "),
            hr(),
            img(src ="huis.PNG") ,
            img(src="varimp.png")
        )
              
              ),
      tabItem(tabName = "imagestab",
          fluidRow(
            column(width = 3,
              numericInput("woonoppervlakte", "woonoppervlakte in m2", 100, min=10,max=1000),
              numericInput("aantalkamers", "aantal kamers", 5, min=1, max=15),
              numericInput("ouderdom", "ouderdom huis (in jaren)", 8, min=0, max=200),
              numericInput("perceel", "perceel oppervlakte in m2", 100, min=10,max=2000),
              numericInput("inhoud", "inhoud  in m3", 300, min=50,max=6000),
              textInput("PC", "postcode", "1628EP"),
              selectInput("typehuis", "Type huis", wtypes),
              checkboxInput("vrijopnaam", "Vrij Op Naam"),
              actionButton("goButton", "Bereken prijs")
            ),
            column( width = 9,
              fluidRow(
                h3("Huiswaarde voorspelling en verklaring"),
                withSpinner(valueBoxOutput("homevalue"))
              ),
              fluidRow(
                withSpinner(plotOutput("iml_shaply"))
              )
            )
          )
      ),

      tabItem(
        tabName = "uitleg",
        h3("Zie mijn Linkedin article voor verdere uitleg:", 
           a("Blogje", href="https://www.linkedin.com/pulse/wat-mijn-huis-waard-leg-dat-eens-uit-longhow-lam/")
        )
      )
    )
  )
)


# SERVER PART of the app   ##############################################################


server <- function(input, output) {

  getParameters <- eventReactive(input$goButton, {
    
    ### first lookup if we can find neigbourhood data
    omgeving = PC_lookup[PC6 == input$PC,]
    
    # no neighborhood data, use model without neigborhoud data
    if(nrow(omgeving) == 0)
    {
      mijnhuis = data.frame(
        PC2 = stringr::str_sub(input$PC,1,2), 
        KoopConditie = ifelse(input$vrijopnaam, "vrij op naam", "kosten koper"), 
        ouderdom = input$ouderdom,
        Woonoppervlak = input$woonoppervlakte,
        aantalkamers = input$aantalkamers,
        Perceel = input$perceel,
        Inhoud = input$inhoud,
        woningBeschrijving = input$typehuis 
      ) 
      out = round(predict(huismodel , mijnhuis %>% as.h2o()) %>% as.data.frame()) 
      
      sh_out = Shapley$new(predictor.rf, x.interest = mijnhuis)
    }
    else{
      # when there is neighboourhood data use the better neighborhood model
      mijnhuis = dplyr::bind_cols(
        data.frame(
          PC2 = stringr::str_sub(input$PC,1,2), 
          KoopConditie = ifelse(input$vrijopnaam, "vrij op naam", "kosten koper"), 
          ouderdom = input$ouderdom,
          Woonoppervlak = input$woonoppervlakte,
          aantalkamers = input$aantalkamers,
          Perceel = input$perceel,
          Inhoud = input$inhoud,
          woningBeschrijving = input$typehuis 
        ),
        omgeving
      )
      # drop the PC6 column, not needed in prediction and shapely values
      mijnhuis$PC6 = NULL
      out = round(predict(huismodel_omg , mijnhuis %>% as.h2o()) %>% as.data.frame()) 
      sh_out = Shapley$new(predictor_omg.rf, x.interest = mijnhuis)
     
    }
    return(list(price = out, shapley = sh_out))
  })
  
  output$homevalue = renderValueBox({
    
    price = getParameters()$price
    valueBox(
      paste(  "\u20ac", format(price, nsmall=2, big.mark=".", decimal.mark = ",")  )
      , "Random Forest predictie", width = 2,
      icon = icon("cog", lib = "glyphicon")
    )
    
  })
  
  output$iml_shaply = renderPlot({
    shapley.rf = getParameters()$shapley
    plot(shapley.rf)
  })
}

shinyApp(ui, server)