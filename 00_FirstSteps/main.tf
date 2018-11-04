provider "vsphere" {
  user           = "${var.vsphere_server_login["user"]}"
  password       = "${var.vsphere_server_login["password"]}"
  vsphere_server = "${var.vsphere_server_login["ip"]}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

