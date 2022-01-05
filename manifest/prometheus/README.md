### 1. slack secret 생성

```yaml
# values-secret.yaml
alertmanager:
  config:
    global:
      slack_api_url: <slack url>
      resolve_timeout: 5m
```

### 2.  helm 차트 배포

```bash
helm upgrade -i p prometheus-community/kube-prometheus-stack \
  -f values-default.yaml -f values-alert.yaml -f values-secret.yaml \
  -n monitor
```