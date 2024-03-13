# Predict Walmart Weekly Sales Shiny App
## Overview
This Shiny app is designed to predict Walmart weekly sales using time series forecasting. It incorporates the modeltime package along with the H2O AutoML algorithm for accurate and efficient regression modeling. Users can upload their own data in an Excel file format (.xlsx) and visualize the results through interactive plots and tables.

## Dependencies
### The app requires several R libraries, including:

- h2o
- tidyverse
- shiny
- highcharter
- timetk
- lubridate
- tidymodels
- inspectdf
- modeltime.h2o
- rstudioapi
- modeltime.ensemble
- plotly
- DT
- shinythemes
- glue
### Make sure to install these libraries before running the app.

## Instructions
1. Run the app by executing the provided R script.
2. Upload an Excel file containing your Walmart weekly sales data. The app expects columns named id, Date, and Weekly_Sales.
3. Explore the uploaded data using the interactive DataTable.
4. Review the calibration and forecast plots to visualize the model's predictions.
5. Examine the results in tabular format, comparing actual and predicted sales for the test data.
6. Analyze performance metrics such as Adjusted R-squared and R-squared in a separate DataTable.
## Code Highlights
- The app begins by initializing the H2O instance using h2o.init() and loads the Walmart sales dataset.
- Data preprocessing involves splitting the dataset into training and testing sets, creating a time series recipe, and preparing the data for model training and evaluation.
- The H2O AutoML model is specified and trained using the automl_reg function.
- The app includes various interactive elements, such as file input, DataTables, and plotly plots, to provide a user-friendly experience.
- The eval_func function calculates and displays key evaluation metrics, including Adjusted R-squared and R-squared.
- The app allows users to visualize both the predicted results for the test data and forecasts for the next two years.
- Feel free to customize the app based on your specific requirements and data characteristics.
