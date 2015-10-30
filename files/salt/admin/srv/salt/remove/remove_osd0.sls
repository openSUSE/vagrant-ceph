
remove crush:
  cmd.run:
    - name: "ceph osd crush remove osd.0"

remove auth:
  cmd.run:
    - name: "ceph auth del osd.0"

remove osd:
  cmd.run:
    - name: "ceph osd rm 0"


