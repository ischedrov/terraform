terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "rebrain_key" {
  name = var.rebrain_ssh_key
}

output "ssh" {
  value = data.digitalocean_ssh_key.rebrain_key.fingerprint
}


data "digitalocean_sizes" "available_sizes" {
  filter {
    key    = "vcpus"
    values = [1]
  }
  filter {
    key    = "memory"
    values = [1024]
  }
  filter {
    key    = "disk"
    values = [25]
  }
}

data "digitalocean_images" "image" {
  filter {
    key    = "distribution"
    values = ["Ubuntu 20.04 LTS"]
  }
}

resource "digitalocean_tag" "module_name" {
  name = var.course_name
}

resource "digitalocean_tag" "your_name" {
  name = var.email
}

resource "digitalocean_droplet" "test" {
  name     = "test vrs"
  image    = data.digitalocean_images.image.id
  size     = data.digitalocean_sizes.available_sizes.id
  region   = var.do_region
  ssh_keys = [data.digitalocean_ssh_key.rebrain_key.fingerprint]
  tags     = [digitalocean_tag.module_name.id, digitalocean_tag.your_name.id]
}
