{% for node in [ 'data4' ] %}
  {% for device in [ 'vdc' ] %}
prepare {{ node }} {{ device }}:
  cmd.run:
    - name: ceph-deploy --overwrite-conf osd prepare {{ node }}:{{ device }}2:{{ device }}1
    - unless: ssh -o ConnectTimeout=3 {{ node }} fsck /dev/{{ device }}2

activate {{ node }} {{ device }}:
  cmd.run:
    - name: ceph-deploy osd activate {{ node }}:{{ device }}2:{{ device }}1
    - unless: ssh -o ConnectTimeout=3 {{ node }} grep -q /dev/{{ device }}2 /proc/mounts

  {% endfor %}
{% endfor %}
