# Creating repository and adding public key to it

terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}

provider "gitlab" {
  token    = var.token
  base_url = var.url
}

data "gitlab_group" "own_group" {
  full_path = var.git_path
}

resource "gitlab_project" "terraform_01" {
  name         = "terraform_01"
  namespace_id = data.gitlab_group.own_group.group_id
}

resource "gitlab_deploy_key" "ssh_key" {
  title    = "terraform_deploy_key"
  project  = gitlab_project.terraform_01.id
  key      = file(var.ssh_path)
  can_push = true
}


