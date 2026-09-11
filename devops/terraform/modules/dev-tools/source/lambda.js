exports.handler = async (event) => {
  // console.log(event)
  // Extract common fields with fallbacks to support ALB and other Lambda Proxy event formats
  const method = event?.requestContext?.http?.method || event?.requestContext?.httpMethod || event?.method;
  const path = event?.requestContext?.http?.path || event?.requestContext?.path || event?.path;

  const headers = event?.headers || event?.requestContext?.headers || [];
  const body = event?.body || event?.requestContext?.body || null;
  const queryStringParameters = event?.queryStringParameters || event?.requestContext?.queryStringParameters || {};

  const identity = event?.requestContext?.identity || { sourceIp: null };

  // Build a generic requestContext object similar to the example provided
  const requestContext = {
    domainName: event?.requestContext?.domainName || '',
    domainPrefix: '',
    httpMethod: method,
    identity,
    path,
    protocol: event?.requestContext?.protocol || 'HTTP/1.1',
    requestTime: new Date().toISOString(),
    requestTimeEpoch: Date.now(),
    resourceId: `${method} ${path}`,
    resourcePath: path,
  };

  // Default response wrapper
  const response = {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ headers, body, queryStringParameters, requestContext }),
  };

  // Special handling for specific paths
  if (path === '/ip') {
    const ip = headers['x-forwarded-for'] || null;
    response.body = ip;
  } else if (path === '/notfound') {
    response.statusCode = 404;
    response.body = JSON.stringify({ error: 'Not found' });
  }
  // response.body = JSON.stringify(event);

  return response;
};