const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");

const imageRoutes = require("./routes/images");

const app = express();

app.set("view engine", "ejs");
app.set("views", "views");

const errorController = require("./controllers/error");

app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, "public")));

app.use(imageRoutes);

app.use(errorController.get404);

app.listen(3000);
