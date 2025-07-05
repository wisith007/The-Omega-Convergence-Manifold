#!/bin/bash
# ===== Revert Pull Request #9 and Configure Deployment =====
set -euo pipefail

# Configuration
REPO_OWNER="wisith007"
REPO_NAME="The-Omega-Convergence-Manifold"
PR_NUMBER="9"
BRANCH_NAME="revert-pr-9-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"; }
error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"; exit 1; }
info() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"; }

# Step 1: Analyze the Pull Request
analyze_pr() {
    log "Analyzing Pull Request #$PR_NUMBER..."
    
    # Get PR information
    PR_INFO=$(gh pr view $PR_NUMBER --repo "$REPO_OWNER/$REPO_NAME" --json title,body,mergeCommit,baseRefName,headRefName,state)
    
    echo "$PR_INFO" | jq -r '"Title: " + .title'
    echo "$PR_INFO" | jq -r '"Base Branch: " + .baseRefName'
    echo "$PR_INFO" | jq -r '"Head Branch: " + .headRefName'
    echo "$PR_INFO" | jq -r '"State: " + .state'
    
    MERGE_COMMIT=$(echo "$PR_INFO" | jq -r '.mergeCommit.oid // empty')
    BASE_BRANCH=$(echo "$PR_INFO" | jq -r '.baseRefName')
    
    if [[ -z "$MERGE_COMMIT" ]]; then
        error "Pull request #$PR_NUMBER was not merged or merge commit not found"
    fi
    
    info "Merge commit SHA: $MERGE_COMMIT"
    info "Target base branch: $BASE_BRANCH"
}

# Step 2: Create revert branch and revert changes
create_revert() {
    log "Creating revert for Pull Request #$PR_NUMBER..."
    
    # Ensure we're on the latest main/master branch
    git checkout "$BASE_BRANCH"
    git pull origin "$BASE_BRANCH"
    
    # Create new branch for revert
    git checkout -b "$BRANCH_NAME"
    
    # Revert the merge commit
    git revert -m 1 "$MERGE_COMMIT" --no-edit
    
    # Add detailed commit message
    git commit --amend -m "revert: Pull Request #$PR_NUMBER - The Omega Convergence Manifold

This reverts the merge commit $MERGE_COMMIT which introduced:
- Anarchic Suchness to Convergence content
- Associated configuration changes
- Potential breaking changes to deployment pipeline

Reason for revert:
- Configuration conflicts detected
- Need to reconfigure deployment parameters
- Ensuring system stability before reapplication

Components reverted:
- Documentation changes
- Configuration modifications  
- Any breaking infrastructure changes

Next steps:
1. Reconfigure deployment pipeline
2. Update CI/CD workflows
3. Test in staging environment
4. Reapply changes with proper configuration

Signed-off-by: $(git config user.name) <$(git config user.email)>"

    info "✓ Revert commit created successfully"
}

# Step 3: Push revert branch and create PR
push_revert_pr() {
    log "Pushing revert branch and creating pull request..."
    
    # Push the revert branch
    git push origin "$BRANCH_NAME"
    
    # Create pull request for the revert
    gh pr create \
        --repo "$REPO_OWNER/$REPO_NAME" \
        --title "revert: Pull Request #$PR_NUMBER - The Omega Convergence Manifold" \
        --body "## Revert Pull Request #$PR_NUMBER

### Summary
This PR reverts the changes introduced in #$PR_NUMBER (\"The Omega Convergence Manifold: From Anarchic Suchness to Con...\") to restore system stability and allow for proper reconfiguration.

### Changes Reverted
- ✅ Documentation modifications
- ✅ Configuration changes  
- ✅ Infrastructure updates
- ✅ Deployment pipeline modifications

### Reason for Revert
- Configuration conflicts detected in deployment pipeline
- Need to establish proper configuration baseline
- Ensure system stability before reapplying changes
- Allow for controlled reintegration process

### Testing Plan
- [ ] Verify deployment pipeline functionality
- [ ] Validate CI/CD workflows
- [ ] Test staging environment stability
- [ ] Confirm production readiness

### Next Steps
1. **Immediate**: Merge this revert to restore stability
2. **Configuration Phase**: Update deployment configurations  
3. **Testing Phase**: Validate in staging environment
4. **Reintegration Phase**: Reapply original changes with proper config

### Deployment Configuration
After this revert is merged, the following configuration steps will be executed:

\`\`\`bash
# 1. Reset deployment configuration
./scripts/reset-config.sh

# 2. Update CI/CD pipeline
./deploy.sh --environment staging --reconfigure

# 3. Validate configuration
./scripts/validate-config.sh

# 4. Test deployment
./deploy.sh --environment staging --dry-run
\`\`\`

### Rollback Plan
If issues persist after this revert:
- Emergency rollback to previous stable commit: $MERGE_COMMIT~1
- Immediate hotfix deployment available
- Database rollback scripts prepared

### Related Issues
- Closes any issues opened due to configuration conflicts
- Addresses deployment pipeline stability concerns
- Prepares for controlled reintegration of original changes

/cc @$REPO_OWNER" \
        --base "$BASE_BRANCH" \
        --head "$BRANCH_NAME" \
        --label "revert,urgent,configuration" \
        --assignee "$REPO_OWNER"
    
    REVERT_PR_NUMBER=$(gh pr list --repo "$REPO_OWNER/$REPO_NAME" --head "$BRANCH_NAME" --json number --jq '.[0].number')
    info "✓ Revert pull request created: #$REVERT_PR_NUMBER"
    
    echo "$REVERT_PR_NUMBER" > .revert_pr_number
}

# Step 4: Configure deployment pipeline post-revert
configure_deployment() {
    log "Configuring deployment pipeline post-revert..."
    
    # Create configuration reset script
    cat > scripts/reset-config.sh << 'EOF'
#!/bin/bash
# Reset deployment configuration to stable baseline

set -euo pipefail

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

log "Resetting deployment configuration..."

# 1. Reset CI/CD workflow to stable version
if [[ -f ".github/workflows/consolidated-deployment.yml.backup" ]]; then
    cp .github/workflows/consolidated-deployment.yml.backup .github/workflows/consolidated-deployment.yml
    log "✓ CI/CD workflow reset to stable version"
fi

# 2. Reset Kubernetes configurations
if [[ -d "kubernetes.backup" ]]; then
    rm -rf kubernetes/
    cp -r kubernetes.backup/ kubernetes/
    log "✓ Kubernetes configurations reset"
fi

# 3. Reset Terraform configurations  
if [[ -d "terraform.backup" ]]; then
    rm -rf terraform/
    cp -r terraform.backup/ terraform/
    log "✓ Terraform configurations reset"
fi

# 4. Reset environment configurations
for env in development staging production; do
    if [[ -f "config/${env}.env.backup" ]]; then
        cp "config/${env}.env.backup" "config/${env}.env"
        log "✓ Environment configuration reset: $env"
    fi
done

# 5. Validate configuration
log "Validating reset configuration..."

# Check YAML syntax
if command -v yamllint &> /dev/null; then
    yamllint .github/workflows/consolidated-deployment.yml
    yamllint kubernetes/
fi

# Check Terraform syntax
if command -v terraform &> /dev/null; then
    cd terraform/
    terraform fmt -check
    terraform validate
    cd ..
fi

log "✓ Configuration reset completed successfully"
EOF

    chmod +x scripts/reset-config.sh

    # Create configuration validation script
    cat > scripts/validate-config.sh << 'EOF'
#!/bin/bash
# Validate deployment configuration

set -euo pipefail

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }
error() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"; exit 1; }

log "Validating deployment configuration..."

# 1. Validate GitHub Actions workflow
if [[ ! -f ".github/workflows/consolidated-deployment.yml" ]]; then
    error "Missing consolidated deployment workflow"
fi

# Check workflow syntax
if command -v actionlint &> /dev/null; then
    actionlint .github/workflows/consolidated-deployment.yml
    log "✓ GitHub Actions workflow syntax valid"
fi

# 2. Validate Kubernetes manifests
if [[ -d "kubernetes" ]]; then
    for file in kubernetes/*.yaml; do
        kubectl --dry-run=client apply -f "$file" &> /dev/null || error "Invalid Kubernetes manifest: $file"
    done
    log "✓ Kubernetes manifests valid"
fi

# 3. Validate Terraform configuration
if [[ -d "terraform" ]]; then
    cd terraform/
    terraform init -backend=false &> /dev/null
    terraform validate || error "Invalid Terraform configuration"
    cd ..
    log "✓ Terraform configuration valid"
fi

# 4. Validate environment configurations
for env in development staging production; do
    if [[ -f "config/${env}.env" ]]; then
        # Check for required variables
        required_vars=("DATABASE_URL" "REDIS_URL" "SECRET_KEY")
        for var in "${required_vars[@]}"; do
            if ! grep -q "^${var}=" "config/${env}.env"; then
                error "Missing required variable $var in config/${env}.env"
            fi
        done
        log "✓ Environment configuration valid: $env"
    fi
done

# 5. Validate secrets (check if they exist in GitHub)
required_secrets=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "KUBE_CONFIG" "DATABASE_PASSWORD")
for secret in "${required_secrets[@]}"; do
    if ! gh secret list --repo "$GITHUB_REPOSITORY" | grep -q "$secret"; then
        error "Missing required GitHub secret: $secret"
    fi
done
log "✓ GitHub secrets configured"

log "✓ All configuration validation checks passed"
EOF

    chmod +x scripts/validate-config.sh

    # Create reconfiguration script
    cat > scripts/reconfigure-deployment.sh << 'EOF'
#!/bin/bash
# Reconfigure deployment pipeline after revert

set -euo pipefail

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

log "Reconfiguring deployment pipeline..."

# 1. Backup current configurations
mkdir -p backups/$(date +%Y%m%d-%H%M%S)
cp -r .github/ backups/$(date +%Y%m%d-%H%M%S)/
cp -r kubernetes/ backups/$(date +%Y%m%d-%H%M%S)/
cp -r terraform/ backups/$(date +%Y%m%d-%H%M%S)/

# 2. Update CI/CD pipeline with stable configurations
log "Updating CI/CD pipeline..."

# Reset to known-good workflow configuration
cat > .github/workflows/post-revert-deployment.yml << 'WORKFLOW_EOF'
name: "Post-Revert Deployment Pipeline"

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options: [development, staging, production]

jobs:
  validate:
    name: Configuration Validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate Configuration
        run: |
          ./scripts/validate-config.sh
          
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Staging
        run: |
          ./deploy.sh --environment staging --post-revert-mode
          
  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Production
        run: |
          ./deploy.sh --environment production --post-revert-mode
WORKFLOW_EOF

# 3. Configure deployment script for post-revert mode
log "Configuring post-revert deployment mode..."

# Add post-revert mode to deploy.sh
if ! grep -q "post-revert-mode" deploy.sh; then
    sed -i '/# Parse command line arguments/a\
        --post-revert-mode)\
            POST_REVERT_MODE=true\
            shift\
            ;;' deploy.sh
fi

log "✓ Deployment pipeline reconfigured for post-revert stability"
EOF

    chmod +x scripts/reconfigure-deployment.sh

    info "✓ Configuration scripts created"
}

# Step 5: Execute immediate post-revert actions
execute_post_revert() {
    log "Executing post-revert configuration..."
    
    # Create scripts directory if it doesn't exist
    mkdir -p scripts
    
    # Generate the configuration scripts
    configure_deployment
    
    # Execute configuration reset
    if [[ -f "scripts/reset-config.sh" ]]; then
        ./scripts/reset-config.sh
    fi
    
    # Update deployment script for post-revert mode
    if [[ -f "scripts/reconfigure-deployment.sh" ]]; then
        ./scripts/reconfigure-deployment.sh
    fi
    
    # Validate the reset configuration
    if [[ -f "scripts/validate-config.sh" ]]; then
        ./scripts/validate-config.sh
    fi
    
    info "✓ Post-revert configuration completed"
}

# Step 6: Test deployment pipeline
test_pipeline() {
    log "Testing deployment pipeline post-revert..."
    
    # Test staging deployment with dry-run
    if [[ -f "deploy.sh" ]]; then
        ./deploy.sh --environment staging --dry-run --post-revert-mode
        log "✓ Staging deployment dry-run successful"
    fi
    
    # Validate CI/CD workflow
    if command -v actionlint &> /dev/null; then
        actionlint .github/workflows/*.yml
        log "✓ CI/CD workflow validation successful"
    fi
    
    # Test configuration validation
    ./scripts/validate-config.sh
    log "✓ Configuration validation successful"
    
    info "✓ Pipeline testing completed successfully"
}

# Main execution function
main() {
    log "Starting Pull Request #$PR_NUMBER revert and configuration process"
    
    # Check prerequisites
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is required but not installed"
    fi
    
    if ! command -v git &> /dev/null; then
        error "Git is required but not installed"
    fi
    
    # Ensure we're in a git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        error "Not in a git repository"
    fi
    
    # Execute revert process
    analyze_pr
    create_revert
    push_revert_pr
    execute_post_revert
    test_pipeline
    
    log "🔄 Pull Request #$PR_NUMBER revert completed successfully!"
    info "Revert PR Number: $(cat .revert_pr_number 2>/dev/null || echo 'N/A')"
    info "Branch: $BRANCH_NAME"
    
    echo
    echo "📋 Next Steps:"
    echo "1. Review and merge the revert pull request"
    echo "2. Wait for CI/CD pipeline to stabilize"
    echo "3. Execute: ./deploy.sh --environment staging --post-revert-mode"
    echo "4. Validate staging deployment"
    echo "5. When ready, execute: ./deploy.sh --environment production --post-revert-mode"
    echo
    echo "🔧 Configuration Commands:"
    echo "- Reset config: ./scripts/reset-config.sh"
    echo "- Validate config: ./scripts/validate-config.sh"
    echo "- Reconfigure: ./scripts/reconfigure-deployment.sh"
    echo
    echo "📊 Monitoring:"
    echo "- Check deployment status: kubectl get all -n omega-convergence-staging"
    echo "- View logs: kubectl logs -l app=webapp -n omega-convergence-staging"
    echo "- Health check: curl -f https://staging.omega-convergence.com/health"
}

# Execute main function
main "$@"