---
name: dalle-image
description: Generate images using OpenAI's GPT Image / DALL-E API. Use when the user asks to create, generate, draw, or make an image, picture, illustration, logo, icon, or artwork. Requires OPENAI_API_KEY env var.
---

# DALL-E Image Generation

Generate images from text prompts using the OpenAI Images API.

## Usage

Run the generation script with a prompt:

```bash
node /root/clawd/skills/dalle-image/scripts/generate.js "A watercolor painting of a sunset over mountains"
```

### Options

```bash
# Custom size (default: 1024x1024)
node /root/clawd/skills/dalle-image/scripts/generate.js "prompt" --size 1792x1024

# Custom model (default: gpt-image-1)
node /root/clawd/skills/dalle-image/scripts/generate.js "prompt" --model gpt-image-1

# Custom output path
node /root/clawd/skills/dalle-image/scripts/generate.js "prompt" --output /path/to/image.png

# High quality
node /root/clawd/skills/dalle-image/scripts/generate.js "prompt" --quality hd
```

### Supported Sizes

- `1024x1024` (square, default)
- `1792x1024` (landscape)
- `1024x1792` (portrait)

### Supported Models

- `gpt-image-1` (default, best quality)

## Workflow

1. User requests an image with a description
2. Run the generate script with the prompt
3. The script saves the image as a PNG file and prints the path
4. Share the generated image file with the user

## Important Notes

- The script requires `OPENAI_API_KEY` to be set in the environment
- Images are saved to `~/clawd/media/generated/` by default
- Each image filename includes a timestamp for uniqueness
- The script outputs the absolute path to the saved file on success
