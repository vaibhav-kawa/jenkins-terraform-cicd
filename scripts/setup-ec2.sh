#!/usr/bin/env bash
# =====================================================================
#  One-shot setup for an Ubuntu 22.04 / 24.04 EC2 instance.
#  Installs: Java 21, Jenkins (LTS), Docker, Terraform, Python venv, git
#  Usage:   bash scripts/setup-ec2.sh
# =====================================================================
set -e

echo "===== 1/7 Updating packages ====="
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl wget gnupg unzip git \
     python3 python3-venv python3-pip fontconfig openjdk-21-jre

echo "===== 2/7 Adding 2 GB swap (helps on small instances) ====="
if ! sudo swapon --show | grep -q /swapfile; then
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

echo "===== 3/7 Installing Docker ====="
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo systemctl enable --now docker

echo "===== 4/7 Installing Jenkins (LTS) ====="
sudo mkdir -p /etc/apt/keyrings
# Jenkins rotates its signing key; try the current key, fall back to the older one
sudo wget -q -O /etc/apt/keyrings/jenkins-keyring.asc \
     https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  || sudo wget -q -O /etc/apt/keyrings/jenkins-keyring.asc \
     https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl enable --now jenkins

echo "===== 5/7 Installing Terraform ====="
if ! command -v terraform >/dev/null; then
  wget -qO- https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo $VERSION_CODENAME) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y terraform
fi

echo "===== 6/7 Giving Jenkins and ubuntu access to Docker ====="
sudo usermod -aG docker jenkins
sudo usermod -aG docker "$USER"
sudo systemctl restart jenkins

echo "===== 7/7 Versions ====="
java -version 2>&1 | head -1
docker --version
terraform version | head -1
python3 --version
echo
echo "Jenkins status: $(systemctl is-active jenkins)"
PUBLIC_IP=$(curl -s --max-time 3 https://checkip.amazonaws.com || echo "<EC2-PUBLIC-IP>")
echo "Open Jenkins at:  http://${PUBLIC_IP}:8080"
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo
echo ">>> Now run:  newgrp docker   (so your shell can use docker without sudo)"
