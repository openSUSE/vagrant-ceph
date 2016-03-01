
stop osd0:
  salt.state:
    - tgt: "data1.ceph"
    - sls: remove.stop_osd0

remove osd0:
  salt.state:
    - tgt: "mon1.ceph"
    - sls: remove.remove_osd0

umount osd0:
  salt.state:
    - tgt: "data1.ceph"
    - sls: remove.umount_osd0

