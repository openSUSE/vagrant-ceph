set -ex

# get version number of latest Vagrant

latest="$(wget https://releases.hashicorp.com/vagrant -q -O - | grep '/vagrant/' | head -1 | \
        awk -F '<a href="/vagrant/' '{ print $2 }' | awk -F '/">' '{ print $1 }')"

# construct download URL for latest Vagrant version

vagrant_url="https://releases.hashicorp.com/vagrant/""$latest""/vagrant_""$latest""_x86_64.rpm"

# install vagrant and its dependencies, also devel files to build vagrant plugins later
# use new --allow-unsigned-rpm option if zypper supports it

zypper_version=($(zypper -V))
if [[ ${zypper_version[1]} < '1.14.4' ]]
then
    zypper --no-gpg-checks in -y $vagrant_url
else
    zypper in -y --allow-unsigned-rpm $vagrant_url
fi

# workaround for https://github.com/hashicorp/vagrant/issues/10019

mv /opt/vagrant/embedded/lib/libreadline.so.7{,.disabled} | true
    
zypper in -y ruby-devel
zypper in -y gcc gcc-c++ make
zypper in -y qemu-kvm libvirt-daemon-qemu libvirt libvirt-devel

# needed for vagrant-libvirt

gem install ffi
gem install unf_ext
gem install ruby-libvirt

systemctl enable libvirtd
systemctl start libvirtd

vagrant plugin install vagrant-libvirt

git clone --depth 1 https://github.com/openSUSE/vagrant-ceph

#cd vagrant-ceph

#vagrant up
