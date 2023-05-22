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
  bucket  = "aws-lambda-labs-${random_string.random.result}"
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
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:DeleteSnapshot",
                "ec2:Describe*",
                "ec2:ModifySnapshotAttribute",
                "ec2:ResetSnapshotAttribute"
			],
			"Resource": "*"
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
    data.archive_file.file,
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
      FLOWLOGS_GROUP_NAME = var.name
      ROLE_ARN = aws_cloudwatch_event_rule.cloudwatch_event_rule.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name = "Daily"
  description = "Run every day"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "event_target" {
  arn  = aws_lambda_function.this.arn
  rule = aws_cloudwatch_event_rule.event_rule.name
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.event_rule.arn
}

resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name = var.name
  description = "Rule about ${var.name}"
  event_pattern = jsonencode(
    {
      detail = {
        eventName   = [ "CreateVpc" ]
        eventSource = [  "ec2.amazonaws.com" ]
      }
      detail-type = [
        "AWS API Call via CloudTrail"
      ]
      source = [
        "aws.ec2"
      ]
    }
  )
  tags = {
    "Name" = var.name
  }
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  arn  = aws_lambda_function.this.arn
  rule = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
}
