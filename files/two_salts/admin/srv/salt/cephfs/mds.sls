
mds:
  cmd.run:
    - name: "ceph-deploy mds create mds1 mds2"
    - unless: "ssh -o ConnectTimeout=3 mds1 'pgrep ceph-mds'"

{% for node in [ 'mds1', 'mds2' ] %}
start {{ node }}:
  cmd.run:
    - name: "ssh -o ConnectTimeout=3 {{ node }} systemctl start ceph.target"

{% endfor %}

conf:
  cmd.run:
    - name: "ceph-deploy admin client1 client2"


