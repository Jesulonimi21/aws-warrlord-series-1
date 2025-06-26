

variable storage-bucket-prefix{
    description = "storage bucket name"
}

output "s3-backend-tf-config-name" {
  value = aws_s3_bucket.state_storage.id
}
# todo: use kms key to encrypt
resource "aws_s3_bucket" "state_storage" {
  bucket_prefix = var.storage-bucket-prefix
      force_destroy = true
  tags = {
    environment: "war-lord"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_dynamodb_table" "state_lock" {
  name         = "state_lock_table"
  billing_mode = "PROVISIONED"
  hash_key     = "LockID"
  read_capacity  = 1
  write_capacity = 1
  attribute {
    name = "LockID"
    type = "S"
  }
}
