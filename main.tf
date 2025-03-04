# Get the project information
data "google_project" "main" {
  project_id = var.project_id
}

# Retrieve VPC network information if provided
# Only used when runtime_type is "CLOUD"
data "google_compute_network" "main" {
  count   = var.vpc_name != null ? 1 : 0
  name    = var.vpc_name
  project = data.google_project.main.project_id
}

# Enable Service Networking API for Cloud runtime
# Required for VPC peering in Apigee X
resource "google_project_service" "main" {
  for_each = var.runtime_type == "CLOUD" ? toset(["enable"]) : toset([])
  project  = data.google_project.main.project_id
  service  = "servicenetworking.googleapis.com"
}

# Create the Apigee Organization
# This is the top-level resource that contains all Apigee components
resource "google_apigee_organization" "main" {
  project_id                 = data.google_project.main.project_id
  display_name               = var.apigee_org_display_name
  description                = var.apigee_org_description
  analytics_region           = var.region
  api_consumer_data_location = var.region
  # VPC configuration is only needed for CLOUD runtime
  authorized_network  = var.runtime_type == "CLOUD" ? data.google_compute_network.main[0].name : null
  disable_vpc_peering = var.runtime_type == "CLOUD" ? false : true
  runtime_type        = var.runtime_type
  billing_type        = var.apigee_org_billing_type
  # Retention is only applicable for non-EVALUATION billing types
  retention = var.apigee_org_billing_type != "EVALUATION" ? var.retention : null
}

# Create environment groups
# Environment groups are used to organize environments and manage hostnames
resource "google_apigee_envgroup" "main" {
  for_each  = var.environment_config
  name      = each.key
  org_id    = google_apigee_organization.main.id
  hostnames = [each.value.hostnames]
}

# Create environments within environment groups
# Uses a nested for_each to iterate through all environments in all groups
resource "google_apigee_environment" "main" {
  for_each = merge([
    for group_name, group in var.environment_config : {
      for env_name, env in group.environments :
      "${group_name}/${env_name}" => merge(env, {
        group_name = group_name
      })
    }
  ]...)

  name              = split("/", each.key)[1]
  org_id            = google_apigee_organization.main.id
  display_name      = each.value.display_name
  description       = each.value.description
  deployment_type   = each.value.deployment_type
  api_proxy_type    = each.value.api_proxy_type
  type              = each.value.type
  forward_proxy_uri = each.value.forward_proxy_uri
  
  # Configure node scaling if provided
  dynamic "node_config" {
    for_each = each.value.node_config != null ? [each.value.node_config] : []
    content {
      min_node_count = node_config.value.min_node_count
      max_node_count = node_config.value.max_node_count
    }
  }
}

# Attach environments to their respective environment groups
resource "google_apigee_envgroup_attachment" "main" {
  for_each = merge([
    for group_name, group in var.environment_config : {
      for env_name, env in group.environments :
      "${group_name}/${env_name}" => {
        group_name = group_name
        env_name   = env_name
      }
    }
  ]...)

  envgroup_id = google_apigee_envgroup.main[split("/", each.key)[0]].id
  environment = google_apigee_environment.main[each.key].name
}

# Create Apigee runtime instances
# Instances are the compute resources that run your API proxies
resource "google_apigee_instance" "main" {
  for_each             = var.instance_config
  name                 = each.key
  location             = each.value.location
  org_id               = google_apigee_organization.main.id
  peering_cidr_range   = each.value.peering_cidr_range
  ip_range             = each.value.ip_range
  description          = each.value.description
  display_name         = each.value.display_name
  consumer_accept_list = each.value.consumer_accept_list
}

# Attach instances to environments
# This determines which environment's proxies run on which instances
resource "google_apigee_instance_attachment" "main" {
  for_each    = var.instance_config
  environment = each.value.environment
  instance_id = google_apigee_instance.main[each.key].id
}
