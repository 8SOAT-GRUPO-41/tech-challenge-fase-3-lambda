data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_apigatewayv2_api" "api_gateway" {
  api_id = var.api_gateway_id
}

resource "aws_lambda_function" "authorizer" {
  function_name    = "cognito-authorizer"
  role             = data.aws_iam_role.lab_role.arn
  handler          = "src/index.handler"
  runtime          = "nodejs20.x"
  filename         = "lambda_function.zip"
  publish          = true
  source_code_hash = filebase64sha256("lambda_function.zip")

  timeout = 15

  environment {
    variables = {
    }
  }
}

resource "aws_apigatewayv2_authorizer" "lambda_authorizer" {
  name                              = "lambda-authorizer"
  api_id                            = data.aws_apigatewayv2_api.api_gateway.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.authorizer.invoke_arn
  identity_sources                  = ["$request.header.Authorization"]
  authorizer_payload_format_version = "2.0"
}
