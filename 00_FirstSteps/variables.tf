variable "vsphere_server_login" {
  description = "The credentials for the VMware cluster." 
  type = "map"
}

variable "datacenter" {
  type = "string" 
}
