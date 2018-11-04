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

# ------------------------------------------------------------------------------
# Describe the webserver
# ------------------------------------------------------------------------------
data "vsphere_virtual_machine" "server_template" {
	name = "${var.server_template}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "web_server" {
  name = "${var.server_vmname}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"
  
  num_cpus = "${var.server_num_cpus}"
  memory   = "${var.server_memory}"
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

      network_interface {} # Even if the network isn't customized, it needs to
                           # have a block here.
                           # This is a bug in the current Terraform version.
                           # TODO: Check if the bug is still present.
    }
  }
}


# Provision the web server
# ------------------------------------------------------------------------------
resource "null_resource" "webserver_provisioner" {
	depends_on = ["vsphere_virtual_machine.web_server"] 

  triggers = {
    werbserver = "${vsphere_virtual_machine.web_server.id}"
  }

  connection {
    type = "ssh"
    # TODO: Make this more generic.
    host = "${vsphere_virtual_machine.web_server.0.guest_ip_addresses.0}"
    user = "${var.ssh_user}"
    private_key = "${file(var.id_rsa)}"
  }

  provisioner "remote-exec" {
    inline = [
      "yum upgrade -y",
      "yum -y install httpd",
      "yum -y install php",
    ]
  }

  provisioner "file" {
    source      = "./files/index.php"
    destination = "/var/www/html/index.php"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl start httpd.service",
      "systemctl enable httpd.service",
      "firewall-cmd --permanent --zone=public --add-service=http",
      "firewall-cmd --permanent --zone=public --add-service=https",
      "firewall-cmd --reload",
    ]
  }

	provisioner "local-exec" {
    command = "echo 'Webserver IP: ${vsphere_virtual_machine.web_server.default_ip_address}' > ip.txt"
  }
}
