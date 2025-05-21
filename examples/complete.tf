provider "google" {
  project = "my-project-id"
  region  = "europe-west1"
  # Custom endpoint for Apigee API data residency if required
  # See: https://cloud.google.com/apigee/docs/api-platform/get-started/api-control-plane-jurisdiction
  apigee_custom_endpoint = "https://REGION.apigee.googleapis.com"
}

module "apigee" {
  source = "../"

  project_id              = "my-project-id"
  vpc_name                = "my-vpc"
  apigee_org_display_name = "My Apigee Organization"
  apigee_org_description  = "Complete example of Apigee X deployment"
  region                  = "europe-west1"
  runtime_type            = "CLOUD"
  apigee_org_billing_type = "EVALUATION"
  retention               = "MINIMUM"

  # KMS Configuration for CMEK (Customer-Managed Encryption Keys)
  # Required for non-EVALUATION billing types to encrypt data
  kms_key_ring_name     = "apigee-keyring"
  kms_key_ring_location = "europe-west1" # Should match the Apigee region

  # KMS Crypto Key for API Consumer Data encryption
  kms_crypto_key_api_consumer_data = {
    "apigee-consumer-key" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s" # 90 days
      labels = {
        env        = "prod"
        created_by = "terraform"
        purpose    = "apigee-consumer-data"
      }
      prevent_destroy = true
    }
  }

  # KMS Crypto Key for Control Plane encryption
  kms_crypto_key_control_plane = {
    "apigee-control-key" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s" # 90 days
      labels = {
        env        = "prod"
        created_by = "terraform"
        purpose    = "apigee-control-plane"
      }
      prevent_destroy = true
    }
  }

  # KMS Crypto Key for Runtime Database encryption
  kms_crypto_key_runtime_database = {
    "apigee-db-key" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s" # 90 days
      labels = {
        env        = "prod"
        created_by = "terraform"
        purpose    = "apigee-runtime-db"
      }
      prevent_destroy = true
    }
  }

  # Environment configuration
  environment_config = {
    "prod-group" = {
      hostnames = ["api.example.com", "api.example.org"]
      environments = {
        "prod" = {
          display_name      = "Production Environment"
          description       = "Production environment for API proxies"
          deployment_type   = "PROXY"
          api_proxy_type    = "PROGRAMMABLE"
          type              = "COMPREHENSIVE"
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
          type            = "INTERMEDIATE"
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
          type            = "BASE"
        }
      }
    }
  }

  # Environment IAM bindings
  environment_iam = {
    "prod" = {
      role    = ["roles/apigee.environmentAdmin"]
      members = ["user:admin@example.com", "group:apigee-admins@example.com"]
    }
    "dev" = {
      role    = ["roles/apigee.developer", "roles/apigee.analyticsViewer"]
      members = ["group:developers@example.com"]
    }
  }

  # Runtime instance configuration
  instance_config = {
    "instance-1" = {
      location             = "europe-west1"
      peering_cidr_range   = "10.0.0.0/22"
      ip_range             = "10.0.4.0/22"
      description          = "Production instance"
      display_name         = "Production Instance"
      consumer_accept_list = ["10.0.0.0/8"]
      environments         = ["prod"]
    }
    "instance-2" = {
      location     = "europe-west1"
      description  = "Development instance"
      display_name = "Development Instance"
      environments = ["dev"]
    }
  }
}
