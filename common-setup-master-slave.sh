#!/bin/bash

swapoff -a  # optional but its good to do as it may impact performance
dnf install -y iproute-tc  #install the traffic control utility package

modprobe overlay # it will load the driver overlay
modprobe br_netfilter # it will load the driver br_netfilter (used for managing patting)

# to make loading of drivers permanent, post reboot also, it will be loaded
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# to enable IP forwarding post reboot also, it will be enabled using this
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system  # to activate above modules

setenforce 0  # stopping seLinux
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config # permanently stopping seLinux

KUBERNETES_VERSION=v1.29       #Command line variable for k8s
PROJECT_PATH=prerelease:/main  #Command line variable for cri-o

# configure yum for cri-o
cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/rpm/repodata/repomd.xml.key
EOF

dnf install -y cri-o # install cri-o
systemctl enable --now crio #start and enable crio service

# configure yum for kubernetes
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/repodata/repomd.xml.key
EOF

dnf install -y kubelet kubeadm kubectl #install kubelet, kubeadm, kubectl

systemctl enable --now kubelet #start and enable the kubelet service

#crictl can be used just like kubectl

*****************************
