import time
from locust import HttpUser, task, between


class ComplexItsmUser(HttpUser):

    # 모든 작업 사이에 1초에서 3초의 대기
    wait_time = between(1, 2)

    # 헤더 리스트 조회, 가중치 3
    @task(3)
    def get_header(self):
        url = "/api/admin/header"
        res = self.client.get(url)

    # 환경변수 리스트 조회 -> 개별 조회, 가중치 1
    @task(1)
    def get_env(self):
        url = "/api/admin/env"
        res = self.client.get(url)
        list = res.json()
        for item in list:
            key = str(item.get("key"))
            res = self.client.get(f"{url}/{key}")

    # 새로운 유저 생성 시에 실행
    def on_start(self):
        self.client.verify = False
        url = "/api/user/login"
        res = self.client.post(
            url, json={"userId": "viewer", "userPw": "viewer"})
