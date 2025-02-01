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

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "my-lambda-bucket-dritter"
  force_destroy = true
}

