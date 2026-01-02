output "nginx_container_name" {
  value = docker_container.nginx.name
}

output "php_container_name" {
  value = docker_container.php.name
}

output "healthz_url" {
  value = "http://localhost:${var.host_port}/healthz"
}
