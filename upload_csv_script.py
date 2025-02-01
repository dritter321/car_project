import boto3

# Create an S3 client
s3_client = boto3.client('s3')

# Specify the bucket name
bucket_name = 'my-landing-zone-bucket-dritter'

# Specify the file path and the key in S3 bucket
file_path = './resources/sample_input.csv'
s3_key = 'sample_input.csv'

# Upload the file
s3_client.upload_file(file_path, bucket_name, s3_key)
print("File uploaded successfully.")