
/tmp/lrbd.conf:
  file.managed:
    - source: 
      - salt://iscsi/lrbd.conf
    - user: root
    - group: root
    - mode: 600

configure:
  cmd.run:
    - name: "lrbd -f /tmp/lrbd.conf"
    - shell: /bin/bash
    - unless: "lrbd -o | grep -q 'pools.: .$'"
    - require:
      - file: /tmp/lrbd.conf


