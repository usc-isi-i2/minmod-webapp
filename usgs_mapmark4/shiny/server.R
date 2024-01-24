library(corrplot)
library(dplyr)
library(MapMark4)
library(purrr)
library(shiny)
library(shinybusy)
library(shinycssloaders)
library(stringr)
library(ggiraph)
library(ggplot2)

server <- function(input, output) {
    
    #read grade-tonnage model dataframe
    myGatm <- reactive({
        req(input$gtcsv)
        read.csv(input$gtcsv$datapath, header = input$headergtcsv)
    })
    
    #read deposit estimate dataframe
    dfdepcsv <- reactive({
        req(input$depcsv)
        read.csv(input$depcsv$datapath,
                 header = input$headerdepcsv)
    })
    
   
    myGatmdata <- reactive({
      req(input$gtcsv)
      inFile <- input$gtcsv
      df <- read.csv(inFile$datapath, header = input$headergtcsv)
      
      df$Ore = df$Ore/1e6
      # Dynamically add tooltip columns
      grade_cols <- setdiff(names(df), c("ID", "Name", "Ore"))
      for(col in grade_cols) {
        tooltip_colname <- paste0(col, "_tooltip")
        df[[tooltip_colname]] <- paste("Deposit Name: ", df$Name, 
                                       "\nOre: ", df$Ore, 
                                       "\n", col, " Grade: ", df[[col]], sep = "")
      }
      return(df)
    })
    
    isFileUploaded <- reactive({
      !is.null(input$gtcsv)
    })
    
    # Render the header UI conditionally
    output$gradeTonnageHeader <- renderUI({
      if (isFileUploaded()) {
        h3("Grade-Tonnage Models")
      }
    })
    
    # Dynamically create plots based on grade columns
    output$plots <- renderUI({
      cols <- grade_cols()
      
      plot_output_list <- lapply(cols, function(col) {
        plotname <- paste0(col, "Plot")
        column(width = 6, girafeOutput(plotname))
      })
      fluidRow(plot_output_list)
    })
    
    grade_cols <- reactive({
      data <- myGatmdata()
      # Exclude columns that are not grades or end with '_tooltip'
      cols <- setdiff(names(data), c("ID", "Name", "Ore"))
      cols <- cols[!grepl("_tooltip$", cols)]  # Exclude tooltip columns
      return(cols)
    })
    
    # Generating each plot
    observe({
      data <- myGatmdata()
      cols <- grade_cols()
      
      for(col in cols) {
        local({
          colname <- col
          tooltip_colname <- paste0(col, "_tooltip")  # Ensuring single '_tooltip' suffix
          output[[paste0(colname, "Plot")]] <- renderGirafe({
            gg <- ggplot(data, aes_string(x = "Ore", y = colname, tooltip = tooltip_colname)) +
              geom_point_interactive() +
              scale_x_log10() + 
              theme_minimal() +
              labs(title = paste0(colname, " Grade-Tonnage Model"),
                   x = "Tonnage, in million metric tons (log scale)",
                   y = paste0("Grade, in percent (",colname,")"))
            girafe(ggobj = gg)
          })
        })
      }
    })
    
    # Generating each plot
   
    #generate view of deposit estimate dataframe when it is uploaded and generate oPmf, summary_oPmf, and dep_plot
    observeEvent(input$depcsv, {
        output$contentsdep <- renderTable({
            if(input$dispdepcsv == "preview") {
                return(head(dfdepcsv()))
            }
            else {
                return(dfdepcsv())
            }
        })
        
        oPmf <<- reactive({NDepositsPmf('NegBinomial', list(nDepEst = dfdepcsv()))})
        
        summary_oPmf <<- capture.output(summary(oPmf()))
        
        output$dep_plot <- renderPlot({
            return(plot(oPmf()))
        })
        
        output$dep_sum <- renderTable({
            return(summary_oPmf)
        })
    })
    
    #show view of the grade-tonnage model dataframe 
    output$contentsgt <- renderTable({
        
        if(input$dispgtcsv == "preview") {
            return(head(myGatm()))
        }
        else {
            return(myGatm())
        }
    })
    
    
    #generate correlation matrix if and when the grade-tonnage model is uploaded along with an explanation of its purpose
    observeEvent(input$gtcsv, {
        output$correlation_matrix <- renderPlot({
            myGatm_matrix <- reactive({as.matrix(myGatm()[, 3:ncol(myGatm())])})
            myGatm_matrix2 <- reactive({log(myGatm_matrix())})
            myGatm_corr <- reactive({cor(myGatm_matrix2(), method = "pearson")})
            p_vals <- reactive({cor.mtest(myGatm_matrix2(), conf.level = .95, method = "pearson")})
            return(corrplot(myGatm_corr(), p.mat = p_vals()$p, insig = "p-value", sig.level = -1, diag = F, type = 'upper', 
                            number.cex = 1, mar = c(0, 0, 2, 0), title = 'G-T (logged values) Correlation Matrix (p-values listed)'))
        })
        
        output$text_out <- renderText({
            return("The sample correlation coefficients are represented by circle color (color legend) and size (more extreme values are represented by larger circles). The p-values associated with testing the null hypothesis that the correlation coefficients are equal to zero are represented in the plot numerically. Potential issues arise if non-zero correlation exists between tonnage and any of the grades. Statistically significant non-zero correlation coefficients are indicated by p-values <= .05 across the first row.")
        })
    })
    
    #run remaining analysis
    observeEvent(input$RUNanalysis, {
        
        #generate tonnage distribution via kde if number of deposits in G-T model exceeds 50 else normal distribution, seed is set to 7, sample is truncated
        if (nrow(myGatm()) > 50) {
            oTonPdf <<- reactive({TonnagePdf(myGatm(), seed = 7, pdfType = 'kde', isTruncated = T, minNDeposits = 20, nRandomSamples = 1e+06)})
        } else {
            oTonPdf <<- reactive({TonnagePdf(myGatm(), seed = 7, pdfType = 'normal', isTruncated = T, minNDeposits = 20, nRandomSamples = 1e+06)})    
        }
        
        #summary of the tonnage distribution
        summary_oTonPdf <<- capture.output(summary(oTonPdf()))
        
        #generate grade distribution via kde if number of deposits in G-T model exceeds 50 else normal distribution, seed is set to 7, sample is truncated
        if (nrow(myGatm()) > 50){
            oGradePdf <<- reactive({GradePdf(myGatm(), seed = 7, pdfType = 'kde', isTruncated = T)})
        } else {
            oGradePdf <<- reactive({GradePdf(myGatm(), seed = 7, pdfType = 'normal', isTruncated = T)})
        }
        
        #summary of the grade distribution
        summary_oGradePdf <<- capture.output(summary(oGradePdf()))
        
        #generate simulation
        oSimulation <<- reactive({Simulation(oPmf(), oTonPdf(), oGradePdf())})
        
        #generate total tonnage
        oTotalTonPdf <<- reactive({TotalTonnagePdf(oSimulation(), oPmf(), oTonPdf(), oGradePdf())})
        
        #summary of total tonnages
        summary_oTotalTonPdf <<- capture.output(summary(oTotalTonPdf()))
        
        #write simulation data to directory
        print(oSimulation(), 'sim_data.csv')
        
        sim_dat <- as_tibble(read.csv('sim_data.csv', header = T))
        unlink('sim_data.csv')
        
        contained_weight <- function(x){
            x * sim_dat$Ore.tonnage / 100
        }
        
        MetricTons <- sim_dat %>%
            select(-Simulation.Index, -Number.of.Deposits, -Sim.Deposit.Index, -Ore.tonnage, -gangue.grade) %>% 
            mutate_all(contained_weight) %>% 
            purrr::set_names(~ str_replace_all(., "\\.grade", " _MetricTons"))
        
        meta <- sim_dat %>% 
            select(Simulation.Index, Number.of.Deposits, Sim.Deposit.Index, Ore.tonnage, ends_with("grade")) %>% 
            purrr::set_names(~ str_replace(., "\\.tonnage", "_MetricTons")) %>% 
            purrr::set_names(~ str_replace(., "\\.grade", " _pct")) %>% 
            purrr::set_names(~ str_replace(., "gangue _pct", "gangue"))
        
        sim_ef <- bind_cols(meta, MetricTons)
        
        contained_totals <- sim_ef %>% 
            group_by(Simulation.Index) %>% 
            mutate_at(vars(matches("_MetricTons")), sum) %>% 
            select(Simulation.Index, Number.of.Deposits, contains("_MetricTons")) %>% 
            distinct(Simulation.Index, .keep_all = T)
        
        output$dep_plot <- renderPlot({
            return(plot(oPmf()))
        })
        
        output$tonnage_plot <- renderPlot({
            return(plot(oTonPdf()))
        })
        
        output$grade_plot <- renderPlot({
            return(plot(oGradePdf()))
        })
        
        output$total_tonnage_plot <- renderPlot({
            return(plot(oTotalTonPdf()))
        })
        
        output$marginals_plot <- renderPlot({
            return(plotMarginals(oTotalTonPdf()))
        })
        
        output$download_results <- downloadHandler(
            
            filename = paste(input$tract_id, 'mm4_output.zip', sep = '_'),
            content = function(fname) {
                tmpdir <- tempdir()
                setwd(tempdir())
                print(tempdir())
                
                fs <- c('pmfPlot.jpg', 'pmfPlot.tiff', 'pmfPlot.eps', 'summary_oPmf.txt', 'TonPdfPlot.jpg', 
                        'TonPdfPlot.tiff', 'TonPdfPlot.eps', 'summary_oTonPdf.txt', 'GradPdfPlot.jpg', 'GradPdfPlot.tiff', 
                        'GradPdfPlot.eps', 'summary_oGradePdf.txt', 'SimTotalPlot.jpg', 'SimTotalPlot.tiff', 
                        'SimTotalPlot.eps', 'summary_oTotalTonPdf.txt', 'SimMatrixPlot.jpg', 'SimMatrixPlot.tiff', 
                        'SimMatrixPlot.eps', 'SIM_DATA.csv', 'SIM_EF.csv', 'contained_totals.csv')
                
                fs2 <- c()
                for (i in 1:length(fs)) {
                    fs2 <- c(fs2, paste(input$tract_id, fs[i], sep = '_'))
                }
                
                jpeg(paste(input$tract_id, 'pmfPlot.jpg', sep = '_'), height = 240)
                plot(oPmf())
                dev.off()
                
                tiff(paste(input$tract_id, 'pmfPlot.tiff', sep = '_'))
                plot(oPmf())
                dev.off()
                
                ps.options()
                setEPS()
                postscript(paste(input$tract_id, 'pmfPlot.eps', sep = '_'), height = 3.5)
                plot(oPmf())                
                dev.off()
                
                jpeg(paste(input$tract_id, 'TonPdfPlot.jpg', sep = '_'), height = 240)
                plot(oTonPdf())
                dev.off()
                
                tiff(paste(input$tract_id, 'TonPdfPlot.tiff', sep = '_'))
                plot(oTonPdf())
                dev.off()
                
                setEPS()
                postscript(paste(input$tract_id, 'TonPdfPlot.eps', sep = '_'), height = 3.5)
                plot(oTonPdf())                
                dev.off()
                
                jpeg(paste(input$tract_id, 'GradPdfPlot.jpg', sep = '_'))
                plot(oGradePdf())
                dev.off()
                
                tiff(paste(input$tract_id, 'GradPdfPlot.tiff', sep = '_'))
                plot(oGradePdf())
                dev.off()
                
                setEPS()
                postscript(paste(input$tract_id, 'GradPdfPlot.eps', sep = '_'))
                plot(oGradePdf())                
                dev.off()
                
                jpeg(paste(input$tract_id, 'SimTotalPlot.jpg', sep = '_'), height = 240)
                plot(oTotalTonPdf())
                dev.off()
                
                tiff(paste(input$tract_id, 'SimTotalPlot.tiff', sep = '_'))
                plot(oTotalTonPdf())
                dev.off()
                
                setEPS()
                postscript(paste(input$tract_id, 'SimTotalPlot.eps', sep = '_'), height = 3.5)
                plot(oTotalTonPdf())                
                dev.off()
                
                jpeg(paste(input$tract_id, 'SimMatrixPlot.jpg', sep = '_'))
                plotMarginals(oTotalTonPdf())
                dev.off()
                
                tiff(paste(input$tract_id, 'SimMatrixPlot.tiff', sep = '_'))
                plotMarginals(oTotalTonPdf())
                dev.off()
                
                setEPS()
                postscript(paste(input$tract_id, 'SimMatrixPlot.eps', sep = '_'))
                plotMarginals(oTotalTonPdf())                
                dev.off()
                
                write(summary_oPmf, paste(input$tract_id, 'summary_oPmf.txt', sep = '_'), ncolumns = 1)
                write(summary_oTonPdf, paste(input$tract_id, 'summary_oTonPdf.txt', sep = '_'), ncolumns = 1)
                write(summary_oGradePdf, paste(input$tract_id, 'summary_oGradePdf.txt', sep = '_'), ncolumns = 1)
                write(summary_oTotalTonPdf, paste(input$tract_id, 'summary_oTotalTonPdf.txt', sep = '_'), ncolumns = 1)
                
                write.csv(sim_dat, paste(input$tract_id, 'sim_data.csv', sep = '_'), row.names = F)
                write.csv(sim_ef, paste(input$tract_id, 'sim_ef.csv', sep = '_'), row.names = T)
                write.csv(contained_totals, paste(input$tract_id, 'contained_totals.csv', sep = '_'), row.names = T)
                
                zip::zip(zipfile = fname, files = fs2)	
            }
        )
    })
    
    shinyServer(function(input, output, session){
        session$onSessionEnded(function() {
            stopApp()
        })
    })
    
}