base:
  'E@mon.*|data.*|igw.*|mds.*':
    - match: compound
    - prep
  'E@client.*':
    - match: compound
    - prep.client
  'data*':
    - partition
  'igw*':
    - iscsi
  'client*':
    - initiator
  'admin.ceph':
    - prep.complete
  'calamari.ceph':
    - prep.complete
  'mon1.ceph':
    - cephfs.pools
