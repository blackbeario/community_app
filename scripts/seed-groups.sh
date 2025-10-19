#!/bin/bash

###############################################################################
# Seed Groups Script
#
# Seeds groups into an existing Firebase project
#
# Usage: ./seed-groups.sh <project-id> <config-file>
# Example: ./seed-groups.sh champion-hills configs/champion-hills.json
###############################################################################

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Check arguments
if [ $# -lt 2 ]; then
    print_error "Missing arguments"
    echo "Usage: ./seed-groups.sh <project-id> <config-file>"
    echo "Example: ./seed-groups.sh champion-hills configs/champion-hills.json"
    exit 1
fi

PROJECT_ID="$1"
CONFIG_FILE="$2"

# Validate inputs
if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

if ! project_exists "$PROJECT_ID"; then
    print_error "Project not found: $PROJECT_ID"
    exit 1
fi

print_step "Seeding groups for project: $PROJECT_ID"
print_info "Config file: $CONFIG_FILE"

# Set Google Application Credentials
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"

if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    print_info "Setting up application default credentials"
    gcloud auth application-default login
fi

# Run seed script
node "$SCRIPT_DIR/lib/seed-groups.js" "$PROJECT_ID" "$CONFIG_FILE"

print_success "Groups seeded successfully"
