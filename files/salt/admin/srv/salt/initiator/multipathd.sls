
/etc/multipath.conf:
  file.managed:
    - source: 
      - salt://initiator/multipath.conf
    - user: root
    - group: root
    - mode: 600

/etc/multipath/bindings:
  file.append:
    - text: "mpatha 36001405537ec755f2363939950c3db55"

multipathd:
  service.running:
    - name: multipathd
    - enable: True

