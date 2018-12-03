# Login
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

data "vsphere_host" "esxi_host" {
  name          = "${var.esxi_host}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_host_virtual_switch" "vswitch" {
  name           = "${var.vswitch_name}"
  host_system_id = "${data.vsphere_host.esxi_host.id}"

  network_adapters = []

  active_nics  = []
  standby_nics = []
}

resource "vsphere_host_port_group" "port_group" {
  name                = "${var.port_group_name}"
  host_system_id      = "${data.vsphere_host.esxi_host.id}"
  virtual_switch_name = "${vsphere_host_virtual_switch.vswitch.name}"
}

data "vsphere_network" "internal_network" {
  depends_on = ["vsphere_host_port_group.port_group"]
	name = "${var.port_group_name}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
