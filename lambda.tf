data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-code"
  output_path = "${path.module}/lambda-code.zip"
  excludes = [
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",
  ]
}

resource "aws_lambda_function" "geff_lambda" {
  function_name    = "${var.prefix}_geff"
  role             = aws_iam_role.geff_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  memory_size      = "4096"
  runtime          = "python3.8"
  timeout          = "900"
  publish          = null
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  depends_on = [
    aws_s3_bucket.geff_bucket,
    aws_s3_bucket_object.geff_data_folder,
    aws_s3_bucket_object.geff_meta_folder,
    aws_iam_role_policy_attachment.geff_write_logs
  ]
}

resource "aws_iam_role" "geff_lambda_role" {
  name = "${var.prefix}_geff_lambda"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "geff_write_logs" {
  role       = aws_iam_role.geff_lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_write.arn
}

resource "aws_iam_role_policy_attachment" "geff_decrypt_secrets" {
  role       = aws_iam_role.geff_lambda_role.name
  policy_arn = aws_iam_policy.kms_decrypt.arn
}

resource "aws_iam_policy" "geff_lambda_policy" {
  # 1. read and write to S3 bucket
  # 2. Allow lambda to invoke lambda
  name = "${var.prefix}_geff_lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : "${aws_s3_bucket.geff_bucket.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : aws_lambda_function.geff_lambda.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "geff_lambda_policy_attachment" {
  role       = aws_iam_role.geff_lambda_role.name
  policy_arn = aws_iam_policy.geff_lambda_policy.arn
}

resource "aws_lambda_permission" "api_gateway" {
  function_name = aws_lambda_function.geff_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.ef_to_lambda.execution_arn}/*/*"

  depends_on = [aws_lambda_function.geff_lambda]
}
