# Terraform vSphere Examples
A collection of Terraform examples using the vSphere provider and other elements to demonstrate  different concepts.

## Prerequisites
There are a bunch of prerequisites to use these examples:

* A Unix-like host OS (OSX, GNU/Linux).
* Terraform (Terraform v0.11.10)
* Python 2 (Python 2.7.15rc1)
* VMware vSphere 6.5 login access
* VMware esxi 6.5 login access
* CentOS-7-template (More info TBA)
* CentOS-7-webserver-template (More info TBA)
* pfSense-CE-2.4.4-template (More info TBA)
* SSH keys to access the templates

## Before running ANY example
VMWare vSphere and VMWare esxi access is absolutely necessary. Test it is before
running any of the examples.

## Before running an example
Each subdirectory, listed below in The examples, contains a complete Terraform example, including the `terraform.tfvars` file. Each example needs 3 steps to get up and running. Execute the commands inside the directory of the example.

1. Fill in the necessary variables.
2. `$ terraform plan`
3. `$ terraform apply`

## Before moving to another example
Always clean up before going to the next (or previous) example, otherwise (strange) errors can occur. Debugging those is time consuming.

```bash
$ terraform destroy
```

## The examples
This gives a short overview of all the examples.

### `00_FirstSteps`
Take a few first steps with Terraform and its vSphere provider.

### `01_DataSources`
This inspects different data sources on a vSphere system.

### `02_SimpleCloneFromTemplate`
This creates a simple virtual machine from an already existing template.

### `03_PrivateNetwork`
A virtual switch and port group are the building blocks to create a private network on esxi. This example explains how Terraform can create such network.

### `04_SecondCloneFromTemplate`
A second example to create a virtual machine from a template.

### `05_AddWebserverToCloneFromTempate`
This provisions a clone, it adds Apache and PHP to create a simple webserver.

### `06_MultipleWebServersBehindpfSense`
This example creates a small setup, putting pfSense in front of a fixnum of webservers.

### `07_CentOSNATRouter`
A NAT router will be create in this example.

### `08_CentOSHAProxy`
The end result of this example is small setup containing a round robin load balancer using a HAProxy on Centos and multiple webservers on a private network.

