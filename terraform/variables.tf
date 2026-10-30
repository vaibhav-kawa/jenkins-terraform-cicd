# ---------------------------------------------------------------
# Input variables - change these values (or terraform.tfvars)
# to reuse the same configuration for a different environment.
# ---------------------------------------------------------------
variable "docker_host" {
  description = "Docker daemon socket"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "app_name" {
  description = "Base name used for all resources"
  type        = string
  default     = "cicd-demo"
}

variable "environment" {
  description = "Deployment environment label (dev / staging / prod)"
  type        = string
  default     = "staging"
}

variable "image_tag" {
  description = "Tag for the Docker image Terraform builds"
  type        = string
  default     = "tf"
}

variable "replicas" {
  description = "Number of application containers to provision"
  type        = number
  default     = 2

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 5
    error_message = "replicas must be between 1 and 5."
  }
}

variable "base_port" {
  description = "First host port; replica N is published on base_port + N"
  type        = number
  default     = 8081
}
