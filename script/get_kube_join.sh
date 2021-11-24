#! /bin/bash

### 나중에 알았는데 `kubeadm token create --print-join-command`으로 이미 제공하는 기능이 있었다...

# 워커 노드 조인 명령어 - 매번 하나하나 치기 귀찮아서 작성
# 조상현 <cho911115@gmail.com>

function get_cmdline() {
  # kubeadm 토큰 생성
  KUBEADM_TOKEN=$(sudo kubeadm token create)
  # 토큰 hash 값 조회
  HASH_VALUE=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
  # 클러스터 endpoint 조회
  ENDPOINT=$(kubectl get po -n kube-system -l component=kube-apiserver -o jsonpath="{.items[0].metadata.annotations.kubeadm\.kubernetes\.io/kube-apiserver\.advertise-address\.endpoint}")
  # join 명령어 출력
  echo "kubeadm join $ENDPOINT --token $KUBEADM_TOKEN --discovery-token-ca-cert-hash sha256:$HASH_VALUE"
}

function main() {
  get_cmdline
}

main

exit 0
