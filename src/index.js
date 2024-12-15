const generatePolicy = (principalId, effect, resource) => {
    if (!effect || !resource) {
        return { principalId };
    }
    return {
        principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [
                {
                    Action: 'execute-api:Invoke',
                    Effect: effect,
                    Resource: resource,
                },
            ],
        },
    };
};

module.exports.handler = (event, context, callback) => {
    const { authorizationToken, methodArn } = event;

    if (authorizationToken === 'allow') {
        const policy = generatePolicy('user', 'Allow', methodArn);
        callback(null, policy);
    } else {
        callback('Unauthorized');
    }
};
