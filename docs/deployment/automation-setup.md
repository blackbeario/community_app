# Deployment Automation Setup

**Date:** 2025-10-19
**Status:** Ready for Testing

## Overview

Complete automation system for managing single-tenant community deployments. Includes scripts for creating new Firebase projects, seeding data, and a multi-project admin interface.

## What's Been Built

### 1. Deployment Scripts (`scripts/`)

A comprehensive set of Bash scripts for automating community deployment:

#### Main Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `create-community.sh` | Create new Firebase project | `./scripts/create-community.sh "Champion Hills"` |
| `seed-groups.sh` | Seed groups for existing project | `./scripts/seed-groups.sh champion-hills config.json` |
| `create-admin.sh` | Grant admin privileges | `./scripts/create-admin.sh champion-hills admin@example.com` |
| `deploy-all.sh` | Deploy to all communities | `./scripts/deploy-all.sh` |

#### Supporting Files

- **`lib/utils.sh`**: Shared utilities (colors, validation, helpers)
- **`lib/seed-groups.js`**: Node.js script for Firestore seeding
- **`package.json`**: Node dependencies (firebase-admin)
- **`configs/template.json`**: Template for community configuration
- **`configs/projects.json`**: Registry of all communities

### 2. Multi-Project Admin Tool

Flutter web interface for managing multiple communities:

- **Location**: `lib/views/admin/multi_project_admin_screen.dart`
- **Service**: `lib/services/admin/multi_project_service.dart`
- **Model**: `CommunityProject` (Freezed)

**Features**:
- Project switcher dropdown
- Project info dashboard
- Admin action cards (seed groups, manage users, create admins, etc.)
- Status indicators
- Firebase console links

### 3. Configuration System

**Template** (`scripts/configs/template.json`):
```json
{
  "name": "Community Name",
  "projectId": "community-example",
  "iosBundleId": "io.vibesoftware.community.example",
  "androidPackageName": "io.vibesoftware.community.example",
  "groups": [...],
  "admins": ["admin@example.com"]
}
```

**Projects Registry** (`scripts/configs/projects.json`):
```json
{
  "projects": [
    {
      "name": "Champion Hills",
      "projectId": "community-champion-hills",
      "created": "2025-01-19T12:00:00Z",
      "status": "active"
    }
  ]
}
```

## Quick Start Guide

### Prerequisites

Install required tools:

```bash
# Firebase CLI
npm install -g firebase-tools

# jq for JSON processing (macOS)
brew install jq

# Google Cloud SDK (optional, for advanced features)
# https://cloud.google.com/sdk/docs/install
```

Authenticate:

```bash
# Firebase
firebase login

# Google Cloud (for gcloud commands)
gcloud auth login
gcloud auth application-default login
```

### Install Script Dependencies

```bash
cd scripts
npm install
```

### Create Your First Community

1. **Create Firebase project manually** (CLI can't do this):
   - Go to https://console.firebase.google.com/
   - Click "Add project"
   - Name: "Champion Hills"
   - Project ID: `community-champion-hills` (use this exact ID)
   - Enable Blaze (pay-as-you-go) plan

2. **Run creation script**:
   ```bash
   ./scripts/create-community.sh "Champion Hills"
   ```

   This will:
   - Generate config from template
   - Create iOS and Android apps
   - Deploy Firestore rules and Cloud Functions
   - Seed initial groups
   - Update projects registry

3. **Download config files**:
   ```bash
   # iOS
   firebase apps:sdkconfig ios io.vibesoftware.community.championhills \
     > ios/Runner/GoogleService-Info.plist

   # Android
   firebase apps:sdkconfig android io.vibesoftware.community.championhills \
     > android/app/google-services.json

   # FlutterFire
   flutterfire configure --project=community-champion-hills
   ```

4. **Build the app**:
   ```bash
   flutter build ios --release
   flutter build android --release
   ```

5. **Create admin users**:
   - Have users sign up in the app
   - Grant admin privileges:
     ```bash
     ./scripts/create-admin.sh community-champion-hills admin@example.com
     ```

### Deploy Updates to All Communities

```bash
# Deploy everything
./scripts/deploy-all.sh

# Deploy only Cloud Functions
./scripts/deploy-all.sh --functions-only

# Deploy only Firestore rules
./scripts/deploy-all.sh --rules-only
```

## File Structure

```
community/
├── scripts/
│   ├── README.md                    # Full documentation
│   ├── create-community.sh          # Main creation script ✓
│   ├── seed-groups.sh              # Group seeding ✓
│   ├── create-admin.sh             # Admin creation ✓
│   ├── deploy-all.sh               # Multi-project deploy ✓
│   ├── package.json                # Node dependencies ✓
│   ├── lib/
│   │   ├── utils.sh               # Shared utilities ✓
│   │   └── seed-groups.js         # Firestore seeding ✓
│   └── configs/
│       ├── template.json          # Template config ✓
│       ├── projects.json          # Projects registry ✓
│       └── champion-hills.json    # Example (gitignored)
├── lib/
│   ├── views/admin/
│   │   └── multi_project_admin_screen.dart  # Admin UI ✓
│   └── services/admin/
│       └── multi_project_service.dart       # Multi-project service ✓
└── docs/
    ├── deployment/
    │   └── automation-setup.md              # This file
    └── research/
        └── single-vs-multi-tenant.md        # Architecture decision
```

## Security Notes

⚠️ **Important Security Considerations**:

1. **Gitignored Files**:
   - `scripts/configs/*.json` (except template and projects)
   - `scripts/downloads/`
   - Config files contain sensitive project IDs

2. **Access Control**:
   - Limit script access to authorized personnel
   - Store production configs in 1Password/Secrets Manager
   - Never commit Firebase config files to git

3. **Admin Privileges**:
   - Admin creation requires gcloud CLI access
   - First admin must be created manually
   - Subsequent admins can be created via Cloud Function

## What's Working

✅ **Scripts**:
- Community creation workflow
- Group seeding with custom data
- Multi-project deployment
- Admin user creation (via gcloud)
- Utility functions (colors, validation, etc.)

✅ **Admin Tool**:
- Project switcher UI
- Dashboard layout
- Action cards placeholders
- Project info display

## What's Not Yet Implemented

❌ **Scripts**:
- Automatic Firebase project creation (requires manual step)
- Config file downloading (manual Firebase CLI commands provided)

❌ **Admin Tool** (TODO):
- Actual group seeding implementation
- User management interface
- Admin creation dialog
- Analytics/statistics
- Deploy functions interface
- URL launching for Firebase console
- Loading projects from `projects.json` (currently hardcoded examples)

❌ **Advanced Features**:
- Automated testing of deployments
- Rollback functionality
- Version tracking per project
- CI/CD GitHub Actions workflows

## Next Steps

### Immediate (Testing Phase)

1. **Test deployment workflow**:
   ```bash
   # Create a test community
   ./scripts/create-community.sh "Test Community"

   # Verify all components work
   # - Firebase project exists
   # - Apps created
   # - Rules deployed
   # - Functions deployed
   # - Groups seeded
   ```

2. **Document any issues** in testing

3. **Refine error handling** based on test results

### Short-term (Week 1)

1. **Implement admin tool features**:
   - Wire up "Seed Groups" action to actually seed groups
   - Build "Create Admin" dialog
   - Load projects from `projects.json` instead of hardcoded list

2. **Add FlutterFire auto-configuration**:
   - Modify scripts to auto-run `flutterfire configure`
   - Auto-place config files in correct locations

3. **Create GitHub Actions workflow**:
   - Auto-deploy on push to main
   - Deploy to all registered projects

### Long-term (Month 1)

1. **Build admin tool features**:
   - User management (list, suspend, delete)
   - Analytics dashboard (user count, message stats, etc.)
   - Inline function deployment

2. **Advanced deployment features**:
   - Rollback to previous deployment
   - Staged rollouts (deploy to one project, test, then all)
   - Version tags per project

3. **Multi-environment support**:
   - Dev/staging/production environments
   - Environment-specific configs

## Troubleshooting

### Scripts Won't Run

**Problem**: Permission denied
```bash
chmod +x scripts/*.sh scripts/lib/*.sh
```

### Firebase Auth Errors

**Problem**: Not authenticated
```bash
firebase login
gcloud auth login
gcloud auth application-default login
```

### Group Seeding Fails

**Problem**: Missing Node dependencies
```bash
cd scripts
npm install
```

**Problem**: Firestore permissions
- Ensure you're authenticated with correct account
- Check Firestore rules allow admin writes

### Admin Creation Fails

**Problem**: User not found
- User must sign up in app first
- Check email is correct

**Problem**: gcloud command fails
- Install Google Cloud SDK
- Authenticate: `gcloud auth login`

## Related Documentation

- [scripts/README.md](../../scripts/README.md) - Detailed script documentation
- [docs/research/single-vs-multi-tenant.md](../research/single-vs-multi-tenant.md) - Architecture decision
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [FlutterFire Setup](https://firebase.flutter.dev/docs/cli/)

## Support

For issues or questions:
1. Check [scripts/README.md](../../scripts/README.md) for detailed usage
2. Review error messages and logs
3. Check Firebase console for project status
4. Verify authentication: `firebase projects:list`

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2025-01-19 | Initial deployment automation system created | Claude |
| TBD | First production deployment test | - |
| TBD | Admin tool features implementation | - |
