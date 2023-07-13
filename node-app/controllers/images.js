const Image = require("../models/image")
const moment = require("moment-timezone");

exports.getTodaysImage = (req, res, next) => {
    const today = moment().tz("America/Chicago").format().slice(0,10);
    res.redirect(`/images/${today}`);
};

exports.getImage = (req, res, next) => {
    const today = moment().tz("America/Chicago").format().slice(0,10);
    const image = new Image;
    var date = req.params.imageDate;
    if (!req.params.imageDate) {
        date = today;
    };
    var prev_date = new Date(date), next_date = new Date(date);
    prev_date.setDate(prev_date.getDate() - 1);
    next_date.setDate(next_date.getDate() + 1);
    (async () => {
        try {
            await image.getImage(date)
            .then((image) => {
                var copyright = "N/A";
                if (copyright in image) {
                    copyright = image.copyright;
                };
                res.render("images/show-image", {
                    date: date,
                    media_type: image.media_type,
                    image: image.url,
                    image_title: image.title,
                    image_description: image.explanation,
                    image_copyright: copyright,
                    pageTitle: "Welcome to my image viewer!",
                    today: today,
                    prev_date: prev_date.toISOString().slice(0,10),
                    next_date: next_date.toISOString().slice(0,10),
                    path: "/"
                });
            });
        } catch (error) {
            console.error(error);
        };
    })()
};