const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");
const session = require('express-session');
const dotenv = require('dotenv');
const DynamoDBStore = require('dynamodb-store');

dotenv.config();

const moment = require("moment-timezone");
global.moment = moment;

const imageRoutes = require("./routes/images");
const loginRoutes = require("./routes/auth");

const app = express();

app.set("view engine", "ejs");
app.set("views", "views");

app.use(
  session({
    secret: process.env.EXPRESS_SECRET,
    resave: false,
    saveUninitialized: true,
    store: new DynamoDBStore({
      "table": {
        "name": process.env.DYNAMO_DB_TABLE_NAME,
        "hashKey": process.env.DYNAMO_DB_TABLE_PARTITION_KEY,
      },
      "dynamoConfig": {
        "endpoint": process.env.DYNAMO_DB_TABLE_ENDPOINT
      }
    }),
    cookie: {
      httpOnly: true,
      secure: false,
      maxAge: 600000
    }
  })
);

const errorController = require("./controllers/error");

app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, "public")));

app.use(imageRoutes);
app.use(loginRoutes);

app.use(errorController.get404);

app.listen(3000);
