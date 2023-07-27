exports.getFavorites = (req, res, next) => {
    res.render("favorites/view-favorites", {
        imageDate: req.session.imageDate,
        pageTitle: "Favorites",
        today: res.locals.today,
        isLoggedIn: req.session.isLoggedIn,
        favorites: req.session.favorites
    });
};