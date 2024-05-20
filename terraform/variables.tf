variable proxmox_node_name {
  type = string
}

variable proxmox_api_url {
  type = string
}

variable proxmox_api_insecure {
  type = bool
  default = true
}

variable proxmox_api_token {
  type = string
  sensitive = true
}

variable proxmox_username {
  description = "The Username used by SSH"
  type = string
  default = "root"
}


variable vm_user {
  description = "VM username"
  type = string
}

variable vm_password {
  description = "VM Password used for Sudo"
  type = string
  sensitive = true
}

variable "vm_dns_domain" {
  type = string
}

variable "vm_dns_servers" {
  type = list(string)
}

variable "vm_timezone" {
  type = string
}

variable public_key {
  description = "SSH Public Key"
  type = string
}

variable k8s_version {
  description = "Kubernetes version"
  type        = string
}

variable k8s_workers {
  description = "Total amount of workers"
  type = list(object({
    id = number
    cores = number
    memory = number
  }))
}

variable cilium_cli_version {
  description = "Cilium CLI version"
  type        = string
}