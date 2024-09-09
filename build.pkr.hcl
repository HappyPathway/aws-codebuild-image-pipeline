packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
  }
}

variable login_password {
  type = string
}

variable login_username {
  type = string
}

variable repo {
  type = string
}

variable docker_hub_org {
  type = string
  default = "happypathway"
}

variable source_image {
  type = string
  default = "ubuntu:latest"
} 

variable file_template {
  type = string
  default = "buildscript.sh.tpl"
}

variable vars_file {
  type = string
  default = "vars.json"
}

source "docker" "image" {
  image  = var.source_image
  commit = true
}


build {
  name    = var.repo
  sources = [
    "source.docker.image"
  ]
  provisioner "file" {
    content = templatefile(
      var.file_template,
      jsondecode(file(var.vars_file))
    )
    destination = "/tmp/buildscript"
  }

  provisioner shell {
    inline = [
      "chmod +x /tmp/buildscript",
      "/tmp/buildscript",
      "rm /tmp/buildscript"
    ]
  }

  post-processors {
    post-processor "docker-tag" {
        repository =  "${var.docker_hub_org}/${var.repo}"
        tag = ["latest"]
      }
    post-processor "docker-push" {
        login_username = var.login_username
        login_password = var.login_password
        login = true
      }
  }
}

