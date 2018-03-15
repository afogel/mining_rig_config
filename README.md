# Remotely configging a mining rig
## Table of Contents
- [Beginning with the basics](#beginning-with-the-basics)
	- [Hardware inventory](#hardware-inventory)
	- [Software inventory](#software-inventory)
- [Establishing SSH tunneling](#establishing-ssh-tunneling)
	- [Static IP](#static-ip)
	- [Setting up port forwarding on the router](#setting-up-port-forwarding-on-the-router)
- [Configuring SSH to reduce friction when working remotely](#configuring-ssh-to-reduce-friction-when-working-remotely)
	- [Reduce the command length necessary to SSH](#reduce-the-command-length-necessary-to-SSH)
	- [Avoid typing a password after the initial handshake](#avoid-typing-a-password-after-the-initial-handshake)

### Purpose

This project is a tutorial for setting up an Ethereum mining rig from a remote location. While there exist many tutorials online, the hardware we used appears to be more obscure, so...enjoy!
Hopefully this is helpful.

It may go without saying, but this is a two man project that requires heavy involvement from the person who has access to the physical machine at the onset. Once the SSH tunneling is set up, the rest of the work can be done remotely.

### Intended Roadmap

The steps we will follow to set this machine up is:
- [X] Set up SSH tunneling into our machine
- [X] Configure our local ssh so we don't need to type in passwords when using SSH
- [] Set up VNC through the SSH tunnel in order to access a GUI (can be useful)
- [] Install drivers (CUDA) so that our NVIDIA GPU work can be parallelized

## Beginning with the basics
### Hardware inventory
- Apple Airport Extreme
- NVIDIA 1060
- NVIDIA 1070

### Software Inventory
We are configuring a rig running Ubuntu 16.04 LTS. The steps herein should be supported through April 2021 for a 64-bit architecture.

[[Table of contents](#table-of-contents)] | [[Beginning with the basics](#beginning-with-the-basics)]

## Establishing SSH tunneling
In order to connect to the mining rig using a remote machine, we need to:
- [X] Set up a static IP on our local machine
- [X] Configure the Router for Port Forwarding


### Static IP
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

[[Table of contents](#table-of-contents)] | [[Establishing SSH tunneling](#establishing-ssh-tunneling)]

### Setting up port forwarding on the router

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

[[Table of contents](#table-of-contents)] | [[Establishing SSH tunneling](#establishing-ssh-tunneling)]

## Configuring SSH to reduce friction when working remotely

### Reduce the command length necessary to SSH
Typing out a long command like `ssh -p <PORT NUMBER> <username>@<router public IP address>` every time you want to reach your mining rig is a total drag. We can reduce friction by configuring your machine to understand that a shorter command, like `ssh mining_rig`, means the exact same thing.

We can accomplish this by following these steps:
1. Open your `~/.ssh/config` file in your favorite editor.
2. Adding (and modifying as appropriate) the following code below the existing text:
```
Host <NAME OF ALIAS, e.g. mining_rig>
	Hostname <PUBLIC IP ADDRESS OF THE ROUTER>
	User <USERNAME>
	Port <PORT>
```
3. Save and exit.

You should now be able to type `ssh mining_rig` (or whatever you called the alias) in order to log on.

### Avoid typing a password after the initial handshake

If we want to avoid typing a password during the initial ssh login to our mining rig, we need to add our public key into the list of authorized keys allowed to access the mining rig.

Check first to see whether you have a [public key/private key pair](https://en.wikipedia.org/wiki/Public-key_cryptography) by inspecting the contents of the `~/.ssh/` folder (`ls ~/.ssh/`). If there are two files in the folder called `id_rsa` and `id_rsa.pub`, then you're ready to proceed to the next step. Otherwise, run `ssh-keygen` and follow the prompts.

Finally, run `ssh-copy-id mining_rig` (or whatever you have aliased your rig to be called), enter in the rig's password, and you're done!

You should now be able to run `ssh mining_rig` and seemlessly log into your mining rig.

[[Table of contents](#table-of-contents)] | [[Configuring SSH to reduce friction when working remotely](#configuring-ssh-to-reduce-friction-when-working-remotely)]


## CUDA Installation

CUDA® is a parallel computing platform and programming model invented by NVIDIA. It enables dramatic increases in computing performance by harnessing the power of the graphics processing unit (GPU). 

We opted to download and use an older/more stable version of CUDA (8.0 GA2 - released Feb 2017) in order to minimize the potential to run into unprecendented bugs and spent more time than necessary debugging. We downloaded the archived release from [the CUDA toolkit archive](https://developer.nvidia.com/cuda-toolkit-archive).

NVIDIA releases an extensive walkthrough in order to set up CUDA. Rather than fully rehashing the detailed steps, we have included a PDF copy of the instructions in the repo. Unfortunately, the sequencing of the instructions contained in the PDF was not always clear. For clarity and  replicability, we have included the sequence of the steps we followed below. A careful read of the PDF instructions would yield the same result.

## Steps to installing CUDA
- [X] Verify You Have a CUDA-Capable GPU
- [X] Verify You Have a Supported Version of Linux
- [X] Verify the System Has gcc Installed
- [X] Verify the System has the Correct Kernel Headers and Development Packages Installed
- [X] [Download base installer](https://developer.nvidia.com/cuda-80-ga2-download-archive) for CUDA toolkit [[1](#download-the-base-installer-file)]
- [X] [Verify checksum on base installer file](http://developer.download.nvidia.com/compute/cuda/8.0/secure/Prod2/docs/sidebar/md5sum.txt?06dfgqL57dw7YCSfYZdf6EJBl-z5Xjqh67N6QysuJqv8ubYsVM0eRabE5aMvDttlYjo5XpbLtDxS1IMfCiFAmY3hdG8eeBRc3WeP7e71VlaO4DKq-OW-fxAH31j0LLNfxiBaLAgPzXhDZ592HIK-4FAFQzs) and make sure it matches local value of `md5sum <file>`
- [X] Disable Nouveau drivers [1](#disable-the-nouveau-drivers)
- [X] Reboot into text mode
- [X] Run base installer file
- [X] Create an xconfig file (`sudo nvidia-xconfig`)
- [X] Follow instructions after install (add `/usr/local/cuda-8.0/bin` to `$PATH` and `/usr/local/cuda-8.0/lib64` to `$LD_LIBRARY_PATH`)
-

### Download the base installer file
Initially, we tried to make this work by `curl`ing the endpoint that we see once we selected the OS/hardware options for the driver, but it didn't work. We then `scp`ed the file over to the rig. The next step to verify the checksum was an important sanity check before we proceeded as we didn't have a straightforward download.

**TODO**: explain above in English.

[[Table of contents](#table-of-contents)] | [[Steps to installing CUDA](#steps-to-installing-cuda)]

### Disable the Nouveau drivers
Nouveau is an open source driver for NVIDIA cards that appears to ship with Ubuntu. It follows that we need to disable it in order to install our own drivers. Additionally, it seems unlikely that we will need enable it once the CUDA drivers are enabled.

[[Table of contents](#table-of-contents)] | [[Steps to installing CUDA](#steps-to-installing-cuda)]

### Reboot into text mode
We followed instructions from [this askubuntu post](https://askubuntu.com/questions/870221/booting-into-text-mode-in-16-04#870226) in order to boot into text mode.
```bash
# set text mode
sudo systemctl set-default multi-user.target
# reboot
sudo reboot
```

Once the installation is complete, to set back to GUI, we will run:
```bash
# set default booting into X (GUI)
sudo systemctl set-default graphical.target
sudo reboot
```

### Potential errors
**Problem/Error Message:**
The driver installation is unable to locate the kernel source. Please make sure that the kernel source packages are installed and set up correctly.

**Solution:**
Adapted from [this tutorial answer](https://spturtle.blogspot.com/2015/07/cuda70-and-theano-setup-in-ubuntu-linux.html):
`sudo apt-get install dkms fakeroot build-essential linux-headers-generic`

If I'm being honest, I'm not entirely sure why installing these packages worked. Our machine already had fakeroot and build-essential installed, but did not have [dkms](https://help.ubuntu.com/community/Kernel/DkmsDriverPackage) or [linux-headers-generic](https://superuser.com/questions/697024/what-does-apt-get-install-linux-headers-generic-do). Further investigation will be merited and this doc will hopefully be updated.

The going hypothesis is that DKMS was the necessary dependency due to [this askUbuntu post](https://askubuntu.com/questions/492217/nvidia-driver-reset-after-each-kernel-update/496146#496146).