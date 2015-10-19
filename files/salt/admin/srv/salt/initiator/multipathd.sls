
/etc/multipath.conf:
  file.managed:
    - source: 
      - salt://initiator/multipath.conf
    - user: root
    - group: root
    - mode: 600

multipathd:
  service.running:
    - name: multipathd
    - enable: True

