const axios = require("axios");
const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm")

const ssm_client = new SSMClient();
const url = "https://api.nasa.gov/planetary/apod";

module.exports = class Image {
    constructor(id, url) {
        this.id = id;
        this.url = url;
    };

    async getImage(date) {

        const input = {
            Name: "nasa-api-key"
        };
        const command = new GetParameterCommand(input);
        const response = await ssm_client.send(command);

        const params = {
            date: date,
            api_key: response.Parameter.Value,
        };

        try {
            const response = await axios.get(url, {params});
            return response.data;
        } catch (error) {
            console.log(error);
        };
    };
};