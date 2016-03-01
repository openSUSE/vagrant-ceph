base:
  'E@mon.*|data.*|mds.*':
    - match: compound
    - prep
  'E@client.*':
    - match: compound
    - prep.client
  'E@igw.*':
    - match: compound
    - prep.gateway
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
