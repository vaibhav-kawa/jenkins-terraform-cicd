# Recorded Demo Script (~7 minutes)

Record with OBS / Zoom / Google Meet / Loom (screen + voice). Before recording:
EC2 running, Jenkins logged in, Terraform resources **destroyed** (so you can create them live),
tabs ready: GitHub repo, Jenkins job, `http://<IP>:5000`, EC2 terminal.

---

### 1. Intro (30 s)
"In this demo I show a CI/CD workflow for a Flask web application using Jenkins, and
Infrastructure as Code using Terraform. Everything runs on an Ubuntu EC2 instance.
The source code is on GitHub."

### 2. Repository walkthrough (1 min) — GitHub tab
- `app.py`: "a small Flask app with a home page, a /health endpoint and an /api/add endpoint."
- `tests/test_app.py`: "five pytest unit tests."
- `Dockerfile`: "packages the app into a container image using gunicorn."
- `Jenkinsfile` and `terraform/` folder: "the two main deliverables."

### 3. Jenkins configuration (1 min) — Jenkins tab
- Open job → Configure → Pipeline section.
- "This is a Pipeline job using *Pipeline script from SCM*. Jenkins pulls the Jenkinsfile
  from my GitHub repository on the main branch, so the pipeline itself is version-controlled —
  this is called *Pipeline as Code*."

### 4. Explain the Jenkinsfile (1.5 min) — GitHub tab
- `agent any` — run on any available executor.
- `triggers { pollSCM('H/2 * * * *') }` — "Jenkins checks GitHub every 2 minutes and builds automatically on a new commit. That is continuous integration."
- `environment` — shared variables; image is tagged with the Jenkins **BUILD_NUMBER** so every build is traceable.
- Stages: **Checkout** (get code) → **Build** (virtual env + dependencies + compile check) →
  **Test** (pytest, results published with JUnit) → **Docker Build** (image) →
  **Deploy** (replace old container with the new one on port 5000) → **Verify** (smoke test calling /health).
- `post` — on success archive test reports, always clean dangling images.

### 5. Live automated run (1.5 min)
- On GitHub edit `app.py`: `APP_VERSION = "1.2.0"` → commit message "demo: bump version".
- Switch to Jenkins: "I did not press Build — the commit triggers a new build automatically." (wait ≤2 min)
- Show Stage View turning green, open Console Output → point at `5 passed`, `docker run`, `"status":"UP"`, `Finished: SUCCESS`.
- Show **Test Result** page.
- Refresh `http://<IP>:5000` — "the new version and new build number are live."

### 6. Terraform (1.5 min) — terminal
```bash
cd ~/jenkins-terraform-cicd/terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
terraform output
docker ps
```
Say while it runs:
- "providers.tf declares the Docker provider; variables.tf holds inputs like environment,
  replicas and port, with validation; main.tf creates a network, builds the image and creates
  containers using `count`; outputs.tf prints the URLs."
- "`init` downloads the provider, `plan` shows what will change — 4 resources — and `apply`
  makes it real. Terraform records everything in the state file."
- Open `:8081` / `:8082` → "two replicas in the staging environment."
- `terraform plan -var="replicas=1"` → "Changing only a variable changes the infrastructure — the configuration is reusable for dev, staging or prod."
- `terraform destroy -auto-approve` → "and everything is removed cleanly."

### 7. Conclusion (20 s)
"So, a code commit automatically goes through build, test, containerization and deployment
in Jenkins, and Terraform provisions the infrastructure declaratively and repeatably. Thank you."

---

## Likely viva questions (short answers)

| Question | Answer |
|---|---|
| What is CI/CD? | CI = automatically build & test every code change; CD = automatically deliver/deploy the tested build. |
| Declarative vs Scripted pipeline? | Declarative uses the structured `pipeline { stages {} }` syntax (easier, validated); Scripted is plain Groovy (more flexible). We used Declarative. |
| What is a Jenkinsfile? | The pipeline definition stored in the repo — Pipeline as Code, versioned with the app. |
| What is an agent? | The machine/executor where the pipeline runs; `agent any` = any available one. |
| pollSCM vs webhook? | Polling: Jenkins checks the repo on a schedule. Webhook: GitHub pushes an event to Jenkins instantly. Polling needs no public webhook setup. |
| What does `post` do? | Actions after the pipeline/stage: `always`, `success`, `failure`. |
| Why tag images with BUILD_NUMBER? | Traceability and easy rollback to any previous build. |
| What is Infrastructure as Code? | Defining infrastructure in code files so it is versioned, repeatable and reviewable instead of manual clicks. |
| What is a Terraform provider? | A plugin that lets Terraform talk to a platform's API (here Docker; could be AWS, Azure…). |
| What is the state file? | `terraform.tfstate` — Terraform's record of real resources, used to compute the next plan. |
| init / plan / apply / destroy? | Download providers / preview changes / make changes / remove everything. |
| Terraform is declarative — meaning? | You describe the desired end state; Terraform works out the steps. |
| How is your config reusable? | Variables + tfvars + `count`; change values for another environment without editing main.tf. |
| Terraform vs Ansible? | Terraform provisions infrastructure (IaC, stateful); Ansible mainly configures software on existing servers. |
| Why Docker provider and not AWS? | Same IaC concepts with no cloud credentials or cost; switching to AWS only changes the provider and resource types. |
