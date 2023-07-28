const { CognitoIdentityProviderClient, InitiateAuthCommand, GlobalSignOutCommand, SignUpCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { DynamoDBClient, PutItemCommand, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const { validationResult } = require("express-validator");
const { CognitoJwtVerifier } = require("aws-jwt-verify");

const cognitoClient = new CognitoIdentityProviderClient();
const dynamoDBClient = new DynamoDBClient();

exports.getLoginForm = (req, res, next) => {
    res.render("auth/login", {
        pageTitle: "Login",
        errorMessage: req.query.errorMessage,
        today: res.locals.today,
        imageDate: req.session.imageDate,
        isLoggedIn: req.session.isLoggedIn
    });
};

exports.postUserLogin = (req, res, next) => {
    const { email, password } = req.body;
    const { imageDate } = req.session;
    var userId = "";

    (async () => {
        try {
            const input = {
                AuthFlow: "USER_PASSWORD_AUTH",
                AuthParameters: {
                    USERNAME: email,
                    PASSWORD: password
                },
                ClientId: process.env.COGNITO_CLIENT_ID
            };
            const command = new InitiateAuthCommand(input);
            const response = await cognitoClient.send(command)
            .then((response) => {
                req.session.isLoggedIn = true;
                req.session.accessToken = response.AuthenticationResult.AccessToken;
                req.session.refreshToken = response.AuthenticationResult.RefreshToken;
            })
        } catch (error) {
            console.log(error);
            return res.status(401).render("auth/login", {
                pageTitle: "Login",
                errorMessage: "Incorrect username or password, please try again.",
                today: res.locals.today,
                isLoggedIn: req.session.isLoggedIn,
                imageDate: req.session.imageDate,
            });
        };

        // if (req.session.accessToken && req.session.isLoggedIn) {
            const verifier = CognitoJwtVerifier.create({
                userPoolId: process.env.USER_POOL_ID,
                tokenUse: "access",
                clientId: process.env.COGNITO_CLIENT_ID,
            });
            const payload = await verifier.verify(req.session.accessToken)
            .then((response) => {
                userId = response.username;
                exp = new Date(response.exp*1000);
                req.session.cookie.expires = exp;
            });

        try {
            const input = {
                TableName: process.env.DYNAMO_DB_FAVORITES_TABLE_NAME,
                Key: {
                    "userID": {"S": userId}
                }
            };
            const command = new GetItemCommand(input);
            const response = await dynamoDBClient.send(command)
            .then((response) => {
                req.session.favorites = [];
                favorites = response.Item.favorites.L
                for (let i=0; i < favorites.length; i++) {
                    fav_date = response.Item.favorites.L[i].M.date["S"];
                    fav_title = response.Item.favorites.L[i].M.title["S"];
                    fav_url = response.Item.favorites.L[i].M.url["S"];
                    req.session.favorites.push({"date": fav_date, "title": fav_title, "url": fav_url});
                };
                res.redirect(`/images?imageDate=${imageDate}`);
            });
        } catch (error) {
            console.log(error);
            res.render("auth/login", {
                pageTitle: "Login",
                errorMessage: "There was an error logging in, please try again.",
                today: res.locals.today,
                isLoggedIn: req.session.isLoggedIn,
                imageDate: req.session.imageDate,
            });
        };
        // };
    })();
};

exports.postUserLogout = (req, res, next) => {
    const { imageDate } = req.session;
    (async () => {
        const input = {AccessToken: req.session.accessToken};
        const command = new GlobalSignOutCommand(input);
        const response = await cognitoClient.send(command)
        .then(() => {
            req.session.destroy(() => {
                res.redirect(`/images?imageDate=${imageDate}`)
            });
        });
    })();
};

exports.getSignUpForm = (req, res, next) => {
    res.render("auth/signup", {
        pageTitle: "Sign Up",
        errorMessage: req.query.errorMessage,
        today: res.locals.today,
        imageDate: req.session.imageDate,
        isLoggedIn: req.session.isLoggedIn
    });
};

exports.postUserSignUp = (req, res, next) => {
    const { email, password, } = req.body;
    const { imageDate } = req.session;
    const errors = validationResult(req);
    var userId = "";
    if (!errors.isEmpty()) {
      return res.status(422).render('auth/signup', {
        path: '/signup',
        pageTitle: 'Sign Up',
        errorMessage: errors.array(),
        today: res.locals.today,
        isLoggedIn: req.session.isLoggedIn
      });
    }

    (async () => {
        try {
            const input = {
                ClientId: process.env.COGNITO_CLIENT_ID,
                Username: email,
                Password: password,
            };
            const command = new SignUpCommand(input);
            const response = await cognitoClient.send(command)
            .then((response) => {
                userId = response.UserSub
            });
        } catch (error) {
            res.render("auth/signup", {
                imageDate: imageDate,
                pageTitle: "Sign Up",
                errorMessage: "",
                today: res.locals.today,
                isLoggedIn: req.session.isLoggedIn
            });
        };

        try {
            const input = {
                TableName: process.env.DYNAMO_DB_FAVORITES_TABLE_NAME,
                Item: {
                    "userID": {
                        "S": userId
                    },
                    "favorites": {
                        "L": []
                    }
                }
            };
            const command = new PutItemCommand(input);
            const response = await dynamoDBClient.send(command)
            .then(() => {
                res.render("auth/signup-confirm", {
                    imageDate: imageDate,
                    pageTitle: "Sign Up Successful!",
                    today: res.locals.today,
                    isLoggedIn: req.session.isLoggedIn
                });
            });
        } catch (error) {
            console.log(error);
        };
        
    })();
};

exports.getSignupConfirm = (req, res, next) => {
    res.render("auth/signup-confirm", {
        imageDate: imageDate,
        pageTitle: "Sign Up Successful!",
        today: res.locals.today,
        isLoggedIn: req.session.isLoggedIn
    });
};