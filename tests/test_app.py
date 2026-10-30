"""Unit tests executed by the Jenkins 'Test' stage."""
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

import pytest  # noqa: E402
from app import app, add  # noqa: E402


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def test_add_function():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_home_page(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert b"CI/CD Demo" in resp.data


def test_health_endpoint(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "UP"


def test_api_add(client):
    resp = client.get("/api/add?a=10&b=5")
    assert resp.status_code == 200
    assert resp.get_json()["result"] == 15


def test_api_add_invalid_input(client):
    resp = client.get("/api/add?a=x&b=5")
    assert resp.status_code == 400
