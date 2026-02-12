# Variables for Frontend Terraform Configuration

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name (used for resource naming)"
  type        = string
  default     = "user-registration"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Custom domain name for the frontend (e.g., app.example.com). Leave empty to use CloudFront domain"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for custom domain (must be in us-east-1 for CloudFront)"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for DNS record creation"
  type        = string
  default     = ""
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"  # US, Canada, Europe
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
