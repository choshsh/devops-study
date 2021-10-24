# **DevOps Study**

DevOps 공부 목적의 프로젝트입니다. [Kubernetes](https://kubernetes.io/)와 CI/CD 및 모니터링에 중점을 두고 있습니다.

## 디렉토리

- `argocd-deploy` : Kubernetes manifest 배포를 위한 [ArgoCD](https://argoproj.github.io/argo-cd/) helm chart
- `dockerfiles` : 이미지 빌드를 위한 dockerfile
- `jenkins` : jenkins pipeline 스크립트
- `script` : bash, python 스크립트
- `terraform` : AWS에 Kubernetes 클러스터를 생성하기 위한 IaC 코드

## 사전 준비

- [Kubernetes 클러스터 구성](https://choshsh.notion.site/3-b8c85437bc4c4fb89c91137dd6d4ee7a)
- [ArgoCD 설치](https://choshsh.notion.site/3-Argo-CD-4d7c138785834ed3a19521d16d26adc7)
- [Istio 설치](https://choshsh.notion.site/3-Istio-ab8442964e5944e3881486bc81b2958b)

## manifest 정보

### Jenkins

stateless하게 구성하여 jenkins를 쉽게 관리하는 것이 목적입니다. 

Init Container를 사용하여 jenkins 설정과 플러그인 설치가 완료된 상태로 jenkins가 실행되도록 합니다.

- 플러그인 설치
    
    ```bash
    # Init container command 중 일부
    wget https://github.com/choshsh/jenkins-plugins/archive/refs/heads/master.zip -O /tmp/plugins.zip && \
      unzip -qq /tmp/plugins.zip -d /tmp && \
      mkdir -p /tmp/jenkins_home/plugins && \
      mv /tmp/jenkins-plugins-master/*.hpi /tmp/jenkins_home/plugins/
    ```
    
- Jenkins 설정 ([Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/) 플러그인)
    
    ```bash
    # Init container command 중 일부
    wget https://raw.githubusercontent.com/choshsh/devops-study/master/manifest/jenkins/jcasc.yaml -O /tmp/jenkins_home/casc_configs/jcasc.yaml
    ```
    
- DSL seed job 생성 ([jenkins DSL](https://plugins.jenkins.io/job-dsl/) 플러그인)
    
    ```bash
    # Init container command 중 일부
    wget https://raw.githubusercontent.com/choshsh/devops-study/master/manifest/jenkins/config.xml -O /tmp/usr/share/jenkins/ref/jobs/seed/config.xml
    ```
    

**사용법**

1. secret 생성
    
    ```bash
    echo -n '1234' >./slack-token
    echo -n '1234' >./choshsh-github-token
    
    kubectl create -n jenkins secret generic jenkins-cred \
      --from-file choshsh-github-token \
      --from-file slack-token
    ```
    
2. Pod 구동 및 Web 접속
3. 최초 사용자 생성 (사용자 데이터까지 설정할 수 있는 방법 찾는 중)
4. 생성되어 있는 seed job을 빌드하여 DSL 스크립트 실행
    
    ```bash
    # seed job 빌드 로그
    Processing DSL script jenkins/jobs/base
    Added items:
        GeneratedJob{name='CoreDNS-Debug'}
        GeneratedJob{name='image-build'}
        GeneratedJob{name='kubectl'}
        GeneratedJob{name='load-test'}
    Finished: SUCCESS
    ```
    

## ArgoCD를 사용하여 배포하기

GitOps 방식의 CD 도구인 ArgoCD를 사용하여 배포합니다. GitHub와 `sync`되면 `argocd-deploy/values.yaml`에 포함된 manifest들이 자동으로 배포됩니다.

```bash
cd argocd-deploy
helm upgrade -i -n argocd argocd-deploy . -f values.yaml -f <your values.yaml>
```

```bash
$ kubectl get -n argocd applications.argoproj.io

NAME                              SYNC STATUS   HEALTH STATUS
argocd                            Synced        Healthy
choshsh-db                        Synced        Healthy
choshsh-ui                        Synced        Healthy
grafana                           Synced        Healthy
istio-default                     Synced        Healthy
jenkins                           Synced        Healthy
loki-network                      Synced        Healthy
nfs-subdir-external-provisioner   Synced        Healthy
```
