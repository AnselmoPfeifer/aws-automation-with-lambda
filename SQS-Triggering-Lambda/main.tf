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
                "dynamodb:PutItem"
			],
			"Resource": [
              "${aws_dynamodb_table.dynamodb_table.arn}"
            ]
		},
        {
			"Effect": "Allow",
			"Action": [
              "sqs:Describe*",
              "sqs:Get*",
              "sqs:List*",
              "sqs:DeleteMessage",
              "sqs:ReceiveMessage"
			],
			"Resource": [
              "${aws_sqs_queue.sqs_queue.arn}"
            ]
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

resource "aws_dynamodb_table" "dynamodb_table" {
  billing_mode = "PROVISIONED"
  hash_key     = "MessageId"
  name = "Message"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "MessageId"
    type = "S"
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "Messages"
  fifo_queue = false
  # Similar to aws_lambda_function > timeout
  visibility_timeout_seconds = 60
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
      QUEUE_NAME = aws_sqs_queue.sqs_queue.name
      DYNAMODB_TABLE = aws_dynamodb_table.dynamodb_table.name
      MAX_QUEUE_MESSAGES = 10
    }
  }
}

resource "aws_lambda_event_source_mapping" "source_mapping" {
  function_name = aws_lambda_function.this.arn
  enabled = true
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  batch_size = 10
}
