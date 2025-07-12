//allow private s3 bucket access to cloudfront during creation, what it takes to configure WAD
//.cloudfront.net. makesure to template this
// set the default root object
//might need to set the behavior
//sign request value of always
//When you use CloudFront OAC with Amazon S3 bucket origins, you must set Amazon S3 Object Ownership to Bucket
//configure a path of / for any error 403 and 404
//read on ordered_cache_behavior 
//read on caching in cloudfrontin general, ordered cache,...

output cloudfront-distribution-url{
  value = aws_cloudfront_distribution.react_website_distribution.domain_name
}

variable "s3_json_document" {
  type = string
  description = "the json document for the s3 bucket resourrce policy"
}
variable "s3_bucket_arn" {
  type = string
  description = "the arn of the s3 bucket"
}

variable "s3_bucket_id" {
  type = string
  description = "the id of the s3 bucket"       
}

variable "s3_domain_name" {
  type = string
  description = "the domain name of the s3 bucket"      
}
variable "alternate_domain_name"{
    type = string
    description = "the alternate domain name for the cloudfront distribution, this is optional and can be used to set a custom domain name for the cloudfront distribution"
    default = null
}
variable "acm_certificate_arn"{
    type = string
    description = "value of the ACM certificate ARN, this is optional and can be used to set a custom domain name for the cloudfront distribution"
    default = null

}

resource "aws_cloudfront_origin_access_control" "react_bucket_acesss_control" {
  name                              = "react-bucket-cloudfront-access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = "react_bucket"
}

resource "aws_cloudfront_distribution" "react_website_distribution" {
    aliases = var.alternate_domain_name == null ? []: [var.alternate_domain_name]
     enabled             = true
    default_root_object = "index.html"
     price_class = "PriceClass_100"
  origin{
    domain_name = var.s3_domain_name
    origin_id = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.react_bucket_acesss_control.id
  }
   default_cache_behavior {
    allowed_methods  = ["HEAD","GET",]
    cached_methods   = ["HEAD","GET",]
    target_origin_id =  local.s3_origin_id
    #caching optimized policy
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = var.acm_certificate_arn == null ?  "allow-all": "redirect-to-https"

  }

#todo: use condtitions for this, this should be optional or just use cloudfront default certificate
    viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null ? true : false
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method = "sni-only"
  }
    restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB",]
    }
  }

  custom_error_response {
    error_code = 403
    response_code = 200
    response_page_path = "/"
  }
}


 data "aws_iam_policy_document" "react_bucket_cloudfront_s3_access_document" {
  source_policy_documents = [var.s3_json_document]
    statement {
      effect = "Allow"
      actions = ["s3:GetObject"]
      resources = ["${var.s3_bucket_arn}/*"]
      principals {
        type = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }
      condition {
        test = "StringEquals"
        variable = "AWS:SourceArn"
        values = [aws_cloudfront_distribution.react_website_distribution.arn]
      }
    }

}

resource "aws_s3_bucket_policy" "cloudfront_bucket_policy_attachment"{
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.react_bucket_cloudfront_s3_access_document.json
}
