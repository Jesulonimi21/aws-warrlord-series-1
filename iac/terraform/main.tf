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