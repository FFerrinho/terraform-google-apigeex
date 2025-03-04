module "apigee" {
  source = "../../"

  project_id              = "my-project-id"
  apigee_org_display_name = "My Apigee Organization"
  apigee_org_description  = "Minimal example of Apigee X deployment"
  region                  = "europe-west1"

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

  instance_config = {
    "instance-1" = {
      location    = "europe-west1"
      environment = "dev"
    }
  }
}
