provider "google" {
  project = "my-project-id"
  region  = "europe-west1"
  # Set a custom endpoint for Apigee API data residency if required
  # apigee_custom_endpoint = "https://REGION.apigee.googleapis.com"
}

module "apigee" {
  source = "../"

  project_id              = "my-project-id"
  apigee_org_display_name = "My Apigee Organization"
  apigee_org_description  = "Minimal example of Apigee X deployment"
  region                  = "europe-west1"

  # For CLOUD runtime, specify the VPC network name
  vpc_name     = "default"
  runtime_type = "CLOUD"

  # Using default EVALUATION billing type (free tier)
  # No KMS encryption keys required for EVALUATION

  # Environment configuration
  environment_config = {
    "default-group" = {
      hostnames = ["api.example.com"]
      environments = {
        "dev" = {
          display_name = "Development Environment"
          description  = "Development environment for API proxies"
        }
      }
    }
  }

  # Runtime instance configuration
  instance_config = {
    "instance-1" = {
      location    = "europe-west1"
      environment = "dev"
    }
  }
}
