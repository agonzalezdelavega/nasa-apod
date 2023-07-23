const Image = require("../models/image");

exports.getTodaysImage = (req, res, next) => {
    res.redirect(`/images/${res.locals.today}`)
};

exports.getImage = (req, res, next) => {
    const image = new Image;
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
                res.render("images/show-image", {
                    imageDate: imageDate,
                    media_type: image.media_type,
                    image: image.url,
                    image_title: image.title,
                    image_description: image.explanation,
                    image_copyright: copyright,
                    pageTitle: "Welcome to my image viewer!",
                    today: res.locals.today,
                    prevDate: prevDate.toISOString().slice(0,10),
                    nextDate: nextDate.toISOString().slice(0,10),
                    isLoggedIn: req.session.isLoggedIn
                });
            });
        } catch (error) {
            console.error(error);
        };
    })()
};