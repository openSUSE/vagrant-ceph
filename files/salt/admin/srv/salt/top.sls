base:
  ceph:
    - match: nodegroup
    - prep
  'data*':
    - partition
  'igw*':
    - iscsi
  'client*':
    - initiator
  'admin.ceph':
    - deploy
