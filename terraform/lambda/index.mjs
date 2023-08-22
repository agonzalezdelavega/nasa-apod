import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const dynamoDBClient = new DynamoDBClient();

export const handler = async (event) => {
    const userId = event.request.userAttributes.sub;

    const input = {
        TableName: process.env.DYNAMO_DB_FAVORITES_TABLE_NAME,
        Item: {
            "userID": {
                "S": userId
            },
            "favorites": {
                "L": []
            }
        }
    };
    const command = new PutItemCommand(input);

    try {
        await dynamoDBClient.send(command)
        .then((response) => {
            console.log(response);
        });
    } catch (error) {
        console.log(error);
    };
    
    return event;
};