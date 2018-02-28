# Remotely configging a mining rig

This project is a tutorial for setting up an Ethereum mining rig from a remote location. While there exist many tutorials online, the hardware we used appears to be more obscure, so...enjoy!
Hopefully this is helpful.

It may go without saying, but this is a two man project that requires heavy involvement from the person who has access to the physical machine at the onset. Once the SSH tunneling is set up, the rest of the work can be done remotely.

The steps we will follow to set this machine up is:
- [X] Set up SSH tunneling into our machine
- [X] Configure our local ssh so we don't need to type in passwords when using SSH
- [] Set up VNC through the SSH tunnel in order to access a GUI (can be useful)
- [] Install drivers (CUDA) so that our NVIDIA GPU work can be parallelized

## Beginning with the basics
### Hardware inventory
Apple Airport Extreme
NVIDIA 1060
NVIDIA 1070

### Software Inventory
We are configuring a rig running Ubuntu 16.04 LTS. The steps herein should be supported through April 2021 for a 64-bit architecture.

## Establishing SSH tunneling
In order to connect to the mining rig using a remote machine, we need to:
- [X] Set up a static IP on our local machine
- [X] Configure the Router for Port Forwarding


### Setting up port forwarding for the router
#### Static IP
Out of the box, Ubuntu use DHCP (Dynamic Host Configuration Protocol) to set our IPs, but we want to change that to a static IP. The rationale behind this change is that by using a static IP, we will always reliably know the IP address of our rig. Otherwise, it is conceivable that the IP address will be dynamically reassigned underfoot, making ssh tunneling difficult if not impossible.

As of February 22, 2018, the out of the box configuration for Ubuntu 16.04 LTS Desktop is configured differently than many of the tutorials we encountered\*. As a result, we opted to set the IP to be a static one using the "Network Connections" GUI tool in Ubuntu. 

First, we needed to find the local IP address, gateway, and netmask. To find the local IP address and netmask, we run `ifconfig`. 

In `ifconfig`'s output, we first identify the connection to the internet (i.e. `enp0s31f6` on our machine), then the local IP address and netmask are the corresponding values next to `inet addr` and `Mask`, respectively.

To find the gateway, we run `nmcli dev show` and record the value associated with the `IP4_GATEWAY` variable.

We open the "Network Connections" GUI tool, navigate to the available connection, then select Edit.
After navigating to the IPv4 Settings, we select "Manual" in the "Method" dropdown, then input our recorded IP, netmask, and gateway values.
In the DNS nameserver, we will set the values to be Google's public DNS (`8.8.8.8 8.8.4.4`).

Finally, we restart the networking service by running `sudo /etc/init.d/networking restart`.

If there are no errors, the primary network interface should be configured with the static IP address.

\* While many Ubuntu 16.04 guides reference setting a static IP in `/etc/network/interfaces`, our config file did not match. Instead our file mirrored [these](https://askubuntu.com/questions/874689/16-04-static-ip) [askUbuntu](https://askubuntu.com/questions/948078/ubuntu-16-04-where-is-the-network-configuration) posts':
```
auto lo
iface lo inet loopback
``` 


#### Setting up port forwarding on the router

The router we have chosen is an Apple Airport Extreme (actually, it's a Time Capsule, but who's really keeping score :P). In order to configure our router, we are running a version of the Airport Utility 6.X.

In order to allow traffic from outside of the network within, we had to modify the approach contained within [this tutorial](https://www.rainmachine.com/support/portforwarding/Port-Forwarding-Apple-AirPortExtreme-Router-for-HTTPS.pdf) to incorporate information from [this informative thread](https://lime-technology.com/forums/topic/31154-how-to-request-ssh-from-outside-home-network/).

1. First, we have to reserve the IP address we set for our rig. We can do that by opening the AirPort Utility, then navigating through the following:
*AirPort Utility​> Select the base station​> Edit​> Network​* tab
	1. Verify the Router Mode is "​DHCP and NAT"
	2. Click the Add *+* ​button under DHCP Reservations
	3. Description: <enter the desired description of the host device> eg: *Mining Rig*
	4. Reserve address by: *MAC address*
	5. MAC Address: <Mining Rig's MAC Address> eg: *64:70:a6:34:65:12*. This can be found by running `ifconfig | grep HWaddr` on the mining rig's CLI.
	6. IPv4 Address: <enter the desired Private (LAN­side) IP address that we want to reserve from
the DHCP pool of addresses> eg: *192.168.1.2*
	7. Click Save ​button
2. Second, we need to configure the port forwarding for our reserved IP address. This work will also be on the same *Network* tab in the Airport Utility where just reserved the private IP address.
	1. Click the Add *+* ​button under Port Settings
	2. Description: <Remote Login - SSH>
	3. Public UDP Port(s): <leave blank>
	4. Public TCP Port(s): <this should auto-populate with the value of 22>. For security's sake, it is important to change this to an uncommon and [unreserved port number](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_number) (e.g. 21011). This will act as a first deterrant to prevent people from infilitrating your system using SSH.
	5. Private IP Address: <enter the private IP address we reserved in the previous step> 
	6. Private UDP Port(s): <leave blank>
	7. Private TCP Port(s): <this should auto-populate with the value of 22> *NOTE: This _must_ remain 22. If you change this from 22, your SSH tunnel will not function. This is due to [Apple port reservations](https://support.apple.com/en-us/HT202944), which you can note only has a single port that is reserved for SSH.*
	8. Click Continue
3. Click update. You'll temporarily lose access to the internet as the router is reconfigured. Once internet access is restored, you should now be able to SSH into the machine remotely!

To access the mining rig from your local machine, run `ssh -p <PORT NUMBER, e.g. 21000> <username>@<router public IP address>`.
If you are unsure of the router's public IP address, you should run `curl ipinfo.io/ip; echo` from a CLI on a computer within the network.