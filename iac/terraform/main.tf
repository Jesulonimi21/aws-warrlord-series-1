provider "aws"{
    region = "us-east-1"
}


# terraform{
#   backend "s3" {
#     key = "globals/s3/terraform.tfstate"
#   }
# }

module s3-static-website{
  source = "./modules/s3-static-website"
  projectName = "frontend-server"
}


module s3-tf-backend{
  source = "./modules/s3-tf-backend-config"
  storage-bucket-prefix = "tfbackend"
  
}


output "s3-website-url" {
  value = module.s3-static-website.s3_website_endpoint
}
output s3-backend-config-bucket-name{
  value = module.s3-tf-backend.s3-backend-tf-config-name
}


//todo: move cloudfront to its own module

output cloudfront-distribution-url{
  value = aws_cloudfront_distribution.react_website_distribution.domain_name
}

 

//allow private s3 bucket access to cloudfront during creation, what it takes to configure WAD
//.cloudfront.net. makesure to template this
// set the default root object
//might need to set the behavior
//sign request value of always
//When you use CloudFront OAC with Amazon S3 bucket origins, you must set Amazon S3 Object Ownership to Bucket
//configure a path of / for any error 403 and 404


resource "aws_cloudfront_origin_access_control" "react_bucket_acesss_control" {
  name                              = "react-bucket-cloudfront-access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


locals {
  s3_origin_id = "react_bucket"
}


//read on ordered_cache_behavior 
//read on caching in cloudfrontin general, ordered cache,...

resource "aws_cloudfront_distribution" "react_website_distribution" {
     enabled             = true
    default_root_object = "index.html"
     price_class = "PriceClass_100"
  origin{
    domain_name = module.s3-static-website.bucket_regional_domain_name
    origin_id = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.react_bucket_acesss_control.id
  }
   default_cache_behavior {
    allowed_methods  = ["HEAD","GET",]
    cached_methods   = ["HEAD","GET",]
    target_origin_id = local.s3_origin_id
    #caching optimized policy
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "allow-all"

  }

    viewer_certificate {
    cloudfront_default_certificate = true
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
  source_policy_documents = [module.s3-static-website.s3jsondocument]
    statement {
      effect = "Allow"
      actions = ["s3:GetObject"]
      resources = ["${module.s3-static-website.react_bucket_arn}/*"]
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
  bucket = module.s3-static-website.react_bucket_id
  policy = data.aws_iam_policy_document.react_bucket_cloudfront_s3_access_document.json
}