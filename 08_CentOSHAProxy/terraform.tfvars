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

# SSH information
ssh_user     = ""
ssh_password = ""
id_rsa       = ""

# Firewall information
firewall_template  = "CentOS-7-template"
firewall_vmname    = "firewall"
firewall_num_cpus  = 2
firewall_memory    = 1024
firewall_disk      = "firewall"
firewall_host_name = "firebastion"
firewall_domain    = "local"

firewall_wan_nic    = "ens192"
firewall_lan_nic    = "ens224"
firewall_lan_zone   = "internal"
firewall_lan        = "192.168.0.0"
firewall_lan_mask   = "255.255.255.0"
firewall_lan_prefix = "24"
firewall_lan_ip     = "192.168.0.1"
firewall_lan_DNS1   = "192.168.0.1"
firewall_lan_DNS2   = "10.50.40.100" # PXL DNS Server
firewall_lan_DNS3   = "10.50.40.101" # PXL DNS Server
firewall_dhcp_begin = "192.168.0.10"
firewall_dhcp_end   = "192.168.0.250"
firewall_dhcp_time  = "12h"


# Server information
server_template  = "CentOS-7-webserver-template"
server_vmname    = "webserver"
server_num_cpus  = 2
server_memory    = 2048
server_disk      = "server"
server_host_name = "webserver"
server_domain    = "local"
