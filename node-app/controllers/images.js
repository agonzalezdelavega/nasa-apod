const { DynamoDBClient, TransactWriteItemsCommand, UpdateItemCommand, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const Image = require("../models/image");

const client = new DynamoDBClient();

exports.getTodaysImage = (req, res, next) => {
    res.redirect(`/images/${res.locals.today}`)
};

exports.getImage = (req, res, next) => {
    const image = new Image;
    var isFavorite = false;
    var { imageDate } = req.params;
    if (!req.params.imageDate) {
        imageDate = res.locals.today;
    };
    var prevDate = new Date(imageDate), nextDate = new Date(imageDate);
    prevDate.setDate(prevDate.getDate() - 1);
    nextDate.setDate(nextDate.getDate() + 1);
    req.session.imageDate = imageDate;

    (async () => {
        try {
            await image.getImage(imageDate)
            .then((image) => {
                var copyright = "N/A";
                if (image.copyright) {
                    copyright = image.copyright;
                };

                if (req.session.isLoggedIn) {
                    const fav_check = req.session.favorites.some(entry => imageDate === entry.date);

                    if (req.session.favorites && fav_check) {
                        isFavorite = true;
                    };  
                };

                res.render("images/show-image", {
                    imageDate: imageDate,
                    media_type: image.media_type,
                    image: image.url,
                    imageTitle: image.title,
                    imageDescription: image.explanation,
                    imageCopyright: copyright,
                    pageTitle: "Welcome to my image viewer!",
                    today: res.locals.today,
                    prevDate: prevDate.toISOString().slice(0,10),
                    nextDate: nextDate.toISOString().slice(0,10),
                    isLoggedIn: req.session.isLoggedIn,
                    isFavorite: isFavorite
                });
            });
        } catch (error) {
            console.error(error);
        };
    })()
};

exports.postFavorite = (req, res, next) => {
    const { imageDate, imageTitle, image } = req.body;
    const userid = res.locals.userid;
    const imageData = {"date": imageDate, "title": imageTitle, "url": image};
    const fav_check = req.session.favorites.some(entry => imageData.date === entry.date);
    if (req.session.favorites && fav_check) {
        const index = req.session.favorites.findIndex(entry => imageData.date === entry.date);
        req.session.favorites.splice(index, 1);
        const input = {
            TableName: process.env.DYNAMO_DB_FAVORITES_TABLE_NAME,
            Key: {
                "userID": {"S": userid}
            },
            UpdateExpression:`REMOVE favorites[${index}]`
        };
        const command = new UpdateItemCommand(input);
        (async () => {
            try {
                await client.send(command)
                .then((response) => {
                });
            } catch (error) {
                // console.log(error);
            };
        })();
        res.redirect(`/images/${imageDate}`);
    } else {
        const index = req.session.favorites.push(imageData) - 1;
        const input = {
            TableName: process.env.DYNAMO_DB_FAVORITES_TABLE_NAME,
            Key: {
                "userID": {"S": userid}
            },
            "ExpressionAttributeValues": {
                ":i": {
                    "M": {
                        "date": {"S": imageDate},
                        "url": {"S": image},
                        "title": {"S": imageTitle},
                    },
                }
            },
            UpdateExpression:`SET favorites[${index}] = :i`
        };
        const command = new UpdateItemCommand(input);
        (async () => {
            try {
                await client.send(command)
                .then((response) => {
                });
            } catch (error) {
                console.log(error);
            };
        })();
        res.redirect(`/images/${imageDate}`);
    };
};