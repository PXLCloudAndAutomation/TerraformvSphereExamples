variable "vsphere_server_login" {
	description = "The credentials for the VMware cluster." 
	type = "map"
}

variable "datacenter" {
  type = "string" 
}

variable "datastore" {
  type = "string"
}

variable "resource_pool" {
  type = "string"
}

variable "virtual_machines_folder" {
  type = "string"
}

variable "esxi_host" {
  type = "string"
}

variable "vswitch_name" {
  type = "string"
}
 
variable "port_group_name" {
  type = "string"
}
variable "network" {
  type = "string"
}

variable "firewall_template" {
  type = "string" 
}

variable "firewall_vmname" {
  type = "string" 
  description = "The name of the VM."
}

variable "firewall_num_cpus" {} 
variable "firewall_memory" {}

variable "firewall_disk" {
  type = "string"
}

variable "firewall_host_name" {
  type = "string"
}

variable "firewall_domain" {
  type = "string"
}

variable "firewall_wan_nic" {
  type = "string"
}

variable "firewall_wan_ipv4_address" {
  type = "string"
}

variable "firewall_wan_ipv4_netmask" {
  default = "24"
}

variable "firewall_wan_ipv4_gateway" {
  type = "string"
}

variable "firewall_wan_dns_server_list" {
  type = "list"
}

variable "firewall_lan_nic" {
  type = "string"
}

variable "firewall_lan_zone" {
  type = "string"
}

variable "firewall_lan" {
  type = "string"
}

variable "firewall_lan_mask" {
  type = "string"
}

variable "firewall_lan_prefix" {
  type = "string"
}

variable "firewall_lan_ip" {
  type = "string"
}

variable "firewall_lan_DNS1" {
  type = "string"
}

variable "firewall_lan_DNS2" {
  type = "string"
}

variable "firewall_lan_DNS3" {
  type = "string"
}

variable "firewall_dhcp_begin" {
  type = "string"
}

variable "firewall_dhcp_end" {
  type = "string"
}

variable "firewall_dhcp_time" {
  type = "string"
}

variable "number_of_webservers" {} 

variable "server_template" {
  type = "string" 
}

variable "server_vmname" {
  type = "string" 
  description = "The name of the VM."
}

variable "server_num_cpus" {} 
variable "server_memory" {}

variable "server_disk" {
  type = "string"
}

variable "server_host_name" {
  type = "string"
}

variable "server_domain" {
  type = "string"
}

variable "ssh_user" {
	type = "string"
}

variable "ssh_password" {
	type = "string"
}

variable "id_rsa" {
	type = "string"
}
