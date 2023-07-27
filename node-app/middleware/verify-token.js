const { CognitoIdentityProviderClient, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { CognitoJwtVerifier } = require("aws-jwt-verify");

const client = new CognitoIdentityProviderClient();
    
module.exports = (req, res, next) => {
    if (req.session.accessToken) {
        const currentTime = new Date();
        req.session.cookie._expires = new Date(1658865607000);
        if (currentTime > req.session.cookie._expires) {
            (async() => {
                const input = {
                    AuthFlow: "REFRESH_TOKEN_AUTH",
                    AuthParameters: {"REFRESH_TOKEN": req.session.refreshToken},
                    ClientId: process.env.COGNITO_CLIENT_ID
                };
                const command = new InitiateAuthCommand(input);
                const response = await client.send(command)
                .then((response) => {
                    req.session.accessToken = response.AuthenticationResult.AccessToken;
                });
            })();
        };

        (async() => {
            const verifier = CognitoJwtVerifier.create({
                userPoolId: process.env.USER_POOL_ID,
                tokenUse: "access",
                clientId: process.env.COGNITO_CLIENT_ID,
            });

            const payload = await verifier.verify(req.session.accessToken)
            .then((response) => {
                exp = new Date(response.exp*1000);
                req.session.cookie.expires = exp;
                res.locals.userid = response.username;
                next();
            });
        })();
    } else {
        next();
    };
};