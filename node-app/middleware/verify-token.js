const { CognitoJwtVerifier } = require("aws-jwt-verify");
    
module.exports = (req, res, next) => {
    if (req.session.accessToken) {
        (async() => {
            const verifier = CognitoJwtVerifier.create({
                userPoolId: process.env.USER_POOL_ID,
                tokenUse: "access",
                clientId: process.env.COGNITO_CLIENT_ID,
            });

            const payload = await verifier.verify(req.session.accessToken);
            req.locals.userid = payload.username;
        })();
    };

    next();
};