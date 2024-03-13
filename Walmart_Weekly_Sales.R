
library(h2o)
library(tidyverse)
library(shiny)
library(highcharter)
library(tidyverse)
library(timetk)
library(lubridate)
library(tidymodels)
library(inspectdf)
library(modeltime.h2o)
library(rstudioapi)
library(modeltime.ensemble)
library(plotly)
library(DT)
library(shinythemes)
library(glue)


h2o.init()

# pred <- prediction$.pred
# 
# actual <- test %>% as.data.frame() %>% pull(all_of(Weekly_Sales))
# 
# eval_func <- function(x,y) summary(lm(y~x))
# eval_sum <- eval_func(actual,pred)
# 
# Adjusted_R2 <- eval_sum$adj.r.squared
# R_squared <- eval_sum$r.squared



ui <- fluidPage(
  titlePanel('Predict Walmart weekly sales'),
  hr(),
  theme = shinytheme(theme='flatly'),
  br(),
  fileInput('upload',NULL,accept = '.xlsx'),
  br(),
  dataTableOutput('data'),
  hr(),
  br(),
  dataTableOutput('data1'),
  hr(),
  br(),
  dataTableOutput('data2',width = "20%"),
  hr(),
  br(),
  plotlyOutput('plot1',height = '1000px'),
  br(),
  plotlyOutput('plot2',height = '1000px'),
  hr(),
  br()
)

server <- function(input,output,session){
  timetk::walmart_sales_weekly %>% 
    select(id,Date,Weekly_Sales)%>% 
    writexl::write_xlsx('walmart_sales_weekly.xlsx')
  
  data <- timetk::walmart_sales_weekly %>% select(id,Date,Weekly_Sales)
  split <- data %>% 
    time_series_split(assess = "3 month",cumulative = T)
  
  recipe_spec <- recipe(Weekly_Sales~.,training(split)) %>% 
    step_timeseries_signature(Date)
  
  train <- training(split) %>% bake(prep(recipe_spec),.)
  test <- testing(split) %>% bake(prep(recipe_spec),.)
  

  

  
  model_spec_h2o <- automl_reg(mode="regression") %>% 
    set_engine(
      "h2o", max_runtime_secs=20,
      nfolds=5,seed=123,
      verbosity=NULL,max_models=3,
      exclude_algos="GLM",
      max_runtime_secs_per_model=3
    )
  
  model_fit_h2o <- model_spec_h2o %>% 
    fit(Weekly_Sales~.,train)
  prediction <- model_fit_h2o %>% predict(test)
  
  data_prepared <- bind_rows(train,test)
  
  
  future <- data_prepared %>% 
    group_by(id) %>% 
    future_frame(.length_out = "2 year") %>% 
    ungroup()
  
  future_prepared <- recipe_spec %>% prep() %>% bake(future)
  modeltime <- model_fit_h2o %>% modeltime_table()
  refit <- modeltime %>% modeltime_refit(data_prepared)
  
  
  
output$data <- DT::renderDataTable({
  file <- input$upload
  df <- readxl::read_xlsx(file$datapath)
  df
  
},
  class='cell-border stripe',
  rownames=F,editable=T,
  filter=list(position='top',clear=F,pain=F),
  extensions="Buttons",
  options=list(dom='Blfrtip',
               pageLength=10,
               buttons=list(I('colvis'),c("copy","csv","excel","print")))

  )

eval_func <- function(x,y) summary(lm(y~x))
eval_sum <- eval_func(actual,pred)

Adjusted_R2 <- eval_sum$adj.r.squared
R_squared <- eval_sum$r.squared

output$data2 <- renderDataTable({
  results <- cbind(round(Adjusted_R2,2),round(R_squared,2)) %>% 
    as.data.frame() %>% rename(Adjusted_R2=V1,
                               R_squared=V2)
  datatable(results, options = list(dom = 't'))
  
})
  output$plot1 <-  renderPlotly({
    
    pred_test <- modeltime %>% 
      modeltime_calibrate(test) %>% 
      modeltime_forecast(
        new_data = test,
        actual_data=data,
        keep_data=T
      ) %>% 
      group_by(id) %>% 
      plot_modeltime_forecast(
        .title = 'Predicted test result',
        .facet_ncol = 2,
        .interactive = T
      )
    pred_test

  })
  
  output$plot2 <- renderPlotly({
    next_2year <-  refit %>% modeltime_forecast(
      new_data = future_prepared,
      actual_data = data_prepared,
      keep_data=T) %>% 
      group_by(id) %>% 
      plot_modeltime_forecast(
        .title = 'Next 2 year',
        .facet_ncol = 2,
        .interactive = T
      )
    next_2year
  })
  output$data1 <- renderDataTable({
    df <- cbind(test[, c('id', 'Date','Weekly_Sales')],prediction['.pred']) %>% 
      rename(Actual_Sales=Weekly_Sales,
             Predicted_Sales=.pred) %>% as.data.frame()
    df
  })
  
}
shinyApp(ui,server)

