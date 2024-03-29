provider "vsphere" {
  version = "~> 1.9"
  user           = "${var.vsphere_server_login["user"]}"
  password       = "${var.vsphere_server_login["password"]}"
  vsphere_server = "${var.vsphere_server_login["vsphere_server"]}"

  # If you have a self-signed cert
  allow_unverified_ssl = "${var.vsphere_server_login["allow_unverified_ssl"]}"
}

provider "null" {
  version = "~> 1.0"
}

data "vsphere_datacenter" "dc" {
	name = "${var.datacenter}"
}

data "vsphere_datastore" "datastore" {
	name = "${var.datastore}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# TODO If your setup doesn't have a resource_pool, create one!
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
  depends_on = ["vsphere_host_port_group.port_group"]
	name = "${var.port_group_name}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


data "vsphere_virtual_machine" "firewall_template" {
	name = "${var.firewall_template}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


# ------------------------------------------------------------------------------
# Describe the firewall
# ------------------------------------------------------------------------------
resource "vsphere_virtual_machine" "firewall" {
  depends_on = ["vsphere_host_port_group.port_group"]

  /* wait_for_guest_net_timeout = 0 */

  name = "${var.firewall_vmname}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"

  folder = "${var.virtual_machines_folder}"
  
  num_cpus = "${var.firewall_num_cpus}"
  memory   = "${var.firewall_memory}"
  memory_reservation = "${var.firewall_memory}"
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
    size = "${data.vsphere_virtual_machine.firewall_template.disks.0.size}"
    eagerly_scrub = "${data.vsphere_virtual_machine.firewall_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.firewall_template.disks.0.thin_provisioned}"
  }
  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.firewall_template.id}"

    customize {
      linux_options {
        host_name = "${var.firewall_host_name}"
        domain = "${var.firewall_domain}"
      }

      network_interface {
        ipv4_address = "${var.firewall_wan_ipv4_address}"
        ipv4_netmask = "${var.firewall_wan_ipv4_netmask}"
      }

      network_interface{
        ipv4_address = "${var.firewall_lan_ip}"
        ipv4_netmask = "${var.firewall_lan_prefix}"
      }

      ipv4_gateway = "${var.firewall_wan_ipv4_gateway}"
      dns_server_list = "${var.firewall_wan_dns_server_list}"
    }
  }
}

# Add a new SSH key to the server.
# ------------------------------------------------------------------------------
resource "null_resource" "firewall_add_ssh_key" {
	depends_on = ["vsphere_virtual_machine.firewall"] 

  triggers = {
    werbserver = "${vsphere_virtual_machine.firewall.id}"
  }

  provisioner "local-exec" {
    command = "./create_ssh_keys_local.sh"
  }

  connection {
    type = "ssh"
    host = "${var.firewall_wan_ipv4_address}"
    user = "${var.ssh_user}"
    password = "${var.ssh_password}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir ~/.ssh/",
      "chmod 700 /home/${var.ssh_user}/.ssh/",
    ]
  }

  provisioner "file" {
    source      = "./key/id_rsa.pub"
    destination = "/home/${var.ssh_user}/.ssh/authorized_keys"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/${var.ssh_user}/.ssh/authorized_keys",
    ]
  }
}

# ------------------------------------------------------------------------------
# Provision the firewall
# ------------------------------------------------------------------------------
resource "null_resource" "firewall_provisioner" {
	depends_on = ["null_resource.firewall_add_ssh_key"]

  triggers {
    firewall = "${vsphere_virtual_machine.firewall.id}"
  }

  connection {
    type = "ssh"
    host = "${var.firewall_wan_ipv4_address}"
    user = "${var.ssh_user}"
    private_key = "${file(var.id_rsa)}"
  }

  # Update the server.
  provisioner "remote-exec" {
    inline = [
      "sudo yum upgrade -y",
    ]
  }

  # Set up the NIC for the private network.
  provisioner "remote-exec" {
    inline = [
      "sudo head -5 /etc/sysconfig/network-scripts/ifcfg-${var.firewall_lan_nic} >> /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "echo 'BOOTPROTO=none' >> /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "echo 'ZONE=${var.firewall_lan_zone}' >> /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "echo 'IPADDR=${var.firewall_lan_ip}' >> /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "echo 'PREFIX=${var.firewall_lan_prefix}' >> /${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "echo 'DEFROUTE=yes' >> /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "echo 'IPV4_FAILURE_FATAL=no' >> /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "echo 'IPV6INIT=no' >> /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic}",
      "sudo mv /home/${var.ssh_user}/ifcfg-${var.firewall_lan_nic} /etc/sysconfig/network-scripts/ifcfg-${var.firewall_lan_nic}",
      "sudo systemctl restart network",
    ]
  }

  # Install and configure NAT and its dependencies.
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y ntp",
      "sudo yum install -y dnsmasq",
      "sudo bash -c \"echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf\"",
			"sudo sysctl -p",
      "sudo systemctl enable firewalld",
      "sudo systemctl start firewalld",
			"sudo firewall-cmd --permanent --zone=internal --add-interface=${var.firewall_lan_nic}",
      "sudo firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o ${var.firewall_wan_nic} -j MASQUERADE",
      "sudo firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i ${var.firewall_lan_nic} -o ${var.firewall_wan_nic} -j ACCEPT",
      "sudo firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i ${var.firewall_wan_nic} -o ${var.firewall_lan_nic} -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "sudo firewall-cmd --permanent --zone=${var.firewall_lan_zone} --add-port=53/udp",
      "sudo firewall-cmd --permanent --zone=${var.firewall_lan_zone} --add-port=67/udp",
      "sudo firewall-cmd --permanent --zone=${var.firewall_lan_zone} --add-port=123/udp",
      "sudo firewall-cmd --permanent --zone=${var.firewall_lan_zone} --add-port=80/udp",
      "sudo firewall-cmd --permanent --zone=${var.firewall_lan_zone} --add-port=80/tcp",
      "sudo firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client",
      "sudo firewall-cmd --reload",
      "sudo bash -c \"echo 'interface=${var.firewall_lan_nic}' >> /etc/dnsmasq.conf\"",
      "sudo bash -c \"echo 'listen-address=${var.firewall_lan_ip}' >> /etc/dnsmasq.conf\"",
      "sudo bash -c \"echo 'dhcp-range=${var.firewall_dhcp_begin},${var.firewall_dhcp_end},${var.firewall_dhcp_time}' >> /etc/dnsmasq.conf\"",
      "sudo bash -c \"echo 'dhcp-option=option:dns-server,${var.firewall_lan_DNS1},${var.firewall_lan_DNS2},${var.firewall_lan_DNS3}' >> /etc/dnsmasq.conf\"",
      "sudo bash -c \"echo 'dhcp-option=option:router,${var.firewall_lan_ip}' >> /etc/dnsmasq.conf\"",
      "sudo bash -c \"echo 'dhcp-option=option:ntp-server,${var.firewall_lan_ip}' >> /etc/dnsmasq.conf\"",
      "sudo bash -c \"echo 'restrict ${var.firewall_lan} mask ${var.firewall_lan_mask} nomodify notrap' >> /etc/ntp.conf\"",
      "sudo ystemctl enable dnsmasq",
      "sudo systemctl start dnsmasq",
      "sudo systemctl enable ntpd",
      "sudo systemctl start ntpd",
    ]
  }

  # Install HAProxy and cofigure the firewall to allow incomming traffic.
  # The HAProxy config is done AFTER the webservers are created. 
  # (Why? Their IPs are not known yet.)
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y haproxy",
      "sudo firewall-cmd --permanent --zone=public --add-service=http",
      "sudo firewall-cmd --permanent --zone=public --add-service=https",
      "sudo firewall-cmd --reload",
    ]
  }
}


# ------------------------------------------------------------------------------
# Describe the webserver(s)
# ------------------------------------------------------------------------------
data "vsphere_virtual_machine" "server_template" {
	name = "${var.server_template}"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "web_server" {
  depends_on = ["null_resource.firewall_provisioner"]

  count = "${var.number_of_webservers}" 
  name = "${var.server_vmname}${count.index + 1}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"

  folder = "${var.virtual_machines_folder}"
  
  num_cpus = "${var.server_num_cpus}"
  memory   = "${var.server_memory}"
  memory_reservation = "${var.server_memory}"
  guest_id = "${data.vsphere_virtual_machine.server_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.server_template.scsi_type}"
  
  network_interface {
    network_id  = "${data.vsphere_network.internal_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.server_template.network_interface_types[0]}"
  }
  
  disk {
    label = "${var.server_disk}${count.index + 1}.vmdk"
    size = "${data.vsphere_virtual_machine.server_template.disks.0.size}"
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

      network_interface {} # An empty block will configure the NIC to DHCP
    }
  }
}

resource "null_resource" "after_web_server" {
  depends_on = ["vsphere_virtual_machine.web_server"]

  triggers {
    firewall       = "${vsphere_virtual_machine.firewall.id}"
    webservers     = "${join(":", vsphere_virtual_machine.web_server.*.id)}"
    webservers_ips = "${join(":", vsphere_virtual_machine.web_server.*.default_ip_address)}"
  }

	provisioner "local-exec" {
    command = "echo '${join(":", vsphere_virtual_machine.web_server.*.default_ip_address)}' > private_ips.txt"
  }

  # Generate the correct hosts file and ha proxy file.
  # Unfortunately Terraform null_resource has no inline for local-exec
  # Let's use a Python2 script.
	provisioner "local-exec" {
    command = "./gen_haproxy_and_hosts_files.py ${var.firewall_host_name} ${var.firewall_domain} ${join(":", vsphere_virtual_machine.web_server.*.default_ip_address)}"
  }

  connection {
    type = "ssh"
    # TODO: Make this more generic.
    host = "${vsphere_virtual_machine.firewall.0.guest_ip_addresses.0}"
    user = "${var.ssh_user}"
    private_key = "${file(var.id_rsa)}"
  }

  # TODO ERROR ROOT RIGHTS copy to ~ en move to /... !!! 
  provisioner "file" {
    source      = "./files/hosts"
    destination = "/home/${var.ssh_user}/hosts"
  }

  provisioner "file" {
    source      = "./files/haproxy.cfg"
    destination = "/home/${var.ssh_user}/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/${var.ssh_user}/hosts /etc/hosts",
      "sudo mv /home/${var.ssh_user}/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo systemctl restart haproxy",
    ]
  }
}
