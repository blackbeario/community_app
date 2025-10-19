# Community Deployment Scripts

Automation scripts for deploying new single-tenant community instances.

## Overview

These scripts automate the process of:
1. Creating a new Firebase project for a community
2. Configuring iOS and Android apps
3. Seeding initial groups/data
4. Creating admin users
5. Deploying Cloud Functions and Firestore rules

## Prerequisites

### Required Tools
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- [Node.js](https://nodejs.org/) (v16 or higher)
- [jq](https://stedolan.github.io/jq/) for JSON processing (`brew install jq` on macOS)
- Firebase account with billing enabled
- Google Cloud SDK (for advanced features)

### Authentication
```bash
# Login to Firebase
firebase login

# Login to Google Cloud (for project creation)
gcloud auth login
```

## Quick Start

### Create a New Community

```bash
./scripts/create-community.sh "Champion Hills"
```

This will:
1. Create Firebase project: `community-champion-hills`
2. Enable required Firebase services
3. Create iOS app: `io.vibesoftware.community.championhills`
4. Create Android app: `io.vibesoftware.community.championhills`
5. Download GoogleService-Info.plist and google-services.json
6. Deploy Firestore rules and Cloud Functions
7. Seed initial groups from configuration

### Seed Groups for Existing Project

```bash
./scripts/seed-groups.sh champion-hills groups-champion-hills.json
```

### Create Admin User

```bash
./scripts/create-admin.sh champion-hills user@example.com
```

### Deploy to All Communities

```bash
./scripts/deploy-all.sh
```

## Configuration Files

### Community Configuration
Create a JSON file for each community in `scripts/configs/`:

**Example: `configs/champion-hills.json`**
```json
{
  "name": "Champion Hills",
  "projectId": "community-champion-hills",
  "iosBundleId": "io.vibesoftware.community.championhills",
  "androidPackageName": "io.vibesoftware.community.championhills",
  "groups": [
    {
      "id": "announcements",
      "name": "Announcements",
      "description": "Important community announcements from management",
      "icon": "📢",
      "memberCount": 0
    },
    {
      "id": "events",
      "name": "Events",
      "description": "Community events, gatherings, and activities",
      "icon": "🎉",
      "memberCount": 0
    },
    {
      "id": "general",
      "name": "General Discussion",
      "description": "General community discussions and conversations",
      "icon": "💬",
      "memberCount": 0
    },
    {
      "id": "maintenance",
      "name": "Maintenance",
      "description": "Maintenance requests and updates",
      "icon": "🔧",
      "memberCount": 0
    }
  ],
  "admins": [
    "admin@championhills.com"
  ]
}
```

### Projects Registry
The script maintains a registry of all communities in `scripts/configs/projects.json`:

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

## Scripts Reference

### `create-community.sh`
Creates a complete new community instance.

**Usage:**
```bash
./scripts/create-community.sh <community-name> [config-file]
```

**Arguments:**
- `community-name`: Display name (e.g., "Champion Hills")
- `config-file`: Optional path to community config JSON (defaults to auto-generated)

**Example:**
```bash
./scripts/create-community.sh "Champion Hills" configs/champion-hills.json
```

### `seed-groups.sh`
Seeds groups for an existing project.

**Usage:**
```bash
./scripts/seed-groups.sh <project-id> <groups-json>
```

**Arguments:**
- `project-id`: Firebase project ID (e.g., `champion-hills`)
- `groups-json`: Path to JSON file with groups array

**Example:**
```bash
./scripts/seed-groups.sh champion-hills configs/champion-hills.json
```

### `create-admin.sh`
Grants admin privileges to a user.

**Usage:**
```bash
./scripts/create-admin.sh <project-id> <email>
```

**Example:**
```bash
./scripts/create-admin.sh champion-hills admin@example.com
```

### `deploy-all.sh`
Deploys code to all registered community projects.

**Usage:**
```bash
./scripts/deploy-all.sh [--functions-only|--rules-only]
```

**Options:**
- `--functions-only`: Deploy only Cloud Functions
- `--rules-only`: Deploy only Firestore rules

**Example:**
```bash
# Deploy everything to all communities
./scripts/deploy-all.sh

# Deploy only functions
./scripts/deploy-all.sh --functions-only
```

### `download-configs.sh`
Downloads Firebase config files for all apps.

**Usage:**
```bash
./scripts/download-configs.sh <project-id>
```

**Example:**
```bash
./scripts/download-configs.sh champion-hills
```

## Workflow

### Setting Up a New Community

1. **Create configuration file**
   ```bash
   cp scripts/configs/template.json scripts/configs/champion-hills.json
   # Edit the file with community-specific details
   ```

2. **Run creation script**
   ```bash
   ./scripts/create-community.sh "Champion Hills" configs/champion-hills.json
   ```

3. **Download config files**
   ```bash
   ./scripts/download-configs.sh champion-hills
   ```

4. **Move config files to Flutter project**
   ```bash
   # iOS
   cp downloads/champion-hills/GoogleService-Info.plist ios/Runner/

   # Android
   cp downloads/champion-hills/google-services.json android/app/
   ```

5. **Update Flutter Firebase options**
   ```bash
   flutterfire configure --project=community-champion-hills
   ```

6. **Build and deploy app**
   ```bash
   flutter build ios --release
   flutter build android --release
   ```

### Updating Existing Communities

```bash
# Deploy code updates to all communities
./scripts/deploy-all.sh

# Or deploy to specific community
firebase use champion-hills
firebase deploy
```

## Troubleshooting

### Firebase CLI not authenticated
```bash
firebase login
```

### Project creation fails
- Ensure billing is enabled on your Google Cloud account
- Check that project ID is unique globally
- Verify you have owner permissions

### Can't download config files
- Ensure apps are created in Firebase console
- Check Firebase CLI version: `firebase --version` (should be 11.0.0+)

### Deployment fails
- Verify you're authenticated: `firebase login`
- Check you're using correct project: `firebase use <project-id>`
- Review error logs: `firebase functions:log`

## Security Notes

⚠️ **Important:**
- Config files contain sensitive data - do NOT commit to git
- Add to `.gitignore`: `scripts/downloads/`, `scripts/configs/*.json` (except template)
- Store production configs securely (1Password, Secrets Manager, etc.)
- Limit access to deployment scripts to authorized personnel only

## File Structure

```
scripts/
├── README.md                    # This file
├── create-community.sh          # Main creation script
├── seed-groups.sh              # Group seeding script
├── create-admin.sh             # Admin creation script
├── deploy-all.sh               # Multi-project deployment
├── download-configs.sh         # Config file downloader
├── lib/
│   ├── utils.sh               # Shared utilities
│   └── seed-groups.js         # Node script for seeding
├── configs/
│   ├── template.json          # Template configuration
│   ├── projects.json          # Projects registry
│   └── champion-hills.json    # Example community config
└── downloads/                  # Downloaded config files (gitignored)
    └── champion-hills/
        ├── GoogleService-Info.plist
        └── google-services.json
```

## Related Documentation

- [Single vs Multi-Tenant Architecture](../docs/research/single-vs-multi-tenant.md)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [FlutterFire Setup](https://firebase.flutter.dev/docs/cli/)
