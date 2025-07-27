
variable "s3_bucket_arn_for_deployment" {
  description = "The ARN of the S3 bucket we want codebuild to deploy its build output to"
  type        = string
}

variable "secretsmanager_arn_for_github_secret" {
  description = "The ARN of the Secrets Manager secret containing GitHub credentials for CodeBuild"
  type        = string
}   

variable "github_repo_url" {
  description = "The URL of the GitHub repository to be used by CodeBuild"
  type        = string
  default = "https://github.com/Jesulonimi21/aws-warrlord-series-1"
}

variable "s3_bucket_id_for_deployment" {
  description = "The ID of the S3 bucket we want codebuild to deploy its build output to"
  type        = string
  
}



data "aws_iam_policy_document" "frontend_production_codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  # condition {
  #   test     = "ArnEquals"
  #   variable = "aws:arn"
  #   values   = [aws_codebuild_project.frontend_production_codebuild.arn] # replace with your AWS account ID
  # }
  }
}

resource "aws_iam_role" "frontend_production_codebuild_role" {
  name               = "frontend_production_codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.frontend_production_codebuild_assume_role.json
}

data "aws_iam_policy_document" "frontend_production_codebuild_policy_document" {
    statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      var.s3_bucket_arn_for_deployment,
      "${var.s3_bucket_arn_for_deployment}/*"
    ]
  }

    statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.secretsmanager_arn_for_github_secret]
  }

}
resource "aws_iam_role_policy" "codebuild_policy" {
  role   = aws_iam_role.frontend_production_codebuild_role.name
  policy = data.aws_iam_policy_document.frontend_production_codebuild_policy_document.json
}


resource "time_sleep" "wait_for_iam_propagation" {

  create_duration = "45s"


  depends_on = [ aws_iam_role_policy.codebuild_policy]
}


resource "aws_codebuild_project" "frontend_production_codebuild" {

  depends_on = [
    aws_iam_role_policy.codebuild_policy
  ]
  name           = "frontend_production_codebuild"
  description    = "CodeBuild project for building the frontend application"
  build_timeout  = 5
  queued_timeout = 5
  
    service_role = aws_iam_role.frontend_production_codebuild_role.arn
  
   environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

   source {
    buildspec = "buildspec.yml"
    auth {
      type = "SECRETS_MANAGER"
      resource = var.secretsmanager_arn_for_github_secret
    }
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  artifacts {
    type = "S3"
    location = var.s3_bucket_id_for_deployment
    namespace_type = "NONE"
    packaging       = "NONE"         
    path            = ""        
    name            = "." 
     encryption_disabled = true         
  }

# Change log group name
  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild-frontend-production-logs"
      stream_name = "codebuild-frontend-production-logs-stream"
    }
  }
}

  resource "aws_codebuild_webhook" "frontend_codebuild_webhook" {
  project_name = aws_codebuild_project.frontend_production_codebuild.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
  }

 depends_on = [time_sleep.wait_for_iam_propagation]
}