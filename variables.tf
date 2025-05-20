variable "project_id" {
  description = "The Google Cloud project ID where Apigee X resources will be created."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC network to use for Apigee X. Required when runtime_type is 'CLOUD'. Must be an existing VPC network."
  type        = string
  default     = null
}

variable "apigee_org_display_name" {
  description = "Human-readable name for the Apigee organization. Used in the Google Cloud Console and Apigee UI."
  type        = string
}

variable "apigee_org_description" {
  description = "Detailed description of the Apigee organization's purpose or scope."
  type        = string
}

variable "region" {
  description = "Google Cloud region where Apigee analytics data and runtime instances will be hosted. Cannot be changed after creation."
  type        = string
}

variable "runtime_type" {
  description = <<EOT
Type of Apigee runtime to deploy:
- CLOUD: Fully managed Apigee X runtime (recommended)
- HYBRID: Self-managed runtime that connects to Apigee cloud
EOT
  type        = string
  default     = "CLOUD"

  validation {
    condition     = var.runtime_type == "CLOUD" || var.runtime_type == "HYBRID"
    error_message = "Runtime type must be either CLOUD or HYBRID."
  }
}

variable "apigee_org_billing_type" {
  description = <<EOT
Billing configuration for the Apigee organization:
- EVALUATION: Free tier with limitations (default)
- PAYG: Pay-as-you-go billing based on API calls
- SUBSCRIPTION: Fixed price subscription with included API call quota
EOT
  type        = string
  default     = "EVALUATION"

  validation {
    condition     = var.apigee_org_billing_type == "PAYG" || var.apigee_org_billing_type == "SUBSCRIPTION" || var.apigee_org_billing_type == "EVALUATION"
    error_message = "Billing type must be either EVALUATION, PAYG or SUBSCRIPTION."
  }
}

variable "retention" {
  description = <<EOT
Data retention policy for the Apigee organization:
- DELETION_RETENTION_UNSPECIFIED: Default retention period (default)
- MINIMUM: Minimum required retention period
Only applicable when billing_type is not EVALUATION.
EOT
  type        = string
  default     = "DELETION_RETENTION_UNSPECIFIED"

  validation {
    condition     = var.retention == "DELETION_RETENTION_UNSPECIFIED" || var.retention == "MINIMUM"
    error_message = "Retention must be either DELETION_RETENTION_UNSPECIFIED or MINIMUM."
  }
}

variable "environment_config" {
  description = <<EOT
Configuration for Apigee environment groups and their associated environments.
Structure:
- Environment groups are used to organize environments and manage hostnames
- Each group can contain multiple environments
- Each environment can have its own configuration for deployment, scaling, and routing
EOT
  type = map(object({
    hostnames = optional(set(string), [])
    environments = map(object({
      display_name      = optional(string) # Human-readable name for the environment
      description       = optional(string) # Detailed description of the environment
      deployment_type   = optional(string) # How API proxies are deployed (PROXY or ARCHIVE)
      api_proxy_type    = optional(string) # Type of API proxies supported (PROGRAMMABLE or CONFIGURABLE)
      type              = optional(string) # Environment feature set (BASE, INTERMEDIATE, or COMPREHENSIVE)
      forward_proxy_uri = optional(string) # URI for forwarding requests through a proxy
      node_config = optional(object({
        min_node_count = optional(number, 1) # Minimum number of runtime nodes
        max_node_count = optional(number, 2) # Maximum number of runtime nodes
      }))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for group in var.environment_config : alltrue([
        for env in group.environments :
        env.deployment_type == null ||
        contains(["DEPLOYMENT_TYPE_UNSPECIFIED", "PROXY", "ARCHIVE"], env.deployment_type)
      ])
    ])
    error_message = "deployment_type must be one of: DEPLOYMENT_TYPE_UNSPECIFIED, PROXY or ARCHIVE"
  }

  validation {
    condition = alltrue([
      for group in var.environment_config : alltrue([
        for env in group.environments :
        env.api_proxy_type == null ||
        contains(["API_PROXY_TYPE_UNSPECIFIED", "PROGRAMMABLE", "CONFIGURABLE"], env.api_proxy_type)
      ])
    ])
    error_message = "api_proxy_type must be one of: API_PROXY_TYPE_UNSPECIFIED, PROGRAMMABLE or CONFIGURABLE"
  }

  validation {
    condition = alltrue([
      for group in var.environment_config : alltrue([
        for env in group.environments :
        env.type == null ? true : 
        contains(["ENVIRONMENT_TYPE_UNSPECIFIED", "BASE", "INTERMEDIATE", "COMPREHENSIVE"], env.type)
      ])
    ])
    error_message = "type must be one of: ENVIRONMENT_TYPE_UNSPECIFIED, BASE, INTERMEDIATE or COMPREHENSIVE"
  }

  validation {
    condition = alltrue([
      for group in var.environment_config : alltrue([
        for env in group.environments :
        env.forward_proxy_uri == null ||
        can(regex("^[a-zA-Z]+://[a-zA-Z0-9.-]+:[0-9]+$", env.forward_proxy_uri))
      ])
    ])
    error_message = "forward_proxy_uri must be in the format {scheme}://{hostname}:{port}"
  }
}

variable "environment_iam" {
  description = <<EOT
IAM role bindings for Apigee environments. Configure access control for each environment.
Structure:
{
  "environment-name" = {
    role    = ["roles/apigee.environmentAdmin"]
    members = ["user:jane@example.com", "group:devs@example.com"]
  }
}

Common roles:
- roles/apigee.environmentAdmin: Full access to manage the environment
- roles/apigee.developer: Deploy and manage API proxies
- roles/apigee.analyticsViewer: View analytics data
- roles/apigee.analyticsAdmin: Manage analytics data
- roles/apigee.deploymentAdmin: Manage deployments

Member types:
- user:email@example.com
- serviceAccount:sa@project.iam.gserviceaccount.com
- group:group@example.com
- domain:example.com
EOT
  type = map(object({
    role    = list(string)
    members = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for env, config in var.environment_iam : alltrue([
        for member in config.members :
        can(regex("^(user|serviceAccount|group|domain):", member))
      ])
    ])
    error_message = "Members must be prefixed with 'user:', 'serviceAccount:', 'group:', or 'domain:'"
  }
}

variable "instance_config" {
  description = <<EOT
Configuration for Apigee runtime instances.
Each instance represents a regional deployment of the Apigee runtime:
- location: Region where the instance will be deployed
- peering_cidr_range: CIDR range for VPC peering (required for CLOUD runtime)
- ip_range: CIDR range for instance IP allocation
- consumer_accept_list: List of CIDR ranges allowed to access the instance
- environment: Name of the environment to attach this instance to
EOT
  type = map(object({
    location             = string
    peering_cidr_range   = optional(string)
    ip_range             = optional(string)
    description          = optional(string)
    display_name         = optional(string)
    consumer_accept_list = optional(list(string))
    environments         = optional(set(string))
  }))
  default = {}
}

variable "kms_key_ring_name" {
  description = <<EOT
The name for the KMS key ring to be created for Apigee X encryption.
Required when using CMEK (Customer-Managed Encryption Keys) with Apigee X.
Only applicable when billing_type is not EVALUATION.
EOT
  type        = string
  default     = ""
}

variable "kms_key_ring_location" {
  description = <<EOT
The location for the KMS key ring to be created.
Required when using CMEK (Customer-Managed Encryption Keys) with Apigee X.
Only applicable when billing_type is not EVALUATION.
Typically should match the region where Apigee X resources are deployed.
You can retrieve available locations using the command: gcloud kms locations list
EOT
  type        = string
  default     = ""
}

variable "kms_crypto_key_api_consumer_data" {
  description = <<EOT
Configuration for KMS crypto keys used to encrypt API consumer data in Apigee X.
Only applies when billing_type is not EVALUATION.
Structure:
{
  "key-name" = {
    purpose         = "ENCRYPT_DECRYPT"  # Purpose of the key (default)
    rotation_period = "7776000s"         # Key rotation period in seconds (default: 90 days)
    labels          = { team = "api" }   # Custom labels for the key
  }
}

Note: All KMS keys are protected with prevent_destroy=true by default.
To destroy KMS keys, you need to modify the lifecycle blocks in the kms.tf file.
EOT
  type = map(object({
    purpose         = optional(string, "ENCRYPT_DECRYPT")
    rotation_period = optional(string, "7776000s") # Minimum value is 1 day (86400s), variable default value is 90 days (7776000s)
    labels          = optional(map(string), {})
  }))
  default = {}
}

variable "kms_crypto_key_control_plane" {
  description = <<EOT
Configuration for KMS crypto keys used to encrypt the Apigee X control plane.
Only applies when billing_type is not EVALUATION.
Structure:
{
  "key-name" = {
    purpose         = "ENCRYPT_DECRYPT"  # Purpose of the key (default)
    rotation_period = "7776000s"         # Key rotation period in seconds (default: 90 days)
    labels          = { team = "api" }   # Custom labels for the key
  }
}

Note: All KMS keys are protected with prevent_destroy=true by default.
To destroy KMS keys, you need to modify the lifecycle blocks in the kms.tf file.
EOT
  type = map(object({
    purpose         = optional(string, "ENCRYPT_DECRYPT")
    rotation_period = optional(string, "7776000s") # Minimum value is 1 day (86400s), variable default value is 90 days (7776000s)
    labels          = optional(map(string), {})
  }))
  default = {}
}

variable "kms_crypto_key_runtime_database" {
  description = <<EOT
Configuration for KMS crypto keys used to encrypt the Apigee X runtime database.
Only applies when billing_type is not EVALUATION.
Structure:
{
  "key-name" = {
    purpose         = "ENCRYPT_DECRYPT"  # Purpose of the key (default)
    rotation_period = "7776000s"         # Key rotation period in seconds (default: 90 days)
    labels          = { team = "api" }   # Custom labels for the key
  }
}

Note: All KMS keys are protected with prevent_destroy=true by default.
To destroy KMS keys, you need to modify the lifecycle blocks in the kms.tf file.
EOT
  type = map(object({
    purpose         = optional(string, "ENCRYPT_DECRYPT")
    rotation_period = optional(string, "7776000s") # Minimum value is 1 day (86400s), variable default value is 90 days (7776000s)
    labels          = optional(map(string), {})
  }))
  default = {}
}
