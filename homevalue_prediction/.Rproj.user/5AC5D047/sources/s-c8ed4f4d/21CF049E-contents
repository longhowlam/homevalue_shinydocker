omgeving = PC_lookup[PC6 == "1628EP",]


input = list(
  PC = "1628EP",
  vrijopnaam = "kosten koper",
  ouderdom = 8,
  woonoppervlakte = 100,
  perceel = 100,
  inhoud = 350,
  typehuis = "EengezinswoningTussenwoning",
  aantalkamers = 5
)

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
print(mijnhuis)  
out = round(predict(huismodel_omg , mijnhuis %>% as.h2o()) %>% as.data.frame()) 

sh_out = Shapley$new(predictor_omg.rf, x.interest = mijnhuis)
mijnhuis$PC6 = NULL


h2o.shutdown()
