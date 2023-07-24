const { CognitoIdentityProviderClient, InitiateAuthCommand, GlobalSignOutCommand, SignUpCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { validationResult } = require("express-validator");

const client = new CognitoIdentityProviderClient();

exports.getLoginForm = (req, res, next) => {
    res.render("auth/login", {
        pageTitle: "Login",
        errorMessage: req.query.errorMessage,
        today: res.locals.today,
        isLoggedIn: req.session.isLoggedIn
    });
};

exports.postUserLogin = (req, res, next) => {
    const { email, password } = req.body;
    const { imageDate } = req.session;
    
    // Input and command for API call
    const input = {
        AuthFlow: "USER_PASSWORD_AUTH",
        AuthParameters: {
            USERNAME: email,
            PASSWORD: password
        },
        ClientId: process.env.COGNITO_CLIENT_ID
    };

    const command = new InitiateAuthCommand(input);

    // Verify User
    (async () => {
        try {
            const response = await client.send(command)
            .then((response) => {
                req.session.isLoggedIn = true;
                req.session.accessToken = response.AuthenticationResult.AccessToken;
                res.redirect(`/images/${imageDate}`);
            });
        } catch (error) {
            res.render("auth/login", {
                pageTitle: "Login",
                errorMessage: "Incorrect username or password, please try again.",
                today: res.locals.today,
                isLoggedIn: req.session.isLoggedIn
            });
        };
    })();
};

exports.postUserLogout = (req, res, next) => {
    const { imageDate } = req.session;
    (async () => {
        const input = {AccessToken: req.session.accessToken};
        const command = new GlobalSignOutCommand(input);
        const response = await client.send(command)
        .then(() => {
            req.session.destroy(() => {
                res.redirect(`/images/${imageDate}`)
            });
        });
    })();
};

exports.getSignUpForm = (req, res, next) => {
    res.render("auth/signup", {
        pageTitle: "Sign Up",
        errorMessage: req.query.errorMessage,
        today: res.locals.today,
        isLoggedIn: req.session.isLoggedIn
    });
};

exports.postUserSignUp = (req, res, next) => {
    const { email, password, } = req.body;
    const { imageDate } = req.session;
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).render('auth/signup', {
        path: '/signup',
        pageTitle: 'Sign Up',
        errorMessage: errors.array(),
        today: res.locals.today,
        isLoggedIn: req.session.isLoggedIn
      });
    }

    const input = {
        ClientId: process.env.COGNITO_CLIENT_ID,
        Username: email,
        Password: password,
    };
    const command = new SignUpCommand(input);
    (async () => {
        try {
            const response = await client.send(command)
            .then((response) => {
                res.render("auth/signup-confirm", {
                    imageDate: imageDate,
                    pageTitle: "Sign Up Successful!",
                    today: res.locals.today,
                    isLoggedIn: req.session.isLoggedIn
                });
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