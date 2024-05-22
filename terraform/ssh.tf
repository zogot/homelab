resource "tls_private_key" "terraform_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "terraform_public_key" {
  value = tls_private_key.terraform_key.public_key_openssh
}