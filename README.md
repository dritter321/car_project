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
