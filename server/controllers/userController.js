const admin = require("../firebase-admin");

const userController = {
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

      res.status(200).json({ message: "Users deleted successfully." });
    } catch (error) {
      console.error("Error deleting users:", error);
      res.status(500).json({ error: "Failed to delete users." });
    }
  },
};

module.exports = userController;
