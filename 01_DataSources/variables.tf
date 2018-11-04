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

variable "server_template" {
  type = "string" 
}
