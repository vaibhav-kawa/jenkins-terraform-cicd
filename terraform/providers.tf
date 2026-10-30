# ---------------------------------------------------------------
# Terraform & provider configuration
# Uses the Docker provider so infrastructure is provisioned on the
# same EC2 host without needing any AWS access keys.
# ---------------------------------------------------------------
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}
