# ---------------------------------------------------------------
# Infrastructure resources
#   1. A dedicated Docker network
#   2. A Docker image built from the project's Dockerfile
#   3. N application containers (replicas) attached to the network
# ---------------------------------------------------------------
locals {
  name_prefix = "${var.app_name}-${var.environment}"
  project_dir = abspath("${path.module}/..")

  common_labels = {
    project     = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# 1. Network
resource "docker_network" "app_net" {
  name = "${local.name_prefix}-net"

  dynamic "labels" {
    for_each = local.common_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}

# 2. Image (rebuilt automatically when app.py / requirements / Dockerfile change)
resource "docker_image" "app_image" {
  name = "${var.app_name}:${var.image_tag}"

  build {
    context = local.project_dir
    tag     = ["${var.app_name}:${var.image_tag}"]
  }

  triggers = {
    source_hash = sha1(join("", [
      filesha1("${local.project_dir}/app.py"),
      filesha1("${local.project_dir}/requirements.txt"),
      filesha1("${local.project_dir}/Dockerfile"),
    ]))
  }

  keep_locally = false
}

# 3. Application containers
resource "docker_container" "app" {
  count = var.replicas

  name    = "${local.name_prefix}-${count.index + 1}"
  image   = docker_image.app_image.image_id
  restart = "unless-stopped"

  env = [
    "APP_ENV=${var.environment}",
    "BUILD_NUMBER=terraform-replica-${count.index + 1}",
  ]

  ports {
    internal = 5000
    external = var.base_port + count.index
  }

  networks_advanced {
    name = docker_network.app_net.name
  }

  dynamic "labels" {
    for_each = local.common_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}
