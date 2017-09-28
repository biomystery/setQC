library(plotly)
require(heatmaply)
library(shiny)
require(rbokeh)

# compute a correlation matrix

libs<- unlist(strsplit(readLines("./including_libs.txt"),split = " "))
pd <- read.table("./avgOverlapFC.tab")
pd.log2 <- log2(subset(pd,apply(pd,1,max)>2)+1)
names(pd.log2)<- libs
correlation <- round(cor(pd.log2), 3)


ui <- fluidPage(
  fluidRow(
    column(6,
           plotlyOutput("heat")),
    column(6,
           rbokehOutput("scatterplot")
           )
  )
)

server <- function(input, output, session) {
  output$heat <- renderPlotly({
    heatmaply(correlation,colors = Reds(n = 9),margins = c(40,40,NA,20))
    #heatmaply_cor(correlation,margins = c(40,40,NA,20))
  })

  output$selection <- renderPrint({
    s <- event_data("plotly_click")
    if (length(s) == 0) {
      "Click on a cell in the heatmap to display a scatterplot"
    } else {
      cat("You selected: \n\n")
      as.list(s)
    }
  })

  output$scatterplot <- renderRbokeh({
    s <- event_data("plotly_click")
    if (length(s)) {
      vars <- c(s[["x"]], s[["y"]])
      print(vars)
      figure(data=pd.log2, title=paste0("cor=",correlation[vars[1],vars[2]]),
             tools = c("pan", "wheel_zoom", "box_select",  "reset", "save")) %>%
        ly_hexbin(libs[vars[1]], libs[vars[2]],xbins = 50,trans=log2,palette="RdYlBu11")%>%
        ly_abline(a=0,b=1)
    } else {
     figure(data=pd.log2,title=paste0("cor=",correlation[1,2]),
            tools = c("pan", "wheel_zoom", "box_select",  "reset", "save")) %>%
        ly_hexbin(libs[1], libs[2],xbins = 50,trans=log2,palette="RdYlBu11")%>%
        ly_abline(a=0,b=1)
    }
  })

}

shinyApp(ui, server)
