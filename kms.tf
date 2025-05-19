# Define region mappings for data residency validation
locals {
  # Map of broader regions to their subregions
  region_mappings = {
    "europe"    = ["europe-north1", "europe-west1", "europe-west2", "europe-west3", "europe-west4", "europe-west6", "europe-central2"]
    "us"        = ["us-central1", "us-east1", "us-east4", "us-west1", "us-west2", "us-west3", "us-west4", "us-south1"]
    "asia"      = ["asia-east1", "asia-east2", "asia-northeast1", "asia-northeast2", "asia-northeast3", "asia-south1", "asia-south2", "asia-southeast1", "asia-southeast2"]
    "australia" = ["australia-southeast1", "australia-southeast2"]
  }

  # Check if KMS location is compatible with Apigee region
  is_valid_location = (
    var.kms_key_ring_name == "" || var.kms_key_ring_location == "" ? true :
    var.kms_key_ring_location == var.region ||                                                                                             # Exact match is valid
    contains(local.region_mappings[var.kms_key_ring_location] != null ? local.region_mappings[var.kms_key_ring_location] : [], var.region) # Broader region contains Apigee region
  )
}

# Create the KMS key ring and crypto keys for use with Apigee X
resource "google_kms_key_ring" "main" {
  count    = var.kms_key_ring_name != "" ? 1 : 0
  name     = var.kms_key_ring_name
  location = var.kms_key_ring_location

  lifecycle {
    precondition {
      condition     = var.kms_key_ring_location != ""
      error_message = "KMS key ring location must be specified when kms_key_ring_name is provided."
    }

    precondition {
      condition     = local.is_valid_location
      error_message = "KMS key ring location (${var.kms_key_ring_location}) must either match the Apigee region (${var.region}) or be a broader region that contains it."
    }
  }
}

resource "google_kms_crypto_key" "api_consumer_data" {
  for_each        = var.kms_crypto_key_api_consumer_data != null ? var.kms_crypto_key_api_consumer_data : {}
  name            = each.key
  key_ring        = google_kms_key_ring.main[0].id
  purpose         = each.value.purpose
  rotation_period = each.value.rotation_period

  labels = merge(
    each.value.labels,
    {
      "created_by" = "terraform"
      "created_at" = timestamp()
      "in_use_by"  = "apigee-x"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "control_plane" {
  for_each        = var.kms_crypto_key_control_plane != null ? var.kms_crypto_key_control_plane : {}
  name            = each.key
  key_ring        = google_kms_key_ring.main[0].id
  purpose         = each.value.purpose
  rotation_period = each.value.rotation_period

  labels = merge(
    each.value.labels,
    {
      "created_by" = "terraform"
      "created_at" = timestamp()
      "in_use_by"  = "apigee-x"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "runtime_database" {
  for_each        = var.kms_crypto_key_runtime_database != null ? var.kms_crypto_key_runtime_database : {}
  name            = each.key
  key_ring        = google_kms_key_ring.main[0].id
  purpose         = each.value.purpose
  rotation_period = each.value.rotation_period

  labels = merge(
    each.value.labels,
    {
      "created_by" = "terraform"
      "created_at" = timestamp()
      "in_use_by"  = "apigee-x"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Manage permissions for all crypto keys
locals {
  all_crypto_keys = merge(
    { for k, v in google_kms_crypto_key.api_consumer_data : k => v.id },
    { for k, v in google_kms_crypto_key.control_plane : k => v.id },
    { for k, v in google_kms_crypto_key.runtime_database : k => v.id }
  )
}

resource "google_kms_crypto_key_iam_member" "crypto_keys" {
  for_each      = local.all_crypto_keys
  crypto_key_id = each.value
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.main.number}@gcp-sa-apigee.iam.gserviceaccount.com"
}
