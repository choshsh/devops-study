Amazon Elastic Kubernetes Service(***EKS***)로 Kubernetes 클러스터를 구축합니다.

- AWS IaC 도구 : terraform
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
    cd terraform/kubernetes-eks
    terraform init
    ```
    
2. 사전 검증
    
    ```bash
    terraform plan --var-file choshsh.tfvars
    ```
    
3. 배포
    
    ```bash
    terraform apply --var-file choshsh.tfvars
    ```
    
4. output 확인
    
    ```bash
    eks_endpoint = "<퍼블릭 DNS>"
    eks_name = "<클러스터 이름>"
    how_to_use = "aws eks update-kubeconfig --name <클러스터 이름>"
    vpc_id = "<vpc 아이디>"
    ```
    

### 2. kubernetes 클러스터

1. kube-context 설정
    
    ```bash
    # 바로 전 단계의 how_to_use 출력 실행
    $ aws eks update-kubeconfig --name <클러스터 이름>
    
    Added new context arn:<arn 이름> to /home/cho/.kube/config
    ```
    
2. 확인
    
    ```bash
    $ kubectl cluster-info
    
    Kubernetes control plane is running at https://<URL>
    CoreDNS is running at <URL>/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    ```
    

### 3. istio (with helm)

*Elastic Load Balancing*와 *Certificate Manager*를 istio ingress-gateway와 연동하여 트래픽을 받습니다.

1. [설치](https://istio.io/latest/docs/setup/install/helm/) (❗ingress 배포 전까지만)
2. ingress-gateway
    - aws 로드밸런서와 acm 사용을 위한 `override.yaml` 파일 생성
        
        ```yaml
        # override.yaml
        gateways:
          istio-ingressgateway:
            serviceAnnotations:
              service.beta.kubernetes.io/aws-load-balancer-ssl-cert: <arn>
              service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
              service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
        ```
        
    - 배포
        
        ```bash
        helm install istio-ingress manifests/charts/gateways/istio-ingress -f override.yaml -n istio-system
        ```
        
    - 확인
        
        ```bash
        $ kubectl get svc -n istio-system istio-ingressgateway
        
        NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP                                                                   PORT(S)                                      AGE
        istio-ingressgateway   LoadBalancer   10.100.57.13   ab986fdd6efdf40cf86d2cb16a5bbe72-696013522.ap-northeast-2.elb.amazonaws.com   15021:32049/TCP,80:30330/TCP,443:32381/TCP   36s
        ```
        
        ```bash
        $ kubectl describe svc -n istio-system istio-ingressgateway
        
        Events:
          Type    Reason                Age   From                Message
          ----    ------                ----  ----                -------
          Normal  EnsuringLoadBalancer  9s    service-controller  Ensuring load balancer
          Normal  EnsuredLoadBalancer   7s    service-controller  Ensured load balancer
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
    kubectl apply -f https://gist.githubusercontent.com/choshsh/e321761b43b5646821d3c2a6c18715f7/raw/csi-driver-sc.yaml
    ```
    
    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: dynamic
    provisioner: ebs.csi.aws.com
    volumeBindingMode: WaitForFirstConsumer
    allowVolumeExpansion: true
    parameters:
      type: gp3
      fsType: ext4
    ```
