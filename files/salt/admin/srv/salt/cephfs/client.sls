
mount:
  cmd.run:
    - name: "mount -t ceph 172.16.11.11:6789,172.16.11.12:6789:/ /mnt -o name=admin,secret=AQAK4IpWdFOpFxAANx1LoodhXKMVjLlMvO9A0g=="
    - unless: "mount | grep -q /mnt"

