############################################
# Data Sources
############################################

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_apigatewayv2_api" "api_gateway" {
  api_id = var.api_gateway_id
}

############################################
# NLB and Listener Data Sources for /payments
############################################
data "aws_lb" "payments_nlb" {
  name = var.payments_nlb_name
}

data "aws_lb_listener" "payments_listener" {
  load_balancer_arn = data.aws_lb.payments_nlb.arn
  port              = 80
}

############################################
# NLB and Listener Data Sources for /products
############################################
data "aws_lb" "products_nlb" {
  name = var.products_nlb_name
}

data "aws_lb_listener" "products_listener" {
  load_balancer_arn = data.aws_lb.products_nlb.arn
  port              = 80
}

############################################
# NLB and Listener Data Sources for /customers
############################################

data "aws_lb" "customers_nlb" {
  name = var.customers_nlb_name
}

data "aws_lb_listener" "customers_listener" {
  load_balancer_arn = data.aws_lb.customers_nlb.arn
  port              = 80
}

############################################
# NLB and Listener Data Sources for /orders
############################################

data "aws_lb" "orders_nlb" {
  name = var.orders_nlb_name
}

data "aws_lb_listener" "orders_listener" {
  load_balancer_arn = data.aws_lb.orders_nlb.arn
  port              = 80
}

############################################
# VPC Link Data Source
############################################

data "aws_apigatewayv2_vpc_link" "vpc_link" {
  vpc_link_id = var.vpc_link_id
}

############################################
# Create API Gateway Integration
############################################

resource "aws_apigatewayv2_integration" "payments_integration" {
  api_id             = data.aws_apigatewayv2_api.api_gateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.aws_lb_listener.payments_listener.arn
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_apigatewayv2_vpc_link.vpc_link.id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "customers_integration" {
  api_id             = data.aws_apigatewayv2_api.api_gateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.aws_lb_listener.customers_listener.arn
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_apigatewayv2_vpc_link.vpc_link.id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "products_integration" {
  api_id             = data.aws_apigatewayv2_api.api_gateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.aws_lb_listener.products_listener.arn
  connection_type    = "VPC_LINK"
  connection_id      = data.aws_apigatewayv2_vpc_link.vpc_link.id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "orders_integration" {
  api_id             = data.aws_apigatewayv2_api.api_gateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.aws_lb_listener.orders_listener.arn
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
# resource "aws_apigatewayv2_route" "eks_route_with_auth" {
#   api_id             = data.aws_apigatewayv2_api.api_gateway.id
#   route_key          = "ANY /admin/{proxy+}"
#   target             = "integrations/${aws_apigatewayv2_integration.products_integration.id}"
#   authorization_type = "CUSTOM"
#   authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
# }


############################################
# PRODUCTS ROUTES
############################################
resource "aws_apigatewayv2_route" "products_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /products/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.products_integration.id}"
}

resource "aws_apigatewayv2_route" "products_root_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /products"
  target    = "integrations/${aws_apigatewayv2_integration.products_integration.id}"
}

resource "aws_apigatewayv2_route" "products_docs_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /products-docs"
  target    = "integrations/${aws_apigatewayv2_integration.products_integration.id}"
}

############################################
# CUSTOMERS ROUTES
############################################
resource "aws_apigatewayv2_route" "customers_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /customers/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.customers_integration.id}"
}

resource "aws_apigatewayv2_route" "customers_root_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /customers"
  target    = "integrations/${aws_apigatewayv2_integration.customers_integration.id}"
}

resource "aws_apigatewayv2_route" "customers_docs_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /customers-docs"
  target    = "integrations/${aws_apigatewayv2_integration.customers_integration.id}"
}

############################################
# PAYMENTS ROUTES
############################################
resource "aws_apigatewayv2_route" "payments_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /payments/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.payments_integration.id}"
}

resource "aws_apigatewayv2_route" "payments_root_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /payments"
  target    = "integrations/${aws_apigatewayv2_integration.payments_integration.id}"
}

resource "aws_apigatewayv2_route" "payments_docs_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /payments-docs"
  target    = "integrations/${aws_apigatewayv2_integration.payments_integration.id}"
}

############################################
# ORDERS ROUTES
############################################
resource "aws_apigatewayv2_route" "orders_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /orders/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.orders_integration.id}"
}

resource "aws_apigatewayv2_route" "orders_root_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /orders"
  target    = "integrations/${aws_apigatewayv2_integration.orders_integration.id}"
}

resource "aws_apigatewayv2_route" "orders_docs_route" {
  api_id    = data.aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /orders-docs"
  target    = "integrations/${aws_apigatewayv2_integration.orders_integration.id}"
}