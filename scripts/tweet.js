const crypto = require('crypto');
const https = require('https');

const config = {
  consumer_key: 'RHFKmtl9ltgziXlwZkgPQikFN',
  consumer_secret: 'DDe5brZPhIlcSB3v09mLU78mQIK0ezQyTyY5DcTl703GN6UL2m',
  access_token: '2018824194361053185-9dDGDzpR9ByoWm3hwJCDXnmuoCdINw',
  access_token_secret: '6DRXZEZNNOdePZpi6U5cl5tH66cX2h7e8ZXGNfiKdzWHV'
};

const tweet = process.argv[2] || 'Test tweet';

function percentEncode(str) {
  return encodeURIComponent(str).replace(/[!'()*]/g, c => '%' + c.charCodeAt(0).toString(16).toUpperCase());
}

function generateOAuthSignature(method, url, params, consumerSecret, tokenSecret) {
  const sortedParams = Object.keys(params).sort().map(k => `${k}=${percentEncode(params[k])}`).join('&');
  const baseString = `${method}&${percentEncode(url)}&${percentEncode(sortedParams)}`;
  const signingKey = `${percentEncode(consumerSecret)}&${percentEncode(tokenSecret)}`;
  return crypto.createHmac('sha1', signingKey).update(baseString).digest('base64');
}

const url = 'https://api.twitter.com/2/tweets';
const method = 'POST';
const timestamp = Math.floor(Date.now() / 1000).toString();
const nonce = crypto.randomBytes(16).toString('hex');

const oauthParams = {
  oauth_consumer_key: config.consumer_key,
  oauth_nonce: nonce,
  oauth_signature_method: 'HMAC-SHA1',
  oauth_timestamp: timestamp,
  oauth_token: config.access_token,
  oauth_version: '1.0'
};

const signature = generateOAuthSignature(method, url, oauthParams, config.consumer_secret, config.access_token_secret);
oauthParams.oauth_signature = signature;

const authHeader = 'OAuth ' + Object.keys(oauthParams).sort().map(k => `${percentEncode(k)}="${percentEncode(oauthParams[k])}"`).join(', ');

const body = JSON.stringify({ text: tweet });

const req = https.request(url, {
  method: 'POST',
  headers: {
    'Authorization': authHeader,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body)
  }
}, res => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log(data));
});

req.on('error', e => console.error(e));
req.write(body);
req.end();