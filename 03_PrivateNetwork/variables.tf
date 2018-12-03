variable "vsphere_server_login" {
	description = "The credentials for the VMware cluster." 
	type = "map"
}

variable "datacenter" {
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
