const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const addData = async () => {
  try {
    const docRef = db.collection("users").doc("user1");
    await docRef.set({
      name: "John Doe",
      age: 30,
      email: "john.doe@example.com",
    });
    console.log("Data added successfully!");
  } catch (error) {
    console.error("Error adding data: ", error);
  }
};

addData();
