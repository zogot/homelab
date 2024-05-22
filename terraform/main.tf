terraform {
  required_version = ">= 0.13.0"

  cloud {
    organization = "homelab-rowland-nl"
    workspaces {
      name = "homelab"
    }
  }

  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.57.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.13.2"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }
}

provider "proxmox" {
  alias = "jupiter"
  endpoint = var.proxmox_api_url
  insecure = true

  api_token = var.proxmox_api_token

  ssh {
    agent = true
    username = var.proxmox_username
  }
}

provider "helm" {
  kubernetes {
    config_path = "../output/kubernetes/config"
  }
}

provider "kubernetes" {
  config_path = "../output/kubernetes/config"
}