# DevOps Study

DevOps 공부 목적의 프로젝트입니다.
[Kubernetes](https://kubernetes.io/)와 CI/CD 및 모니터링에 중점을 두고 있습니다.

## 디렉토리 구조

- `manifest` : Kubernetes manifest 파일 모음
- `argocd-deploy` : `manifest` 디렉토리에 있는 manifest를 자동으로 배포하기 위한 [ArgoCD](https://argoproj.github.io/argo-cd/) manifest 파일 모음
- `jenkins` : jenkins pipeline 스크립트 파일 모음

## 준비 사항

- [Kubernetes 클러스터 구성](https://choshsh.notion.site/3-b8c85437bc4c4fb89c91137dd6d4ee7a)
- [ArgoCD 설치](https://choshsh.notion.site/3-Argo-CD-4d7c138785834ed3a19521d16d26adc7)
- [Istio 설치](https://choshsh.notion.site/3-Istio-ab8442964e5944e3881486bc81b2958b)


## 시작하기

`argocd-deploy.yaml` 만 수동으로 ArgoCD sync하면 나머지 manifest들은 자동으로 배포된다.

- `dev` namespace 생성 및 Istio injection 설정

```bash
kubectl create namespace dev \
  && kubectl label namespace dev istio-injection=enabled
```

- `argocd-deploy.yaml` 배포

```bash
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/choshsh/devops-study/master/argocd-deploy.yaml
```

- ArgoCD 상태 확인

```bash
$ kubectl get applications.argoproj.io -n argocd

NAME           SYNC STATUS   HEALTH STATUS
argocd         Synced        Healthy
elk            Synced        Healthy
istio-config   Synced        Healthy
itsm-db        Synced        Healthy
itsm-was       Synced        Healthy
jenkins        Synced        Healthy
```
