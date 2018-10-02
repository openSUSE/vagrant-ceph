# vagrant-ceph
Create a vagrant configuration to support multiple ceph cluster topologies.  Ideal for development or exploration of Ceph.

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://github.com/openSUSE/vagrant-ceph/blob/master/LICENSE)

 Box and Base system | openSUSE 42.3 | openSUSE 15.0 
--- | --- | ---
**opensuse/openSUSE-42.3-x86_64** | [![Build Status](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-42.3-x86_64,TARGET_IMAGE=teuthology-opensuse-42.3-x86_64/badge/icon)](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-42.3-x86_64,TARGET_IMAGE=teuthology-opensuse-42.3-x86_64/) | [![Build Status](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-42.3-x86_64,TARGET_IMAGE=teuthology-opensuse-15.0-x86_64/badge/icon)](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-42.3-x86_64,TARGET_IMAGE=teuthology-opensuse-15.0-x86_64/)
**opensuse/openSUSE-15.0-x86_64** | [![Build Status](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-15.0-x86_64,TARGET_IMAGE=teuthology-opensuse-42.3-x86_64/badge/icon)](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-15.0-x86_64,TARGET_IMAGE=teuthology-opensuse-42.3-x86_64/) | [![Build Status](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-15.0-x86_64,TARGET_IMAGE=teuthology-opensuse-15.0-x86_64/badge/icon)](http://ceph-ci.suse.de:8080/job/vagrant-matrix/BOX=opensuse%2FopenSUSE-15.0-x86_64,TARGET_IMAGE=teuthology-opensuse-15.0-x86_64/) 

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

#### Workaround 1
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

Skip this section if you use standard boxes from [Vagrant Cloud](https://app.vagrantup.com/opensuse)

Next, add the vagrant box.  Choose the box you wish to use from the boxes subdirectory.

`$ ls boxes/`

<pre>
openSUSE-13.2.x86_64-1.13.2.libvirt-Build21.39.json
openSUSE-13.2.x86_64-1.13.2.virtualbox-Build21.39.json
SLE-12.x86_64-1.12.0.libvirt-Build6.25.json
SLE-12.x86_64-1.12.0.virtualbox-Build6.25.json
Tumbleweed.x86_64-1.13.2.libvirt-Build2.34.json
Tumbleweed.x86_64-1.13.2.virtualbox-Build2.34.json
</pre>

For instance, add the openSUSE box for libvirt with the following

`$ vagrant box add boxes/openSUSE-13.2.x86_64-1.13.2.libvirt-Build21.39.json`

Edit the _Vagrantfile_ and set BOX, INSTALLATION and CONFIGURATION.  Use the following for an initial test.

`BOX = 'openSUSE-13.2'` <br>
`INSTALLATION = 'ceph-deploy'` <br>
`CONFIGURATION = 'small'` <br>

Start the environment.

`$ vagrant up`

If the admin node starts prior to the other nodes, vagrant will complain that the admin node failed.  (This has been inconsistent depending on an environment.)  Run the provisionining step to compete the setup.

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

"files/<b>installation_mode</b>/<b>BOX</b>_<b>CONFIGURATION</b>"

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
There couple of Jenkins CI jobs currently running:
* every day
* for every push into repo

There is no reporting back to the PR but status could be found on Jenkins: http://storage-ci.suse.de:8080/job/vagrant/ .

Sources for Jenkins jobs are here: https://github.com/SUSE/sesci/blob/master/jenkins/jjb/vagrant-ceph.yaml .
