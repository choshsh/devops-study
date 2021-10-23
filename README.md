# DevOps Study

DevOps 공부 목적의 프로젝트입니다.
[Kubernetes](https://kubernetes.io/)와 CI/CD 및 모니터링에 중점을 두고 있습니다.

## 디렉토리

- `argocd-deploy` : Kubernetes manifest 배포를 위한 [ArgoCD](https://argoproj.github.io/argo-cd/) manifest
- `dockerfiles` : 이미지 빌드를 위한 dockerfile
- `jenkins` : jenkins pipeline 스크립트
- `script` : bash, python 스크립트
- `terraform` : AWS에 Kubernetes 클러스터를 생성하기 위한 IaC 코드

## 사전 준비

- [Kubernetes 클러스터 구성](https://choshsh.notion.site/3-b8c85437bc4c4fb89c91137dd6d4ee7a)
- [ArgoCD 설치](https://choshsh.notion.site/3-Argo-CD-4d7c138785834ed3a19521d16d26adc7)
- [Istio 설치](https://choshsh.notion.site/3-Istio-ab8442964e5944e3881486bc81b2958b)

## manifest 정보

### jenkins

stateless하게 구성하여 jenkins를 쉽게 관리하는 것이 목적입니다. 
([Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/) 플러그인 사용)

- Init container를 사용하여 플러그인 사전 설치 및 JCasC 파일 다운로드
- GitHub, Slack과 같은 토큰 값을 Kubernetes secret으로 생성

**secret 생성**

```bash
echo -n '1234' >./slack-token
echo -n '1234' >./choshsh-github-token

kubectl create -n jenkins secret generic jenkins-cred \
  --from-file choshsh-github-token \
  --from-file slack-token
```

## 배포하기

### argocd-deploy

argocd resource를 배포합니다. github와 `sync`가 되면 각 manifest들이 자동으로 배포됩니다.

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