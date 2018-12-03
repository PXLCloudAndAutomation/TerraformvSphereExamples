provider "vsphere" {
  version = "~> 1.9"
  user           = "${var.vsphere_server_login["user"]}"
  password       = "${var.vsphere_server_login["password"]}"
  vsphere_server = "${var.vsphere_server_login["vsphere_server"]}"

  # If you have a self-signed cert
  allow_unverified_ssl = "${var.vsphere_server_login["allow_unverified_ssl"]}"
}

data "vsphere_datacenter" "dc" {
	name = "${var.datacenter}"
}

data "vsphere_datastore" "datastore" {
	name = "${var.datastore}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# TODO This can be the same datastore as the previous block
data "vsphere_datastore" "iso_datastore" {
	name = "${var.iso_datastore}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# TODO If your don't have a resource_pool, create one or remove this block!
data "vsphere_resource_pool" "pool" {
	name = "${var.resource_pool}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
	name = "${var.network}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "server_template" {
	name = "${var.server_template}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
