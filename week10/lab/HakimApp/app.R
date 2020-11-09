## app.R ##
library(shinydashboard)
library(DT)
library(fpc)
library(DDoutlier)

# This function receives a column of the table and classify the data values into normal and outliers
findStatOutliers <- function(data){
  m = mean(data)
  s = sd(data)
  idx <- abs(data - m) > 3 * s
  classes <- replace(idx, idx == TRUE, 1)
  classes <- replace(classes, classes == FALSE, 2)
  return (classes)
}

# This function receives a string and creates a plot that shows the string
# Useful to show a message instead of empty plot
createTextPlot <- function(stringToDisplay){
  par(mar = c(0,0,0,0))
  plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
  text(x = 0.5, y = 0.5, stringToDisplay, 
       cex = 1.6, col = "black")
}

##  content
# The user interface object
u <- dashboardPage(
  # The title of the page
  dashboardHeader(title = "Simple Dashboard"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Select Data", tabName = "load"),
      menuItem("Data Distribution", tabName = "explore"),
      menuItem("Outlier Detection", tabName = "od"),
      menuItem("Clustering", tabName = "cluster")
    )
  ),
  # The contents of the main page
  dashboardBody(
    tabItems(
      # Tab 1. loading the data
      tabItem(tabName = "load",
              sidebarPanel(
                #Selector for file upload
                fileInput('datafile', 'Choose CSV file',
                          accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv'))
                ),
              mainPanel(
                DT::dataTableOutput("filetable")
              )
      ),   # End of Tab 1.

      # Tab2. Data Distribution
      tabItem(tabName = "explore",
          sidebarPanel(
            uiOutput("expCol"),
          ),
          mainPanel(
            plotOutput('colPlot')
          )
      ),      # End of Tab 2
      
      # Tab 3. Outlier Detection
      tabItem(tabName = "od",
              tabsetPanel(
                # The id lets us use input$tabset1 on the server to find the current tab
                id = "odtabset",
                tabPanel("Statistical Test",
                         sidebarPanel(
                           uiOutput("statodCol"),
                         ),
                         mainPanel(
                           plotOutput('statodPlot')
                         )   
                    ),
                tabPanel("DB", 
                         sidebarPanel(
                           uiOutput("dbodCol1"),
                           uiOutput("dbodCol2"),
                           numericInput('radius', 'Neighborhood radius', 5),
                           numericInput('ratio', 'Ratio of points in r-neighborhood', 0.05),
                         ),
                         mainPanel(
                           plotOutput('odDBPlot')
                         )
                  )
              )
        ),    # End of Tab 3
        
      # Tab 4. Clustering
        tabItem(tabName = "cluster",
                tabsetPanel(
                  # The id lets us use input$tabset1 on the server to find the current tab
                  id = "clustertabset",
                  tabPanel("kmeans", 
                           sidebarPanel(
                             uiOutput("kmeansCol1"),
                             uiOutput("kmeansCol2"),
                             numericInput('clusters', 'Cluster Count', 3,
                                          min = 1, max = 9),
                           ),
                           mainPanel(
                             plotOutput('kmeansPlot')
                           )
                  ),
                  tabPanel("DBSCAN", 
                    sidebarPanel(
                      uiOutput("dbscanCol1"),
                      uiOutput("dbscanCol2"),
                      numericInput('epsilon', 'Radius:', 5),
                      numericInput('knn', 'Number of minPnts:', 5),
                    ),
                    mainPanel(
                      plotOutput('dbscanPlot')
                    )
                )
          )
        ) # End of Tab 4
      
    )  # End of tabitems
  )  # End of dashboardbody
)  # End of dashboardPage -- ui object



# The backend server
s <- function(input, output) {
  # Create a vector of preferred colors
  palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
            "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
  #This function is repsonsible for loading in the selected file
  filedata <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    read.csv(infile$datapath)
  })
  
  
  #The following set of functions populate the column selectors
  output$expCol <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("exploreCol", "Seclect a Column:",items)
    
  })

  output$statodCol <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("stodCol", "Seclect a Column:",items)
    
  })
  
  output$dbodCol1 <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("dbCol1", "Seclect First Column:",items)
  })
  output$dbodCol2 <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("dbCol2", "Seclect Second Column:",items, selected = items[2])
  })
  
  output$kmeansCol1 <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("kmeanCol1", "X:",items)
    
  })
  
  
  output$kmeansCol2 <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("kmeanCol2", "Y:",items, selected = names(df)[2])
    
  })
  
  output$dbscanCol1 <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("dbsCol1", "X:",items)
    
  })
  
  
  output$dbscanCol2 <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("dbsCol2", "Y:", items, selected = names(df)[2])
    
  })
  
  
  
  #This previews the CSV data file
  output$filetable <- DT::renderDataTable({
    df <-filedata()
    if (is.null(df)) return(NULL)
    df
  })
  
  
  # This renders the PDF/histogram for the selected column
  output$colPlot <- renderPlot({
    df <-filedata()     # Get the data in a dataframe
    if (is.null(df)) return(NULL)  # check the dataframe is not null
    if (is.null(input$exploreCol)) return(NULL)
    selectedData <- df[, input$exploreCol]
    # Remove any records with missing values
    selectedData <- selectedData[complete.cases(selectedData)]
    idx = selectedData == ""
    selectedData <- selectedData[!idx]
    # For numerical columns, plot the probablility density function
    if(is.numeric(selectedData)){
      den = density(selectedData)  # You can add more arguments
      plot(den$x, den$y, type = 'l', lwd = 3, col = "blue",
           xlab = input$exploreCol, ylab = paste("PFD(", input$exploreCol, ")"))
    }
    else{ # For categorical (factor) columns
      barplot(prop.table(table(selectedData)))
      }
  })
  
  # This renders the detected outliers using the statistical test
  output$statodPlot <- renderPlot({
    df <-filedata()
    if (is.null(df)) return(NULL)
    if (is.null(input$stodCol)) return(NULL)
    statodData <- df[, input$stodCol]
    # Remove any records with missing values
    statodData <- statodData[complete.cases(statodData)]
    idx = statodData == ""
    statodData <- statodData[!idx]
    if (is.numeric(statodData)){
      statOD <- findStatOutliers(statodData)
      plot(statodData, col = statOD, pch = 4, cex = 3, lwd = 4
           , xlab = "index", ylab = input$stodCol)
    }
    else
      return(NULL)
  })
  
  # This renders the detected outliers using the distance-based outlier detection technique
  output$odDBPlot <- renderPlot({
    df <-filedata()
    if (is.null(df)) return(NULL)
    if (is.null(input$dbCol1) || is.null(input$dbCol2)) return(NULL)
    if (input$dbCol1 == input$dbCol2)
      { return(createTextPlot("You have selected the same column twice"))}
    odDBData <- df[, c(input$dbCol1, input$dbCol2)]
    # Remove any records with missing values
    odDBData <- odDBData[complete.cases(odDBData), ]
    idx = vector(mode = "logical", length = nrow(odDBData))
    for (col in names(odDBData)){
      idx = idx || (odDBData[, col] == "")
    }
    odDBData <- odDBData[!idx, ]
    
    # Classify observations
    if (!is.numeric(input$radius) || !is.numeric(input$ratio) ||
        !is.numeric(odDBData[,1]) || !is.numeric(odDBData[, 2])){
      return (NULL)      
    }
    cls_observations <- DB(dataset=odDBData, d=input$radius, fraction=input$ratio)$classification
    
    # Remove outliers from dataset
    Xi <- odDBData[cls_observations=='Inlier',]
    classes <- replace(cls_observations, cls_observations == 'Inlier', 2)
    classes <- replace(classes, classes == 'Outlier', 1)
    
    plot(odDBData, col = classes, pch = 4, cex = 3, lwd = 4,
         xlab = input$dbCol1, ylab = input$dbCol2)
  })
  
  
  # This renders the clusters found using the kmeans method
  output$kmeansPlot <- renderPlot({
    df <-filedata()
    if (is.null(df)) return(NULL)
    if (is.null(input$kmeanCol1) || is.null(input$kmeanCol2)) return(NULL)
    if (input$kmeanCol1 == input$kmeanCol2)
      { return(createTextPlot("You have selected the same column twice"))}
    kmeansData <- df[, c(input$kmeanCol1, input$kmeanCol2)]
    # Remove any records with missing values
    kmeansData <- kmeansData[complete.cases(kmeansData), ]
    idx = vector(mode = "logical", length = nrow(kmeansData))
    for (col in names(kmeansData)){
      idx = idx || (kmeansData[, col] == "")
    }
    kmeansData <- kmeansData[!idx, ]
    if (!is.numeric(input$clusters)||
        !is.numeric(kmeansData[,1]) || !is.numeric(kmeansData[, 2])){
      return (NULL)      
    }
    clusters <- kmeans(kmeansData, input$clusters)
    
    par(mar = c(5.1, 4.1, 0, 1))
    plot(kmeansData,
         col = clusters$cluster,
         pch = 20, cex = 3, xlab = input$kmeanCol1, 
         ylab = input$kmeanCol2)
    points(clusters$centers, pch = 4, cex = 4, lwd = 4)
  })
  
  
  # This renders the clusters found using the DBSCAN algorithm
  output$dbscanPlot <- renderPlot({
    df <-filedata()
    if (is.null(df)) return(NULL)
    if (is.null(input$dbsCol1) || is.null(input$dbsCol2)) return(NULL)
    if (input$dbsCol1 == input$dbsCol2)
        { return(createTextPlot("You have selected the same column twice"))}
    dbscanData <- df[, c(input$dbsCol1, input$dbsCol2)]
    # Remove any records with missing values
    dbscanData <- dbscanData[complete.cases(dbscanData), ]
    idx = vector(mode = "logical", length = nrow(dbscanData))
    for (col in names(dbscanData)){
      idx = idx || (dbscanData[, col] == "")
    }
    dbscanData <- dbscanData[!idx, ]
    if (!is.numeric(input$epsilon)|| !is.numeric(input$knn) ||
        !is.numeric(dbscanData[, 1]) || !is.numeric(dbscanData[, 2])){
      return (NULL)      
    }
    
    clusters <- dbscan(dbscanData, input$epsilon, input$knn)
    
    plot(dbscanData,
         col = clusters$cluster,
         pch = 20, cex = 3, xlab = input$dbsCol1, ylab = input$dbsCol2)
  })
}

shinyApp(ui = u, server = s)

