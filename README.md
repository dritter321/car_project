# AI&ML service line
Objective: estimating potential selling price of second-hand cars
Pipeline:
- .csv files can be uploaded via AWS Management Console or Python script
- AWS S3 bucket to store data in raw format (landing zone)
- AWS S3 bucket to store data in processed format (curated zone)
- Lambda function triggered by new data received in landing zone
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
- XGBoost won the comparison

RFR:
- RMSE: 1952.71835603326
- R^2: 0.9597850155288421

XGB:
- RMSE: 1912.0344674779114
- R^2: 0.9614432764528569

# Terraform process
1. Execute `./build.sh` to build and deploy the app.
  - In case the Permission denied, execute `chmod +x build.sh`
  - For `aws configure` - create IAM user with appropriate permission then generate Access Key and Secret Access Key.
  - In case, Terraform not installed (mac): brew tap hashicorp/tap && brew install hashicorp/tap/terraform
  - In case, you want modify name of any resources, access `variables.tf`
2. You have two options to upload the csv file to the landing bucket and trigger function
  - aws s3 cp file.csv s3://your-bucket-name/
  - using the upload_csv_script.py

# Development Support:
- In case you modify dependency layer, use `./lambda/layer_generation.py` (pandas_layer.zip) to recreate it


## Task Time Log

| Task ID | Description            | Date       | Time Spent (hrs) |
|---------|------------------------|------------|------------------|
| 1       | EDA                    | 2025-02-01 | 1                |
| 2       | Model Experiments      | 2025-02-02 | 2                |
| 3       | Terraform & AWS Lambda | 2021-02-03 | 4                |

## Further development options

- Target bucket could store a parquet file with versioning inputs (currently you need to upload all data in one file)
- ML Model could have its own deployment with own endpoint
- Creating unique file name in landing and curated buckets for any uploads
- Verifying schema of input csv