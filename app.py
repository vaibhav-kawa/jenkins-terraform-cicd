"""
CI/CD Demo App - a tiny Flask web application used to demonstrate
a Jenkins CI/CD pipeline and Terraform-based provisioning.

Endpoints
  /            -> HTML page showing build number + environment
  /health      -> JSON health check (used by the Jenkins smoke test)
  /api/add     -> simple calculator API, e.g. /api/add?a=2&b=3
"""
import os
from datetime import datetime, timezone

from flask import Flask, jsonify, request

app = Flask(__name__)

APP_VERSION = "1.2.0"


def add(a, b):
    """Business logic that is covered by unit tests."""
    return a + b


def build_info():
    return {
        "version": APP_VERSION,
        "build": os.getenv("BUILD_NUMBER", "local"),
        "environment": os.getenv("APP_ENV", "development"),
    }


@app.route("/")
def home():
    info = build_info()
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    return f"""<!doctype html>
<html><head><meta charset="utf-8"><title>CI/CD Demo App</title>
<style>
 body{{font-family:Arial,sans-serif;background:#0f172a;color:#e2e8f0;
      display:flex;justify-content:center;align-items:center;height:100vh;margin:0}}
 .card{{background:#1e293b;padding:40px 50px;border-radius:14px;
       box-shadow:0 10px 30px rgba(0,0,0,.4);text-align:center}}
 h1{{color:#38bdf8;margin-top:0}}
 td{{padding:6px 14px;text-align:left}}
 .ok{{color:#4ade80;font-weight:bold}}
</style></head>
<body><div class="card">
 <h1>Jenkins + Terraform CI/CD Demo</h1>
 <p class="ok">&#10004; Application deployed successfully</p>
 <table>
  <tr><td>Version</td><td>{info['version']}</td></tr>
  <tr><td>Jenkins Build #</td><td>{info['build']}</td></tr>
  <tr><td>Environment</td><td>{info['environment']}</td></tr>
  <tr><td>Server time</td><td>{now}</td></tr>
 </table>
</div></body></html>"""


@app.route("/health")
def health():
    return jsonify(status="UP", **build_info())


@app.route("/api/add")
def api_add():
    try:
        a = float(request.args.get("a", ""))
        b = float(request.args.get("b", ""))
    except ValueError:
        return jsonify(error="Query params 'a' and 'b' must be numbers"), 400
    return jsonify(a=a, b=b, result=add(a, b))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
