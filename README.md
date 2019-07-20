# Vagrant Network

```
             client (172.17.1.0/24 / ASN 64512)
-------+--------------+------------
       |              |
   eth1|.1      enp0s8|.10
  +----+----+   +-----+-----+
  |  rt-01  |   | client-01 |
  +----+----+   +-----------+
   eth2|.1
       |                                          k8s-cluster (172.17.0.0/24 / ASN 64522)
-------+-----+------------------+-----------------+-----------------+--------
             |                  |                 |                 |
       enp0s8|.10         enp0s8|.21        enp0s8|.22        enp0s8|.23
     +-------+-------+   +------+------+   +------+------+   +------+------+
     | k8s-master-01 |   | k8s-node-01 |   | k8s-node-01 |   | k8s-node-01 |
     +---------------+   +-------------+   +-------------+   +-------------+
```

* docker0 : 172.17.255.0/24
* k8s
    * Flannel Pod Network CIDR :  10.244.0.0/16
    * Service CIDR : 10.244.0.0/16
    * BGP network : 172.17.254.0/24
* ASNs
    * client 64512
    * k8s-cluster 64522

# kube-system with flannel

```
vagrant@k8s-master-01:~$ kubectl get all --namespace=kube-system -o wide
NAME                                        READY   STATUS    RESTARTS   AGE   IP            NODE            NOMINATED NODE   READINESS GATES
pod/coredns-fb8b8dccf-qc8mt                 1/1     Running   1          22h   10.244.0.4    k8s-master-01   <none>           <none>
pod/coredns-fb8b8dccf-stw6c                 1/1     Running   1          22h   10.244.0.5    k8s-master-01   <none>           <none>
pod/etcd-k8s-master-01                      1/1     Running   1          22h   172.17.0.10   k8s-master-01   <none>           <none>
pod/kube-apiserver-k8s-master-01            1/1     Running   1          22h   172.17.0.10   k8s-master-01   <none>           <none>
pod/kube-controller-manager-k8s-master-01   1/1     Running   1          22h   172.17.0.10   k8s-master-01   <none>           <none>
pod/kube-flannel-ds-amd64-bctmz             1/1     Running   1          22h   172.17.0.23   k8s-node-03     <none>           <none>
pod/kube-flannel-ds-amd64-gt76t             1/1     Running   1          22h   172.17.0.10   k8s-master-01   <none>           <none>
pod/kube-flannel-ds-amd64-j8rzm             1/1     Running   1          22h   172.17.0.22   k8s-node-02     <none>           <none>
pod/kube-flannel-ds-amd64-mcffj             1/1     Running   1          22h   172.17.0.21   k8s-node-01     <none>           <none>
pod/kube-proxy-5r2xx                        1/1     Running   1          22h   172.17.0.10   k8s-master-01   <none>           <none>
pod/kube-proxy-cx9wk                        1/1     Running   1          22h   172.17.0.23   k8s-node-03     <none>           <none>
pod/kube-proxy-d9j6k                        1/1     Running   1          22h   172.17.0.22   k8s-node-02     <none>           <none>
pod/kube-proxy-l7mxz                        1/1     Running   1          22h   172.17.0.21   k8s-node-01     <none>           <none>
pod/kube-scheduler-k8s-master-01            1/1     Running   1          22h   172.17.0.10   k8s-master-01   <none>           <none>

NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
service/kube-dns   ClusterIP   10.244.0.10   <none>        53/UDP,53/TCP,9153/TCP   22h   k8s-app=kube-dns

NAME                                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                     AGE   CONTAINERS     IMAGES                                   SELECTOR
daemonset.apps/kube-flannel-ds-amd64     4         4         4       4            4           beta.kubernetes.io/arch=amd64     22h   kube-flannel   quay.io/coreos/flannel:v0.10.0-amd64     app=flannel,tier=node
daemonset.apps/kube-flannel-ds-arm       0         0         0       0            0           beta.kubernetes.io/arch=arm       22h   kube-flannel   quay.io/coreos/flannel:v0.10.0-arm       app=flannel,tier=node
daemonset.apps/kube-flannel-ds-arm64     0         0         0       0            0           beta.kubernetes.io/arch=arm64     22h   kube-flannel   quay.io/coreos/flannel:v0.10.0-arm64     app=flannel,tier=node
daemonset.apps/kube-flannel-ds-ppc64le   0         0         0       0            0           beta.kubernetes.io/arch=ppc64le   22h   kube-flannel   quay.io/coreos/flannel:v0.10.0-ppc64le   app=flannel,tier=node
daemonset.apps/kube-flannel-ds-s390x     0         0         0       0            0           beta.kubernetes.io/arch=s390x     22h   kube-flannel   quay.io/coreos/flannel:v0.10.0-s390x     app=flannel,tier=node
daemonset.apps/kube-proxy                4         4         4       4            4           <none>                            22h   kube-proxy     k8s.gcr.io/kube-proxy:v1.14.3            k8s-app=kube-proxy

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                     SELECTOR
deployment.apps/coredns   2/2     2            2           22h   coredns      k8s.gcr.io/coredns:1.3.1   k8s-app=kube-dns

NAME                                DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                     SELECTOR
replicaset.apps/coredns-fb8b8dccf   2         2         2       22h   coredns      k8s.gcr.io/coredns:1.3.1   k8s-app=kube-dns,pod-template-hash=fb8b8dccf
vagrant@k8s-master-01:~$
```

# setup metallb

```
vagrant@k8s-master-01:~$ kubectl apply -f shared/k8s-configs/metallb.yaml
namespace/metallb-system created
serviceaccount/controller created
serviceaccount/speaker created
clusterrole.rbac.authorization.k8s.io/metallb-system:controller created
clusterrole.rbac.authorization.k8s.io/metallb-system:speaker created
role.rbac.authorization.k8s.io/config-watcher created
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:controller created
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker created
rolebinding.rbac.authorization.k8s.io/config-watcher created
daemonset.apps/speaker created
deployment.apps/controller created
vagrant@k8s-master-01:~$ kubectl apply -f shared/k8s-configs/metallb-bgp.yaml
configmap/config created
vagrant@k8s-master-01:~$ kubectl get all --namespace=metallb-system -o wide
NAME                             READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
pod/controller-cd8657667-nj2lm   1/1     Running   1          21h   10.244.3.9    k8s-node-03   <none>           <none>
pod/speaker-8g955                1/1     Running   1          21h   172.17.0.22   k8s-node-02   <none>           <none>
pod/speaker-vh5x7                1/1     Running   1          21h   172.17.0.21   k8s-node-01   <none>           <none>
pod/speaker-vtb64                1/1     Running   1          21h   172.17.0.23   k8s-node-03   <none>           <none>

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS   IMAGES                   SELECTOR
daemonset.apps/speaker   3         3         3       3            3           <none>          21h   speaker      metallb/speaker:v0.7.3   app=metallb,component=speaker

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
deployment.apps/controller   1/1     1            1           21h   controller   metallb/controller:v0.7.3   app=metallb,component=controller

NAME                                   DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                      SELECTOR
replicaset.apps/controller-cd8657667   1         1         1       21h   controller   metallb/controller:v0.7.3   app=metallb,component=controller,pod-template-hash=cd8657667
vagrant@k8s-master-01:~$
```

# 挙動確認用 nginx デプロイ

```
vagrant@k8s-master-01:~$ kubectl apply -f shared/k8s-configs/nginx-deploy.yaml
deployment.apps/nginx-deployment created
service/nginx-cluster-ip-svc created
service/nginx-nodeport-svc created
service/nginx created
vagrant@k8s-master-01:~$ kubectl get all -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
pod/bbox-64cb8dfdcf-m45pd              1/1     Running   1          24h   10.244.1.18   k8s-node-01   <none>           <none>
pod/nginx-deployment-6fff8bf46-2rfqx   1/1     Running   0          26s   10.244.1.20   k8s-node-01   <none>           <none>
pod/nginx-deployment-6fff8bf46-4m7xz   1/1     Running   0          26s   10.244.3.15   k8s-node-03   <none>           <none>
pod/nginx-deployment-6fff8bf46-5mgft   1/1     Running   0          26s   10.244.3.14   k8s-node-03   <none>           <none>
pod/nginx-deployment-6fff8bf46-bdznk   1/1     Running   0          26s   10.244.2.8    k8s-node-02   <none>           <none>
pod/nginx-deployment-6fff8bf46-c6snv   1/1     Running   0          26s   10.244.2.7    k8s-node-02   <none>           <none>
pod/nginx-deployment-6fff8bf46-pb8sh   1/1     Running   0          26s   10.244.1.19   k8s-node-01   <none>           <none>

NAME                           TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE     SELECTOR
service/kubernetes             ClusterIP      10.244.0.1     <none>        443/TCP        4d20h   <none>
service/nginx                  LoadBalancer   10.244.215.95  172.17.254.1  80:32705/TCP   26s     app=nginx

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES           SELECTOR
deployment.apps/bbox               1/1     1            1           24h   bbox              busybox:latest   run=bbox
deployment.apps/nginx-deployment   6/6     6            6           26s   nginx-container   nginx:alpine     app=nginx

NAME                                         DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES           SELECTOR
replicaset.apps/bbox-64cb8dfdcf              1         1         1       24h   bbox              busybox:latest   pod-template-hash=64cb8dfdcf,run=bbox
replicaset.apps/nginx-deployment-6fff8bf46   6         6         6       26s   nginx-container   nginx:alpine     app=nginx,pod-template-hash=6fff8bf46
vagrant@k8s-master-01:~$
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
    ├── clients    # role for client
    ├── k8s        # role for k8s cluster
    ├── k8s-node   # role for k8s worker nodes
    ├── k8s-master # role for k8s master node
    └── role_template # role template
```

# kubeadm で k8s クラスタに参加する

マスターノード構築時に `kubeadm init` の出力を `shared/k8s-init.txt` で保存しているが、token の有効期間は 24 時間なので、だいたいは有効期限切れになっている。

1. k8s マスターノードで token を発行する
```
$ kubeadm token create --print-join-command
-> kubeadm join コマンドが表示される
```
2. k8s クラスタに参加するノードで `kubeadm token create --print-join-command` で表示された `kubeadm join` を実行する
3. k8s マスターノードでワーカーノードとして登録する
```
kubectl label nodes <hostname> node-role.kubernetes.io/node=
kubectl label nodes <hostname> type=worker
```

# k8s クラスタからノードを削除する

- `kubectl` で安全にノードを削除することができる

```
kubectl cordon <hostname>
kubectl drain <hostname> --ignore-daemonsets
kubectl delete nodes <hostname>
```

# k8s クラスタを作り直す

1. ワーカーノードを削除しておく
2. `kubeadm reset` でクラスタ削除
```
sudo kubeadm reset
```
3. 最後に iptables のルールをリセットするように言われるので、実行しておく
4. `kubeadm init` でクラスタを作る
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=172.17.0.10 --service-cidr=10.244.0.0/16
```

## sample

```
vagrant@k8s-master-01:~$ sudo kubeadm reset
[reset] Reading configuration from the cluster...
[reset] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
[reset] Are you sure you want to proceed? [y/N]: y
[preflight] Running pre-flight checks
[reset] Removing info for node "k8s-master-01" from the ConfigMap "kubeadm-config" in the "kube-system" Namespace
W0614 11:45:46.234057    7260 reset.go:158] [reset] failed to remove etcd member: error syncing endpoints with etc: etcdclient: no available endpoints
.Please manually remove this etcd member using etcdctl
[reset] Stopping the kubelet service
[reset] unmounting mounted directories in "/var/lib/kubelet"
[reset] Deleting contents of stateful directories: [/var/lib/etcd /var/lib/kubelet /etc/cni/net.d /var/lib/dockershim /var/run/kubernetes]
[reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
[reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually.
For example:
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

vagrant@k8s-master-01:~$
```

# kubeadm を使って k8s クラスタのアップデート

1.14 系から 1.15 系にアップデートする

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade-1-15/

control plane node は master ノード、worker node は worker ノードと読み換える

## master ノードをアップデートする

k8s-master-01 で実行する

kubeadm をアップデートする

```shell
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=1.15.1-00
apt-mark hold kubeadm
```


アップデート計画を確認する

```shell
kubeadm upgrade plan
```

問題がなければ、 `kubeadm upgrade plan` の最後に表示された `kubeadm upgrade apply v1.15.X` を実行する

master ノードを冗長化している場合は以下のように他の master ノードも更新する

```shell
kubeadm upgrade node
kubeadm upgrade apply
```

CNI プラグインを更新する。

以下は全ての master node で実施する

kubelet パッケージと kubectl パッケージを更新する

```shell
apt-mark unhold kubelet kubectl
apt-get update && apt-get install kubelet=1.15.1-00 kubectl=1.15.1-00
apt-mark hold kubelet kubectl
```

kubelet を再起動させる

```shell
systemctl restart kubelet
```

## worker ノードをアップデートする

各 worker ノードで以下のように rolling upgrade していく

kubeadm パッケージを更新する

```shell
apt-mark unhold kubeadm
apt-get update && apt-get install kubeadm=1.15.1-00
apt-mark hold kubeadm
```

k8s-master-01 でアップデートする worker ノードを離脱させる

```shell
kubectl drain <node> --ignore-daemonsets
```

`kubectl drain` が完了した worker ノードは `kubectl get nodes` の `STATUS` で `NotReady,SchedulingDisabled` と表示される。また、離脱させた worker ノードで稼働していた Pod などは他の worker ノードに移っている。

アップデートする worker node で以下を実行して kubelet の設定を更新する

```shell
kubeadm upgrade node
```

kubelet パッケージと kubectl パッケージを更新する

```shell
apt-mark unhold kubelet kubectl
apt-get update && apt-get install kubelet=1.15.1-00 kubectl=1.15.1-00
apt-mark hold kubelet kubectl
```

kubelet を再起動する。

```shell
systemctl restart kubelet
```

k8s-master-01 で以下を実行して、アップデートが完了した worker ノードを k8s クラスタに再参加させる。

```shell
kubectl uncordon <node>
```

`kubectl get nodes` で再参加した worker ノードの `STATUS` が `Ready` になっていることを確認する。
