const admin = require('firebase-admin');
const fs = require('fs');

// --- Configuration ---
const SERVICE_ACCOUNT_FILE = './serviceAccountKey.json';
const DATA_FILE = './MOCK_DATA.json';
const COLLECTION_NAME = 'users';
// ---------------------

console.log(`Authenticating with ${SERVICE_ACCOUNT_FILE}...`);
const serviceAccount = require(SERVICE_ACCOUNT_FILE);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const colRef = db.collection(COLLECTION_NAME);

console.log(`Loading data from ${DATA_FILE}...`);
const data = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));

console.log(`Uploading ${data.length} documents to '${COLLECTION_NAME}' collection...`);

async function uploadData() {
  // Use a batch write for efficiency
  let batch = db.batch();
  let count = 0;

  for (const item of data) {
    // Create a new document with an auto-generated ID
    const docRef = colRef.doc();
    batch.set(docRef, item);

    count++;
    // Firestore batches have a limit of 500 operations
    if (count % 499 === 0) {
      console.log(`Committing batch of ${count}...`);
      await batch.commit();
      batch = db.batch(); // Start a new batch
    }
  }

  // Commit any remaining items
  if (count % 499 !== 0) {
    console.log(`Committing final batch of ${count % 499}...`);
    await batch.commit();
  }

  console.log(`✅ Successfully uploaded ${data.length} documents.`);
}

uploadData().catch(console.error);