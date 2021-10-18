# jenkins

[Jenkins Kubernetes 플러그인](https://plugins.jenkins.io/kubernetes/)을 사용하는 [Jenkins](https://www.jenkins.io/) pipeline 스크립트입니다.

## 시작하기

### [load-test](https://github.com/choshsh/devops-study/blob/master/jenkins/load-test)

오픈소스 성능테스트 도구 [locust](https://locust.io/) 를 사용하여 부하테스트를 합니다.

- 파이썬 테스트 코드 작성 필요 [(예시)](https://github.com/choshsh/devops-study/tree/master/script/loadtest)
- 테스트 결과는 csv 파일로 생성되며 artifacts로 기록

### [dns-debug](https://github.com/choshsh/devops-study/blob/master/jenkins/dns-debug)

클러스터 내부/외부 DNS 서비스가 정상인지 점검합니다.

- `Debug CoreDNS` 스테이지는 `[kubectl](https://github.com/choshsh/devops-study/blob/master/jenkins/kubectl)` pipeline 트리거

### [image-build](https://github.com/choshsh/devops-study/blob/master/jenkins/image-build)

[kaniko](https://github.com/GoogleContainerTools/kaniko#kaniko---build-images-in-kubernetes)를 사용하여 Dockerfile에서 이미지를 빌드하고 push합니다.

- `[kaniko` manifest 필요](https://github.com/choshsh/devops-study/blob/master/manifest/utils/kaniko.yaml)
- Dockerfile 필요
- [pod manifest를 배포할 kube-context 필요](https://choshsh.notion.site/Service-Account-170be563911d47ba8f37f5ad2debc4dd#9bc8a75720ab490381652de3ab8161ca)
- [docker registry secret 필요](https://choshsh.notion.site/kaniko-8eb722871ad14abba6832974b0cb0118#deed96aa53e24ade92914146b29fdaf7)

### [kubectl](https://github.com/choshsh/devops-study/blob/master/jenkins/kubectl)

bash 스크립트로 작성된 [간단한 kubectl 명령어](https://github.com/choshsh/devops-study/blob/master/script/kubectl_func.sh)를 실행합니다.

## 기타

### python 이미지로 `[yaml_editor.py](https://github.com/choshsh/devops-study/blob/master/script/yaml_editor.py)` 스크립트 실행

pipeline에서 yaml 파일을 동적으로 수정하기 위해 간단한 파이썬 함수를 구현했습니다. kubectl, build-image pipeline에서 기본 yaml 파일을 기반으로 값만 변경해서 사용하기 때문입니다.

### 공유 라이브러리

`@Library('choshsh') _` 으로 사용하는 공유 라이브러리는 중복 코드를 줄이기 위해 사용합니다. [(링크)](https://github.com/choshsh/jenkins-library.git)