#!/bin/bash

###############################################################################
# Create Admin Script
#
# Grants admin privileges to a user via Cloud Function
#
# Usage: ./create-admin.sh <project-id> <email>
# Example: ./create-admin.sh champion-hills admin@example.com
###############################################################################

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Check arguments
if [ $# -lt 2 ]; then
    print_error "Missing arguments"
    echo "Usage: ./create-admin.sh <project-id> <email>"
    echo "Example: ./create-admin.sh champion-hills admin@example.com"
    exit 1
fi

PROJECT_ID="$1"
EMAIL="$2"

# Validate inputs
if ! project_exists "$PROJECT_ID"; then
    print_error "Project not found: $PROJECT_ID"
    exit 1
fi

if ! is_valid_email "$EMAIL"; then
    print_error "Invalid email format: $EMAIL"
    exit 1
fi

print_step "Granting admin privileges"
print_info "Project: $PROJECT_ID"
print_info "Email: $EMAIL"

# Switch to project
firebase use "$PROJECT_ID"

# Get user UID from email
print_info "Looking up user..."

# Use Firebase Auth to get UID
USER_UID=$(firebase auth:export --format=json /dev/stdout 2>/dev/null | \
    jq -r ".users[] | select(.email==\"$EMAIL\") | .localId" || echo "")

if [ -z "$USER_UID" ]; then
    print_error "User not found with email: $EMAIL"
    print_info "The user must sign up in the app first before being granted admin privileges"
    exit 1
fi

print_success "Found user: $USER_UID"

# Call Cloud Function to set admin claim
print_info "Calling setAdminClaim function..."

# Note: This requires you to be authenticated and the function to be deployed
# The function needs to be called by an existing admin or through Firebase Console

print_warning "Admin claim must be set manually via one of these methods:"
echo ""
echo "  Method 1: Call Cloud Function (requires existing admin)"
echo "    firebase functions:shell"
echo "    > setAdminClaim({data: {userId: '$USER_UID', isAdmin: true}})"
echo ""
echo "  Method 2: Use Firebase Console"
echo "    https://console.firebase.google.com/project/$PROJECT_ID/authentication/users"
echo "    1. Find user: $EMAIL"
echo "    2. Click user -> Edit user"
echo "    3. Add custom claims: {\"admin\": true}"
echo ""
echo "  Method 3: Use gcloud CLI (fastest)"
echo "    gcloud alpha firestore documents update users/$USER_UID \\"
echo "      --database='(default)' \\"
echo "      --project=$PROJECT_ID \\"
echo "      --set-field-value isAdmin:boolean:true"
echo ""

# For the first admin, we can use gcloud
if confirm "Set admin claim using gcloud CLI? (Recommended for first admin)"; then
    print_info "Setting admin claim..."

    # Update Firestore document
    gcloud firestore documents patch "users/$USER_UID" \
        --database='(default)' \
        --project="$PROJECT_ID" \
        --update-mask="isAdmin" \
        --format=json <<EOF
{
  "fields": {
    "isAdmin": {
      "booleanValue": true
    }
  }
}
EOF

    print_success "Admin privileges granted to $EMAIL"
    print_info "User will need to log out and log back in for changes to take effect"
else
    print_info "Skipped. Set admin claim manually using one of the methods above."
fi
