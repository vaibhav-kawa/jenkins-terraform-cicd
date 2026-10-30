# Jenkins CI/CD Pipeline + Terraform

A small Flask web app that is built, tested and deployed automatically by **Jenkins**,
plus a **Terraform** setup that creates Docker containers for the same app.
Everything runs on one Ubuntu EC2 instance.

```
GitHub ──► Jenkins: Checkout → Build → Test → Docker Build → Deploy → Verify ──► app on :5000
Terraform ──► Docker network + image + 2 containers ──► app on :8081 and :8082
```

## Files

| File | What it is |
|---|---|
| `app.py` | Flask app (`/`, `/health`, `/api/add`) |
| `tests/test_app.py` | 5 unit tests |
| `Dockerfile` | Builds the app image |
| `Jenkinsfile` | The CI/CD pipeline (6 stages) |
| `terraform/` | Terraform files (provider, variables, resources, outputs) |
| `scripts/setup-ec2.sh` | Installs Jenkins, Docker, Terraform on EC2 |

## How to run

**1. EC2:** Launch an Ubuntu instance (t3.small, 20 GB). Open ports 22, 8080, 5000, 8081-8082.

**2. Setup:** On the EC2 instance:
```bash
git clone https://github.com/vaibhav-kawa/jenkins-terraform-cicd.git
cd jenkins-terraform-cicd
bash scripts/setup-ec2.sh
```
It prints the Jenkins URL and admin password.

**3. Jenkins:** Open `http://<EC2-IP>:8080` → unlock → install suggested plugins → create admin user.
Then **New Item** → `cicd-demo-pipeline` → **Pipeline** → *Pipeline script from SCM* → Git →
this repo URL → branch `*/main` → script path `Jenkinsfile` → Save.

**4. Run:** Click **Build Now**. All 6 stages turn green. Open `http://<EC2-IP>:5000`.

**5. Auto trigger:** Push a change to `app.py`. Jenkins checks GitHub every 2 minutes and builds by itself.

**6. Terraform:**
```bash
cd ~/jenkins-terraform-cicd/terraform
terraform init
terraform plan
terraform apply -auto-approve
terraform output
terraform destroy -auto-approve
```
After apply, open `http://<EC2-IP>:8081` and `:8082`.

## Common problems

| Problem | Fix |
|---|---|
| Jenkins page won't open | Check port 8080 is open in the security group |
| `permission denied ... docker.sock` | `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins` |
| Terraform `permission denied` on docker | Run `newgrp docker` |
| Port 5000 already in use | `docker rm -f cicd-demo-app` |
