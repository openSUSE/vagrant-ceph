
{% for num in range(6) %}
reweight osd.{{ num }}:
  cmd.run:
    - name: "ceph osd crush reweight osd.{{ num }} 1"
    - unless: "ceph osd tree | awk '/osd.{{ num }}/ { exit ($2 == 0) }'"

{% endfor %}

