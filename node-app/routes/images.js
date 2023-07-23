const path = require("path");
const express = require("express");
const imagesController = require("../controllers/images");
const getTodaysDate = require("../middleware/get-todays-date");
const verifyToken = require("../middleware/verify-jwt");

const router = express.Router();

router.get("/", getTodaysDate, imagesController.getTodaysImage);
router.get("/images/:imageDate", getTodaysDate, verifyToken, imagesController.getImage);

module.exports = router;
