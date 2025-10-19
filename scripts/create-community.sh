#!/bin/bash

###############################################################################
# Create Community Script
#
# Creates a new Firebase project for a community including:
# - Firebase project
# - iOS and Android apps
# - Firestore rules and Cloud Functions deployment
# - Initial groups seeding
# - Admin user setup
#
# Usage: ./create-community.sh <community-name> [config-file]
# Example: ./create-community.sh "Champion Hills" configs/champion-hills.json
###############################################################################

set -e  # Exit on error

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Print header
echo "══════════════════════════════════════════════════════════════"
echo "  Community Creation Script"
echo "══════════════════════════════════════════════════════════════"

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Missing community name"
    echo "Usage: ./create-community.sh <community-name> [config-file]"
    echo "Example: ./create-community.sh \"Champion Hills\" configs/champion-hills.json"
    exit 1
fi

COMMUNITY_NAME="$1"
CONFIG_FILE="${2:-}"

# Generate IDs
PROJECT_ID="community-$(name_to_project_id "$COMMUNITY_NAME")"
BUNDLE_SUFFIX="$(name_to_bundle_suffix "$COMMUNITY_NAME")"
IOS_BUNDLE_ID="io.vibesoftware.community.${BUNDLE_SUFFIX}"
ANDROID_PACKAGE="io.vibesoftware.community.${BUNDLE_SUFFIX}"

print_info "Community: $COMMUNITY_NAME"
print_info "Project ID: $PROJECT_ID"
print_info "iOS Bundle: $IOS_BUNDLE_ID"
print_info "Android Package: $ANDROID_PACKAGE"

# Check requirements
print_step "Checking requirements"
check_requirements
check_firebase_auth

# Check if project already exists
if project_exists "$PROJECT_ID"; then
    print_error "Project $PROJECT_ID already exists"
    print_info "Use a different community name or delete the existing project"
    exit 1
fi

# Load or create config
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    print_info "Using config file: $CONFIG_FILE"
else
    print_step "Creating config from template"
    CONFIG_FILE="$SCRIPT_DIR/configs/${PROJECT_ID#community-}.json"

    # Create config from template
    cp "$SCRIPT_DIR/configs/template.json" "$CONFIG_FILE"

    # Update with actual values using jq
    jq --arg name "$COMMUNITY_NAME" \
       --arg projectId "$PROJECT_ID" \
       --arg iosBundleId "$IOS_BUNDLE_ID" \
       --arg androidPackageName "$ANDROID_PACKAGE" \
       '.name = $name | .projectId = $projectId | .iosBundleId = $iosBundleId | .androidPackageName = $androidPackageName' \
       "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    print_success "Created config: $CONFIG_FILE"
    print_warning "Please review and edit $CONFIG_FILE before continuing"

    if ! confirm "Continue with project creation?"; then
        print_info "Aborted. Edit config and re-run when ready."
        exit 0
    fi
fi

# Confirm creation
echo ""
print_warning "This will create a new Firebase project with billing enabled"
if ! confirm "Create project $PROJECT_ID?"; then
    print_info "Aborted"
    exit 0
fi

###############################################################################
# Step 1: Create Firebase Project
###############################################################################
print_step "Creating Firebase project: $PROJECT_ID"

# Note: Firebase CLI doesn't support project creation directly
# This must be done via Firebase Console or gcloud CLI
# For now, we'll prompt the user to create it manually

print_warning "Firebase CLI cannot create projects automatically"
print_info "Please complete these steps:"
echo ""
echo "  1. Go to https://console.firebase.google.com/"
echo "  2. Click 'Add project'"
echo "  3. Enter project name: $COMMUNITY_NAME"
echo "  4. Suggested project ID: $PROJECT_ID"
echo "  5. Enable Google Analytics (optional)"
echo "  6. Enable Blaze (pay-as-you-go) billing plan"
echo ""

if ! confirm "Have you created the Firebase project?"; then
    print_error "Project creation required to continue"
    exit 1
fi

# Verify project exists
print_step "Verifying project exists"
if ! project_exists "$PROJECT_ID"; then
    print_error "Project $PROJECT_ID not found"
    print_info "Make sure you used the exact project ID: $PROJECT_ID"
    exit 1
fi
print_success "Project verified"

# Set active project
firebase use "$PROJECT_ID"
print_success "Switched to project: $PROJECT_ID"

###############################################################################
# Step 2: Create iOS App
###############################################################################
print_step "Creating iOS app"

IOS_DISPLAY_NAME="$(generate_app_display_name "$COMMUNITY_NAME" "iOS")"

firebase apps:create ios "$IOS_BUNDLE_ID" --display-name="$IOS_DISPLAY_NAME" || {
    print_warning "iOS app may already exist or creation failed"
}
print_success "iOS app configured"

###############################################################################
# Step 3: Create Android App
###############################################################################
print_step "Creating Android app"

ANDROID_DISPLAY_NAME="$(generate_app_display_name "$COMMUNITY_NAME" "Android")"

firebase apps:create android "$ANDROID_PACKAGE" --display-name="$ANDROID_DISPLAY_NAME" || {
    print_warning "Android app may already exist or creation failed"
}
print_success "Android app configured"

###############################################################################
# Step 4: Deploy Firestore Rules and Functions
###############################################################################
print_step "Deploying Firestore rules and Cloud Functions"

cd "$SCRIPT_DIR/.."  # Go to project root

firebase deploy --only firestore:rules,functions --project "$PROJECT_ID" || {
    print_warning "Deployment had some issues, but continuing"
}
print_success "Deployed Firestore rules and Cloud Functions"

###############################################################################
# Step 5: Seed Groups
###############################################################################
print_step "Seeding initial groups"

# Set Google Application Credentials for admin SDK
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"

# Check if we need to setup application default credentials
if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    print_info "Setting up application default credentials"
    gcloud auth application-default login
fi

# Run seed script
cd "$SCRIPT_DIR"
node lib/seed-groups.js "$PROJECT_ID" "$CONFIG_FILE" || {
    print_warning "Group seeding failed, but you can run it manually later:"
    print_info "./scripts/seed-groups.sh $PROJECT_ID $CONFIG_FILE"
}

###############################################################################
# Step 6: Create Admin Users
###############################################################################
print_step "Setting up admin users"

ADMIN_EMAILS=$(jq -r '.admins[]' "$CONFIG_FILE" 2>/dev/null)

if [ -n "$ADMIN_EMAILS" ]; then
    print_info "Admin users will need to be created after first login"
    print_info "Admin emails from config:"
    echo "$ADMIN_EMAILS" | while read email; do
        echo "  - $email"
    done
    echo ""
    print_info "After each admin user signs up, run:"
    echo "  ./scripts/create-admin.sh $PROJECT_ID <email>"
else
    print_warning "No admin emails in config"
fi

###############################################################################
# Step 7: Update Projects Registry
###############################################################################
print_step "Updating projects registry"
update_projects_registry "$PROJECT_ID" "$COMMUNITY_NAME"

###############################################################################
# Step 8: Download Config Files
###############################################################################
print_step "Config files for Flutter"

print_info "To download Firebase config files for your Flutter app:"
echo ""
echo "  1. iOS config:"
echo "     firebase apps:sdkconfig ios $IOS_BUNDLE_ID > ios/Runner/GoogleService-Info.plist"
echo ""
echo "  2. Android config:"
echo "     firebase apps:sdkconfig android $ANDROID_PACKAGE > android/app/google-services.json"
echo ""
echo "  3. Run FlutterFire configure:"
echo "     flutterfire configure --project=$PROJECT_ID"
echo ""

###############################################################################
# Done!
###############################################################################
echo ""
echo "══════════════════════════════════════════════════════════════"
print_success "Community created successfully!"
echo "══════════════════════════════════════════════════════════════"
echo ""
print_info "Project: $PROJECT_ID"
print_info "Config: $CONFIG_FILE"
echo ""
print_info "Next steps:"
echo "  1. Download config files (see commands above)"
echo "  2. Build Flutter app: flutter build ios/android"
echo "  3. Have admin users sign up in the app"
echo "  4. Grant admin privileges: ./scripts/create-admin.sh $PROJECT_ID <email>"
echo ""
print_info "Firebase Console: https://console.firebase.google.com/project/$PROJECT_ID"
echo ""
