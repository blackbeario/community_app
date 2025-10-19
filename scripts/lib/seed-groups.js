#!/usr/bin/env node

/**
 * Seed groups into Firestore
 * Usage: node seed-groups.js <project-id> <groups-json-file>
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Parse arguments
const args = process.argv.slice(2);
if (args.length < 2) {
  console.error('Usage: node seed-groups.js <project-id> <groups-json-file>');
  process.exit(1);
}

const projectId = args[0];
const groupsFile = args[1];

// Read and parse groups file
let config;
try {
  const configContent = fs.readFileSync(groupsFile, 'utf8');
  config = JSON.parse(configContent);
} catch (error) {
  console.error(`Error reading config file: ${error.message}`);
  process.exit(1);
}

if (!config.groups || !Array.isArray(config.groups)) {
  console.error('Config file must contain a "groups" array');
  process.exit(1);
}

// Initialize Firebase Admin
try {
  admin.initializeApp({
    projectId: projectId,
  });
  console.log(`✓ Initialized Firebase Admin for project: ${projectId}`);
} catch (error) {
  console.error(`✗ Failed to initialize Firebase: ${error.message}`);
  process.exit(1);
}

const db = admin.firestore();

async function seedGroups() {
  console.log(`\n▶ Seeding ${config.groups.length} groups...`);

  const batch = db.batch();
  let count = 0;

  for (const group of config.groups) {
    if (!group.id || !group.name) {
      console.warn(`⚠ Skipping invalid group: ${JSON.stringify(group)}`);
      continue;
    }

    const groupRef = db.collection('groups').doc(group.id);
    batch.set(groupRef, {
      id: group.id,
      name: group.name,
      description: group.description || '',
      icon: group.icon || '📁',
      memberCount: group.memberCount || 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    console.log(`  ✓ ${group.icon} ${group.name}`);
    count++;
  }

  try {
    await batch.commit();
    console.log(`\n✓ Successfully seeded ${count} groups`);
  } catch (error) {
    console.error(`\n✗ Failed to seed groups: ${error.message}`);
    process.exit(1);
  }
}

async function checkExistingGroups() {
  try {
    const snapshot = await db.collection('groups').limit(1).get();
    if (!snapshot.empty) {
      console.log('\n⚠ Warning: Groups collection already contains data');
      console.log('This operation will merge/overwrite existing groups with matching IDs');
      return true;
    }
    return false;
  } catch (error) {
    console.error(`Error checking existing groups: ${error.message}`);
    return false;
  }
}

// Main execution
async function main() {
  try {
    await checkExistingGroups();
    await seedGroups();
    process.exit(0);
  } catch (error) {
    console.error(`\n✗ Unexpected error: ${error.message}`);
    process.exit(1);
  }
}

main();
