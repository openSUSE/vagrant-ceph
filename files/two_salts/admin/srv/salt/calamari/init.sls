
/etc/salt/pki/minion/minion_master.pub:
  file.absent

restart minions:
  cmd.run:
    - name: systemctl restart salt-minion

