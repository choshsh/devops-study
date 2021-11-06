AWS 환경에 EC2로 매뉴얼하게 Kubernetes 클러스터를 구축합니다.

- AWS IaC 도구 : terraform
- 클러스터 생성 도구 : kubeadm
- 컨테이너 런타임 : containerd
- 퍼시스턴트 볼륨 드라이버 : Amazon EBS CSI

## 사전 준비

1. aws-cli [설치](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html) 및 [설정](https://learn.hashicorp.com/tutorials/terraform/aws-build?in=terraform/aws-get-started#prerequisites)
2. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) 설치

## 시작하기

### 1. aws 리소스

1. 기본 구성 및 모듈 설치
    
    <aside>
    💡 사전에 `provider.tf`의 `backend`는 수정 또는 삭제
    
    </aside>
    
    ```bash
    cd terraform/kubernetes-ec2
    terraform init
    ```
    
2. [ssh 키페어 생성](https://www.ssh.com/academy/ssh/keygen) - public key를 ec2 디렉토리 안에 `aws-key.pub` 파일명으로 위치
3. 사전 검증
    
    ```bash
    terraform plan --var-file choshsh.tfvars
    ```
    
4. 배포
    
    ```bash
    terraform apply --var-file choshsh.tfvars
    ```
    
5. 확인
    
    ec2가 생성될 때  `ec2/install_k8s.sh` 스크립트가  실행되면서  kubeadm, kubelet, kubectl, containerd 등을 자동으로 설치하고 설정합니다.
    
    - 출력된 EC2 public dns 주소로 ssh secret 키를 사용하여 22번 포트로 ssh 접속
    - kubernetes 관련 패키지, containerd 상태 확인

### 2. kubernetes 클러스터

1. 마스터 노드에서 kubeadm 설정파일 생성
    - cloud-provider와 cluster-cidr을 설정
    - kube-proxy `ipvs` 모드를 사용
    
    ```bash
    curl https://gist.githubusercontent.com/choshsh/de1e2e7c8376ca43bee25fec033bac4d/raw/kubeadm.yaml >kubeadm.yaml
    ```
    
2. 사전 검증
    
    ```bash
    sudo kubeadm init --config kubeadm.yaml --dry-run
    ```
    
3. kubeadm init 및 join
    
    ```bash
    sudo kubeadm init --config kubeadm.yaml
    ```
    
4. 네트워크 플러그인 설치 (CIDR `10.244.0.0/16`)

### 3. istio (with helm)

*Elastic Load Balancing*와 *Certificate Manager*를 istio ingress-gateway와 연동하여 트래픽을 받습니다.

1. [설치](https://istio.io/latest/docs/setup/install/helm/) (❗ingress 배포 전까지만)
2. ingress-gateway
    - aws 로드밸런서와 acm 사용을 위한 `override.yaml` 파일 생성
        
        ```bash
        # override.yaml
        gateways:
          istio-ingressgateway:
            type: "NodePort"
            ports:
            - port: 15021
              targetPort: 15021
              name: status-port
              nodePort: 30021
              protocol: TCP
            - port: 80
              targetPort: 8080
              name: http2
              protocol: TCP
              nodePort: 30080
            - port: 443
              targetPort: 8443
              name: https
              protocol: TCP
              nodePort: 30443
        ```
        
    - 배포
        
        ```bash
        helm install istio-ingress manifests/charts/gateways/istio-ingress -f override.yaml -n istio-system
        ```
        

### 4. Amazon EBS CSI 드라이버

클라우드 디스크를 사용하여 퍼시스턴트볼륨을 동적으로 프로비저닝합니다.

1. 드라이버 배포
    
    ```bash
    helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    helm repo update
    ```
    
    ```bash
    helm upgrade -install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/eks/aws-ebs-csi-driver \
    --set enableVolumeResizing=true \
    --set enableVolumeSnapshot=true \
    --set serviceAccount.controller.create=true \
    --set serviceAccount.controller.name=ebs-csi-controller-sa
    ```
    
2. 스토리지클래스 배포
    
    ```bash
    kubectl apply -f https://gist.github.com/choshsh/e321761b43b5646821d3c2a6c18715f7/raw/050eeb128038ca382d2760288a324de3bb3a71ce/csi-driver-sc.yaml
    ```