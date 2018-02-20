# Config for mining rig

## Beginning with the basics
We are configuring a rig running Ubuntu 16.04 LTS. The steps herein should be supported through April 2021 for a 64-bit architecture.

## Port forwarding via SSH (SSH tunneling)
In order to connect to the local rig using a remote machine, we need to setup port forwarding. This enable SSH traffic through the router to our rig.

### Setting up port forwarding for the router
#### Static IP
By default, we're using DHCP (Dynamic Host Configuration Protocol), but we want to change that to a static IP. The rationale behind this change is that by using a static IP, we will always reliably know the IP address of our rig. Otherwise, it is conceivable that the IP address will be dynamically reassigned underfoot, making ssh tunneling difficult if not impossible.

The steps we followed are laid out in [this tutorial](https://michael.mckinnon.id.au/2016/05/05/configuring-ubuntu-16-04-static-ip-address/), however for posterity (and dev editor preferences), we will duplicate the exact steps we took in order to set up our machine.

1. Find "# The primary network interface" and comment out the line `iface ens160 inet dhcp`.
2. Add below the commented line:
```
# Declare static IP address
iface ens160 inet static
	address <insert address>
	netmask 255.255.255.0
	gateway <insert gateway>
```
To find `address` and `gateway`, we can run `ip route show`. (`ifconfig` for IP).
3. Add `dns-nameservers` below that static IP. To do this, add the following:
```
# Signal google's public DNS as dns-nameservers
dns-nameservers 8.8.8.8 8.8.4.4
```
4. Make sure everything is correct, save the file and restart the networking service. You can do this by running:
`sudo /etc/init.d/networking restart`
If there are no errors, the primary network interface should be configured with the static IP address.

#### Router config
We are using instructions from the [following resource](https://portforward.com). Specifically, since the router we are using is an Apple Time Capsule, we can jump [directly to the apple page](https://portforward.com/apple/).