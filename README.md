# vagrant-ceph
Create a vagrant configuration to support multiple ceph cluster topologies.  Ideal for development or exploration of Ceph.

## Usage
Review the config.yml.  All addresses are on private networks.  Each commented section lists the requirements for a configuration and approxiamate initialization time.

The current setup only supports libvirt as a provider.  Install the plugin if needed.

`$ vagrant plugin install vagrant-libvirt`

Next, add the vagrant box.

`$ vagrant box add boxes/VagrantBox-openSUSE-13.2.x86_64-1.13.2.libvirt.json`

Note: Until hashicorp allows libvirt providers, I am sharing via Google Drive.

Edit the Vagrant file and change CONFIGURATION to small for an initial test.

`CONFIGURATION='small'`

Start the environment.

`$ vagrant up`

Note that the base box image and VM OS disks are added to /var/lib/libvirt/images with additional disks added as 1G raw partitions for the data nodes.

Next, log into the admin node and become root.

`$ vagrant ssh admin`

`vagrant@admin:~> sudo su -`

You may now begin a ceph installation.  

## Caveats
For the sake of completeness and stating the obvious, the private ssh key is only suitable for demonstrations and should never be used in a real environment.

The automation does not install Ceph.  

The default root password is 'vagrant'.
