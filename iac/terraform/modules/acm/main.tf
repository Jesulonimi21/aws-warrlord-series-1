
output "domain_validation_options" {
  value = aws_acm_certificate.react_bucket_certificate.domain_validation_options
}

output "certificate_arn" {
  value = aws_acm_certificate.react_bucket_certificate.arn
}   

variable "alternate_domain_name" {
  type        = string
  description = "The primary domain name for the Route53 zone"
}


resource "aws_acm_certificate" "react_bucket_certificate" {
  # count = 1
  domain_name       = var.alternate_domain_name
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}