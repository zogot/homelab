data "onepassword_item" "proxmox-api-credentials" {
  vault = var.onepassword_vault
  title = "Proxmox API Token"
}