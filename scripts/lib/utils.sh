#!/bin/bash
# Shared utilities for deployment scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}▶${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required commands
check_requirements() {
    local missing=()

    if ! command_exists firebase; then
        missing+=("firebase-tools (npm install -g firebase-tools)")
    fi

    if ! command_exists node; then
        missing+=("node.js")
    fi

    if ! command_exists jq; then
        missing+=("jq (brew install jq)")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing required tools:"
        for tool in "${missing[@]}"; do
            echo "  - $tool"
        done
        exit 1
    fi

    print_success "All required tools installed"
}

# Check if user is authenticated with Firebase
check_firebase_auth() {
    if ! firebase projects:list >/dev/null 2>&1; then
        print_error "Not authenticated with Firebase"
        print_info "Run: firebase login"
        exit 1
    fi
    print_success "Firebase authentication verified"
}

# Convert name to project ID format
# Example: "Champion Hills" -> "champion-hills"
name_to_project_id() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-'
}

# Convert name to bundle ID format
# Example: "Champion Hills" -> "championhills"
name_to_bundle_suffix() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | tr -cd '[:alnum:]'
}

# Check if Firebase project exists
project_exists() {
    local project_id="$1"
    firebase projects:list 2>/dev/null | grep -q "$project_id"
}

# Wait for user confirmation
confirm() {
    local prompt="$1"
    local response

    read -r -p "$prompt [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    fi
}

# Read JSON value using jq
json_get() {
    local file="$1"
    local key="$2"
    jq -r "$key" "$file" 2>/dev/null
}

# Update projects registry
update_projects_registry() {
    local project_id="$1"
    local name="$2"
    local status="${3:-active}"
    local registry="scripts/configs/projects.json"

    ensure_dir "scripts/configs"

    if [ ! -f "$registry" ]; then
        echo '{"projects":[]}' > "$registry"
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local new_project=$(jq -n \
        --arg name "$name" \
        --arg projectId "$project_id" \
        --arg created "$timestamp" \
        --arg status "$status" \
        '{name: $name, projectId: $projectId, created: $created, status: $status}')

    jq ".projects += [$new_project]" "$registry" > "${registry}.tmp" && mv "${registry}.tmp" "$registry"
    print_success "Updated projects registry"
}

# Get all projects from registry
get_all_projects() {
    local registry="scripts/configs/projects.json"
    if [ -f "$registry" ]; then
        jq -r '.projects[].projectId' "$registry"
    fi
}

# Validate email format
is_valid_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Generate Firebase app display name
generate_app_display_name() {
    local community_name="$1"
    local platform="$2"
    echo "$community_name Community ($platform)"
}

# Export functions for use in other scripts
export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f print_step
export -f command_exists
export -f check_requirements
export -f check_firebase_auth
export -f name_to_project_id
export -f name_to_bundle_suffix
export -f project_exists
export -f confirm
export -f ensure_dir
export -f json_get
export -f update_projects_registry
export -f get_all_projects
export -f is_valid_email
export -f generate_app_display_name
