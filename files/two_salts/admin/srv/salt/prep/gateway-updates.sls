
zypper update:
  cmd.run:
    - name: "zypper --non-interactive update --replacefiles"
    - shell: /bin/bash
    - unless: "zypper lu | grep -sq 'No updates found'"

kernel update:
  cmd.run:
    - name: "rpm -U /tmp/kernel-default-3.12.51-60.25.1.10225.0.PTF.964727.x86_64.rpm"
    - shell: /bin/bash
    - unless: "rpm -q kernel-default-3.12.51"

reboot:
  cmd.run:
    - name: "shutdown -r"
    - shell: /bin/bash
    - unless: "test `uname -r` != '3.12.49-11-default'"


