
remove osd:
  cmd.run:
    - name: "umount /var/lib/ceph/osd/ceph-0"

destroy partition:
  cmd.run:
    - name: "dd if=/dev/zero of=/dev/vdb2 bs=1M count=10"
  

