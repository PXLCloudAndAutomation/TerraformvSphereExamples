provider "vsphere" {
  user           = "${var.vsphere_server_login["user"]}"
  password       = "${var.vsphere_server_login["password"]}"
  vsphere_server = "${var.vsphere_server_login["vsphere_server"]}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
	name = "${var.datacenter}"
}

data "vsphere_datastore" "datastore" {
	name = "${var.datastore}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "iso_datastore" {
	name = "${var.iso_datastore}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
	name = "${var.resource_pool}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
	name = "${var.network}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
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
	name = "${var.port_group_name}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
  depends_on = ["vsphere_host_port_group.port_group"]
}

data "vsphere_virtual_machine" "firewall_template" {
	name = "${var.firewall_template}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "firewall" {
  name = "${var.firewall_vmname}"
  wait_for_guest_net_timeout = 0 
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"
  
  num_cpus = "${var.firewall_num_cpus}"
  memory   = "${var.firewall_memory}"
  guest_id = "${data.vsphere_virtual_machine.firewall_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.firewall_template.scsi_type}"
  
  network_interface {
    network_id  = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.firewall_template.network_interface_types[0]}"
  }

  network_interface {
    network_id  = "${data.vsphere_network.internal_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.firewall_template.network_interface_types[1]}"
  }
  
  disk {
    label = "${var.firewall_disk}.vmdk"
    size  = "${data.vsphere_virtual_machine.firewall_template.disks.0.size}"
    eagerly_scrub = "${data.vsphere_virtual_machine.firewall_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.firewall_template.disks.0.thin_provisioned}"
  }
  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.firewall_template.id}"
  }

  depends_on = ["vsphere_host_port_group.port_group"]
}

data "vsphere_virtual_machine" "server_template" {
	name = "${var.server_template}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "web_server" {
  count = 2 
  name = "${var.server_vmname}${count.index + 1}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"
  
  num_cpus = "${var.server_num_cpus}"
  memory   = "${var.server_memory}"
  guest_id = "${data.vsphere_virtual_machine.server_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.server_template.scsi_type}"
  
  network_interface {
    network_id  = "${data.vsphere_network.internal_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.server_template.network_interface_types[0]}"
  }
  
  disk {
    label = "${var.server_disk}${count.index + 1}.vmdk"
    size  = "${data.vsphere_virtual_machine.server_template.disks.0.size}"
    eagerly_scrub = "${data.vsphere_virtual_machine.server_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.server_template.disks.0.thin_provisioned}"
  }
  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.server_template.id}"
    
    customize {
      linux_options {
        host_name = "${var.server_host_name}${count.index +1}"
        domain = "${var.server_domain}"
      }

      network_interface {}
    }
  }

  depends_on = ["vsphere_host_port_group.port_group"]
}

resource "null_resource" "after_web_server" {
  depends_on = ["vsphere_virtual_machine.web_server"]

  triggers {
    firewall    = "${vsphere_virtual_machine.firewall.id}"
    servers     = "${join(":", vsphere_virtual_machine.web_server.*.id)}"
    servers_ips = "${join(":", vsphere_virtual_machine.web_server.*.default_ip_address)}"
  }

  # TODO Terraform doesn't seem to know the IP address of psSense.
  # Hence the "wait_for_guest_net_timeout = 0" while cloning.
  # Therefore no IP can be written to a file here.

	provisioner "local-exec" {
    command = "echo 'Server IPs: ${join(":", vsphere_virtual_machine.web_server.*.default_ip_address)}' > private_ips.txt"
  }
}
