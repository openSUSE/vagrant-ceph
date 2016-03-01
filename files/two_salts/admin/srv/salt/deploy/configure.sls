
backstore:
  cmd.run:
    - name: "rbd -p rbd create archive --size=1024"
    - unless: "rbd -p rbd ls | grep -q archive$"

archive1:
  cmd.run:
    - name: "rbd -p rbd create archive1 --size=768"
    - unless: "rbd -p rbd ls | grep -q archive1$"

archive2:
  cmd.run:
    - name: "rbd -p rbd create archive2 --size=512"
    - unless: "rbd -p rbd ls | grep -q archive2$"

swimming:
  cmd.run:
    - name: "ceph osd pool create swimming 256 256"
    - unless: "ceph osd pool ls | grep -q swimming$"

media:
  cmd.run:
    - name: "rbd -p swimming create media --size=2048"
    - unless: "rbd -p swimming ls | grep -q media$"

cache:
  cmd.run:
    - name: "ceph osd pool create rbd-cache 256 256"
    - unless: "ceph osd pool ls | grep -q rbd-cache"

cache tier:
  cmd.run:
    - name: "ceph osd tier add rbd rbd-cache"

cache mode:
  cmd.run:
    - name: "ceph osd tier cache-mode rbd-cache writeback"

overlay:
  cmd.run:
    - name: "ceph osd tier set-overlay rbd rbd-cache"

hit_set_type:
  cmd.run:
    - name: "ceph osd pool set rbd-cache hit_set_type bloom"

hit_set_period:
  cmd.run:
    - name: "ceph osd pool set rbd-cache hit_set_period 4"

hit_set_count:
  cmd.run:
    - name: "ceph osd pool set rbd-cache hit_set_count 1200"







