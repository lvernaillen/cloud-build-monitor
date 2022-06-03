resource "google_cloudbuild_trigger" "app-triggers" {
  provider = google-beta
  name     = "app-trigger-deploy"

  project = var.project

  description = "build and deploy app on cloud run"

  github {
    owner = var.repo_owner
    name  = var.repo_name
    push {
      branch = var.repo_branch_pattern
    }
  }

  included_files = ["packages/app/**"]

  service_account = "projects/${var.project}/serviceAccounts/${"builder@${var.project}.iam.gserviceaccount.com"}"

  build {
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c",
        "gcloud secrets versions access latest --secret=firebase-env | tee ./packages/app/.env"
      ]
    }
    step {
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = [
        "-c",
        join(" ", [
          "docker build",
          "-t ${var.region}-docker.pkg.dev/${var.project}/docker-repository/app:$COMMIT_SHA",
          "-f packages/app/Dockerfile",
          "--build-arg=GITHUB_TOKEN=$$GITHUB_TOKEN",
          "--build-arg=REPO_REGEX=${var.repo_regex}",
          "--build-arg=JIRA_HOST=${var.jira_host}",
          "--build-arg=JIRA_USER=${var.jira_user}",
          "--build-arg=JIRA_PASSWORD=${var.jira_password}",
          "--build-arg=ISSUE_REGEX=${var.issue_regex}",
          " ."
        ]),
      ]
      secret_env = ["GITHUB_TOKEN"]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.region}-docker.pkg.dev/${var.project}/docker-repository/app:$COMMIT_SHA"]
    }
    step {
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "gcloud"
      args = ["run",
        "deploy",
        google_cloud_run_service.app.name,
        "--image",
        "${var.region}-docker.pkg.dev/${var.project}/docker-repository/app:$COMMIT_SHA",
        "--region",
        var.region,
        "--set-env-vars",
        "HOSTNAME=${google_cloud_run_service.app.status[0].url},GCP_PROJECT=${var.project}",
        "--service-account",
        google_service_account.run-service-account.email
      ]
    }
    artifacts {
      images = [
        "${var.region}-docker.pkg.dev/${var.project}/docker-repository/app:$COMMIT_SHA",
      ]
    }

    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/${var.project}/secrets/github-token/versions/latest"
      }
    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    timeout = "900s"
  }
}
