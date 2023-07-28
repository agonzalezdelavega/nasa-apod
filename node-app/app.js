const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");
const session = require("express-session");
const dotenv = require("dotenv");
const DynamoDBStore = require("connect-dynamodb")(session);

dotenv.config();

const moment = require("moment-timezone");
global.moment = moment;

const imageRoutes = require("./routes/images");
const loginRoutes = require("./routes/auth");
const favoritesRoute = require("./routes/favorites");

const app = express();

app.set("view engine", "ejs");
app.set("views", "views");

app.use(
  session({
    secret: process.env.EXPRESS_SECRET,
    resave: true,
    saveUninitialized: false,
    store: new DynamoDBStore({
      table: process.env.DYNAMO_DB_SESSIONS_TABLE_NAME,
      hashKey: process.env.DYNAMO_DB_SESSIONS_TABLE_PARTITION_KEY,
      readCapacityUnits: 5,
      writeCapacityUnits: 5,
    }),
    cookie: {
      httpOnly: false,
      maxAge: 3600000
    },
  })
);

const errorController = require("./controllers/error");

app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, "public")));

app.use(imageRoutes);
app.use(loginRoutes);
app.use(favoritesRoute);

app.use(errorController.get404);

app.listen(3000);
