set -ex

#install vagrant and it dependencies, devel files to build vagrant plugins later
zypper in -y --allow-unsigned-rpm https://releases.hashicorp.com/vagrant/2.0.3/vagrant_2.0.3_x86_64.rpm
zypper in -y ruby-devel
zypper in -y gcc gcc-c++ make
zypper in -y qemu-kvm libvirt-daemon-qemu libvirt libvirt-devel

#need for vagrant-libvirt
gem install ffi
gem install unf_ext
gem install ruby-libvirt

systemctl enable libvirtd
systemctl start libvirtd

vagrant plugin install vagrant-libvirt

git clone --depth 1 https://github.com/openSUSE/vagrant-ceph
#cd vagrant-ceph

#vagrant up
