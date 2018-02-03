set -ex

#install vagrant and it dependencies, devel files to build vagrant plugins later
zypper in -y https://releases.hashicorp.com/vagrant/1.8.7/vagrant_1.8.7_x86_64.rpm
zypper in -y ruby-devel
zypper in -y gcc gcc-c++ make
zypper in -y qemu-kvm libvirt-daemon-qemu libvirt libvirt-devel

#need for vagrant-libvirt
gem install ffi -v '1.9.18'
gem install unf_ext -v '0.0.7.4'
gem install ruby-libvirt -v '0.7.0'

systemctl enable libvirtd
systemctl start libvirtd

# 0.0.41 does not find provider 2/2/2018
vagrant plugin install --plugin-version 0.0.40 vagrant-libvirt

git clone --depth 1 https://github.com/openSUSE/vagrant-ceph
cd vagrant-ceph

#vagrant up
