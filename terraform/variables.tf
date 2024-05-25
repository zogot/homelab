variable proxmox_node_name {
  type = string
}

variable proxmox_api_insecure {
  type = bool
  default = true
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
    disk_size = number
  }))
}

variable cilium_cli_version {
  description = "Cilium CLI version"
  type        = string
}

variable pihole_hashed_password {
  description = "Hashed Password for Pihole"
  type = string
}

variable onepassword_vault {
  description = "Vault where passwords for Jupiter are"
  type = string
}

variable onepassword_sat {
  description = "1password Service Account Token for Secrets for the Cluster"
  type = string
  sensitive = true
}

variable onepassword_cfile {
  description = "1password Credential file"
  type = string
  sensitive = true
}

variable onepassword_opct {
  description = "1password Connect Token"
  type = string
  sensitive = true
}