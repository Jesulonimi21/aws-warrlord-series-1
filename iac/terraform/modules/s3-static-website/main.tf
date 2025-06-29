variable projectName{
    description = "the name of the project or cluster"
}


resource "aws_s3_bucket" react_bucket{
    bucket_prefix=  var.projectName
    force_destroy = true
    tags = {
        environment: "war-lord"
    }
}
resource "aws_s3_bucket_public_access_block" "react_bucket_public_access_block" {
  bucket = aws_s3_bucket.react_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" react_site_config{
    bucket = aws_s3_bucket.react_bucket.id
    index_document {
      suffix= "index.html"
    }
    error_document {
      key = "index.html"
    }
}

output "s3_website_endpoint"{
    value = aws_s3_bucket_website_configuration.react_site_config.website_endpoint
}
output "bucket_regional_domain_name"{
  value = aws_s3_bucket.react_bucket.bucket_regional_domain_name
}
output "react_bucket_id"{
  value =  aws_s3_bucket.react_bucket.id
}
output "react_bucket_arn"{
  value = aws_s3_bucket.react_bucket.arn
}
output "s3jsondocument"{
  value = data.aws_iam_policy_document.react_bucket_public_policy_document.json
}

data "aws_iam_policy_document" react_bucket_public_policy_document{
  source_policy_documents = [data.aws_iam_policy_document.static-hosting-access-document.json]
}

data "aws_iam_policy_document" "static-hosting-access-document"{
      statement{
        actions = ["s3:GetObject"]
        effect = "Allow"
        resources = [aws_s3_bucket.react_bucket.arn,  "${aws_s3_bucket.react_bucket.arn}/*",]
        principals{
            type = "*"
            identifiers = ["*"]
        }
    }
}


resource "aws_s3_bucket_policy" "aws_bucket_policy_attachment"{
    bucket = aws_s3_bucket.react_bucket.id
    policy = data.aws_iam_policy_document.react_bucket_public_policy_document.json
}

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "/Users/jesulonimiakingbesote/aws-warlord/series-1/client/build/"
}
resource "aws_s3_object" "object" {

   for_each = module.template_files.files
     bucket = aws_s3_bucket.react_bucket.id
  key          = each.key
  content_type = each.value.content_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.source_path
  content = each.value.content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.

  etag = each.value.digests.md5


}



