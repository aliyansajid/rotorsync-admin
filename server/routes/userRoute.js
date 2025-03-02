const express = require("express");
const router = express.Router();
const {
  deleteUsers,
  createUser,
  updateUser,
} = require("../controllers/userController");

router.post("/create", createUser);
router.put("/update/:userId", updateUser);
router.delete("/delete", deleteUsers);

module.exports = router;
