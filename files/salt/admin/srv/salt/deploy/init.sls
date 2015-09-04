
setup: 
  cmd.run:
    - name: "ceph-deploy new mon1 mon2 mon3"
    - unless: stat /root/ceph.conf

{% set public_network = '172.16.11.0/24' %}
{% set cluster_network = '172.16.12.0/24' %}

add_networks:
  file.replace:
    - name: '/root/ceph.conf'
    - pattern: '^$'
    - repl: 'public_network = {{ public_network }}\ncluster_network = {{ cluster_network }}'


monitors:
  cmd.run:
    - name: "ceph-deploy mon create-initial"
    - unless: "ssh -o ConnectTimeout=3 mon1 ceph mon stat"

{% for node in [ 'data1', 'data2', 'data3' ] %}
  {% for device in [ 'vdb', 'vdc' ] %}
prepare {{ node }} {{ device }}:
  cmd.run:
    - name: ceph-deploy osd prepare {{ node }}:{{ device }}2:{{ device }}1
    - unless: ssh -o ConnectTimeout=3 {{ node }} fsck /dev/{{ device }}2

activate {{ node }} {{ device }}:
  cmd.run:
    - name: ceph-deploy osd activate {{ node }}:{{ device }}2:{{ device }}1
    - unless: ssh -o ConnectTimeout=3 {{ node }} grep -q /dev/{{ device }}2 /proc/mounts

  {% endfor %}
{% endfor %}

{% for node in [ 'igw1', 'igw2', 'igw3' ] %}
admin {{ node }}:
  cmd.run:
    - name: "ceph-deploy admin {{ node }}"
    - unless: "ssh -o ConnectTimeout=3 {{ node }} stat /etc/ceph/ceph.conf"
{% endfor %}

