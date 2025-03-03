const admin = require("../firebase-admin");

const userController = {
  /**
   * Create a new user in Firebase Authentication and Firestore.
   * @param {Object} req - The request object.
   * @param {Object} res - The response object.
   */
  createUser: async (req, res) => {
    const { fullName, email, password, role } = req.body;

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

      // Success response
      res.status(201).json({ message: "User created successfully." });
    } catch (error) {
      console.error("Error creating user:", error);

      let errorMessage = "Failed to create user.";
      if (error.code === "auth/email-already-exists") {
        errorMessage =
          "The email address is already in use by another account.";
      } else if (error.code === "auth/invalid-email") {
        errorMessage = "The email address is invalid.";
      } else if (error.code === "auth/weak-password") {
        errorMessage = "The password is too weak.";
      }

      // Error response
      res.status(500).json({ error: errorMessage });
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
    const { fullName, email, password, role } = req.body;

    try {
      const auth = admin.auth();
      const firestore = admin.firestore();

      // Prepare user data for Firebase Authentication update
      const authUpdates = {};
      if (email) {
        authUpdates.email = email;
      }
      if (password) {
        authUpdates.password = password;
      }

      // Update user in Firebase Authentication (if email or password is changed)
      if (Object.keys(authUpdates).length > 0) {
        await auth.updateUser(userId, authUpdates);
      }

      // Prepare user data for Firestore update
      const userData = {
        fullName,
        email,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Include role only if it is provided
      if (role !== undefined) {
        userData.role = role;
      }

      // Update user data in Firestore
      await firestore.collection("users").doc(userId).update(userData);

      // Success response
      res.status(200).json({ message: "User updated successfully." });
    } catch (error) {
      console.error("Error updating user:", error);

      let errorMessage = "Failed to update user.";
      if (error.code === "auth/email-already-exists") {
        errorMessage =
          "The email address is already in use by another account.";
      } else if (error.code === "auth/invalid-email") {
        errorMessage = "The email address is invalid.";
      } else if (error.code === "auth/weak-password") {
        errorMessage = "The password is too weak.";
      }

      // Error response
      res.status(500).json({ error: errorMessage });
    }
  },

  /**
   * Delete users from Firestore and Firebase Authentication.
   * @param {Object} req - The request object.
   * @param {Object} res - The response object.
   */
  deleteUsers: async (req, res) => {
    const { userIds } = req.body;

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

      // Success response
      const message =
        userIds.length === 1
          ? "User deleted successfully."
          : `${userIds.length} users deleted successfully.`;
      res.status(200).json({ message });
    } catch (error) {
      console.error("Error deleting users:", error);

      // Error response
      let errorMessage = "Failed to delete users.";
      if (error.code === "auth/user-not-found") {
        errorMessage = "One or more users not found.";
      }

      res.status(500).json({ error: errorMessage });
    }
  },
};

module.exports = userController;
