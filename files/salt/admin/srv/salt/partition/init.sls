
{% for device in [ "/dev/vdb", "/dev/vdc" ] %}
{{ device }} journal:
  module.run:
    - name: partition.mkpart
    - device: {{ device }}
    - part_type: primary
    - start: 0%
    - end: 10%
    - require:
      - module: {{ device }} label
    - unless: stat {{ device }}1

{{ device }} data:
  module.run:
    - name: partition.mkpart
    - device: {{ device }}
    - part_type: primary
    - start: 10%
    - end: 100%
    - require:
      - module: {{ device }} label
    - unless: stat {{ device }}2

{{ device }} label:
  module.run:
    - name: partition.mklabel
    - device: {{ device }}
    - label_type: gpt
    - unless: blkid {{ device }} 

{% endfor %}


