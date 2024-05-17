packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
  }
}

variable "packer_version" {
  type        = string
  description = "Terraform CLI Version"
  default     = "1.10.3"
}

variable "mitogen_version" {
  type        = string
  description = "Mitogen Version"
  default     = "0.3.7"
}

source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true
}

build {
  name    = "aws-image-pipeline"
  sources = [
    "source.docker.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y ansible awscli curl unzip",
      "curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py",
      "python3 get-pip.py --user",
      "curl -s -qL -o packer.zip https://releases.hashicorp.com/packer/${var.packer_version}/packer_${var.packer_version}_linux_amd64.zip",
      "unzip -o packer.zip",
      "mv packer /bin",
      "rm packer.zip",
      "curl -s -qL -o mitogen.tar.gz https://files.pythonhosted.org/packages/source/m/mitogen/mitogen-${var.mitogen_version}.tar.gz",
      "mv mitogen.tar.gz /opt; cd /opt; tar vxzf mitogen.tar.gz",
    ]
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
  }
  post-processors {
    post-processor "docker-tag" {
        repository =  "HappyPathway/aws-codebuild-image-pipeline"
        tag = [
          "latest"
        ]
      }
    post-processor "docker-push" {}
  }
}

