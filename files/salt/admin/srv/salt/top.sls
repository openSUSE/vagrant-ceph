base:
  'E@mon.*|data.*|igw.*|mds.*|client.*':
    - match: compound
    - prep
  'data*':
    - partition
  'igw*':
    - iscsi
  'client*':
    - initiator
  #'admin.ceph':
  #  - deploy
