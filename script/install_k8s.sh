#! /bin/bash

# CentOS 또는 Amazon Linux 2에 쿠버네티스 설치
# 조상현 <cho911115@gmail.com>

# Kubernetes 버전
KUBE_VERSION="1.22.4"
# 변경할 ssh 포트
SSH_PORT="1746"

# 사전 설정 - OS 설정, 커널 모듈, 패키지
# (기본 설정 참고 : https://kubernetes.io/ko/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
# (ipvs mode 참고 : https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/ipvs/README.md)
function pre_config() {
    sudo sed -i "s/127.0.0.1/127.0.0.1 $HOSTNAME/" /etc/hosts
    sudo yum install -y iproute-tc

    # ssh 포트 변경
    sudo sed -i "/Port 22/ c\Port $SSH_PORT" /etc/ssh/sshd_config

    # If Amazon Linux 2
    if [ $(grep '^NAME' /etc/os-release | grep -i 'Amazon Linux' | wc -l) -gt 0 ]; then
        # kube-proxy ipvs mode 사용을 위한 설정
        sudo yum install -y ipset ipvsadm
        cat <<EOF | sudo tee /etc/sysconfig/modules/ipvs.modules
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
        chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules
    fi

    # If CentOS
    if [ $(grep '^NAME' /etc/os-release | grep -i centos | wc -l) -gt 0 ]; then
        sudo swapoff -a
        sudo echo 0 > /proc/sys/vm/swappines
        sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab;
        sudo systemctl disable --now firewalld
        # selinux permissive 모드로 변경 (Amazon Linux는 기본값이 disabled)
        sudo setenforce 0 && sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
    fi

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

    cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
EOF

    # 재부팅하지 않고 sysctl 파라미터 적용
    sudo sysctl --system
}

# 컨테이너 런타임 설치
function intall_cri() {
    if [ $(grep '^NAME' /etc/os-release | grep -i centos | wc -l) -gt 0 ]; then
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2;
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo;
    fi

    sudo yum install containerd -y && \
        sudo systemctl daemon-reload && \
        sudo systemctl enable --now containerd

    sudo mkdir -p /etc/containerd && \
	    containerd config default | sudo tee /etc/containerd/config.toml

    # cgroup 관리자를 systemd로 설정
    # (참고 : https://kubernetes.io/ko/docs/setup/production-environment/container-runtimes/#cgroup-%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B2%84)
    sudo sed -i '/\[plugins\.\"io\.containerd\.grpc\.v1\.cri\"\.containerd\.runtimes\.runc\.options\]/a \ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true' /etc/containerd/config.toml

    sudo systemctl restart containerd
}

# kubeadm, kubelet, kubectl 설치
function install_k8s() {
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

function main() {
    sudo yum update -y
    pre_config
    intall_cri
    install_k8s
}

# 커널이 업데이트 됐을 경우를 생각해서 reboot
main && reboot

exit 0