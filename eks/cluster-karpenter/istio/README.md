# istio

## 사전 준비
- kubectl 설치
- istioctl 설치

## 설치

### 1. istio operator 설치
```bash
istioctl operator init -r <version>
```

### 2. istio 설치
```bash
kubectl apply -f operator.yml
```