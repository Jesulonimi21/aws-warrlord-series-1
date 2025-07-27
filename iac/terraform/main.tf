provider "aws"{
    region = "us-east-1"
}


# terraform{
#   backend "s3" {
#     key = "globals/s3/terraform.tfstate"
#   }
# }


variable "github_connection_json" {
  default = {
    Token = "..."
    AuthType = "..."
    ServerType = "..."
  }

  type = map(string)
}

module s3-static-website{
  source = "./modules/s3-static-website"
  projectName = "frontend-server"
}

# the alternate domain name should be received as a prefix from a var and then concatenated with the primary domain name
locals {
  alternate_domain_name ="react.aroluwa.com"
  primary_domain_name= "aroluwa.com"
}



module s3-tf-backend{
  source = "./modules/s3-tf-backend-config"
  storage-bucket-prefix = "tfbackend"
}

module "acm" {
  source = "./modules/acm"
  alternate_domain_name = local.alternate_domain_name
  
}

module "cloufront-s3-distribution" {
  source = "./modules/cloudfront-s3-distribution"
  s3_json_document = module.s3-static-website.s3jsondocument
  s3_bucket_arn = module.s3-static-website.react_bucket_arn
  s3_bucket_id = module.s3-static-website.react_bucket_id
  s3_domain_name = module.s3-static-website.bucket_regional_domain_name
  alternate_domain_name = local.alternate_domain_name
  acm_certificate_arn=module.acm.certificate_arn
}

module route53-zone {
  source = "./modules/route53"
  primary_domain_name = local.primary_domain_name
  acm_certificate_validation_options = module.acm.domain_validation_options
  other_records = [
    {
      name            = local.alternate_domain_name
      record  = module.cloufront-s3-distribution.cloudfront-distribution-url
      type   = "CNAME"
    }
  ]
}

module secrets-manager {
  source = "./modules/secrets-manager"
  name_prefix = "codebuild_github_secret_10"
  github_connection_json = var.github_connection_json
}

module "codebuild-main-branch" {
  source = "./modules/codebuild"
  s3_bucket_id_for_deployment = module.s3-static-website.react_bucket_id
  s3_bucket_arn_for_deployment = module.s3-static-website.react_bucket_arn
  secretsmanager_arn_for_github_secret = module.secrets-manager.secrets_manager_arn

  
}


# i can create my own script or data source to only create this if it does not yet exist
# resource "aws_route53_zone" "domain_name" {
#   name = local.primary_domain_name
#     lifecycle {
#     prevent_destroy = true
#   }
# }












output "s3-website-url" {
  value = module.s3-static-website.s3_website_endpoint
}
output s3-backend-config-bucket-name{
  value = module.s3-tf-backend.s3-backend-tf-config-name
}

output cloudfront-distribution-url{
  value = module.cloufront-s3-distribution.cloudfront-distribution-url
}
output route53-zone-id{
  value = module.route53-zone.route53-zone-id
}
// create the route 53 hosted zone first
// i want to create the certificate for acm next
// Create the records for the certificate validation in route53 records
// wait for step 3 until it is successful, then continue with the rest

//if the hoseted zone already exists, dont create it
// if there is already a certidicate to use, dont create it or add anything to the hosted zone


//CODEBUILD CREATION TODOS
//CHOOSE TYPE OF CODEBUILD INTEGRARTION
//STORE GITHUB CONNECTION IN SECRET MANAGER
// specify secret manager location
//Specify primary source webhook event/
//Specify buildspec path
//Specify cloudwatch log group for logs (optional)
//LOOK at the second answer here: https://stackoverflow.com/questions/57066101/how-do-you-specify-github-access-token-with-codebuild-from-cloudformation 
// make sure it triggers everytime code changes build is created
//configure a cloudwatch log group for codebuild


//lock thuis fo









