# **DevOps Study**

DevOps 공부 목적의 프로젝트입니다. [Kubernetes](https://kubernetes.io/) 관리와 모니터링, 자동화에 중점을 두고 있습니다.

## 디렉토리

- `argocd-deploy` : Kubernetes manifest 배포를 위한 [ArgoCD](https://argoproj.github.io/argo-cd/) helm chart
- `dockerfiles` : 이미지 빌드를 위한 dockerfile
- `jenkins` : jenkins pipeline 스크립트
- `script` : 자동화를 위한 bash, python 스크립트
- `terraform` : AWS에 Kubernetes 클러스터를 구축하기 위한 IaC 코드

## 사용법

- [EC2로 클러스터 구축하기](https://github.com/choshsh/devops-study/blob/master/docs/Terraform%20-%20EC2%EB%A1%9C%20%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0%20%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0.MD)
- EKS로 클러스터 구축하기
- [Manifest 배포하기](https://github.com/choshsh/devops-study/blob/master/docs/Manifest%20%EB%B0%B0%ED%8F%AC%ED%95%98%EA%B8%B0.MD)