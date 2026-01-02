terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.5.0"
    }
  }
}


provider "docker" {}

locals {
  nginx_name = "${var.project_name}-nginx"
  php_name   = "${var.project_name}-php"
  net_name   = "${var.project_name}-net"
  vol_name   = "${var.project_name}-www"
}

resource "docker_network" "net" {
  name = local.net_name
}

resource "docker_volume" "www" {
  name = local.vol_name
}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

resource "docker_image" "php" {
  name         = "php:8.3-fpm-alpine"
  keep_locally = true
}


resource "docker_container" "php" {
  name  = local.php_name
  image = docker_image.php.image_id

  networks_advanced {
    name = docker_network.net.name
  }

  volumes {
    volume_name    = docker_volume.www.name
    container_path = "/var/www/html"
  }

  upload {
    file = "/var/www/html/index.php"
    content = templatefile("${path.module}/templates/index.php.tftpl", {
      app_env = var.app_env
    })
  }
}
resource "docker_container" "nginx" {
  name  = local.nginx_name
  image = docker_image.nginx.image_id

  depends_on = [docker_container.php]

  networks_advanced {
    name = docker_network.net.name
  }

  ports {
    internal = 80
    external = var.host_port
  }

  volumes {
    volume_name    = docker_volume.www.name
    container_path = "/var/www/html"
  }

  upload {
    file = "/etc/nginx/conf.d/default.conf"
    content = templatefile("${path.module}/templates/default.conf.tftpl", {
      app_env      = var.app_env
      php_upstream = local.php_name
    })
  }
}
