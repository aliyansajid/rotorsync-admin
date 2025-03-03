const admin = require("../firebase-admin");

const userController = {
  /**
   * Create a new user in Firebase Authentication and Firestore.
   * @param {Object} req - The request object.
   * @param {Object} res - The response object.
   */
  createUser: async (req, res) => {
    const { fullName, email, password, role } = req.body;

    // Validate input
    if (!fullName || !email || !password || !role) {
      return res.status(400).json({ error: "All fields are required." });
    }

    try {
      const auth = admin.auth();
      const firestore = admin.firestore();

      // Create user in Firebase Authentication
      const userRecord = await auth.createUser({
        email,
        password,
      });

      // Save user data in Firestore
      const userData = {
        uid: userRecord.uid,
        fullName,
        email,
        role,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await firestore.collection("users").doc(userRecord.uid).set(userData);

      res.status(201).json({ message: "User created successfully.", userData });
    } catch (error) {
      console.error("Error creating user:", error);
      res.status(500).json({ error: "Failed to create user." });
    }
  },

  /**
   * Fetch user data by UID.
   * @param {Object} req - The request object.
   * @param {Object} res - The response object.
   */
  getUser: async (req, res) => {
    const { userId } = req.params;

    // Validate input
    if (!userId) {
      return res.status(400).json({ error: "User ID is required." });
    }

    try {
      const firestore = admin.firestore();
      const userDoc = await firestore.collection("users").doc(userId).get();

      if (!userDoc.exists) {
        return res.status(404).json({ error: "User not found." });
      }

      const userData = userDoc.data();
      res.status(200).json(userData);
    } catch (error) {
      console.error("Error fetching user data:", error);
      res.status(500).json({ error: "Failed to fetch user data." });
    }
  },

  /**
   * Update an existing user in Firebase Authentication and Firestore.
   * @param {Object} req - The request object.
   * @param {Object} res - The response object.
   */
  updateUser: async (req, res) => {
    const { userId } = req.params;
    const { firstName, lastName, email, password, role } = req.body;

    // Validate input
    if (!userId || !firstName || !lastName || !email) {
      return res.status(400).json({ error: "All fields are required." });
    }

    try {
      const auth = admin.auth();
      const firestore = admin.firestore();

      // Update user in Firebase Authentication (if email or password is changed)
      if (email) {
        await auth.updateUser(userId, { email });
      }
      if (password) {
        await auth.updateUser(userId, { password });
      }

      // Prepare user data for Firestore update
      const userData = {
        firstName,
        lastName,
        email,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Include role only if it is provided
      if (role !== undefined) {
        userData.role = role;
      }

      // Update user data in Firestore
      await firestore.collection("users").doc(userId).update(userData);

      res.status(200).json({ message: "User updated successfully.", userData });
    } catch (error) {
      console.error("Error updating user:", error);
      res.status(500).json({ error: "Failed to update user." });
    }
  },

  /**
   * Delete users from Firestore and Firebase Authentication.
   * @param {Object} req - The request object.
   * @param {Object} res - The response object.
   */
  deleteUsers: async (req, res) => {
    const { userIds } = req.body;
    console.log(userIds);

    // Validate input
    if (!userIds || !Array.isArray(userIds)) {
      return res.status(400).json({ error: "User IDs are required." });
    }

    try {
      const firestore = admin.firestore();
      const auth = admin.auth();

      // Delete users from Firestore
      const batch = firestore.batch();
      userIds.forEach((userId) => {
        batch.delete(firestore.collection("users").doc(userId));
      });
      await batch.commit();

      // Delete users from Firebase Authentication
      await Promise.all(userIds.map((userId) => auth.deleteUser(userId)));

      res.status(200).json({ message: "Users deleted successfully." });
    } catch (error) {
      console.error("Error deleting users:", error);
      res.status(500).json({ error: "Failed to delete users." });
    }
  },
};

module.exports = userController;
