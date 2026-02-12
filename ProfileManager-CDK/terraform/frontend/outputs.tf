# Outputs for Frontend Terraform Configuration

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend"
  value       = aws_s3_bucket.frontend.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_url" {
  description = "Full HTTPS URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "website_url" {
  description = "URL to access the website"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront hosted zone ID (for Route53 alias records)"
  value       = aws_cloudfront_distribution.frontend.hosted_zone_id
}
