# Vagrant Network

```
             client (172.17.1.0/24)
-------+--------------+------------
       |              |
   eth1|.1      enp0s8|.10
  +----+----+   +-----+-----+
  |  rt-01  |   | client-01 |
  +----+----+   +-----------+
   eth2|.1
       |                                          k8s-cluster (172.17.1.0/24)
-------+-----+------------------+-----------------+-----------------+--------
             |                  |                 |                 |
       enp0s8|.10         enp0s8|.21        enp0s8|.22        enp0s8|.23
     +-------+-------+   +------+------+   +------+------+   +------+------+
     | k8s-master-01 |   | k8s-node-01 |   | k8s-node-01 |   | k8s-node-01 |
     +---------------+   +-------------+   +-------------+   +-------------+
```

# how to use with vagrant

## k8s-cluster

- `vagrant up`
    - `make k8s-cluster-up`
- `vagrant provision`
    - `make k8s-cluster-provision`
- `vagrant halt`
    - `make k8s-cluster-down`
- `vagrant destroy`
    - `make k8s-cluster-clean`

## vagrant up

- all
```
make up
```

- indiviual
```
make rt-up
make client-up
make k8s-master-up
make k8s-nodes-up
```

## vagrant provision

- all
```
make provision
```

- indiviual
```
make rt-provision
make client-provision
make k8s-master-provision
make k8s-nodes-provision
```

## vagrant ssh

- use `Makefile`

```
make rt-01-ssh
make client-01-ssh
make k8s-master-01-ssh
make k8s-node-01-ssh
make k8s-node-02-ssh
make k8s-node-03-ssh
```

- use ssh.config

```
ssh -F rt.ssh.config rt-01
ssh -F client.ssh.config client-01
ssh -F k8s-master.ssh.config k8s-master-01
ssh -F k8s-nodes.ssh.config k8s-node-01
ssh -F k8s-nodes.ssh.config k8s-node-02
ssh -F k8s-nodes.ssh.config k8s-node-03
```

## vagrant halt

- all

```
make down
```

- indiviual

```
make rt-down
make client-down
make k8s-master-down
make k8s-nodes-down
```

## vagrant destroy

- all

```
make clean
```

- indiviual

```
make rt-clean
make client-clean
make k8s-master-clean
make k8s-nodes-clean
```

# ansible

```
ansible
├── all.yml         # playbook for all
├── clients.yml     # playbook for client
├── k8s-masters.yml # playbook for k8s-master
├── k8s-nodes.yml   # playbook for k8s-nodes
|
├── inventories # inventory files
│   ├── clients # inventory file for client
│   ├── masters # inventory file for k8s-master
│   └── nodes   # inventory file for k8s-nodes
|
└── roles       # role direcotry
    ├── clients # role for client
    ├── k8s     # role for k8s cluster
    └── role_template # role template
```
