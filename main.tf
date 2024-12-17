############################################
# Data Sources
############################################

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_apigatewayv2_api" "api_gateway" {
  api_id = var.api_gateway_id
}

data "aws_lb" "eks_nlb" {
  name = var.eks_nlb_name
}

data "aws_lb_listener" "eks_listener" {
  load_balancer_arn = data.aws_lb.eks_nlb.arn
  port              = 80
}

data "aws_apigatewayv2_vpc_link" "vpc_link" {
  vpc_link_id = var.vpc_link_id
}

############################################
# Create API Gateway Integration
############################################
resource "aws_apigatewayv2_integration" "eks_integration" {
  api_id             = data.aws_apigatewayv2_api.api_gateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.aws_lb_listener.eks_listener.arn
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_apigatewayv2_vpc_link.vpc_link.id
  integration_method = "ANY"
}

############################################
# Lambda Function
############################################

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
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
    }
  }
}

############################################
# API Gateway Resources
############################################

resource "aws_apigatewayv2_authorizer" "lambda_authorizer" {
  name                              = "lambda-authorizer"
  api_id                            = data.aws_apigatewayv2_api.api_gateway.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.authorizer.invoke_arn
  identity_sources                  = ["$request.header.Authorization"]
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}


############################################
# API Gateway Routes
############################################
resource "aws_apigatewayv2_route" "eks_route_with_auth" {
  api_id             = data.aws_apigatewayv2_api.api_gateway.id
  route_key          = "ANY /admin/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.eks_integration.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

resource "aws_apigatewayv2_route" "docs_proxy_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks_integration.id}"
}
