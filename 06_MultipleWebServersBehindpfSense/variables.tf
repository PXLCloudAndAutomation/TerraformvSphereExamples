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

variable "iso_datastore" {
  type = "string"
}

variable "resource_pool" {
  type = "string"
}

variable "network" {
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
