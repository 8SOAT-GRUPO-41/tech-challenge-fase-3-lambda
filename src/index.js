module.exports.handler = async (event) => {
    const { headers = {} } = event;
    const token = headers.authorization || '';
  
    return {
      isAuthorized: token === 'allow',
      context: {
        authorizationStatus: token === 'allow' ? 'Authorized' : 'Unauthorized'
      }
    };
  };
  