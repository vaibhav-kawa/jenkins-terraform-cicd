# ---------------------------------------------------------------
# Outputs shown after `terraform apply`
# ---------------------------------------------------------------
output "network_name" {
  description = "Docker network created by Terraform"
  value       = docker_network.app_net.name
}

output "image" {
  description = "Docker image built by Terraform"
  value       = docker_image.app_image.name
}

output "container_names" {
  description = "Provisioned application containers"
  value       = docker_container.app[*].name
}

output "app_urls" {
  description = "Open these in a browser (replace localhost with the EC2 public IP)"
  value       = [for c in docker_container.app : "http://localhost:${c.ports[0].external}"]
}
