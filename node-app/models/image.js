const axios = require("axios");

const url = "https://api.nasa.gov/planetary/apod";

module.exports = class Image {
    constructor(date, url) {
        this.date = date;
        this.url = url;
    };

    async getImage(date) {
        var params = {
            date: date,
            api_key: process.env.API_KEY
        };

        try {
            const response = await axios.get(url, {params})
            return response.data;
        } catch (error) {
            console.log(error);
        };
    };
};