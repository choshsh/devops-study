from locust import HttpUser, task


class SimpleGetUser(HttpUser):

    @task
    def hello_world(self):
        self.client.get("/")
