const path = require("path");
const express = require("express");
const imagesController = require("../controllers/images");

const router = express.Router();

router.get("/", imagesController.getTodaysImage);
router.get("/images/:imageDate", imagesController.getImage);

module.exports = router;
