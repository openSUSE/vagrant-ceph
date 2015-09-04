
pools:
  cmd.run:
    - name: "rbd -p rbd create archive --size=1024"
    - unless: "rbd -p rbd ls | grep -q archive"


