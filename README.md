# Config for mining rig

## Beginning with the basics
We are configuring a rig running Ubuntu 16.04 LTS. The steps herein should be supported through April 2021 for a 64-bit architecture.

## Establishing SSH tunneling
In order to connect to the mining rig using a remote machine, we need to:
[] Set up a static IP on our local machine
[] Configure the Router for Port Forwarding
[] 

We have roughly adapted a [tech otaku tutorial](https://www.tech-otaku.com/networking/establishing-ssh-tunnel-remotely-access-mac-afp-vnc/) for this work in order to reflect our quirks with router config on an Apple airport router.


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


#### Router config
We are using instructions from the [following resource](https://portforward.com). Specifically, since the router we are using is an Apple Time Capsule, we can jump [directly to the apple page](https://portforward.com/apple/).