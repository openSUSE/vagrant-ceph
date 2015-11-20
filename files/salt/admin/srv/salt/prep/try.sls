

reboot:
  salt.function:
    - name: system.reboot
    - tgt: mds1.ceph

wait:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list: 
      - mds1.ceph

