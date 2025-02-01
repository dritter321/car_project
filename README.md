# AI&ML service line
Objective: estimating potential selling price of second-hand cars
Pipeline:
- endpoint available to upload .csv files containing cars for sale
- AWS S3 bucket to store data in raw format (landing zone)
- AWS S3 bucket to store data in processed format (curated zone)
- Lambda function triggered by new data received in landing zone
  - The `environment` variable passes the curated bucket name to the Lambda function.1
- S3 Event trigger of new data received triggering Lambda function
- IAM Role and Policy
  - Lambda function's permission to read landing bucket, and to write to curated bucket
  - Policy that allows logging to CloudWatch
  - S3 permission to invoke Lambda function

# Exploratory Data Analysis
- EDA, data cleansing, data imputing, and creation of curated data for local testing is done in `/notebooks/EDA.ipynb`

# Model Experimenting
- an XGBoost and a Random Forest Regressor models were trained for experimenting
- RFR contains programmatic hyperparameter tuning, XGBoost was tuned manually
- XGBoost won the comparision

RFR:
- RMSE: 1952.71835603326
- R^2: 0.9597850155288421

XGB:
- RMSE: 1912.0344674779114
- R^2: 0.9614432764528569