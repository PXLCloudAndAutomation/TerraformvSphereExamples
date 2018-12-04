# Terraform vSphere Examples
A collection of Terraform examples using the vSphere provider and other elements to demonstrate  different concepts.

## Prerequisites
There are a bunch of prerequisites to use these examples:

* A Unix-like host OS (OSX, GNU/Linux).
* Terraform (Terraform v0.11.10)
* Python 2 (Python 2.7.15rc1)
* VMware vSphere login access
* [CentOS-7-1NIC-base-template](https://drive.google.com/file/d/1rO3r3dLq1r0ftX7U0aAbCJvBWoaH4PCm/view) (Login/Passwd: user/user)
* [CentOS-7-2NICs-base-template](https://drive.google.com/file/d/1y-qoK7-AuzBmQDvthiD7eZZe03OtuNET/view) (Login/Passwd: user/user)

## Before running ANY example
VMWare vSphere access is absolutely necessary. Test this before running any of the examples. For example using Postman.

Make sure the provided templates [CentOS-7-1NIC-base-template](https://drive.google.com/file/d/1rO3r3dLq1r0ftX7U0aAbCJvBWoaH4PCm/view) and [CentOS-7-2NICs-base-template](https://drive.google.com/file/d/1y-qoK7-AuzBmQDvthiD7eZZe03OtuNET/view) are available on the vSphere system **as templates**. Deploy these as OVF and save them as templates.

## Before running an example
Each subdirectory, listed below in The examples, contains a complete Terraform example, including an `terraform.tfvars`  example file caled `terraform.tfvars_example`. 

Each example needs a few steps to get up and running. Execute the commands inside the directory of the example.

0. Remove the `_example` part from the example file. (**Pro-tip:** copy it!)
1. Alter the values of the variables in `terraform.tfvars`.
   Do not forget to uncomment the login information and add your own credentials.
2. `$ terraform init`
3. `$ terraform plan`
4. `$ terraform apply`

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

### `04_AddSSHKeyToClone`
This will clone from a existing template and add an SSH key.

To bybass ssh issues (Already known SSH host) use the following SSH options:

```bash
$ ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i key/id_rsa user@10.72.29.20
```

### `05_AddWebserverToCloneFromTempate`
This provisions a clone, it adds Apache and PHP to create a simple webserver. 

**Save this VirtualMachine as `CentOS-7-1NIC-webserver-template`. It is needed in the following Example**.

### `06_CentOSHAProxyOwnCluster`
The end result of this example is small setup containing a round robin load balancer using a HAProxy on Centos and multiple webservers (= cattle) on a private network.

To test the HAProxy you can execute `wget`:

For example:
```bash
$ wget 10.72.29.20 2>/dev/null; cat index.html | grep served; rm index.html
```

