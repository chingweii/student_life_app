const admin = require('firebase-admin');
const fs = require('fs');

// --- Configuration ---
const SERVICE_ACCOUNT_FILE = './serviceAccountKey.json';

const IMPORT_TASKS = [
  {
    filePath: './event_mock.json', // Your event file
    collectionName: 'events',
    shouldConvertDate: true 
  },
  {
    filePath: './MOCK_DATA.json', // Your user file
    collectionName: 'users',
    shouldConvertDate: false 
  }
];
// ---------------------

console.log(`Authenticating with ${SERVICE_ACCOUNT_FILE}...`);
const serviceAccount = require(SERVICE_ACCOUNT_FILE);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// --- Helper: Convert Dates ---
function convertDateString(dateStr) {
  if (!dateStr) return null;

  const months = {
    "January": 0, "February": 1, "March": 2, "April": 3, "May": 4, "June": 5,
    "July": 6, "August": 7, "September": 8, "October": 9, "November": 10, "December": 11
  };

  try {
    const parts = dateStr.split(' '); 
    if (parts.length !== 3) return dateStr; 

    const day = parseInt(parts[0]);
    const month = months[parts[1]]; 
    const year = parseInt(parts[2]);

    const dateObj = new Date(Date.UTC(year, month, day));
    return dateObj.toISOString(); 
  } catch (e) {
    console.warn(`Could not parse date: ${dateStr}`);
    return dateStr;
  }
}

async function uploadFile(task) {
  const { filePath, collectionName, shouldConvertDate } = task;

  if (!fs.existsSync(filePath)) {
    console.error(`❌ File not found: ${filePath} - Skipping.`);
    return;
  }

  console.log(`\n--- Processing '${collectionName}' from ${filePath} ---`);
  
  const rawData = fs.readFileSync(filePath, 'utf8');
  let data = JSON.parse(rawData);
  
  if (shouldConvertDate) {
    console.log("   --> Converting dates to ISO format...");
    data = data.map(item => {
      return {
        ...item, 
        date: convertDateString(item.date) 
      };
    });
  }

  console.log(`   --> Prepare to upload ${data.length} documents.`);

  const colRef = db.collection(collectionName);
  let batch = db.batch();
  let count = 0;
  let totalUploaded = 0;

  for (const item of data) {
    let docRef;

    // --- SMART ID LOGIC ---
    if (item.id) {
      // 1. Priority: Use the explicit ID if provided (e.g., 'evt_001')
      docRef = colRef.doc(item.id);
    } else if (item.email) {
      // 2. Priority: Use EMAIL as ID for users (Guarantees uniqueness!)
      docRef = colRef.doc(item.email);
    } else {
      // 3. Fallback: Generate random ID (Only if no ID and no Email found)
      docRef = colRef.doc();
    }
    // ----------------------
    
    batch.set(docRef, item);

    count++;
    totalUploaded++;

    if (count === 499) {
      await batch.commit();
      batch = db.batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
  }

  console.log(`✅ Finished '${collectionName}': ${totalUploaded} docs.`);
}

async function runAllImports() {
  for (const task of IMPORT_TASKS) {
    await uploadFile(task);
  }
  console.log("\n🎉 All imports complete!");
}

runAllImports().catch(console.error);