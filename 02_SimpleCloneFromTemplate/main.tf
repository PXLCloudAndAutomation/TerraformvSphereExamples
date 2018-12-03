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

# TODO If your setup don't have a resource_pool, create one!
data "vsphere_resource_pool" "pool" {
	name = "${var.resource_pool}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
	name = "${var.network}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# ------------------------------------------------------------------------------
# Describe the server
# ------------------------------------------------------------------------------
data "vsphere_virtual_machine" "server_template" {
	name = "${var.server_template}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "server" {
  name = "${var.server_vmname}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"

  folder = "${var.virtual_machines_folder}"

  num_cpus = "${var.server_num_cpus}"
  memory   = "${var.server_memory}"
  memory_reservation = "${var.server_memory}"
  guest_id = "${data.vsphere_virtual_machine.server_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.server_template.scsi_type}"
  
  network_interface {
    network_id  = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.server_template.network_interface_types[0]}"
  }
  
  disk {
    label = "${var.server_disk}.vmdk"
    size = "${data.vsphere_virtual_machine.server_template.disks.0.size}"
    eagerly_scrub = "${data.vsphere_virtual_machine.server_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.server_template.disks.0.thin_provisioned}"
  }
  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.server_template.id}"
    
    customize {
      linux_options {
        host_name = "${var.server_host_name}"
        domain = "${var.server_domain}"
      }

      network_interface {
        ipv4_address = "${var.ipv4_address}"
        ipv4_netmask = "${var.ipv4_netmask}"
      } # Even if the network isn't customized, it needs to
                           # have a block here.
                           # This is a bug in the current Terraform version.
                           # TODO: Check if the bug is still present.
      ipv4_gateway = "${var.ipv4_gateway}"
      dns_server_list = "${var.dns_server_list}"
    }
  }
}
