# Firebase Manual Setup Instructions

**Project Details:**
- Project Name: `community-app-001`
- Project ID: `community-app-001-7c072`
- Project Number: `1097511872453`

---

## Part 1: Enable Firebase Services in Console

Go to: https://console.firebase.google.com/project/community-app-001-7c072

### 1. Enable Authentication
1. Click **Build > Authentication** in left sidebar
2. Click **"Get started"**
3. Click **"Email/Password"** under Sign-in providers
4. Toggle **"Enable"** on
5. Click **"Save"**

### 2. Create Firestore Database
1. Click **Build > Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"** (we'll add security later)
4. Choose location: **us-central** (or closest to you)
5. Click **"Enable"**

### 3. Enable Cloud Storage
1. Click **Build > Storage**
2. Click **"Get started"**
3. Select **"Start in test mode"**
4. Use **same location** as Firestore
5. Click **"Done"**

### 4. Enable Cloud Messaging (FCM)
1. Click **Build > Cloud Messaging**
2. Should be auto-enabled (if not, click "Get started")

---

## Part 2: Register iOS App

1. In Firebase Console, go to **Project Overview** (top-left)
2. Click the **iOS** icon (or "Add app")
3. **iOS bundle ID:** `com.community.app` (you can change this)
4. **App nickname:** `Community iOS`
5. Click **"Register app"**
6. **Download** `GoogleService-Info.plist`
7. Save it somewhere accessible (Desktop is fine)
8. Click **"Next"** through remaining steps

---

## Part 3: Register Android App

1. In Firebase Console, go to **Project Overview**
2. Click the **Android** icon (or "Add app")
3. **Android package name:** `com.community.app` (match iOS bundle)
4. **App nickname:** `Community Android`
5. Click **"Register app"**
6. **Download** `google-services.json`
7. Save it somewhere accessible (Desktop is fine)
8. Click **"Next"** through remaining steps

---

## Part 4: Provide Config Values

I need these values to generate the `firebase_options.dart` file. You can find them in:

### From Firebase Console > Project Settings (⚙️ icon)

**General Tab:**
- Project ID: `community-app-001-7c072` ✅
- Project Number: `1097511872453` ✅

**iOS App Section (scroll down):**
- iOS Bundle ID: `__________` (you entered this)
- iOS App ID: `__________` (shown in console)

**Android App Section:**
- Android Package Name: `__________` (you entered this)
- Android App ID: `__________` (shown in console)

### From GoogleService-Info.plist (iOS)
Open the downloaded file in a text editor and find:
- `API_KEY`: `__________`
- `GOOGLE_APP_ID`: `__________`
- `GCM_SENDER_ID`: `__________`
- `PROJECT_ID`: `community-app-001-7c072` ✅
- `STORAGE_BUCKET`: `__________`

### From google-services.json (Android)
Open the downloaded file and find:
- `mobilesdk_app_id`: `__________`
- `api_key` (current_key): `__________`
- `project_id`: `community-app-001-7c072` ✅
- `storage_bucket`: `__________`

---

## Once You Provide the Values Above:

I will:
1. Create the `firebase_options.dart` file with your config
2. Move the iOS/Android config files to the correct locations
3. Initialize Firebase in `main.dart`
4. Set up Firestore security rules

---

## Quick Way - Just Upload the Files

**Or**, you can simply:
1. Upload/paste the contents of `GoogleService-Info.plist`
2. Upload/paste the contents of `google-services.json`

And I'll extract all the values automatically!

Let me know which approach you prefer! 🚀
