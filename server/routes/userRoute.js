const express = require("express");
const router = express.Router();
const { deleteUsers } = require("../controllers/userController");

router.delete("/delete", deleteUsers);

module.exports = router;
