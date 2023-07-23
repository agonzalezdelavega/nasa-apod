const path = require("path");
const express = require("express");
const authController = require("../controllers/auth");
const getTodaysDate = require("../middleware/get-todays-date");
const { body } = require("express-validator");

const router = express.Router();

// Log In
router.get("/login", getTodaysDate, authController.getLoginForm);
router.post("/login", getTodaysDate, authController.postUserLogin);

// Log Out
router.get("/logout", authController.postUserLogout);

// Sign Up
router.get("/signup", getTodaysDate, authController.getSignUpForm);
router.post(
    "/signup",
    [
        body(
            "email",
            "Please enter a valid email email address"
        ).isEmail(),
        body(
            "password",
            "Password must be at least 8 characters long"
        )
        .isLength({"min": 8}),
        body('confirmpassword')
        .trim()
        .custom((value, { req }) => {
          if (value !== req.body.password) {
            throw new Error('Passwords must match');
          }
          return true;
        })
    ],
    getTodaysDate,
    authController.postUserSignUp
);
router.get("/signup-successful", getTodaysDate, authController.getSignupConfirm);

module.exports = router;
