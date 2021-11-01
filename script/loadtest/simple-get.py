import time
from locust import HttpUser, task, between


class SimpleGetUser(HttpUser):
    # 모든 작업 사이에 1초에서 2초 대기
    wait_time = between(1, 2)

    @task
    def hello_world(self):
        self.client.get("/")
