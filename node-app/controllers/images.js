const { DynamoDBClient, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");
const Image = require("../models/image");

const client = new DynamoDBClient();

exports.getTodaysImage = (req, res, next) => {
    res.redirect(`/images?imageDate=${res.locals.today}`)
};

exports.getImage = (req, res, next) => {
    var isFavorite = false;
    var { imageDate } = req.query;

    if (!req.query.imageDate) {
        imageDate = res.locals.today;
    };
    var prevDate = new Date(imageDate), nextDate = new Date(imageDate);
    prevDate.setDate(prevDate.getDate() - 1);
    nextDate.setDate(nextDate.getDate() + 1);
    req.session.imageDate = imageDate;
    
    (async () => {
        var image = await new Image(imageDate).getImageData();
        image.copyright = ("copyright" in image) ? image.copyright : "N/A";
        return image;
    })()
    .then((image) => {
        if (req.session.isLoggedIn) {
            const fav_check = req.session.favorites.some(entry => imageDate === entry.date);

            if (req.session.favorites && fav_check) {
                isFavorite = true;
            };
        };
        res.render("images/show-image", {   
            imageDate: imageDate,
            mediaType: image.media_type,
            image: image.url,
            imageTitle: image.title,
            imageDescription: image.explanation,
            imageCopyright: image.copyright,
            pageTitle: "Welcome to my image viewer!",
            today: res.locals.today,
            prevDate: prevDate.toISOString().slice(0,10),
            nextDate: nextDate.toISOString().slice(0,10),
            isLoggedIn: req.session.isLoggedIn,
            isFavorite: isFavorite
        });
    });
};

exports.postFavorite = (req, res, next) => {
    const { imageDate, imageTitle, image, mediaType } = req.body;
    const userid = res.locals.userid;
    const imageData = {"date": imageDate, "title": imageTitle, "url": image, "mediaType": mediaType};
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
                response = await client.send(command);
            } catch (error) {
                console.log(error);
            };
        })();
        res.redirect(`/images?imageDate=${imageDate}`);
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
                        "mediaType": {"S": mediaType}
                    },
                }
            },
            UpdateExpression:`SET favorites[${index}] = :i`
        };
        const command = new UpdateItemCommand(input);
        (async () => {
            try {
                await client.send(command)
            } catch (error) {
                console.log(error);
            };
        })();
        res.redirect(`/images?imageDate=${imageDate}`);
    };
};