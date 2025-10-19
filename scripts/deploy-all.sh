#!/bin/bash

###############################################################################
# Deploy All Script
#
# Deploys code to all registered community projects
#
# Usage: ./deploy-all.sh [--functions-only|--rules-only]
###############################################################################

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Parse options
DEPLOY_TARGET="firestore:rules,functions"

while [[ $# -gt 0 ]]; do
    case $1 in
        --functions-only)
            DEPLOY_TARGET="functions"
            shift
            ;;
        --rules-only)
            DEPLOY_TARGET="firestore:rules"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Usage: ./deploy-all.sh [--functions-only|--rules-only]"
            exit 1
            ;;
    esac
done

print_step "Deploying to all communities"
print_info "Target: $DEPLOY_TARGET"

# Get all projects
PROJECTS=$(get_all_projects)

if [ -z "$PROJECTS" ]; then
    print_warning "No projects found in registry"
    print_info "Registry: scripts/configs/projects.json"
    exit 0
fi

# Count projects
PROJECT_COUNT=$(echo "$PROJECTS" | wc -l | tr -d ' ')
print_info "Found $PROJECT_COUNT project(s)"

# Confirm deployment
echo ""
print_warning "This will deploy $DEPLOY_TARGET to $PROJECT_COUNT project(s)"
if ! confirm "Continue?"; then
    print_info "Aborted"
    exit 0
fi

# Deploy to each project
cd "$SCRIPT_DIR/.."  # Go to project root

SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_PROJECTS=()

echo ""
echo "Starting deployment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for project in $PROJECTS; do
    echo ""
    print_step "Deploying to: $project"

    if firebase use "$project" 2>/dev/null; then
        if firebase deploy --only "$DEPLOY_TARGET" --project "$project"; then
            print_success "Deployed to $project"
            ((SUCCESS_COUNT++))
        else
            print_error "Failed to deploy to $project"
            FAILED_PROJECTS+=("$project")
            ((FAIL_COUNT++))
        fi
    else
        print_error "Could not switch to project: $project"
        FAILED_PROJECTS+=("$project")
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_step "Deployment Summary"
echo ""
print_success "Successful: $SUCCESS_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
    print_error "Failed: $FAIL_COUNT"
    echo ""
    print_info "Failed projects:"
    for project in "${FAILED_PROJECTS[@]}"; do
        echo "  - $project"
    done
    exit 1
else
    print_success "All deployments completed successfully!"
fi
