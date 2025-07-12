


variable "primary_domain_name" {
  type        = string
  description = "The primary domain name for the Route53 zone"
}

variable acm_certificate_validation_options{
    type = list(object({
        domain_name            = string
        resource_record_name   = string
        resource_record_value  = string
        resource_record_type   = string
    }))
    description = "List of ACM certificate validation options for the domain"
    default = []
}

variable other_records {
    type = list(object({
        name   = string
        type   = string
        record = string
    }))
    description = "List of other Route53 records to create"
    default = []
}

variable "frontend_domain_name_prefix" {
    type        = string
    description = "The prefix for the frontend domain name, e.g., 'react' for 'react.example.com'"
    default     = "react"
}
output "route53-zone-id" {
    value = data.aws_route53_zone.primary_domain_name.zone_id

}

data aws_route53_zone primary_domain_name{
  name         = var.primary_domain_name
  private_zone = false
}
locals{
  joined_domain_name = "${var.frontend_domain_name_prefix}.${data.aws_route53_zone.primary_domain_name.name}"
}


#this could be other cname records
resource "aws_route53_record" "react_record" {
  count = length(var.other_records)

  allow_overwrite = true
  name            =var.other_records[count.index].name
  records         = [var.other_records[count.index].record]
  ttl             = 60
  type            = var.other_records[count.index].type
  zone_id         = data.aws_route53_zone.primary_domain_name.zone_id

}

resource "aws_route53_record" "site_certificate_validation" {
  for_each = {
    for dvo in var.acm_certificate_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary_domain_name.zone_id
}