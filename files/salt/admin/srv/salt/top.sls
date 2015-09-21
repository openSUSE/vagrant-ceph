base:
  'E@mon.*|data.*|igw.*':
    - match: compound
    - prep
  'data*':
    - partition
  'igw*':
    - iscsi
  'client*':
    - initiator
  'admin.ceph':
    - deploy
