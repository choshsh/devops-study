# DevOps Study

DevOps 공부 목적의 프로젝트입니다.
[Kubernetes](https://kubernetes.io/)와 CI/CD 및 모니터링에 중점을 두고 있습니다.

## 디렉토리 구조

`choshsh/devops-study`  
├── `manifest` : Kubernetes manifest  
├── `argocd-deploy` : Kubernetes manifest 배포를 위한 [ArgoCD](https://argoproj.github.io/argo-cd/) manifest  
├── `dockerfiles` : 이미지 빌드를 위한 dockerfile  
├── `jenkins` : jenkins pipeline 스크립트  
├── `script` : bash, python 스크립트  
└── `terraform` : AWS로 Kubernetes 클러스터 테스트하기 위한 IaC 코드

## 사전 준비

- [Kubernetes 클러스터 구성](https://choshsh.notion.site/3-b8c85437bc4c4fb89c91137dd6d4ee7a)
- [ArgoCD 설치](https://choshsh.notion.site/3-Argo-CD-4d7c138785834ed3a19521d16d26adc7)
- [Istio 설치](https://choshsh.notion.site/3-Istio-ab8442964e5944e3881486bc81b2958b)