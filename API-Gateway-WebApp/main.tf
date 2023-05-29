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
                "ses:SendEmail",
                "ses:SendRawEmail"

			],
			"Resource": [
              "*"
            ]
		},
		{
			"Effect": "Allow",
			"Action": [
                "dynamodb:*"
			],
			"Resource": [
              "${aws_dynamodb_table.dynamodb_table.arn}"
            ]
		}
	]
}
EOF
}

resource "aws_dynamodb_table" "dynamodb_table" {
  billing_mode = "PROVISIONED"
  hash_key     = "Year"
  name = "Contact"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "Year"
    type = "N"
  }
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
}

resource "aws_apigatewayv2_api" "apigateway" {
  name          = var.name
  protocol_type =  "HTTP"
  cors_configuration {
    #allow_credentials = true
    # allow_headers     = [ "Content-Type", "X-Amz-Date", "Authorization", "X-Key", "X-Amz-Security-Token" ]
    allow_headers = [ "content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent" ]
    allow_methods = [ "POST", "OPTIONS", "GET" ]
    allow_origins = [ "*" ]
    max_age       = 600

  }
}

resource "aws_apigatewayv2_integration" "mfapi" {
  api_id                 = aws_apigatewayv2_api.apigateway.id
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "apigatewayv2_route" {
  api_id    = aws_apigatewayv2_api.apigateway.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.mfapi.id}"
}

resource "aws_apigatewayv2_stage" "apigatewayv2_stage" {
  name        = "$default"
  api_id      = aws_apigatewayv2_api.apigateway.id
  auto_deploy = true
}
