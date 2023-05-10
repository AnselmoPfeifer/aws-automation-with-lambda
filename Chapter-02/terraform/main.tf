data "archive_file" "file" {
  type        = "zip"
  source_dir  = "../scripts"
  output_path = "../lambda.zip"
}

resource "aws_s3_object" "object" {
  depends_on = [data.archive_file.file]
  bucket = var.lambda_s3_bucket
  key    = "functions/lambda.zip"
  source = data.archive_file.file.output_path
  etag   = filemd5(data.archive_file.file.output_path)
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
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

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda_policy_attachment"
  roles      = [
    aws_iam_role.lambda_role.name
  ]

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  depends_on = [
    aws_s3_object.object,
    data.archive_file.file,
    aws_iam_role.lambda_role
  ]

  function_name    = "example_lambda"
  description = "This is first test with lambda"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  handler          = "hello.lambda_handler"
  timeout          = 60
  memory_size      = 128
  publish          = true

  filename      = "../lambda.zip"
  source_code_hash = data.archive_file.file.output_base64sha256
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
