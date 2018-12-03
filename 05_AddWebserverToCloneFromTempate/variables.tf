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

variable "network" {
  type = "string"
}

variable "server_template" {
  type = "string" 
}

variable "server_vmname" {
  type = "string" 
  description = "The name of the VM."
}

variable "virtual_machines_folder" {
  type = "string"
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

variable "ipv4_address" {
  type = "string"
}

variable "ipv4_netmask" {
  default = "24"
}

variable "ipv4_gateway" {
  type = "string"
}

variable "dns_server_list" {
  type = "list"
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
