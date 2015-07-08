# vagrant-ceph
Create a vagrant configuration to support multiple ceph cluster topologies.  Ideal for development or exploration of Ceph.

## Usage
Review the config.yml.  All addresses are on private networks.  Each commented section lists the requirements for a configuration and approximate initialization time.

The current setup supports both libvirt and virtualbox as providers.  Note that kvm and vbox kernel modules cannot be loaded simultaneously.

### Libvirt plugin

Install the plugin if needed.

`$ vagrant plugin install vagrant-libvirt`

Note: fog-1.30.0 seems to remove support for libvirt.  To workaround this issue, run the following as well if needed

`$ vagrant plugin uninstall fog`

`$ vagrant plugin install --plugin-version 1.29.0 fog`

## Adding Vagrant boxes
Next, add the vagrant box.  Choose the box you wish to use from the boxes subdirectory.

`$ ls boxes/`

<pre>
openSUSE-13.2.x86_64-1.13.2.libvirt-Build21.16.json
openSUSE-13.2.x86_64-1.13.2.virtualbox-Build21.16.json
SLE-12.x86_64-1.12.0.libvirt-Build6.1.json
SLE-12.x86_64-1.12.0.virtualbox-Build6.1.json
Tumbleweed.x86_64-1.13.2.libvirt-Build2.20.json
Tumbleweed.x86_64-1.13.2.virtualbox-Build2.20.json
</pre>

For instance, add the openSUSE box for libvirt with the following

`$ vagrant box add boxes/openSUSE-13.2.x86_64-1.13.2.libvirt-Build21.16.json`

Edit the _Vagrantfile_ and set BOX, INSTALLATION and CONFIGURATION.  Use the following for an initial test.

`BOX = 'openSUSE-13.2'` <br>
`INSTALLATION = 'ceph-deploy'` <br>
`CONFIGURATION = 'small'` <br>

Start the environment.

`$ vagrant up`

For libvirt, note that the base box image and VM OS disks are added to /var/lib/libvirt/images with additional disks added as raw partitions for the data nodes.

For virtualbox, the VM OS disks are stored in your home directory.  The additional disks for the data nodes are stored in $HOME/disks.

Next, log into the admin node and become root.

`$ vagrant ssh admin`

`vagrant@admin:~> sudo su -`

You may now begin a ceph installation.  


## Caveats
For the sake of completeness and stating the obvious, the private ssh key is only suitable for demonstrations and should never be used in a real environment.

The automation does not install Ceph (yet).  

The default root password is 'vagrant'.

Depending on your hardware, an ssh command may fail on the initialization when a virtual machine did not respond quickly enough.  Run the provisioning again with

`$ vagrant provision`
