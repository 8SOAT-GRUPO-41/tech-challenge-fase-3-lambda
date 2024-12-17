const jwt = require("jsonwebtoken");
const jwksClient = require("jwks-rsa");

const cognitoUserPoolId = process.env.COGNITO_USER_POOL_ID;

const client = jwksClient({
  jwksUri: `https://cognito-idp.us-east-1.amazonaws.com/${cognitoUserPoolId}/.well-known/jwks.json`,
});

const getKey = (header, callback) => {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.getPublicKey();
    callback(null, signingKey);
  });
};

module.exports.handler = async (event) => {
  const { headers = {} } = event;
  const token = headers.authorization?.split(" ")[1];

  if (!token) {
    return {
      isAuthorized: false,
      context: {
        authorizationStatus: "Unauthorized",
        message: "Token is missing.",
      },
    };
  }

  try {
    const decoded = await new Promise((resolve, reject) => {
      jwt.verify(token, getKey, {}, (err, decoded) => {
        if (err) {
          reject(err);
        } else {
          resolve(decoded);
        }
      });
    });
    const username = decoded.username || decoded.sub;

    return {
      isAuthorized: true,
      context: {
        authorizationStatus: "Authorized",
        username,
        message: "Token is valid.",
      },
    };
  } catch (err) {
    console.error("Token Verification Failed:", err.message);
    return {
      isAuthorized: false,
      context: {
        authorizationStatus: "Unauthorized",
        message: "Token is invalid.",
      },
    };
  }
};
