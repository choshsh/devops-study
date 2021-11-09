ArgoCD를 사용하여 GitOps 패턴으로 manifest들을 배포합니다.

## 사전 준비

- [EC2로 클러스터 구축](https://github.com/choshsh/devops-study/blob/master/docs/Terraform%20-%20EC2%EB%A1%9C%20%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0%20%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0.md) or [EKS로 클러스터 구축](https://github.com/choshsh/devops-study/blob/master/docs/Terraform%20-%20EKS%EB%A1%9C%20%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0%20%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0.md)
- [ArgoCD 설치](https://choshsh.notion.site/4d7c138785834ed3a19521d16d26adc7)
- `dynamic` 이름의 스토리지클래스

## 시작하기

사전 설정을 완료하고 ArgoCD를 사용하여 일괄적으로 배포합니다.

### 클러스터

- 노드 Taints
    
    애플리케이션 빌드, 부하테스트 등 많은 리소스를 사용하는 jenkins는 다른 객체들과 격리시킵니다.
    
    ```bash
    NODE_NAME=<노드이름>
    kubectl label nodes $NODE_NAME node-role.kubernetes.io/jenkins=""
    kubectl taints node $NODE_NAME node-role.kubernetes.io/jenkins:NoSchedule
    ```
    
- `monitoring` 네임스페이스 생성
    
    ```bash
    kubectl create ns monitoring
    ```
    
- Istio sidecar injection
    
    ```bash
    kubectl label ns default istio-injection=enabled
    kubectl label ns monitoring istio-injection=enabled
    ```
    

### Jenkins

- secret 생성
    - kube-context : [이미지 빌드](https://github.com/choshsh/devops-study/blob/master/jenkins/pipelines/imageBuild), [kubectl](https://github.com/choshsh/devops-study/blob/master/jenkins/pipelines/kubectl) 파이프라인에서 사용
        
        ```bash
        kubectl create secret generic -n jenkins kubeconfig \
          --type=string \
          --from-file ~/.kube/config
        ```
        
    - DockerHub : [이미지 빌드](https://github.com/choshsh/devops-study/blob/master/jenkins/pipelines/imageBuild) 파이프라인에서 사용
        
        ```bash
        kubectl -n jenkins create secret docker-registry dockercred \
            --docker-server=https://index.docker.io/v1/ \
            --docker-username=<아이디> \
            --docker-password=<비밀번호 토큰> \
            --docker-email=<이메일>
        ```
        
    - Slack, GitHub
        
        ```bash
        echo -n <Slack 토큰> >slack-token
        echo -n <GitHub 토큰> >github-token
        echo -n <DockerHub 토큰> >dockerhub-token
        
        kubectl create -n jenkins secret generic jenkins-cred \
          --from-file slack-token \
          --from-file github-token \
          --from-file dockerhub-token
        ```
        

### MySQL DB

secret으로 비밀번호를 관리합니다.

```bash
echo -n '<비밀번호>' >./password
kubectl create secret generic mysql-password --from-file password
```

### jenkins-rest

jenkins와 연결할 사용자 토큰을 secret으로 관리합니다.  ([토큰 생성하기](https://choshsh.notion.site/89b9a9ff76ef405b82ba068b4752fb7c))

```bash
echo -n '<아이디>:<토큰>' >jenkins-cred
kubectl create secret generic jenkins-cred --from-file jenkins-cred
```

<aside>
💡 DB 연결 없이 H2 인메모리 DB로 앱을 실행할 수 있습니다.
container args에 `--spring.profiles.active=dev` 설정

</aside>

### choshsh-ui

<aside>
💡 DB 연결 없이 H2 인메모리 DB로 앱을 실행할 수 있습니다.
container args에 `--spring.profiles.active=dev` 설정

</aside>

### Loki, Prometheus, Alertmanager

Slack 토큰(URL)을 helm  파라미터로 설정합니다

```bash
cd manifest/loki-stack
```

```bash
$ vim values-choshsh-secret.yaml

prometheus:
  alertmanagerFiles:
    alertmanager.yml:
      global:
        slack_api_url: "<Slack URL>"
```

```bash
helm upgrade -i loki . -f values.yaml -f values-choshsh.yaml -f values-choshsh-secret.yaml -n monitoring
```

### ArgoCD로 배포하기

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/choshsh/devops-study/master/argocd-deploy.yaml
```

- 확인
    
    ```bash
    $ kubectl get applications.argoproj.io -n argocd
    
    NAME                  SYNC STATUS   HEALTH STATUS
    argocd                Synced        Healthy
    choshsh-db            Synced        Healthy
    choshsh-ui            Synced        Healthy
    choshsh-ui-loadtest   Synced        Healthy
    choshsh-ui-vs         Synced        Healthy
    grafana               Synced        Healthy
    istio-default         Synced        Healthy
    jenkins               Synced        Healthy
    jenkins-rest          Synced        Healthy
    loki-network          Synced        Healthy
    node-exporter         Synced        Healthy
    ```
