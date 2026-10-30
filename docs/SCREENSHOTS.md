# Screenshot Checklist (23 screenshots)

Name each file `SS01_...png`, `SS02_...png` so they drop straight into the report.
Tip: Windows `Win + Shift + S`; make sure the browser address bar (EC2 IP + port) is visible.

## A. Setup (README Step 1–3)
| # | When | What must be visible | Report section |
|---|---|---|---|
| SS01 | EC2 → Instances, after launch | Instance **Running**, type, public IP | 3. Environment Setup |
| SS02 | EC2 → Security → Security group → Inbound rules | Ports 22, 8080, 5000, 8081-8082 | 3. Environment Setup |
| SS03 | GitHub repo home page | File list incl. `Jenkinsfile`, `terraform/` + repo URL | 4. Source Repository |
| SS04 | End of `setup-ec2.sh` in terminal | Java, Docker, Terraform, Python versions + "Jenkins status: active" | 3. Environment Setup |

## B. Jenkins configuration (Step 4) — rubric: *Jenkins Configuration*
| # | When | What must be visible | Report section |
|---|---|---|---|
| SS05 | Jenkins → Manage Jenkins → Plugins → Installed (search "pipeline") | Pipeline & Git plugins installed | 5. Jenkins Configuration |
| SS06 | Job → Configure → **Pipeline** section | "Pipeline script from SCM", Git, repo URL, `*/main`, `Jenkinsfile` | 5. Jenkins Configuration |
| SS07 | Jenkins dashboard | Job `cicd-demo-pipeline` listed | 5. Jenkins Configuration |

## C. Jenkinsfile (rubric: *Jenkinsfile / CI-CD Pipeline*)
| # | When | What must be visible | Report section |
|---|---|---|---|
| SS08 | Jenkinsfile open on GitHub (scroll so all stages show; take 2 shots if needed) | Stages Checkout, Build, Test, Docker Build, Deploy, Verify | 6. Jenkinsfile |

## D. Pipeline execution (Step 5–6) — rubric: *CI/CD Execution*
| # | When | What must be visible | Report section |
|---|---|---|---|
| SS09 | Job page after build #1 | **Stage View** — all 6 stages green | 7. Pipeline Execution |
| SS10 | Build #1 → Console Output (top) | Checkout commit line + pip install | 7. Pipeline Execution |
| SS11 | Console Output (Test part) | pytest `5 passed` | 7. Pipeline Execution |
| SS12 | Console Output (end) | Docker build, `docker ps`, `"status":"UP"`, **Finished: SUCCESS** | 7. Pipeline Execution |
| SS13 | Build #1 → **Test Result** | 5 tests, 0 failures | 7. Pipeline Execution |
| SS14 | Browser `http://<IP>:5000` | Deployed page showing Build # 1 | 8. Deployment Result |
| SS15 | Browser `/health` and `/api/add?a=10&b=5` (side by side or 2 shots) | JSON responses | 8. Deployment Result |
| SS16 | GitHub commit "version 1.1.0" **and** Jenkins build #2 page | "Started by an SCM change" | 9. Automated Trigger |
| SS17 | Browser `http://<IP>:5000` after build #2 | Version 1.1.0, Build # 2 | 9. Automated Trigger |

## E. Terraform (Step 7) — rubric: *Terraform Configuration*
| # | When | What must be visible | Report section |
|---|---|---|---|
| SS18 | Terminal: `terraform init` + `terraform validate` | "successfully initialized" + "configuration is valid" | 10. Terraform |
| SS19 | Terminal: `terraform plan` (end part) | `Plan: 4 to add, 0 to change, 0 to destroy` | 10. Terraform |
| SS20 | Terminal: `terraform apply` end + `terraform output` + `docker ps` | `Apply complete! Resources: 4 added`, URLs, containers | 10. Terraform |
| SS21 | Browser `http://<IP>:8081` (and 8082) | Environment = staging, terraform-replica-1 | 10. Terraform |
| SS22 | Terminal: `terraform plan -var="replicas=1"` | `1 to destroy` (shows reusability) | 10. Terraform |
| SS23 | Terminal: `terraform destroy` | `Destroy complete! Resources: 4 destroyed` | 10. Terraform |

Also screenshot the Terraform `.tf` files open on GitHub if your report wants code images
(otherwise paste the code as text — the template already has places for it).
