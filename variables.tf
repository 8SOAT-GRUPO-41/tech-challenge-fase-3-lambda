variable "api_gateway_id" {
  description = "The ID of the API Gateway"
  type        = string
}

variable "payments_nlb_name" {
  description = "Name tag for the EKS Network Load Balancer (NLB) for /payments"
  type        = string
}

variable "customers_nlb_name" {
  description = "Name tag for the EKS Network Load Balancer (NLB) for /customers"
  type        = string
}

variable "products_nlb_name" {
  description = "Name tag for the EKS Network Load Balancer (NLB) for /products"
  type        = string
}

variable "vpc_link_id" {
  description = "The ID of the VPC Link"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  type        = string
}
