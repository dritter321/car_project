import os
import boto3
import logging
from io import StringIO
import pandas as pd
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(f"Event: {event}")
    s3 = boto3.client('s3')
    input_bucket = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']
    logger.info(f"FILE KEY: {input_bucket} and {file_key}")
    output_bucket = os.environ['OUTPUT_BUCKET']
    copy_source = {
        'Bucket': input_bucket,
        'Key': file_key
    }
    logger.info(f"VARIABLES: {output_bucket} and {copy_source}")

    try:
        # Read the CSV file
        csv_obj = s3.get_object(Bucket=input_bucket, Key=file_key)
        body = csv_obj['Body'].read().decode('utf-8')
        data = pd.read_csv(StringIO(body))
        logger.info("CSV has been read into DataFrame.")

        # Data manipulation with pandas
        # Example: Add a new column
        data = data.drop(columns=['car_ID', 'saledate', 'ownername', 'owneremail', 'dealershipaddress', 'iban'])
        logger.info("Dropped features unrequired")
        data.dropna(subset=['CarName'], inplace=True)
        data.dropna(subset=['Price'], inplace=True)
        logger.info("Dropped rows with no CarName or Price")

        categorical_columns = data.select_dtypes(include='object').columns
        for column in categorical_columns:
            mode_value = data[column].mode()[0]
            data[column].fillna(mode_value, inplace=True)
        logger.info("Imputed missing categorical values in rows with most common item")

        numerical_columns = data.select_dtypes(include=['int64', 'float64']).columns
        for column in numerical_columns:
            mean_value = data[column].mean()
            data[column].fillna(mean_value, inplace=True)
        logger.info("Imputed missing numerical values in rows with most common item")

        output_file_key = 'manipulated_' + file_key
        output = StringIO()
        data.to_csv(output, index=False)
        s3.put_object(Bucket=output_bucket, Key=output_file_key, Body=output.getvalue())
        logger.info(f'File {output_file_key} has been written back to {output_bucket}.')

    except Exception as e:
        logger.error(f'Failed to process file {file_key}. Error: {str(e)}')
        return {
            'statusCode': 500,
            'body': f'Failed to process file {file_key}. Error: {str(e)}'
        }


    return {
        'statusCode': 200,
        'body': f'File {file_key} successfully copied from {input_bucket} to {output_bucket}'
    }