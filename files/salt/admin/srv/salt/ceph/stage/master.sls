
packages:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - sls: ceph.packages

prepare master:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - sls: ceph.prep
    - require:
      - salt: packages


#openattic:
#  salt.state:
#    - tgt: {{ salt['pillar.get']('master_minion') }}
#    - sls: ceph.openattic


complete marker:
  salt.runner:
    - name: filequeue.add
    - queue: 'master'
    - item: 'complete'
    - require:
      - salt: prepare master


include:
  - .prep

#begin marker:
#  salt.runner:
#    - name: filequeue.add
#    - queue: 'master'
#    - item: 'begin'
