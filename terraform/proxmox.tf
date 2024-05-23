data "onepassword_item" "proxmox_api_credentials" {
  vault = var.onepassword_vault
  title = "Proxmox API Token"
}