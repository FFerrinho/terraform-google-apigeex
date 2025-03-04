module "apigee" {
  source = "../../"

  project_id             = "my-project-id"
  vpc_name              = "my-vpc"
  apigee_org_display_name = "My Apigee Organization"
  apigee_org_description  = "Complete example of Apigee X deployment"
  region                  = "europe-west1"
  runtime_type           = "CLOUD"
  apigee_org_billing_type = "CONSUMPTION"
  retention              = "MINIMUM"

  environment_config = {
    "prod-group" = {
      hostnames = ["api.example.com", "api.example.org"]
      environments = {
        "prod" = {
          display_name      = "Production Environment"
          description       = "Production environment for API proxies"
          deployment_type   = "PROXY"
          api_proxy_type    = "PROGRAMMABLE"
          type             = "COMPREHENSIVE"
          forward_proxy_uri = "http://proxy.example.com:3128"
          node_config = {
            min_node_count = 2
            max_node_count = 5
          }
        }
        "staging" = {
          display_name    = "Staging Environment"
          description     = "Staging environment for API proxies"
          deployment_type = "PROXY"
          api_proxy_type  = "PROGRAMMABLE"
          type           = "INTERMEDIATE"
        }
      }
    }
    "dev-group" = {
      hostnames = ["dev-api.example.com"]
      environments = {
        "dev" = {
          display_name    = "Development Environment"
          description     = "Development environment for API proxies"
          deployment_type = "ARCHIVE"
          api_proxy_type  = "CONFIGURABLE"
          type           = "BASE"
        }
      }
    }
  }

  instance_config = {
    "instance-1" = {
      location             = "europe-west1"
      peering_cidr_range   = "10.0.0.0/22"
      ip_range            = "10.0.4.0/22"
      description         = "Production instance"
      display_name        = "Production Instance"
      consumer_accept_list = ["10.0.0.0/8"]
      environment         = "prod"
    }
    "instance-2" = {
      location     = "europe-west1"
      description  = "Development instance"
      display_name = "Development Instance"
      environment  = "dev"
    }
  }
}
