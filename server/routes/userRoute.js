const express = require("express");
const router = express.Router();
const {
  deleteUsers,
  createUser,
  updateUser,
  getUser,
} = require("../controllers/userController");

router.post("/create", createUser);
router.get("/:userId", getUser);
router.put("/update/:userId", updateUser);
router.delete("/delete", deleteUsers);

module.exports = router;
