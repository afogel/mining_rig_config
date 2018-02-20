# Config for mining rig

# Beginning with the basics
We are configuring a rig running Ubuntu 16.04 LTS. The steps herein should be supported through April 2021 for a 64-bit architecture.

## Port forwarding via SSH (SSH tunneling)
In order to connect to the local rig using a remote machine, we need to setup port forwarding. This enable SSH traffic through the router to our rig.

### Setting up port forwarding for the router
#### Static IP
By default, we're using DHCP (Dynamic Host Configuration Protocol), but we want to change that to a static IP. The rationale behind this change is that by using a static IP, we will always reliably know the IP address of our rig. Otherwise, it is conceivable that the IP address will be dynamically reassigned underfoot, making ssh tunneling difficult if not impossible.

The steps we followed are laid out in [this tutorial](https://michael.mckinnon.id.au/2016/05/05/configuring-ubuntu-16-04-static-ip-address/), however for posterity (and dev editor preferences), we will duplicate the exact steps we took in order to set up our machine.

#### Router config
We are using instructions from the [following resource](https://portforward.com). Specifically, since the router we are using is an Apple Time Capsule, we can jump [directly to the apple page](https://portforward.com/apple/).