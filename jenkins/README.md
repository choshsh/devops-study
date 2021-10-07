# jenkins

[Jenkins Kubernetes 플러그인](https://plugins.jenkins.io/kubernetes/)을 사용하는 [Jenkins](https://www.jenkins.io/) pipeline 스크립트입니다.


## 디렉토리 구조

`choshsh/devops-study/jenkins`  
├── `pod_template` : pipeline에서 사용할 pod manifest  
└── *.jenkinsfile : jenkins pipeline script  

보통 pipeline 스크립트는 별도의 확장자를 붙이지 않는 것 같습니다.

저는 스크립트를 작성할 떄 vscode의 highlight와 lint 기능을 사용하기 위해 .jenkinsfile을 붙였습니다.

(vscode가 기본적으로 Jenkinsfile이라는 파일명만 인식해서요😂)

`settings.json`에 아래  설정만 추가하면 됩니다. 편해요👍

```json
"files.associations": {
  "*.jenkinsfile": "jenkinsfile"
}
```
