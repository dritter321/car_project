provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "landing_zone" {
  bucket = var.buckets["landing_zone"]
  force_destroy = true
}

resource "aws_s3_bucket" "curated_zone" {
  bucket = var.buckets["curated_zone"]
  force_destroy = true
}

resource "aws_iam_role" "lambda_exec_role" {
  name = var.lambda_role_name

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

resource "aws_lambda_function" "dataproc_lambda" {
  function_name    = var.lambda_function_name
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "python3.11"
  filename         = "${path.module}/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")
  timeout          = var.lambda_timeout
  environment {
    variables = {
      OUTPUT_BUCKET = var.buckets["curated_zone"]
    }
  }
  layers = [aws_lambda_layer_version.pandas_layer.arn]
}

resource "aws_iam_policy" "lambda_s3_access" {
  name        = var.lambda_policy_name
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
          aws_s3_bucket.landing_zone.arn,
          "${aws_s3_bucket.landing_zone.arn}/*"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.curated_zone.arn,
          "${aws_s3_bucket.curated_zone.arn}/*"
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
  function_name = aws_lambda_function.dataproc_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.landing_zone.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.landing_zone.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.dataproc_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.dataproc_lambda.function_name}"
  retention_in_days = var.cloudwatch_log_retention_days
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
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/${aws_lambda_function.dataproc_lambda.function_name}:*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_lambda_layer_version" "pandas_layer" {
  layer_name = "pandas_layer"
  compatible_runtimes = ["python3.11"]
  filename = "${path.module}/lambda/pandas_layer.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/pandas_layer.zip")
}