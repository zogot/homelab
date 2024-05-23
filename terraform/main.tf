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

    onepassword = {
      source = "1Password/onepassword"
      version = "2.0.0"
    }
  }
}

provider "proxmox" {
  alias = "jupiter"
  endpoint = data.onepassword_item.proxmox_api_credentials.url
  insecure = true

  api_token = data.onepassword_item.proxmox_api_credentials.password

  ssh {
    agent = true
    username = data.onepassword_item.proxmox_api_credentials.username
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

provider "onepassword" {
  service_account_token = var.onepassword_sat
}