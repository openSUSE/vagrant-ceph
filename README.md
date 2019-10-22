# vagrant-ceph
Create a vagrant configuration to support multiple ceph cluster topologies.  Ideal for development or exploration of Ceph.

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://github.com/openSUSE/vagrant-ceph/blob/master/LICENSE)

 Box and Base system | openSUSE 15.1
--- | --- |
**sub0/leap151** | [![Build Status](https://ceph-ci.suse.de/job/vagrant-matrix/BOX=sub0%2Fleap151,TARGET_IMAGE=teuthology-opensuse-15.1-x86_64,WORKER_LABEL=storage-compute/badge/icon)](https://ceph-ci.suse.de/job/vagrant-matrix/BOX=sub0%2Fleap151,TARGET_IMAGE=teuthology-opensuse-15.1-x86_64,WORKER_LABEL=storage-compute) |

## Usage
Review the config.yml.  All addresses are on private networks.  Each commented section lists the requirements for a configuration and approximate initialization time.

The current setup supports both libvirt and virtualbox as providers.  Note that kvm and vbox kernel modules cannot be loaded simultaneously.

### Libvirt plugin

Install the plugin if needed.

`$ vagrant plugin install vagrant-libvirt`

Or use script in case you have openSUSE:
```
# curl https://raw.githubusercontent.com/openSUSE/vagrant-ceph/master/openSUSE_vagrant_setup.sh -o openSUSE_vagrant_setup.sh
# chmod +x openSUSE_vagrant_setup.sh
# sudo ./openSUSE_vagrant_setup.sh
```

#### Enable KSM (Kernel Samepage Merge)
In order to reduce the total memory used to set a ceph cluster, one could enable
the KSM by issuing the follow command as root:
`echo 1 >/sys/kernel/mm/ksm/run`

For more info check [KSM's page.](https://www.linux-kvm.org/page/KSM)

#### Workaround 1
On most systems, this workaround isn't required. Only apply it if you see that libvirt isn't supported:

fog-1.30.0 seems to remove support for libvirt.  To workaround this issue, run the following as well if needed

`$ vagrant plugin uninstall fog`

`$ vagrant plugin install --plugin-version 1.29.0 fog`

#### Workaround 2
Encountering an error similar to the following:

```
ERROR:  Could not find a valid gem 'fog-core' (>= 0), here is why:
          Unable to download data from https://rubygems.org/ - SSL_connect returned=1 errno=0 state=error: certificate verify failed (https://api.rubygems.org/specs.4.8.gz)
```

Update the gem in vagrant.  Download from http://guides.rubygems.org/ssl-certificate-update/#installing-using-update-packages.

```
/opt/vagrant/embedded/bin/gem install --local /tmp/rubygems-update-2.6.7.gem
/opt/vagrant/embedded/bin/update_rubygems --no-ri --no-rdoc
/opt/vagrant/embedded/bin/gem uninstall rubygems-update -x
```

For background on this issue, see https://gist.github.com/luislavena/f064211759ee0f806c88.

Then, rerun the plugin installation above.

## Adding Vagrant boxes

There are a couple of methods to add boxes.

### Adding box from the command line

Suppose we want to add a Kubic image. A suitable Vagrant box for such an image is available in the [openSUSE download server](http://download.opensuse.org/tumbleweed/appliances). Specifically, the file we want is `openSUSE-MicroOS.x86_64-Kubic-kubeadm-Vagrant.box`, so we can directly add the box to our local list of Vagrant boxes by issuing a single command:

`$ vagrant box add --provider libvirt --name opensuse/MicroOS-Kubic-kubeadm http://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-Kubic-kubeadm-Vagrant.box`

By the way, more info on how to use Kubic images with vagrant-ceph is available in the [openSUSE:Ceph Wiki](https://en.opensuse.org/openSUSE:Ceph#Using_Rook_in_Vagrant_cluster).

Following is another example of adding a Vagrant box for openSUSE Leap 15.1, from the [openSUSE Virtualization Appliances repo](https://download.opensuse.org/repositories/Virtualization:/Appliances:/Images:/openSUSE-Leap-15.1/images):

`vagrant box add --provider libvirt --name virt-appl/openSUSE-Leap-15.1 https://download.opensuse.org/repositories/Virtualization:/Appliances:/Images:/openSUSE-Leap-15.1/images/Leap-15.1.x86_64-libvirt.box`

By successfully executing this command we end up with a local Vagrant box for openSUSE Leap 15.1:

`$ vagrant box list`

<pre>
virt-appl/openSUSE-Leap-15.1 (libvirt, 0)
</pre>

Then, to build a Leap 15.1-based cluster all we have to do is type the following:

`BOX="virt-appl/openSUSE-Leap-15.1" vagrant up`

### Boxes from the Vagrant Cloud

Standard (Vagrant) boxes from the [openSUSE project in the Vagrant Cloud](https://app.vagrantup.com/opensuse) should not be added manually. When you assign a standard box in the `BOX` environment variable or you directly specify it in the `Vagrantfile`, then `vagrant` automatically searches for the box in the Vagrant Cloud. Provided the box exists, it is downloaded and added to your local list of Vagrant boxes. An example of a standard box is this: [opensuse/openSUSE-Tumbleweed-Vagrant.x86_64](https://app.vagrantup.com/opensuse/boxes/openSUSE-Tumbleweed-Vagrant.x86_64). Should you choose to use it, all you have to do is type `BOX="opensuse/openSUSE-Tumbleweed-Vagrant.x86_64" vagrant up`.
 
### Boxes from local files

Choose the box you wish to use from the boxes subdirectory.

`$ ls boxes/`

<pre>
sle12-sp3.x86_64-0.0.1.libvirt.json
SLE-12.x86_64-1.12.0.libvirt-Build6.25.json
SLE-12.x86_64-1.12.0.virtualbox-Build6.25.json
Tumbleweed.x86_64-1.13.2.libvirt-Build2.34.json
Tumbleweed.x86_64-1.13.2.virtualbox-Build2.34.json
</pre>

For instance, add the SLE 12 SP3 box for libvirt with the following command:

`$ vagrant box add boxes/sle12-sp3.x86_64-0.0.1.libvirt.json`

### Use the box

Edit `Vagrantfile` and set BOX, INSTALLATION and CONFIGURATION. Set `BOX = 'SUSE/SLE-15-SP1'` for an initial test. Alternatively, you may specify a Vagrant box via an environment variable like this...

`$ BOX="SUSE/SLE-15-SP1" vagrant up`

...or like this:

`$ export BOX="SUSE/SLE-15-SP1"`

Before you can start the environment you need to double check if you can ssh into localhost

`$ ssh root@localhost` 

If that isn't possible please check your /etc/ssh/sshd_config file and change the following option:

`$ PermitRootLogin yes`

Afterwards copy your pub-key by entering

`$ ssh-copy-id root@localhost` 

Start the environment.

`$ vagrant up`

If the admin node starts prior to the other nodes, vagrant will complain that the admin node failed.  (This has been inconsistent depending on an environment.)  Run the provisioning step to compete the setup.

`$ vagrant provision`

For libvirt, note that the base box image and VM OS disks are added to /var/lib/libvirt/images with additional disks added as raw partitions for the data nodes.

For virtualbox, the VM OS disks are stored in your home directory.  The additional disks for the data nodes are stored in $HOME/disks.

Next, log into the admin node and become root.

`$ vagrant ssh admin`

`vagrant@admin:~> sudo su -`

You may now begin a ceph installation.

## Customizations

This repository diverged from it's origin in following features:

  * Partly overwrite configs under files/
    * If you deploy different versions of ceph
      you might need different settings.
      This allows you to do so.
  * Import the ssh pubkey from your $HOME
  * Allow SUSEConnect registrations
  * include a comprehensive .bash_history on the master
  * More cluster sizes and configurations

## Partly overwrite configurations

files/<b>installation_mode</b>/<b>HOST</b> holds files that will be copied over to the <b>HOST</b>.
If you deploy different kinds of Versions of SLES/SES you can create subdirectories that match the following pattern:

`files/<b>installation_mode</b>/<b>BOX</b>_<b>CONFIGURATION</b>`

I.e. "SLE12-SP3\_default"

This directory can hold a single file that differs from the default tree in files/<b>installation_mode</b>/<b>HOST</b>

### Options for files upload
```
files:
  @node: false/true/merge/custom
```

* false - don't upload files
* true - upload directory that matches node name
* custom - upload __only__ directory `BOX_CONFIGURATION`
* merge - upload both node directory as well as `BOX_CONFIGURATION` directory

## Caveats
For the sake of completeness and stating the obvious, the private ssh key is only suitable for demonstrations and should never be used in a real environment.

The ceph-deploy installation option does not automatically install ceph.  The environment is created to allow the running of ceph-deploy.  For automatic installation, compare the salt installation option. 

The default root password is 'vagrant'.

## CI
There are currently a couple of Jenkins jobs that will run:
* Once per day
* For every push into repo

There is no reporting back to the PR, but status can be found on [Jenkins](http://storage-ci.suse.de:8080/job/vagrant/)

Sources for the Jenkins jobs are located [here](https://github.com/SUSE/sesci/blob/master/jjb/vagrant-ceph.yaml)
