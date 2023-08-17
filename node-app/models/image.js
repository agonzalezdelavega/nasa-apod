const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const axios = require("axios");

const secretsManager = new SecretsManagerClient();
const getSecretValueInput = {
  SecretId: process.env.API_KEY_SECRET
};
const command = new GetSecretValueCommand(getSecretValueInput);

const url = "https://api.nasa.gov/planetary/apod";

module.exports = class Image {
    constructor(date) {
        this.date = date;
    };
    
    async getImageData() {
        try{
            const secretValue = await secretsManager.send(command);
            var params = {
                date: this.date,
                api_key: secretValue.SecretString
            };  
            const response = await axios.get(url, {params})
            return response.data;
        } catch(error) {
            console.error(error);
        };
    };
};