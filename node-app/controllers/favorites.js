const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient();

exports.getFavorites = (req, res, next) => {
    const input = {
        "TableName": process.env.DYNAMO_DB_FAVORITES_TABLE_NAME,
        "Key": {
            "userID": {
                "S": res.locals.userid
            }
        }
    };

    const command = new GetItemCommand(input);

    (async () => {
        const response = await client.send(command)
        .then((response) => {
            res.render("favorites/view-favorites", {
                imageDate: req.session.imageDate,
                pageTitle: "Favorites",
                today: res.locals.today,
                isLoggedIn: req.session.isLoggedIn,
            });
        });
    })();
};