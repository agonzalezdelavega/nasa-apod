const path = require("path");
const express = require("express");
const imagesController = require("../controllers/images");
const getTodaysDate = require("../middleware/get-todays-date");
const verifyToken = require("../middleware/verify-token");
const isAuth = require("../middleware/is-auth");

const router = express.Router();

router.get("/", getTodaysDate, imagesController.getTodaysImage);
router.get("/images/:imageDate", getTodaysDate, verifyToken, imagesController.getImage);
router.post("/images/:imageDate", isAuth, getTodaysDate, verifyToken, imagesController.postFavorite);

module.exports = router;
