# Login information
vsphere_server_login {
  "user"           = ""
  "password"       = ""
  "vsphere_server" = ""
}

# Datacenter information
datacenter    = "Datacenter"
datastore     = "datastore1"
iso_datastore = "datastore1"
resource_pool = "CnAResourcePool"
network       = "VM Network"

# Setup information
esxi_host       = ""
vswitch_name    = "InternalSwitch"
port_group_name = "InternalPortGroup"

# Firewall information
firewall_template = "pfSense-CE-2.4.4-template"
firewall_vmname   = "firewall"
firewall_num_cpus = 1
firewall_memory   = 1024
firewall_disk     = "firewall"

# Server information
server_template  = "CentOS-7-webserver-template"
server_vmname    = "webserver"
server_num_cpus  = 1
server_memory    = 1024
server_disk      = "server"
server_host_name = "webserver"
server_domain    = "local"
