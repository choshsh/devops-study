resource "aws_s3_bucket" "codebuild_cache" {
  bucket = "codebuild-cache-choshsh"
}

resource "aws_codebuild_project" "choshsh-ui" {
  name               = "choshsh-ui"
  project_visibility = "PRIVATE"
  service_role       = aws_iam_role.codebuild.arn
  source_version     = "dev"

  source {
    buildspec       = "buildspec.yml"
    location        = "https://github.com/choshsh/choshsh-ui.git"
    type            = "GITHUB"
    git_clone_depth = 1
    git_submodules_config {
      fetch_submodules = false
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "choshsh/ubuntu:jdk17-node16"
    image_pull_credentials_type = "SERVICE_ROLE"
    type                        = "LINUX_CONTAINER"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild_cache.bucket
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  depends_on = [
    aws_s3_bucket.codebuild_cache
  ]
}

resource "aws_codebuild_report_group" "choshsh-ui" {
  name = "choshsh-ui-report"
  type = "TEST"

  export_config {
    type = "NO_EXPORT"
  }
}
