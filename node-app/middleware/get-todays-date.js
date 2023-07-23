module.exports = (req, res, next) => {
    res.locals.today = global.moment().tz("America/Chicago").format().slice(0,10);
    next();
};