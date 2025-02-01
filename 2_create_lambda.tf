provider "aws" {
  region = "eu-west-2"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.landing_zone.arn}/*"
      },
    ]
  })
}

resource "aws_lambda_function" "s3_trigger_lambda" {
  function_name = "S3TriggerLambdaFunction"

  s3_bucket = "my-lambda-bucket-dritter"
  s3_key    = "lambda_function.zip"

  handler = "index.handler"
  runtime = "python3.8"

  role = aws_iam_role.lambda_execution_role.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.landing_zone.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.landing_zone.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "path/to/objects/"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}