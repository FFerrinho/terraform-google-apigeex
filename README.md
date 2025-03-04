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
| [google_apigee_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_instance) | resource |
| [google_apigee_instance_attachment.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_instance_attachment) | resource |
| [google_apigee_organization.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_organization) | resource |
| [google_project_service.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_project.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apigee_org_billing_type"></a> [apigee\_org\_billing\_type](#input\_apigee\_org\_billing\_type) | Billing configuration for the Apigee organization:<br>- EVALUATION: Free tier with limitations (default)<br>- CONSUMPTION: Pay-as-you-go billing based on API calls<br>- PREPAID: Fixed price subscription with included API call quota | `string` | `"EVALUATION"` | no |
| <a name="input_apigee_org_description"></a> [apigee\_org\_description](#input\_apigee\_org\_description) | Detailed description of the Apigee organization's purpose or scope. | `string` | n/a | yes |
| <a name="input_apigee_org_display_name"></a> [apigee\_org\_display\_name](#input\_apigee\_org\_display\_name) | Human-readable name for the Apigee organization. Used in the Google Cloud Console and Apigee UI. | `string` | n/a | yes |
| <a name="input_environment_config"></a> [environment\_config](#input\_environment\_config) | Configuration for Apigee environment groups and their associated environments.<br>Structure:<br>- Environment groups are used to organize environments and manage hostnames<br>- Each group can contain multiple environments<br>- Each environment can have its own configuration for deployment, scaling, and routing | <pre>map(object({<br>    hostnames = optional(set(string), [])<br>    environments = map(object({<br>      display_name      = optional(string)      # Human-readable name for the environment<br>      description       = optional(string)       # Detailed description of the environment<br>      deployment_type   = optional(string)       # How API proxies are deployed (PROXY or ARCHIVE)<br>      api_proxy_type    = optional(string)       # Type of API proxies supported (PROGRAMMABLE or CONFIGURABLE)<br>      type              = optional(string)       # Environment feature set (BASE, INTERMEDIATE, or COMPREHENSIVE)<br>      forward_proxy_uri = optional(string)       # URI for forwarding requests through a proxy<br>      node_config = optional(object({<br>        min_node_count = optional(number, 1)    # Minimum number of runtime nodes<br>        max_node_count = optional(number, 2)    # Maximum number of runtime nodes<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | Configuration for Apigee runtime instances.<br>Each instance represents a regional deployment of the Apigee runtime:<br>- location: Region where the instance will be deployed<br>- peering\_cidr\_range: CIDR range for VPC peering (required for CLOUD runtime)<br>- ip\_range: CIDR range for instance IP allocation<br>- consumer\_accept\_list: List of CIDR ranges allowed to access the instance<br>- environment: Name of the environment to attach this instance to | <pre>map(object({<br>    location             = string<br>    peering_cidr_range   = optional(string)<br>    ip_range             = optional(string)<br>    description          = optional(string)<br>    display_name         = optional(string)<br>    consumer_accept_list = optional(list(string))<br>    environment          = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID where Apigee X resources will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region where Apigee analytics data and runtime instances will be hosted. Cannot be changed after creation. | `string` | n/a | yes |
| <a name="input_retention"></a> [retention](#input\_retention) | Data retention policy for the Apigee organization:<br>- DELETION\_RETENTION\_UNSPECIFIED: Default retention period (default)<br>- MINIMUM: Minimum required retention period<br>Only applicable when billing\_type is not EVALUATION. | `string` | `"DELETION_RETENTION_UNSPECIFIED"` | no |
| <a name="input_runtime_type"></a> [runtime\_type](#input\_runtime\_type) | Type of Apigee runtime to deploy:<br>- CLOUD: Fully managed Apigee X runtime (recommended)<br>- HYBRID: Self-managed runtime that connects to Apigee cloud | `string` | `"CLOUD"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC network to use for Apigee X. Required when runtime\_type is 'CLOUD'. Must be an existing VPC network. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apigeex_org_name"></a> [apigeex\_org\_name](#output\_apigeex\_org\_name) | The name of the Apigee X organization. |
| <a name="output_apigeex_subscription_type"></a> [apigeex\_subscription\_type](#output\_apigeex\_subscription\_type) | The subscription type of the Apigee X organization. |
