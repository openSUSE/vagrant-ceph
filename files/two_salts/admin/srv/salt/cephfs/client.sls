
secret:
  cmd.run:
    - name: "awk '/key/ {print $3}' /etc/ceph/ceph.client.admin.keyring > /etc/ceph/admin.secret"

mount:
  cmd.run:
    - name: "mount.ceph mon1:6789,mon2:6789,mon3:6789:/ /mnt -o name=admin,secretfile=/etc/ceph/admin.secret"
    - unless: "mount | grep -q /mnt"

