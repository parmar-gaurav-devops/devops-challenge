resource "aws_codepipeline" "ruby_pipeline" {
  name     = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codebuild_role.arn

  artifact_store {
    location = "489337450339-terraform-states"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "AppSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn        = data.aws_codestarconnections_connection.vcs.arn
        FullRepositoryId     = var.github_repo_name
        BranchName           = var.branch_name
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
      run_order = "1"
    }

  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.ruby_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version          = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName        = aws_ecs_cluster.ruby_cluster.name
        ServiceName        = aws_ecs_service.ruby_service.name
        FileName           = "imagedefinitions.json"
      }
    }
  }
}
