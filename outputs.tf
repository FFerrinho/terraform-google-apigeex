# Organization outputs
output "apigeex_org_name" {
  description = "The name of the Apigee X organization"
  value       = google_apigee_organization.main.name
}

output "apigeex_org_id" {
  description = "The unique identifier for the Apigee X organization"
  value       = google_apigee_organization.main.id
}

output "apigeex_subscription_type" {
  description = "The subscription type of the Apigee X organization"
  value       = google_apigee_organization.main.subscription_type
}

output "apigeex_ca_certificate" {
  description = "The CA certificate used for the organization's runtime instances"
  value       = google_apigee_organization.main.ca_certificate
  sensitive   = true
}

# Environment Group outputs
output "environment_groups" {
  description = "Map of environment group names to their details"
  value = {
    for k, v in google_apigee_envgroup.main : k => {
      id        = v.id
      name      = v.name
      hostnames = v.hostnames
    }
  }
}

# Environment outputs
output "environments" {
  description = "Map of environment names to their details"
  value = {
    for k, v in google_apigee_environment.main : k => {
      id              = v.id
      name            = v.name
      display_name    = v.display_name
      description     = v.description
      deployment_type = v.deployment_type
      api_proxy_type  = v.api_proxy_type
      type            = v.type
    }
  }
}

# Instance outputs
output "instances" {
  description = "Map of instance names to their details"
  value = {
    for k, v in google_apigee_instance.main : k => {
      id                 = v.id
      name               = v.name
      location           = v.location
      peering_cidr_range = v.peering_cidr_range
      ip_range           = v.ip_range
      host               = v.host
    }
  }
}

# Environment-Instance attachments
output "instance_attachments" {
  description = "Map of instance names to their environment attachments"
  value = {
    for k, v in google_apigee_instance_attachment.main : k => {
      instance_id = v.instance_id
      environment = v.environment
    }
  }
}

# Environment Group attachments
output "environment_group_attachments" {
  description = "Map of environment names to their group attachments"
  value = {
    for k, v in google_apigee_envgroup_attachment.main : k => {
      envgroup_id = v.envgroup_id
      environment = v.environment
    }
  }
}
