output "map" {
  description = "outputs for all service accounts created"
  value       = { for key, sa in google_service_account.map : key => sa }
}
