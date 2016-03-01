ready_check:
  cmd.cmd.run:
    - tgt: admin.ceph
    - arg: 
      - "/srv/reactor/ready_check {{ data['id'] }}"

