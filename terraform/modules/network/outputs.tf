output "network_name" {
  value = google_compute_network.network.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}