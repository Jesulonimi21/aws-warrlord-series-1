
variable "name_prefix"{
    default = "codebuild_github_secret_10"
    type = string
}
output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.codebuild_github_secret.arn
}


resource "aws_secretsmanager_secret" "codebuild_github_secret" {
  name_prefix = var.name_prefix
}

# The map here can come from other supported configurations
# like locals, resource attribute, map() built-in, etc.
variable "github_connection_json" {
  default = {
    Token = "..."
    AuthType = "..."
    ServerType = "..."
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "codebuild_github_secret_version" {
  secret_id     = aws_secretsmanager_secret.codebuild_github_secret.id
  secret_string = jsonencode(var.github_connection_json)
}


