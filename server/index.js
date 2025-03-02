const express = require("express");
const userRoutes = require("./routes/userRoute");
const admin = require("./firebase-admin");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

app.use("/api/users", userRoutes);

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
