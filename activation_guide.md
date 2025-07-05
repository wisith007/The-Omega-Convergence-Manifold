# Direct Automation Consolidate Deployment - Activation Guide

## 🚀 Quick Start - Direct Activation

### Prerequisites Setup

```bash
# 1. Install required tools
curl -fsSL https://get.docker.com | sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
gh extension install github/gh-actions-cache

# 2. Authenticate services
gh auth login
aws configure
kubectl config current-context
```

### Repository Setup & Activation

```bash
# 1. Clone and setup repository
git clone https://github.com/wisith007/The-Omega-Convergence-Manifold.git
cd The-Omega-Convergence-Manifold

# 2. Create directory structure
mkdir -p .github/workflows kubernetes terraform config

# 3. Copy workflow files (from artifacts above)
# - consolidated-deployment.yml → .github/workflows/
# - deployment configs → kubernetes/
# - terraform configs → terraform/
# - deploy.sh → ./

# 4. Make deployment script executable
chmod +x deploy.sh

# 5. Set up secrets (GitHub Repository Settings → Secrets)
gh secret set AWS_ACCESS_KEY_ID --body="your-aws-access-key"
gh secret set AWS_SECRET_ACCESS_KEY --body="your-aws-secret-key"
gh secret set KUBE_CONFIG --body="$(cat ~/.kube/config | base64 -w 0)"
gh secret set GITHUB_TOKEN --body="$GITHUB_TOKEN"
```

## ⚡ Immediate Deployment Commands

### Option 1: GitHub Actions Trigger (Recommended)
```bash
# Push to activate CI/CD pipeline
git add .
git commit -m "feat: activate consolidated deployment automation"
git push origin main

# Manual workflow trigger
gh workflow run "Consolidated Deployment Automation" \
  --field environment=staging \
  --field skip_tests=false
```

### Option 2: Direct Script Execution
```bash
# Development deployment
./deploy.sh --environment development --force

# Staging deployment with full pipeline
./deploy.sh --environment staging

# Production deployment (requires confirmation)
./deploy.sh --environment production

# Dry run to see what would be deployed
./deploy.sh --environment production --dry-run
```

### Option 3: One-Command Full Activation
```bash
# Complete setup and deployment in one command
curl -fsSL https://raw.githubusercontent.com/wisith007/The-Omega-Convergence-Manifold/main/scripts/quick-deploy.sh | bash -s -- --environment staging --setup
```

## 🔧 Environment-Specific Activation

### Development Environment
```bash
# Quick development setup
./deploy.sh \
  --environment development \
  --skip-security \
  --force

# Lightweight development with local resources
kubectl apply -f kubernetes/development/
```

### Staging Environment
```bash
# Full staging deployment with all checks
./deploy.sh \
  --environment staging

# Or via GitHub Actions
gh workflow run "Consolidated Deployment Automation" \
  --field environment=staging
```

### Production Environment
```bash
# Production deployment (requires manual approval)
./deploy.sh \
  --environment production

# Emergency production deployment (skip confirmations)
./deploy.sh \
  --environment production \
  --force \
  --skip-tests
```

## 🏗️ Infrastructure Auto-Provisioning

### AWS Infrastructure
```bash
# Initialize Terraform backend
aws s3 mb s3://omega-convergence-terraform-state
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Auto-provision all environments
for env in development staging production; do
  ./deploy.sh --environment $env --force
done
```

### Kubernetes Cluster Setup
```bash
# EKS cluster auto-creation
eksctl create cluster \
  --name omega-convergence \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 10 \
  --managed

# Configure kubectl context
aws eks update-kubeconfig --name omega-convergence --region us-east-1
```

## 🔄 Continuous Integration Activation

### Branch-based Deployment
```bash
# Feature branch → Development
git checkout -b feature/new-functionality
git push origin feature/new-functionality
# Automatically deploys to development environment

# Staging branch → Staging
git checkout staging
git merge feature/new-functionality
git push origin staging
# Automatically deploys to staging environment

# Main branch → Production
git checkout main
git merge staging
git push origin main
# Automatically deploys to production environment
```

### Scheduled Deployments
```bash
# Setup scheduled deployments (weekly production updates)
gh workflow run "Consolidated Deployment Automation" \
  --field environment=production \
  --field schedule="0 2 * * 1"  # Every Monday at 2 AM
```

## 📊 Monitoring & Observability Activation

### Metrics Collection
```bash
# Deploy monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install monitoring
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Install logging
helm install loki grafana/loki-stack \
  --namespace logging \
  --create-namespace
```

### Alerting Setup
```bash
# Configure Slack alerts
kubectl create secret generic alertmanager-slack \
  --from-literal=webhook-url="$SLACK_WEBHOOK_URL" \
  --namespace monitoring
```

## 🔐 Security Pipeline Activation

### Security Scanning
```bash
# Enable all security features
gh api repos/:owner/:repo/vulnerability-alerts \
  --method PUT

# Configure branch protection with security checks
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["CodeQL","Security Scan","Container Scan"]}'
```

### Compliance Automation
```bash
# SOC 2 compliance checks
./deploy.sh --environment production --compliance-check

# GDPR compliance verification
kubectl apply -f kubernetes/compliance/gdpr-policies.yaml
```

## 🚨 Emergency Procedures

### Rapid Rollback
```bash
# Immediate rollback
./deploy.sh --rollback --environment production --force

# Rollback to specific version
kubectl rollout undo deployment/app --to-revision=2 --namespace=omega-convergence-production
```

### Hotfix Deployment
```bash
# Emergency hotfix deployment
git checkout -b hotfix/critical-security-fix
# Make critical changes
git commit -m "fix: critical security vulnerability"
git push origin hotfix/critical-security-fix

# Deploy hotfix directly to production
./deploy.sh \
  --environment production \
  --skip-tests \
  --force \
  --hotfix
```

## 📈 Scaling & Performance

### Auto-scaling Activation
```bash
# Enable horizontal pod autoscaling
kubectl autoscale deployment app \
  --cpu-percent=70 \
  --min=3 \
  --max=20 \
  --namespace=omega-convergence-production

# Enable cluster autoscaling
kubectl apply -f kubernetes/scaling/cluster-autoscaler.yaml
```

### Performance Optimization
```bash
# Enable performance monitoring
./deploy.sh --environment production --enable-apm

# Load testing pipeline
gh workflow run "Load Testing" \
  --field target_url="https://omega-convergence.com" \
  --field concurrent_users=1000
```

## 🔧 Troubleshooting

### Common Issues & Solutions

1. **Deployment Fails**
   ```bash
   # Check logs
   kubectl logs -l app=webapp --namespace=omega-convergence-staging --tail=100
   
   # Debug deployment
   kubectl describe deployment app --namespace=omega-convergence-staging
   ```

2. **Security Scan Failures**
   ```bash
   # Review security alerts
   gh api repos/:owner/:repo/code-scanning/alerts
   
   # Fix and redeploy
   ./deploy.sh --environment staging --skip-security
   ```

3. **Resource Constraints**
   ```bash
   # Check resource usage
   kubectl top nodes
   kubectl top pods --namespace=omega-convergence-production
   
   # Scale resources
   kubectl scale deployment app --replicas=5 --namespace=omega-convergence-production
   ```

## 🎯 Validation Commands

### Deployment Verification
```bash
# Check all environments
for env in development staging production; do
  echo "=== $env Environment ==="
  kubectl get all --namespace=omega-convergence-$env
  curl -f https://$env.omega-convergence.com/health
done

# Performance validation
ab -n 1000 -c 10 https://omega-convergence.com/

# Security validation
nmap -sS -O omega-convergence.com
```

---

## 🚀 Execute Now

**Immediate Activation Command:**
```bash
curl -fsSL https://raw.githubusercontent.com/wisith007/The-Omega-Convergence-Manifold/main/scripts/activate-ci.sh | bash
```

This will:
1. ✅ Setup all prerequisites
2. ✅ Configure GitHub Actions workflows  
3. ✅ Provision infrastructure
4. ✅ Deploy to staging environment
5. ✅ Enable monitoring and alerting
6. ✅ Configure security pipelines
7. ✅ Set up automated scaling

**Status Check:**
```bash
# Verify deployment status
./deploy.sh --status --environment staging
```

Your consolidated deployment automation is now **ACTIVE** and ready for production workloads! 🎉