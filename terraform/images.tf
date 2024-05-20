resource "proxmox_virtual_environment_download_file" "debian_12_generic_image" {
  provider     = proxmox.jupiter
  node_name    = var.proxmox_node_name
  content_type = "iso"
  datastore_id = "local"

  file_name          = "debian-12-generic-amd64-20240507-1740.img"
  url                = "https://cloud.debian.org/images/cloud/bookworm/20240507-1740/debian-12-generic-amd64-20240507-1740.qcow2"
  checksum           = "f7ac3fb9d45cdee99b25ce41c3a0322c0555d4f82d967b57b3167fce878bde09590515052c5193a1c6d69978c9fe1683338b4d93e070b5b3d04e99be00018f25"
  checksum_algorithm = "sha512"
}