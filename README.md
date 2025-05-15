<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_apigee_envgroup.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_envgroup) | resource |
| [google_apigee_envgroup_attachment.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_envgroup_attachment) | resource |
| [google_apigee_environment.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_environment) | resource |
| [google_apigee_environment_iam_binding.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_environment_iam_binding) | resource |
| [google_apigee_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_instance) | resource |
| [google_apigee_instance_attachment.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_instance_attachment) | resource |
| [google_apigee_organization.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_organization) | resource |
| [google_kms_crypto_key.api_consumer_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key.control_plane](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key.runtime_database](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_member.crypto_keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_key_ring.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_project_service.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_project.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_org_billing_type"></a> [apigee\_org\_billing\_type](#input\_apigee\_org\_billing\_type) | Billing configuration for the Apigee organization:<br>- EVALUATION: Free tier with limitations (default)<br>- CONSUMPTION: Pay-as-you-go billing based on API calls<br>- PREPAID: Fixed price subscription with included API call quota | `string` | `"EVALUATION"` | no |
| <a name="input_apigee_org_description"></a> [apigee\_org\_description](#input\_apigee\_org\_description) | Detailed description of the Apigee organization's purpose or scope. | `string` | n/a | yes |
| <a name="input_apigee_org_display_name"></a> [apigee\_org\_display\_name](#input\_apigee\_org\_display\_name) | Human-readable name for the Apigee organization. Used in the Google Cloud Console and Apigee UI. | `string` | n/a | yes |
| <a name="input_environment_config"></a> [environment\_config](#input\_environment\_config) | Configuration for Apigee environment groups and their associated environments.<br>Structure:<br>- Environment groups are used to organize environments and manage hostnames<br>- Each group can contain multiple environments<br>- Each environment can have its own configuration for deployment, scaling, and routing | <pre>map(object({<br>    hostnames = optional(set(string), [])<br>    environments = map(object({<br>      display_name      = optional(string) # Human-readable name for the environment<br>      description       = optional(string) # Detailed description of the environment<br>      deployment_type   = optional(string) # How API proxies are deployed (PROXY or ARCHIVE)<br>      api_proxy_type    = optional(string) # Type of API proxies supported (PROGRAMMABLE or CONFIGURABLE)<br>      type              = optional(string) # Environment feature set (BASE, INTERMEDIATE, or COMPREHENSIVE)<br>      forward_proxy_uri = optional(string) # URI for forwarding requests through a proxy<br>      node_config = optional(object({<br>        min_node_count = optional(number, 1) # Minimum number of runtime nodes<br>        max_node_count = optional(number, 2) # Maximum number of runtime nodes<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_environment_iam"></a> [environment\_iam](#input\_environment\_iam) | IAM role bindings for Apigee environments. Configure access control for each environment.<br>Structure:<br>{<br>  "environment-name" = {<br>    role    = ["roles/apigee.environmentAdmin"]<br>    members = ["user:jane@example.com", "group:devs@example.com"]<br>  }<br>}<br><br>Common roles:<br>- roles/apigee.environmentAdmin: Full access to manage the environment<br>- roles/apigee.developer: Deploy and manage API proxies<br>- roles/apigee.analyticsViewer: View analytics data<br>- roles/apigee.analyticsAdmin: Manage analytics data<br>- roles/apigee.deploymentAdmin: Manage deployments<br><br>Member types:<br>- user:email@example.com<br>- serviceAccount:sa@project.iam.gserviceaccount.com<br>- group:group@example.com<br>- domain:example.com | <pre>map(object({<br>    role    = list(string)<br>    members = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | Configuration for Apigee runtime instances.<br>Each instance represents a regional deployment of the Apigee runtime:<br>- location: Region where the instance will be deployed<br>- peering\_cidr\_range: CIDR range for VPC peering (required for CLOUD runtime)<br>- ip\_range: CIDR range for instance IP allocation<br>- consumer\_accept\_list: List of CIDR ranges allowed to access the instance<br>- environment: Name of the environment to attach this instance to | <pre>map(object({<br>    location             = string<br>    peering_cidr_range   = optional(string)<br>    ip_range             = optional(string)<br>    description          = optional(string)<br>    display_name         = optional(string)<br>    consumer_accept_list = optional(list(string))<br>    environment          = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_kms_crypto_key_api_consumer_data"></a> [kms\_crypto\_key\_api\_consumer\_data](#input\_kms\_crypto\_key\_api\_consumer\_data) | Configuration for KMS crypto keys used to encrypt API consumer data in Apigee X.<br>Only applies when billing\_type is not EVALUATION.<br>Structure:<br>{<br>  "key-name" = {<br>    purpose         = "ENCRYPT\_DECRYPT"  # Purpose of the key (default)<br>    rotation\_period = "7776000s"         # Key rotation period in seconds (default: 90 days)<br>    labels          = { team = "api" }   # Custom labels for the key<br>  }<br>}<br><br>Note: All KMS keys are protected with prevent\_destroy=true by default.<br>To destroy KMS keys, you need to modify the lifecycle blocks in the kms.tf file. | <pre>map(object({<br>    purpose         = optional(string, "ENCRYPT_DECRYPT")<br>    rotation_period = optional(string, "7776000s") # Minimum value is 1 day (86400s), variable default value is 90 days (7776000s)<br>    labels          = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_kms_crypto_key_control_plane"></a> [kms\_crypto\_key\_control\_plane](#input\_kms\_crypto\_key\_control\_plane) | Configuration for KMS crypto keys used to encrypt the Apigee X control plane.<br>Only applies when billing\_type is not EVALUATION.<br>Structure:<br>{<br>  "key-name" = {<br>    purpose         = "ENCRYPT\_DECRYPT"  # Purpose of the key (default)<br>    rotation\_period = "7776000s"         # Key rotation period in seconds (default: 90 days)<br>    labels          = { team = "api" }   # Custom labels for the key<br>  }<br>}<br><br>Note: All KMS keys are protected with prevent\_destroy=true by default.<br>To destroy KMS keys, you need to modify the lifecycle blocks in the kms.tf file. | <pre>map(object({<br>    purpose         = optional(string, "ENCRYPT_DECRYPT")<br>    rotation_period = optional(string, "7776000s") # Minimum value is 1 day (86400s), variable default value is 90 days (7776000s)<br>    labels          = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_kms_crypto_key_runtime_database"></a> [kms\_crypto\_key\_runtime\_database](#input\_kms\_crypto\_key\_runtime\_database) | Configuration for KMS crypto keys used to encrypt the Apigee X runtime database.<br>Only applies when billing\_type is not EVALUATION.<br>Structure:<br>{<br>  "key-name" = {<br>    purpose         = "ENCRYPT\_DECRYPT"  # Purpose of the key (default)<br>    rotation\_period = "7776000s"         # Key rotation period in seconds (default: 90 days)<br>    labels          = { team = "api" }   # Custom labels for the key<br>  }<br>}<br><br>Note: All KMS keys are protected with prevent\_destroy=true by default.<br>To destroy KMS keys, you need to modify the lifecycle blocks in the kms.tf file. | <pre>map(object({<br>    purpose         = optional(string, "ENCRYPT_DECRYPT")<br>    rotation_period = optional(string, "7776000s") # Minimum value is 1 day (86400s), variable default value is 90 days (7776000s)<br>    labels          = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_kms_key_ring_location"></a> [kms\_key\_ring\_location](#input\_kms\_key\_ring\_location) | The location for the KMS key ring to be created.<br>Required when using CMEK (Customer-Managed Encryption Keys) with Apigee X.<br>Only applicable when billing\_type is not EVALUATION.<br>Typically should match the region where Apigee X resources are deployed.<br>You can retrieve available locations using the command: gcloud kms locations list | `string` | `""` | no |
| <a name="input_kms_key_ring_name"></a> [kms\_key\_ring\_name](#input\_kms\_key\_ring\_name) | The name for the KMS key ring to be created for Apigee X encryption.<br>Required when using CMEK (Customer-Managed Encryption Keys) with Apigee X.<br>Only applicable when billing\_type is not EVALUATION. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID where Apigee X resources will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region where Apigee analytics data and runtime instances will be hosted. Cannot be changed after creation. | `string` | n/a | yes |
| <a name="input_retention"></a> [retention](#input\_retention) | Data retention policy for the Apigee organization:<br>- DELETION\_RETENTION\_UNSPECIFIED: Default retention period (default)<br>- MINIMUM: Minimum required retention period<br>Only applicable when billing\_type is not EVALUATION. | `string` | `"DELETION_RETENTION_UNSPECIFIED"` | no |
| <a name="input_runtime_type"></a> [runtime\_type](#input\_runtime\_type) | Type of Apigee runtime to deploy:<br>- CLOUD: Fully managed Apigee X runtime (recommended)<br>- HYBRID: Self-managed runtime that connects to Apigee cloud | `string` | `"CLOUD"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC network to use for Apigee X. Required when runtime\_type is 'CLOUD'. Must be an existing VPC network. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apigeex_ca_certificate"></a> [apigeex\_ca\_certificate](#output\_apigeex\_ca\_certificate) | The CA certificate used for the organization's runtime instances |
| <a name="output_apigeex_org_id"></a> [apigeex\_org\_id](#output\_apigeex\_org\_id) | The unique identifier for the Apigee X organization |
| <a name="output_apigeex_org_name"></a> [apigeex\_org\_name](#output\_apigeex\_org\_name) | The name of the Apigee X organization |
| <a name="output_apigeex_subscription_type"></a> [apigeex\_subscription\_type](#output\_apigeex\_subscription\_type) | The subscription type of the Apigee X organization |
| <a name="output_environment_group_attachments"></a> [environment\_group\_attachments](#output\_environment\_group\_attachments) | Map of environment names to their group attachments |
| <a name="output_environment_groups"></a> [environment\_groups](#output\_environment\_groups) | Map of environment group names to their details |
| <a name="output_environments"></a> [environments](#output\_environments) | Map of environment names to their details |
| <a name="output_instance_attachments"></a> [instance\_attachments](#output\_instance\_attachments) | Map of instance names to their environment attachments |
| <a name="output_instances"></a> [instances](#output\_instances) | Map of instance names to their details |
| <a name="output_kms_crypto_keys"></a> [kms\_crypto\_keys](#output\_kms\_crypto\_keys) | Map of all KMS crypto keys created for Apigee X |
| <a name="output_kms_key_ring"></a> [kms\_key\_ring](#output\_kms\_key\_ring) | The KMS key ring created for Apigee X encryption |
<!-- END_TF_DOCS -->