# jenkins

[Jenkins Kubernetes 플러그인](https://plugins.jenkins.io/kubernetes/)을 사용하는 [Jenkins](https://www.jenkins.io/) pipeline 스크립트입니다.

## Pipeline

### [load-test](https://github.com/choshsh/devops-study/blob/master/jenkins/load-test)

오픈소스 성능테스트 도구 [locust](https://locust.io/) 를 사용하여 부하테스트를 합니다. 

- 파이썬 테스트 코드 작성 필요 [(예시)](https://github.com/choshsh/devops-study/tree/master/script/loadtest)
- 테스트 결과는 csv 파일로 생성되며 artifacts로 기록

### [dns-debug](https://github.com/choshsh/devops-study/blob/master/jenkins/dns-debug)

클러스터 내부/외부 DNS 서비스가 정상인지 점검합니다.

- `Debug CoreDNS` 스테이지는 [kubectl pipeline](https://github.com/choshsh/devops-study/blob/master/jenkins/kubectl) 트리거

### [image-build](https://github.com/choshsh/devops-study/blob/master/jenkins/image-build)

[kaniko](https://github.com/GoogleContainerTools/kaniko#kaniko---build-images-in-kubernetes)를 사용하여 Dockerfile에서 이미지를 빌드하고 push합니다.

- kaniko manifest 필요 [(링크)](https://github.com/choshsh/devops-study/blob/master/manifest/utils/kaniko.yaml)
- Dockerfile 필요
- pod manifest를 배포할 kube-context 필요 ([만들기](https://www.notion.so/Service-Account-170be563911d47ba8f37f5ad2debc4dd))
- docker registry secret 필요 [(만들기)](https://www.notion.so/kaniko-8eb722871ad14abba6832974b0cb0118)

### [kubectl](https://github.com/choshsh/devops-study/blob/master/jenkins/kubectl)

bash 스크립트로 작성된 간단한 kubectl 명령어를 실행합니다. [(링크)](https://github.com/choshsh/devops-study/blob/master/script/kubectl_func.sh)

## 시작하기

[jenkins DSL](https://plugins.jenkins.io/job-dsl/) 플러그인을 사용하여 모든 job을 코드로 관리합니다. 단 코드를 실행하기 위한 seed job은 직접 생성해야 합니다.

### seed job 생성

[새로운 Item] → [Freestyle project]

### seed job 설정

**노드 설정**

`MASTER`라는 Label을 가진 빌드는 마스터 노드에서 실행되도록 설정합니다.

![https://user-images.githubusercontent.com/40452325/138561543-dc105b95-1f14-4376-a6d9-1b9bd22f01f2.png](https://user-images.githubusercontent.com/40452325/138561543-dc105b95-1f14-4376-a6d9-1b9bd22f01f2.png)

**빌드 설정 - 매개변수**

seed job이 마스터 노드에서 실행되도록 label을 매개변수로 설정합니다.

![https://user-images.githubusercontent.com/40452325/138561567-6fb24b45-d6e1-40c9-ab5f-76d6033fc353.png](https://user-images.githubusercontent.com/40452325/138561567-6fb24b45-d6e1-40c9-ab5f-76d6033fc353.png)

**빌드 설정 - 소스 코드 관리**

jenkins DSL 코드를 읽고 실행할 수 있도록 GitHub 프로젝트를 연동합니다.

![https://user-images.githubusercontent.com/40452325/138561590-94518527-5e12-45af-866e-144c346dace0.png](https://user-images.githubusercontent.com/40452325/138561590-94518527-5e12-45af-866e-144c346dace0.png)

**Build**

process job DSLs를 추가

![https://user-images.githubusercontent.com/40452325/138561602-6435bca6-825c-4d7d-9b42-1420a4798b77.png](https://user-images.githubusercontent.com/40452325/138561602-6435bca6-825c-4d7d-9b42-1420a4798b77.png)

### seed job 실행

seed job이 성공적으로 빌드되면 아래와 같이 로그가 출력되고 job이 생성됩니다.

```
Processing DSL script jenkins/jobs/base
Added items:
    GeneratedJob{name='kubectl-script'}
Existing items:
    GeneratedJob{name='CoreDNS-Debug'}
Finished: SUCCESS
```

## 기타

### python 이미지로 [yaml_editor.py](https://github.com/choshsh/devops-study/blob/master/script/yaml_editor.py) 스크립트 실행

pipeline에서 yaml 파일을 동적으로 수정하기 위해 간단한 파이썬 함수를 구현했습니다. kubectl, build-image pipeline에서 기본 yaml 파일을 기반으로 값만 변경해서 사용하기 때문입니다.

### 공유 라이브러리

`@Library('choshsh') _` 으로 사용하는 공유 라이브러리는 중복 코드를 줄이기 위해 사용합니다. [(링크)](https://github.com/choshsh/jenkins-library.git)