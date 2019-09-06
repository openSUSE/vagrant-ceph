#!/bin/bash

# ----------------------------------------------------------------------
# Global variable definitions
# ----------------------------------------------------------------------

dist_id_file=/etc/os-release

leap_name="openSUSE Leap"
leap_accepted_ver="15.1"

tumbleweed_name="openSUSE Tumbleweed"

zypper_inst_cmd="/usr/bin/zypper -q -n in"

# ----------------------------------------------------------------------
# left_part_of():
#   Returns the left part of a string, in relation to given substring
# ----------------------------------------------------------------------

left_part_of() {
  input_string="$1"
  the_mark="$2"
  left_part="$(echo "$input_string" | awk -F "$the_mark" '{ print $1 }')"
  echo "$left_part"
}

# ----------------------------------------------------------------------
# right_part_of():
#   Returns the right part of a string, in relation to given substring
# ----------------------------------------------------------------------

right_part_of() {
  input_string="$1"
  the_mark="$2"
  right_part="$(echo "$input_string" | awk -F "$the_mark" '{ print $2 }')"
  echo "$right_part"
}

# ----------------------------------------------------------------------
# in_between():
#   Returns the part of a string which is between two given substrings
# ----------------------------------------------------------------------

in_between() {
  input_string="$1"
  left_mark="$2"
  right_mark="$3"
  right_part="$(right_part_of "$input_string" "$left_mark")"
  middle_part="$(left_part_of "$right_part" "$right_mark")"
  echo "$middle_part"
}

# ----------------------------------------------------------------------
# Detect whether we're running on accepted version of openSUSE Leap
# or on openSUSE Tumbleweed
#
# Accepted version of Leap: Install latest RPM of Vagrant directly
# from Hashicorp, then manually install Vagrant plugin vagrant-libvirt
#
# Tumbleweed: Autimatically install packages vagrant, vagrant-libvirt
# from standard distribution repositories
# ----------------------------------------------------------------------

if [ ! -f "$dist_id_file" ]; then
  echo "===== File $dist_id_file does not exist"
  exit 1
fi

dist_name=$(in_between "$(grep -e "^NAME=" "$dist_id_file")" 'NAME="' '"')

case $dist_name in

  "$leap_name")

    echo "===== Detected $dist_name, checking version number"

    dist_ver=$(in_between "$(grep -e "^VERSION_ID=" "$dist_id_file")" 'VERSION_ID="' '"')

    if [ "$dist_ver" != "$leap_accepted_ver" ]; then
      echo "===== Sorry, but for the time being I can only work with $dist_name version $leap_accepted_ver"
      exit 1
    fi

    echo "===== Version number is $leap_accepted_ver -- good!"

    if [ ! -f "/usr/bin/wget" ]; then
      echo
      echo "===== wget is missing, installing corresponding package now"
      $zypper_inst_cmd wget
      zypper_ec=$?
      if [ $zypper_ec -ne 0 ]; then
        echo "===== Something went wrong (zypper exit code: $zypper_ec)"
        exit 2
      fi
    fi

    latest=$(in_between \
      "$(wget https://releases.hashicorp.com/vagrant -q -O - | grep '/vagrant/' | head -1)" \
      '<a href="/vagrant/' \
      '/">')
    vagrant_url="https://releases.hashicorp.com/vagrant/""$latest""/vagrant_""$latest""_x86_64.rpm"

    echo
    echo "===== Installing RPM package of Vagrant, directly from $vagrant_url"

    $zypper_inst_cmd --allow-unsigned-rpm "$vagrant_url"
    zypper_ec=$?
    if [ $zypper_ec -ne 0 ]; then
      echo "===== Something went wrong (zypper exit code: $zypper_ec)"
      exit 2
    fi

    echo "===== Applying workaround for https://github.com/hashicorp/vagrant/issues/10019"

    mv /opt/vagrant/embedded/lib/libreadline.so.7{,.disabled} 2> /dev/null

    echo
    echo "===== Installing dependencies for building vagrant-libvirt"

    $zypper_inst_cmd gcc gcc-c++ make ruby-devel \
      libvirt libvirt-devel libvirt-daemon-qemu qemu-kvm
    zypper_ec=$?
    if [ $zypper_ec -ne 0 ]; then
      echo "===== Something went wrong (zypper exit code: $zypper_ec)"
      exit 2
    fi

    echo
    echo "===== Installing Ruby gems for vagrant-libvirt"

    gem install ffi unf_ext ruby-libvirt
    gem_inst_ec=$?
    if [ $gem_inst_ec -ne 0 ]; then
      echo "===== Something went wrong (gem exit code: $gem_inst_ec)"
      exit 2
    fi

    echo
    echo "===== Installing plugin vagrant-libvirt using vagrant"

    vagrant plugin install vagrant-libvirt
    vagrant_ec=$?
    if [ $vagrant_ec -ne 0 ]; then
      echo "===== Something went wrong (vagrant exit code: $vagrant_ec)"
      exit 2
    fi

  ;;

  "$tumbleweed_name")

    echo "===== Detected $dist_name, so moving on to installing packages vagrant & vagrant-libvirt"

    $zypper_inst_cmd vagrant vagrant-libvirt
    zypper_ec=$?
    if [ $zypper_ec -ne 0 ]; then
      echo "===== Something went wrong (zypper exit code: $zypper_ec)"
      exit 2
    fi

  ;;

  *)

    echo "===== This doesn't look like a Leap system, nor like a Tumbleweed system"
    exit 1

  ;;

esac

echo "===== Making sure service libvirtd is enabled and active"

systemctl enable libvirtd
systemctl start libvirtd

echo
echo "===== Your vagrant-ceph playground is ready -- have at it!"
echo

exit 0
