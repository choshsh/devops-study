#! /bin/bash

# Kubernetes version
KUBE_VERSION="1.22.2"

# Install kubernetes on linux dist from Red Hat
# Use containerd as CRI
function pre_config(){
    sudo sed -i "s/127.0.0.1/127.0.0.1 $HOSTNAME/" /etc/hosts
    sudo yum install -y iproute-tc

    if [ $(grep '^NAME' /etc/os-release | grep -i centos | wc -l) -gt 0 ]; then
        sudo swapoff -a && \
            sudo echo 0 > /proc/sys/vm/swappines
        sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab;
        sudo systemctl disable --now firewalld
    fi

    sudo setenforce 0 \
        && sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

    cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay && sudo modprobe br_netfilter
    
    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

    sudo sysctl --system
}

# Install CRI
function intall_cri(){
    if [ $(grep '^NAME' /etc/os-release | grep -i centos | wc -l) -gt 0 ]; then
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2;
        sudo yum-config-manager --add-repo \
            https://download.docker.com/linux/centos/docker-ce.repo;
    fi

    sudo yum update -y && \
        sudo yum install containerd -y && \
        sudo systemctl daemon-reload && \
        sudo systemctl enable --now containerd

    sudo mkdir -p /etc/containerd && \
	    containerd config default | sudo tee /etc/containerd/config.toml

    sudo sed -i '/\[plugins\.\"io\.containerd\.grpc\.v1\.cri\"\.containerd\.runtimes\.runc\.options\]/a \ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true' /etc/containerd/config.toml

    sudo systemctl restart containerd
}

# Install k8s package
function install_k8s(){
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

    sudo yum install -y --disableexcludes=kubernetes \
        kubelet-$KUBE_VERSION \
        kubeadm-$KUBE_VERSION \
        kubectl-$KUBE_VERSION

    sudo systemctl daemon-reload && \
	    sudo systemctl enable --now kubelet
}

function main(){
    pre_config
    intall_cri
    install_k8s
}

main

exit 0