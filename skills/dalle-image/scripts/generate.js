#!/usr/bin/env node
'use strict';

const https = require('https');
const fs = require('fs');
const path = require('path');

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
if (!OPENAI_API_KEY) {
  console.error('Error: OPENAI_API_KEY environment variable is not set');
  process.exit(1);
}

// Parse arguments
const args = process.argv.slice(2);
if (args.length === 0 || args[0] === '--help') {
  console.log('Usage: generate.js "prompt" [--size 1024x1024] [--model gpt-image-1] [--quality standard] [--output path.png]');
  process.exit(args[0] === '--help' ? 0 : 1);
}

const prompt = args[0];
const getFlag = (flag, fallback) => {
  const idx = args.indexOf(flag);
  return idx !== -1 && args[idx + 1] ? args[idx + 1] : fallback;
};

const size = getFlag('--size', '1024x1024');
const model = getFlag('--model', 'gpt-image-1');
const quality = getFlag('--quality', 'standard');

// Output path
const outputDir = path.join(process.env.HOME || '/root', 'clawd', 'media', 'generated');
const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
const defaultOutput = path.join(outputDir, `image-${timestamp}.png`);
const outputPath = getFlag('--output', defaultOutput);

// Ensure output directory exists
fs.mkdirSync(path.dirname(outputPath), { recursive: true });

// gpt-image-1 returns b64_json by default and rejects explicit response_format
const body = JSON.stringify({
  model,
  prompt,
  n: 1,
  size,
  quality,
});

const req = https.request({
  hostname: 'api.openai.com',
  path: '/v1/images/generations',
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${OPENAI_API_KEY}`,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body),
  },
}, (res) => {
  let data = '';
  res.on('data', (chunk) => { data += chunk; });
  res.on('end', () => {
    if (res.statusCode !== 200) {
      console.error(`API error (${res.statusCode}): ${data}`);
      process.exit(1);
    }

    let parsed;
    try {
      parsed = JSON.parse(data);
    } catch (e) {
      console.error('Failed to parse API response:', e.message);
      process.exit(1);
    }

    const imageData = parsed.data?.[0]?.b64_json;
    if (!imageData) {
      console.error('No image data in response:', JSON.stringify(parsed, null, 2));
      process.exit(1);
    }

    const buffer = Buffer.from(imageData, 'base64');
    fs.writeFileSync(outputPath, buffer);
    console.log(outputPath);

    if (parsed.data[0].revised_prompt) {
      console.error(`Revised prompt: ${parsed.data[0].revised_prompt}`);
    }
  });
});

req.on('error', (e) => {
  console.error(`Request failed: ${e.message}`);
  process.exit(1);
});

req.write(body);
req.end();
