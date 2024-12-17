variable "api_gateway_id" {
  description = "The ID of the API Gateway"
  type        = string
}

variable "eks_nlb_name" {
  description = "Name tag for the EKS Network Load Balancer"
  type        = string
}

variable "vpc_link_id" {
  description = "The ID of the VPC Link"
  type        = string
}
