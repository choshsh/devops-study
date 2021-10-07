# argocd-deploy

[ArgoCD](https://argo-cd.readthedocs.io/en/stable/)를 활용하여 GitOps 방식으로 Kubernetes manifest들을 배포합니다.

ArgoCD는 별도의 저장소를 사용하지 않고 아래와 같은 Kubernetes 리소스로 관리됩니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
...
```

새로운 배포를 만들 때 지루한 반복을 줄이기 위해 helm chart로 작성했습니다.