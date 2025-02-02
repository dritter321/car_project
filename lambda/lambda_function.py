import boto3
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(f"Event: {event}")
    s3 = boto3.client('s3')
    input_bucket = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']
    logger.info(f"FILE KEY: {input_bucket} and {file_key}")
    output_bucket = 'my-curated-zone-bucket-dritter'
    copy_source = {
        'Bucket': input_bucket,
        'Key': file_key
    }
    logger.info(f"VARIABLES: {output_bucket} and {copy_source}")
    try:
        s3.copy(copy_source, output_bucket, file_key)
        logger.info(f'File {file_key} copied from {input_bucket} to {output_bucket}')
    except Exception as e:
        logger.error(f'Failed to copy file {file_key} from {input_bucket} to {output_bucket}. Error: {str(e)}')

    return {
        'statusCode': 200,
        'body': f'File {file_key} successfully copied from {input_bucket} to {output_bucket}'
    }