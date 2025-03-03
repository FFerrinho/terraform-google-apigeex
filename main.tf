data "google_project" "main" {
  project_id = var.project_id
}

data "google_compute_network" "main" {
  count   = var.vpc_name != null ? 1 : 0
  name    = var.vpc_name
  project = data.google_project.main.project_id
}

# TODO Enable API servicenetworking.googleapis.com if RuntimeType is set to CLOUD

resource "google_apigee_organization" "main" {
  project_id                 = data.google_project.main.project_id
  display_name               = var.apigee_org_display_name
  description                = var.apigee_org_description
  analytics_region           = var.region
  api_consumer_data_location = var.region
  authorized_network         = var.runtime_type == "CLOUD" ? data.google_compute_network.main[0].name : null
  disable_vpc_peering        = var.runtime_type == "CLOUD" ? false : true
  runtime_type               = var.runtime_type
  billing_type               = var.apigee_org_billing_type
}
