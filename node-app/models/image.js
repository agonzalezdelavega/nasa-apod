const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const axios = require("axios");

const secretsManager = new SecretsManagerClient();
const getSecretValueInput = {
  SecretId: process.env.API_KEY_SECRET
};

const url = "https://api.nasa.gov/planetary/apod";

module.exports = class Image {
    constructor(date, url) {
        this.date = date;
        this.url = url;
    };

    async getImage(date) {
        const command = new GetSecretValueCommand(getSecretValueInput);
        const secretValue = await secretsManager.send(command);

        var params = {
            date: date,
            api_key: secretValue.SecretString
        };

        try {
            const response = await axios.get(url, {params})
            return response.data;
        } catch (error) {
            console.log(error);
        };
    };
};