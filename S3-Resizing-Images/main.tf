data "archive_file" "file" {
  type        = "zip"
  source_dir  = "scripts"
  output_path = "lambda.zip"
}

resource "random_string" "random" {
  length    = 4
  special = false
  upper = false
  lower = true
  override_special = "/@£$"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket  = "aws-lambda-${random_string.random.result}"
}

resource "aws_s3_object" "object" {
  depends_on = [
    data.archive_file.file,
    aws_s3_bucket.s3_bucket
  ]
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "functions/lambda.zip"
  source = data.archive_file.file.output_path
  etag   = filemd5(data.archive_file.file.output_path)
}

resource "aws_s3_bucket" "s3_bucket_source" {
  bucket  = "images-${random_string.random.result}"
}

resource "aws_s3_bucket" "s3_bucket_target" {
  bucket  = "thumbnail-${random_string.random.result}"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy" {
  name = "lambda-policy-${var.name}"
  path = "/"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogStream",
				"logs:CreateLogGroup",
				"logs:PutLogEvents"
			],
			"Resource": "arn:aws:logs:*:*:*"
		},
		{
			"Effect": "Allow",
			"Action": [
                "s3:GetObject"
			],
			"Resource": "${aws_s3_bucket.s3_bucket_source.arn}/*"
		},
		{
			"Effect": "Allow",
			"Action": [
                "s3:PutObject"
			],
			"Resource": "${aws_s3_bucket.s3_bucket_target.arn}/*"
		}
	]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment-${var.name}"
  roles      = [
    aws_iam_role.lambda_role.name
  ]

  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_lambda_function" "this" {
  depends_on = [
    aws_s3_object.object,
    aws_iam_role.lambda_role
  ]

  function_name    = var.name
  description      = "Function lambda related to ${var.name}"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  handler          = "run.lambda_handler"
  timeout          = 60
  memory_size      = 128
  publish          = true

  filename      = "lambda.zip"
  source_code_hash = data.archive_file.file.output_base64sha256
  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.s3_bucket_target.id
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  depends_on = [ aws_lambda_function.this ]
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.s3_bucket_source.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_bucket_source.id

  lambda_function {
    events = [ "s3:ObjectCreated:Put" ]
    lambda_function_arn = aws_lambda_function.this.arn
  }
}
