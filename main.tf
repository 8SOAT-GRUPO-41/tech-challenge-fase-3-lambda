data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_lambda_function" "authorizer" {
  function_name = "cognito-authorizer"
  role          = data.aws_iam_role.lab_role.arn
  handler       = "src/index.handler"
  runtime       = "nodejs20.x"
  filename      = "lambda.zip"
  publish       = true

  environment {
    variables = {
      USER_POOL_ID = "us-east-1_examplePoolId"
      REGION       = "us-east-1"
    }
  }
}

