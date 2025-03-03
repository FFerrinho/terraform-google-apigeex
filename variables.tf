variable "project_id" {
  description = "The project ID to use for the Google Cloud resources."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC to use with Apigee X."
  type        = string
  default     = null
}

variable "apigee_org_display_name" {
  description = "The display name of the Apigee organization."
  type        = string
}

variable "apigee_org_description" {
  description = "The description of the Apigee organization."
  type        = string
}

variable "region" {
  description = "The region to use for the Apigee organization."
  type        = string
}

variable "runtime_type" {
  description = "The runtime type to use for the Apigee organization."
  type        = string
  default     = "CLOUD"

  validation {
    condition     = var.runtime_type == "CLOUD" || var.runtime_type == "HYBRID"
    error_message = "Runtime type must be either CLOUD or HYBRID."
  }
}

variable "apigee_org_billing_type" {
  description = "The billing type to use for the Apigee organization."
  type        = string
  default     = "EVALUATION"

  validation {
    condition     = var.apigee_org_billing_type == "CONSUMPTION" || var.apigee_org_billing_type == "PREPAID" || || var.apigee_org_billing_type == "EVALUATION"
    error_message = "Billing type must be either EVALUATION, CONSUMPTION or PREPAID."
  }
}
