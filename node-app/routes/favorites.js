const path = require("path");
const express = require("express");
const favoritesController = require("../controllers/favorites");
const getTodaysDate = require("../middleware/get-todays-date");
const verifyToken = require("../middleware/verify-token");
const isAuth = require("../middleware/is-auth");

const router = express.Router();

router.get("/favorites", isAuth, getTodaysDate, verifyToken, favoritesController.getFavorites);

module.exports = router;
