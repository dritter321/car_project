provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "landing_zone" {
  bucket = "my-landing-zone-bucket-dritter"
  force_destroy = true
}

resource "aws_s3_bucket" "curated_zone" {
  bucket = "my-curated-zone-bucket-dritter"
  force_destroy = true
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

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

resource "aws_lambda_function" "example" {
  function_name    = "MyLambdaFunction"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "python3.8"
  filename         = "${path.module}/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")
  timeout          = 30
}

resource "aws_iam_policy" "lambda_s3_access" {
  name        = "lambda_s3_access_policy"
  description = "IAM policy for accessing S3 buckets in Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::my-landing-zone-bucket-dritter",
          "arn:aws:s3:::my-landing-zone-bucket-dritter/*"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::my-curated-zone-bucket-dritter",
          "arn:aws:s3:::my-curated-zone-bucket-dritter/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_s3_access_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.landing_zone.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.landing_zone.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.example.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.example.function_name}"
  retention_in_days = 14  # Set log retention policy (for example, 14 days).
}

# Assign the appropriate IAM policy to allow Lambda to log to CloudWatch.
resource "aws_iam_role_policy" "lambda_logging_policy" {
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = "logs:CreateLogStream",
        Resource = "${aws_cloudwatch_log_group.lambda_log_group.arn}:*",
        Effect   = "Allow"
      },
      {
        Action   = [
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/${aws_lambda_function.example.function_name}:*",
        Effect   = "Allow"
      }
    ]
  })
}