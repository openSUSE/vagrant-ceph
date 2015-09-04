
zypper update:
  cmd.run:
    - name: "zypper --non-interactive update --replacefiles"
    - shell: /bin/bash
    - unless: "zypper lu | grep -sq 'No updates found'"

kernel update:
  cmd.run:
    - name: "zypper --non-interactive --no-gpg-checks in kernel-default-3.12.47"
    - shell: /bin/bash
    - unless: "rpm -q kernel-default-3.12.47"

reboot:
  module.run:
    - name: system.reboot
    - unless: "test `uname -r` == '3.12.47-108-default'"

