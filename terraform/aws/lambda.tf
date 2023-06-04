locals {
  lambda_function_name = "${local.name}-application-lambda"
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/../../backend/bundle"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = local.lambda_function_name
  role             = aws_iam_role.application_lambda.arn
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs16.x"

  vpc_config {
    subnet_ids         = aws_subnet.application[*].id
    security_group_ids = [aws_security_group.application_lambda.id]
  }

  depends_on = [aws_cloudwatch_log_group.application_lambda, aws_iam_role_policy_attachment.application_lambda]
}

# Security group
resource "aws_security_group" "application_lambda" {
  name        = "${local.name}-application-lambda-sg"
  vpc_id      = aws_vpc.this.id
}

# ALB invocation permission
resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.application_alb.arn
}

# IAM
data "aws_iam_policy_document" "application_lambda_trust" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "application_lambda_permission" {
  statement {
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.application_lambda.arn}:*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "application_lambda" {
  name   = "${local.name}-application-lambda-policy"
  policy = data.aws_iam_policy_document.application_lambda_permission.json
}

resource "aws_iam_role" "application_lambda" {
  name               = "${local.name}-application-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.application_lambda_trust.json
}

resource "aws_iam_role_policy_attachment" "application_lambda" {
  policy_arn = aws_iam_policy.application_lambda.arn
  role       = aws_iam_role.application_lambda.name
}

# CloudWatch
resource "aws_cloudwatch_log_group" "application_lambda" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 3
}