variable "project_name" {
  description = "Project prefix for docker resources"
  type        = string
}

variable "host_port" {
  description = "Host port to expose nginx"
  type        = number
  default     = 8080
}

variable "app_env" {
  description = "Environment string for /healthz JSON"
  type        = string
  default     = "dev"
}
