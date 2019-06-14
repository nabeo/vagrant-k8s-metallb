.PHONY: up
up: rt-up client-up k8s-master-up k8s-nodes-up
.PHONY: provision
provision: rt-provision client-provision k8s-master-provision k8s-nodes-provision
.PHONY: down
down: rt-down client-down k8s-master-down k8s-nodes-down
.PHONY: clean
clean: rt-clean client-clean k8s-master-clean k8s-nodes-clean


# rt-01
.PHONY: rt-up
rt-up: rt.ssh.config
rt.ssh.config: Vagrantfile
	vagrant up rt-01
	vagrant ssh-config rt-01 > rt.ssh.config

.PHONY: rt-provision
rt-provision: rt.ssh.config
	vagrant provision rt-01

.PHONY: rt-01-ssh
rt-01-ssh: rt.ssh.config
	ssh -F rt.ssh.config rt-01

.PHONY: rt-down
rt-down:
	vagrant halt rt-01

.PHONY: rt-clean
rt-clean:
	vagrant destroy -f rt-01
	rm -f rt.ssh.config

# client-01
.PHONY: client-up
client-up: client.ssh.config
client.ssh.config: Vagrantfile
	vagrant up client-01
	vagrant ssh-config client-01 > client.ssh.config

.PHONY: client-provision
client-provision: client.ssh.config
	vagrant provision client-01

.PHONY: client-01-ssh
client-01-ssh: client-01.ssh.config
	ssh -F client.ssh.config client-01

.PHONY: client-down
client-down:
	vagrant halt client-01

.PHONY: client-clean
client-clean:
	vagrant destroy -f client-01
	rm -f client.ssh.config

# k8s-cluster
.PHONY: k8s-cluster-up
k8s-cluster-up: k8s-master-up k8s-nodes-up
.PHONY: k8s-cluster-provision
k8s-cluster-provision: k8s-master-provision k8s-nodes-provision
.PHONY: k8s-cluster-down
k8s-cluster-down: k8s-master-down k8s-nodes-down
.PHONY: k8s-cluster-clean
k8s-cluster-clean: k8s-master-clean k8s-nodes-clean

# k8s-master-01
.PHONY: k8s-master-up
k8s-master-up: k8s-master.ssh.config
k8s-master.ssh.config: Vagrantfile
	vagrant up k8s-master-01
	vagrant ssh-config k8s-master-01 > k8s-master.ssh.config

.PHONY: k8s-master-provision
k8s-master-provision: k8s-master.ssh.config
	vagrant provision k8s-master-01

.PHONY: k8s-master-01-ssh
k8s-master-01-ssh: k8s-master.ssh.config
	ssh -F k8s-master.ssh.config k8s-master-01

.PHONY: k8s-master-down
k8s-master-down:
	vagrant halt k8s-master-01
	rm -f k8s-master.ssh.config

.PHONY: k8s-master-clean
k8s-master-clean:
	vagrant destroy -f k8s-master-01
	rm -f k8s-master.ssh.config

# k8s-node-XX
.PHONY: k8s-nodes-up
k8s-nodes-up: k8s-nodes.ssh.config
k8s-nodes.ssh.config: Vagrantfile
	vagrant up --parallel /k8s-node/
	vagrant ssh-config /k8s-node/ > k8s-nodes.ssh.config

.PHONY: k8s-nodes-provision
k8s-nodes-provision: k8s-nodes.ssh.config
	vagrant up --parallel --provision /k8s-node/

.PHONY: k8s-node-01-ssh
k8s-node-01-ssh: k8s-nodes.ssh.config
	ssh -F k8s-nodes.ssh.config k8s-node-01

.PHONY: k8s-node-02-ssh
k8s-node-02-ssh: k8s-nodes.ssh.config
	ssh -F k8s-nodes.ssh.config k8s-node-02

.PHONY: k8s-node-03-ssh
k8s-node-03-ssh: k8s-nodes.ssh.config
	ssh -F k8s-nodes.ssh.config k8s-node-03

.PHONY: k8s-nodes-down
k8s-nodes-down:
	vagrant halt /k8s-node/

.PHONY: k8s-nodes-clean
k8s-nodes-clean:
	vagrant destroy -f /k8s-node/
	rm -f k8s-nodes.ssh.config
