# Vagrant Network

```
             client (172.17.0.0/24)
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

* docker0 : 172.17.255.0/24
* k8s
    * Flannel Pod Network CIDR :  10.244.0.0/16/16
    * Service CIDR : 10.32.0.0/24

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
    ├── clients    # role for client
    ├── k8s        # role for k8s cluster
    ├── k8s-node   # role for k8s worker nodes
    ├── k8s-master # role for k8s master node
    └── role_template # role template
```

# join to k8s cluster

- on k8s worker nodes

```
sudo $( tail -n 1 /home/vagrant/shared/k8s-init.txt )
```

or 

```
kubectl join 172.17.0.10:6443 --token <token> --discovery-token-ca-cert-hash $( tail -n 1 /home/vagrant/shared/k8s-init.txt | awk '{print $NF}' )
```

- create token at k8s master node
```
kubeadm token create --pront-join-command
```

- kubeadm join at k8s nodes

- on k8s master nodes

```
kubectl label nodes <hostname> node-role.kubernetes.io/node=
kubectl label nodes <hostname> type=worker
```

# remove from k8s cluster

- on k8s master node

```
kubectl cordon <hostname>
kubectl drain <hostname> --ignore-daemonsets
kubectl delete nodes <hostname>
```
