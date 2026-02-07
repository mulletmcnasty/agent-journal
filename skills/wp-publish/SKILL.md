---
name: wp-publish
version: 2.3.0
description: When the user wants to publish content to a WordPress site. Also use when the user mentions "publish to WordPress," "WordPress post," "wp publish," "blog post to WordPress," "create WordPress post," "upload to WordPress," "publish article," "WordPress draft," "push to WordPress," "add WordPress site," "list WordPress sites," "remove WordPress site," "wp sites," "WordPress comments," "content health," "content calendar," "site stats," "bulk publish," "WordPress backup," or "WordPress export." This skill publishes content via the WordPress REST API, supporting multiple sites, posts, pages, media uploads, categories, tags, featured images, SEO metadata (Yoast/RankMath), comments management, content health scoring, content calendar, site stats, bulk operations, and backup/export. Chains with content-pipeline output. **Now includes automatic image optimization** via image-optimize skill.
---

# WordPress Publish

You are an expert WordPress publishing assistant. Your goal is to take content (raw text, HTML, or a content-pipeline artifact) and publish it to one or more WordPress sites via the REST API using `curl`. You support managing multiple WordPress sites per user.

**Image Optimization:** This skill automatically optimizes featured images before upload using the image-optimize skill, reducing file sizes by 60-90% while maintaining quality. This dramatically improves Core Web Vitals (LCP) performance.

## Initial Assessment

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before doing anything else, **load the site configuration** (see Site Configuration below).

Then understand:

1. **Which site?** — If the user names a site, use it. If not, use the default. If no sites configured, help them add one.

2. **Content Source**
   - Is this a new post to write from scratch?
   - An existing HTML artifact from content-pipeline (in `~/clawd/canvas/`)?
   - Raw text or markdown to convert?

3. **Publication Settings**
   - Publish immediately, or save as **draft** for review? (default: draft)
   - Post type: post or page?
   - Category and tag assignments?
   - Featured image: **always generate one automatically** unless the user says "no image" or provides their own file

4. **SEO (if Yoast or RankMath installed)**
   - Target keyword?
   - Custom meta title and description?

---

## Site Configuration

### Multi-Site Config File

WordPress sites are stored in `~/clawd/.wp-sites.json`. Each ClawdBot user (Seth, Curtis, etc.) has their own file in their own workspace — no shared credentials.

**At the start of every wp-publish invocation, read the config:**
```bash
cat ~/clawd/.wp-sites.json 2>/dev/null || echo '{"sites":{}}'
```

**Config file format:**
```json
{
  "default": "memberpress",
  "sites": {
    "memberpress": {
      "url": "https://801website.com/membepress",
      "username": "seth",
      "app_password": "xxxx xxxx xxxx xxxx xxxx xxxx",
      "description": "MemberPress test site"
    },
    "sethshoultes": {
      "url": "https://sethshoultes.com",
      "username": "admin",
      "app_password": "yyyy yyyy yyyy yyyy yyyy yyyy",
      "description": "Personal blog"
    },
    "caseproof": {
      "url": "https://caseproof.com",
      "username": "seth",
      "app_password": "zzzz zzzz zzzz zzzz zzzz zzzz",
      "description": "Company site"
    }
  }
}
```

### Fallback: Environment Variables

If `~/clawd/.wp-sites.json` doesn't exist or is empty, fall back to env vars from `clawdbot.json`:
```bash
echo "WP_SITE_URL=$WP_SITE_URL"
echo "WP_USERNAME is $([ -n "$WP_USERNAME" ] && echo 'set' || echo 'NOT SET')"
echo "WP_APP_PASSWORD is $([ -n "$WP_APP_PASSWORD" ] && echo 'set' || echo 'NOT SET')"

# Create secure auth file from env vars — credentials never in process args
WP_AUTH_FILE=$(umask 077; mktemp /tmp/wp-auth-XXXXXX)
trap 'rm -f "$WP_AUTH_FILE"' EXIT
printf -- '--user %s:%s\n' "$WP_USERNAME" "$WP_APP_PASSWORD" > "$WP_AUTH_FILE"
```

If env vars are set, treat them as a single site named "default".

### Inline Override

If the user provides credentials directly in the chat prompt, use those instead of config file or env vars.

### Site Selection

When the user invokes wp-publish:
1. If they name a site (e.g., "publish to memberpress"), use that site
2. If they don't name a site and there's a `default`, use the default
3. If they don't name a site and there's no default but only one site, use that one
4. If there are multiple sites and no default, **list available sites and ask which one**

---

## Site Management Commands

The user can manage their WordPress sites through natural language. When they ask to add, remove, list, or update sites, handle it directly.

### List Sites

When the user asks to list, show, or view their WordPress sites:

```bash
cat ~/clawd/.wp-sites.json 2>/dev/null | jq '{default, sites: (.sites | to_entries | map({key, url: .value.url, description: .value.description}))}'
```

Display as a formatted list:
```
WordPress Sites:
  * memberpress (default) — https://801website.com/membepress — MemberPress test site
    sethshoultes — https://sethshoultes.com — Personal blog
    caseproof — https://caseproof.com — Company site
```

### Add a Site

When the user asks to add a WordPress site, collect:
- **Site name** (short, no spaces, used as key — e.g., "memberpress", "myblog")
- **URL** (no trailing slash)
- **Username**
- **Application Password** (with spaces)
- **Description** (optional, one-liner)
- **Set as default?**

Then write to the config:
```bash
# Ensure config file exists
[ -f ~/clawd/.wp-sites.json ] || echo '{"sites":{}}' > ~/clawd/.wp-sites.json

# Add the new site using jq (reads file directly — no echo-pipe)
jq --arg name "SITE_NAME" \
  --arg url "https://example.com" \
  --arg user "admin" \
  --arg pass "xxxx xxxx xxxx xxxx xxxx xxxx" \
  --arg desc "Site description" \
  '.sites[$name] = {url: $url, username: $user, app_password: $pass, description: $desc}' \
  ~/clawd/.wp-sites.json > /tmp/wp-sites-tmp.json && mv /tmp/wp-sites-tmp.json ~/clawd/.wp-sites.json

# Optionally set as default
jq '.default = "SITE_NAME"' ~/clawd/.wp-sites.json > /tmp/wp-sites-tmp.json && mv /tmp/wp-sites-tmp.json ~/clawd/.wp-sites.json
```

After adding, verify connectivity:
```bash
# Create temp auth file for verification — credentials never in process args
WP_AUTH_FILE=$(umask 077; mktemp /tmp/wp-auth-XXXXXX)
trap 'rm -f "$WP_AUTH_FILE"' EXIT
jq -r '.sites["SITE_NAME"] | "--user " + .username + ":" + .app_password' \
  ~/clawd/.wp-sites.json > "$WP_AUTH_FILE"

curl -s -o /dev/null -w "%{http_code}" \
  -K "$WP_AUTH_FILE" "URL/wp-json/wp/v2/posts?per_page=1"
```

### Remove a Site

```bash
jq 'del(.sites["SITE_NAME"])' ~/clawd/.wp-sites.json > /tmp/wp-sites-tmp.json && mv /tmp/wp-sites-tmp.json ~/clawd/.wp-sites.json
```

If the removed site was the default, clear the default and tell the user.

### Set Default Site

```bash
jq '.default = "SITE_NAME"' ~/clawd/.wp-sites.json > /tmp/wp-sites-tmp.json && mv /tmp/wp-sites-tmp.json ~/clawd/.wp-sites.json
```

### Test All Sites

When the user asks to test connections:
```bash
WP_AUTH_FILE=$(umask 077; mktemp /tmp/wp-auth-XXXXXX)
trap 'rm -f "$WP_AUTH_FILE"' EXIT

for site in $(jq -r '.sites | keys[]' ~/clawd/.wp-sites.json); do
  URL=$(jq -r ".sites[\"$site\"].url" ~/clawd/.wp-sites.json)
  jq -r ".sites[\"$site\"] | \"--user \" + .username + \":\" + .app_password" \
    ~/clawd/.wp-sites.json > "$WP_AUTH_FILE"
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -K "$WP_AUTH_FILE" "$URL/wp-json/wp/v2/posts?per_page=1")
  echo "$site: $URL — $CODE"
done
```

---

## Core Workflow

### Step 0: Load Site Config

Read `~/clawd/.wp-sites.json` and select the target site (see Site Selection above). Set variables for the rest of the workflow:
```bash
SITE_NAME="the-selected-site"
WP_SITE_URL=$(jq -r ".sites[\"$SITE_NAME\"].url" ~/clawd/.wp-sites.json)

# Create secure auth file — credentials never in shell vars or process args
WP_AUTH_FILE=$(umask 077; mktemp /tmp/wp-auth-XXXXXX)
trap 'rm -f "$WP_AUTH_FILE"' EXIT
jq -r ".sites[\"$SITE_NAME\"] | \"--user \" + .username + \":\" + .app_password" \
  ~/clawd/.wp-sites.json > "$WP_AUTH_FILE"
```

### Step 1: Validate Connection

```bash
curl -s -o /dev/null -w "%{http_code}" \
  -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=1"
```

Also check which plugins are available for SEO:
```bash
# Check for Yoast
curl -s -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/yoast/v1/get_head?url=${WP_SITE_URL}" \
  -o /dev/null -w "%{http_code}"

# Check for RankMath
curl -s -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/rankmath/v1/getHead?url=${WP_SITE_URL}" \
  -o /dev/null -w "%{http_code}"
```

### Step 2: Prepare Content

**If from content-pipeline artifact (HTML file in `~/clawd/canvas/`):**
1. Read the HTML file
2. Extract the article body content (inside `<article>` or `<main>` tags)
3. Convert to WordPress-compatible HTML (Gutenberg block format preferred)
4. Extract title, excerpt, and meta description from the article

**If from raw text or markdown:**
1. Convert markdown to HTML
2. Wrap in Gutenberg block markup:
   - Paragraphs: `<!-- wp:paragraph --><p>text</p><!-- /wp:paragraph -->`
   - Headings: `<!-- wp:heading {"level":2} --><h2>text</h2><!-- /wp:heading -->`
   - Lists: `<!-- wp:list --><ul><li>text</li></ul><!-- /wp:list -->`
   - Images: `<!-- wp:image --><figure class="wp-block-image"><img src="URL" alt="alt"/></figure><!-- /wp:image -->`
   - Blockquotes: `<!-- wp:quote --><blockquote class="wp-block-quote"><p>text</p></blockquote><!-- /wp:quote -->`

**If writing from scratch:**
1. Ask for the topic, angle, and key points
2. Draft the content
3. Format as Gutenberg blocks

### Step 3: Handle Categories and Tags

**List existing categories:**
```bash
curl -s -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/categories?per_page=100" \
  | jq '.[] | {id, name, slug}'
```

**Create a new category if needed:**
```bash
curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/categories" \
  -H "Content-Type: application/json" \
  -d '{"name": "Category Name", "slug": "category-slug"}'
```

**List existing tags:**
```bash
curl -s -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/tags?per_page=100&search=keyword" \
  | jq '.[] | {id, name}'
```

**Create a new tag if needed:**
```bash
curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/tags" \
  -H "Content-Type: application/json" \
  -d '{"name": "Tag Name"}'
```

### Step 4: Generate & Upload Featured Image

**Always generate a featured image** unless the user explicitly says "no image" or provides their own image file.

**4a. Craft the image prompt:**

Based on the post title and content, create a descriptive image generation prompt:
- Describe a scene that visually represents the article's main topic
- Style: professional illustration, modern, clean, suitable for a blog header
- Orientation: landscape (wider than tall — ideal for WordPress featured images and social sharing)
- Avoid: text/words in the image, faces of real people, brand logos

**Prompt pattern:**
```
professional illustration of [topic visual metaphor], [2-3 style details], [color palette], modern digital art style, clean composition, landscape orientation, suitable for blog featured image
```

**4b. Generate the image:**

Spawn a subagent to generate the image:
```
sessions_spawn: "Generate a single image: [crafted prompt]. Save the output image file to /tmp/wp-featured-image.png"
```

Wait for the subagent to complete and confirm the image file exists:
```bash
ls -la /tmp/wp-featured-image.png 2>/dev/null || ls -la /tmp/wp-featured-image.* 2>/dev/null
```

If the image was saved to a different path or filename, use whatever path the subagent reported.

**4c. Optimize the generated image:**

Before uploading, optimize the image for web performance:

```bash
# Detect the generated image
IMG_FILE=$(ls /tmp/wp-featured-image.* 2>/dev/null | head -1)

# Optimize to WebP format (60-90% size reduction)
python3 ~/.clawdbot/skills/image-optimize/scripts/optimize.py \
  "$IMG_FILE" \
  /tmp/wp-featured-image-optimized.webp \
  --quality 85 \
  --max-width 2400

# Use optimized file for upload
IMG_FILE="/tmp/wp-featured-image-optimized.webp"
IMG_NAME="featured-image-optimized.webp"
MIME="image/webp"
```

**Why optimize:** AI-generated images (DALL-E, etc.) are often 2-3 MB. Optimization reduces them to 150-300 KB (80-90% smaller) with imperceptible quality loss, dramatically improving LCP (Largest Contentful Paint).

**If optimization fails** (e.g., image-optimize skill not installed), fall back to uploading the original:

```bash
if [ ! -f /tmp/wp-featured-image-optimized.webp ]; then
  echo "⚠️  Optimization failed, uploading original"
  IMG_FILE=$(ls /tmp/wp-featured-image.* 2>/dev/null | head -1)
  IMG_NAME=$(basename "$IMG_FILE")
  IMG_EXT="${IMG_NAME##*.}"
  case "$IMG_EXT" in
    png)  MIME="image/png" ;;
    jpg|jpeg) MIME="image/jpeg" ;;
    webp) MIME="image/webp" ;;
    *)    MIME="image/png" ;;
  esac
fi
```

**4d. Upload to WordPress media library:**

```bash
curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/media" \
  -H "Content-Disposition: attachment; filename=${IMG_NAME}" \
  -H "Content-Type: ${MIME}" \
  --data-binary @"${IMG_FILE}"
```

Save the returned `id` for use as `featured_media` in the post.

**4e. Set alt text on the uploaded image:**

```bash
curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/media/{MEDIA_ID}" \
  -H "Content-Type: application/json" \
  -d '{"alt_text": "Descriptive alt text based on article topic"}'
```

**If image generation fails:** Continue without a featured image — don't block the post. Tell the user the image failed and they can upload one manually in WordPress.

### Step 5: Create the Post

Write the post JSON to a temporary file to avoid shell escaping issues:

```bash
cat > /tmp/wp-post.json << 'POSTEOF'
{
  "title": "Post Title Here",
  "content": "<!-- wp:paragraph --><p>Content here</p><!-- /wp:paragraph -->",
  "excerpt": "Brief summary for archives and search results",
  "status": "draft",
  "categories": [1, 5],
  "tags": [10, 15],
  "featured_media": 123,
  "slug": "post-url-slug"
}
POSTEOF

curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/posts" \
  -H "Content-Type: application/json" \
  -d @/tmp/wp-post.json
```

**Status options:** `draft` (default), `publish`, `pending` (for review), `private`

Save the returned post `id` and `link` for the next steps.

### Step 6: Set SEO Metadata (if Yoast or RankMath detected)

**Yoast SEO:**
```bash
curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "_yoast_wpseo_title": "SEO Title — %%sitename%%",
      "_yoast_wpseo_metadesc": "Meta description under 160 chars",
      "_yoast_wpseo_focuskw": "target keyword"
    }
  }'
```

**RankMath SEO:**
```bash
curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "rank_math_title": "SEO Title %sep% %sitename%",
      "rank_math_description": "Meta description under 160 chars",
      "rank_math_focus_keyword": "target keyword"
    }
  }'
```

### Step 7: Confirm and Report

After creating the post, report back to the user:

- **Site:** Which WordPress site was used (by name)
- **Post ID:** The WordPress post ID
- **Status:** Draft, Published, or Pending Review
- **Edit URL:** `${WP_SITE_URL}/wp-admin/post.php?post={POST_ID}&action=edit`
- **View URL:** The post permalink (from the API response `link` field)
- **Categories and tags** assigned
- **Featured image** (generated prompt, media ID, and alt text)
- **SEO metadata** (if set)

If status is `draft`, remind the user: "The post is saved as a draft. Log into WordPress to review and publish when ready."

---

## Publishing a Content-Pipeline Artifact

When chaining with the content-pipeline skill:

1. User runs content-pipeline to create an article → HTML saved to `~/clawd/canvas/article-*.html`
2. User invokes wp-publish, referencing the artifact and optionally naming a target site
3. wp-publish reads the HTML, extracts the article body, title, and excerpt
4. Converts inline-styled HTML to Gutenberg blocks (strip `<style>` tags, keep semantic HTML)
5. Generates a featured image based on the article topic (Step 4 above)
6. Creates the WordPress post as a draft on the selected site with featured image attached
7. Reports the draft URL for review

**Conversion rules for content-pipeline HTML:**
- `<h2>` → `<!-- wp:heading {"level":2} --><h2>text</h2><!-- /wp:heading -->`
- `<h3>` → `<!-- wp:heading {"level":3} --><h3>text</h3><!-- /wp:heading -->`
- `<p>` → `<!-- wp:paragraph --><p>text</p><!-- /wp:paragraph -->`
- `<blockquote>` → `<!-- wp:quote --><blockquote class="wp-block-quote"><p>text</p></blockquote><!-- /wp:quote -->`
- `<ul>/<ol>` → `<!-- wp:list --><ul>items</ul><!-- /wp:list -->`
- `<figure><img>` → `<!-- wp:image --><figure class="wp-block-image"><img src="..." alt="..."/></figure><!-- /wp:image -->`
- Strip all `<style>`, `<script>`, `<header>`, `<footer>`, `<nav>` tags
- Strip inline `style` attributes
- Preserve `<a>` links, `<strong>`, `<em>` formatting

---

## Publishing to Multiple Sites

The user can publish the same content to multiple sites in one request:

"Publish this article to memberpress and sethshoultes as drafts"

For each site:
1. Load credentials from the config
2. Create categories/tags if needed (each site has its own)
3. Create the post
4. Report results for each site

---

## Creating Pages (instead of posts)

For WordPress pages, use the pages endpoint:

```bash
curl -s -X POST -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/pages" \
  -H "Content-Type: application/json" \
  -d @/tmp/wp-post.json
```

Pages don't support categories or tags but do support `parent` (page hierarchy) and `template` (page template slug).

---

## Output Format

### Chat Summary
After publishing, provide:
- Site name and URL
- Post title and status
- WordPress edit URL and preview URL
- Categories and tags assigned
- Featured image (generated prompt and media ID)
- SEO metadata summary (if set)
- Next steps (review draft, publish)

---

## Error Handling

| HTTP Code | Meaning | Fix |
|---|---|---|
| 401 | Authentication failed | Check username and app_password in wp-sites.json |
| 403 | Insufficient permissions | User needs Editor or Administrator role |
| 404 | Endpoint not found | Check site URL, ensure REST API is enabled |
| 400 | Bad request | Check JSON syntax, required fields |
| 413 | File too large | Reduce image size before uploading |
| 500 | Server error | Check WordPress error logs |

If the REST API returns an error, show the full error response to the user and suggest a fix.

---

## Task-Specific Questions

1. Which WordPress site? (if multiple configured and none specified)
2. What content should be published? (topic, existing file, or content-pipeline artifact)
3. Post or page?
4. Publish immediately or save as draft? (default: draft)
5. Categories and tags to assign?
6. Featured image to upload?
7. SEO keyword and meta description? (if Yoast/RankMath installed)

---

## Comments Management

Manage WordPress comments directly from the CLI using `scripts/wp-rest.sh`.

### List and Moderate Comments

```bash
# List approved comments
./scripts/wp-rest.sh list-comments --site=mysite

# List pending (held for moderation)
./scripts/wp-rest.sh pending-comments --site=mysite

# Approve a comment
./scripts/wp-rest.sh approve-comment 42 --site=mysite

# Mark as spam
./scripts/wp-rest.sh spam-comment 42 --site=mysite

# Delete a comment (move to trash)
./scripts/wp-rest.sh delete-comment 42 --site=mysite

# Permanently delete
./scripts/wp-rest.sh delete-comment 42 true --site=mysite
```

### Reply to a Comment

```bash
./scripts/wp-rest.sh reply-comment 42 "Thanks for the feedback!" --site=mysite
```

This creates a new comment as a child of comment #42 on the same post.

### Bulk Approve All Pending Comments

```bash
./scripts/wp-rest.sh bulk-approve-comments --site=mysite
```

Approves all comments currently in "hold" status.

---

## Content Health Check

Score any post's content quality on a 0-100 scale (A-F grade). Checks title length, word count, excerpt, featured image, categories, tags, subheadings, links, and inline images.

```bash
./scripts/wp-rest.sh health-check 123 --site=mysite
```

**Output example:**
```
=== Content Health Check: Post #123 ===
Title: How to Build a WordPress Plugin
Slug: how-to-build-a-wordpress-plugin
Words: 1247

Score: 85/100 (B)

PASS:
  + Title length OK (38 chars)
  + Word count: 1247 (good)
  + Has excerpt
  + Has featured image
  + Categorized (2)
  + Tagged (5)
  + Has 4 subheadings

ISSUES:
  - No images in content body
```

**Scoring breakdown:**

| Check | Points | Criteria |
|---|---|---|
| Title length | 20 | 10-70 chars = full, any other = half |
| Word count | 20 | 300+ = full, 100+ = half |
| Excerpt | 10 | Present and 10+ chars |
| Featured image | 15 | Has featured_media |
| Categories | 10 | At least 1 assigned |
| Tags | 5 | At least 1 assigned |
| Subheadings | 10 | 2+ H2/H3/H4 = full, 1 = half |
| Links | 5 | At least 1 link in content |
| Content images | 5 | At least 1 img tag in body |

---

## Content Calendar

View published, scheduled, and draft posts for a given month.

```bash
# Current month
./scripts/wp-rest.sh calendar --site=mysite

# Specific month
./scripts/wp-rest.sh calendar 2026-03 --site=mysite
```

**Output example:**
```
=== Content Calendar: 2026-02 ===

PUBLISHED:
  2026-02-01 09:00  #101 Getting Started with WordPress
  2026-02-05 14:30  #105 Plugin Development Guide

SCHEDULED:
  2026-02-15 08:00  #110 Advanced Custom Fields Tutorial

DRAFTS:
  2026-02-10 12:00  #108 REST API Best Practices
```

---

## Site Stats

Get a quick overview of content counts across your site.

```bash
./scripts/wp-rest.sh stats --site=mysite
```

Shows post counts by status (publish, draft, pending, private, future, trash), total pages, media items, categories, tags, and comments by status (approved, hold, spam, trash).

---

## Bulk Operations

### Bulk Publish All Drafts

Publishes every draft post on the site. **Use with caution.**

```bash
./scripts/wp-rest.sh bulk-publish --site=mysite
```

### Bulk Delete Old Trashed Posts

Permanently deletes posts in the trash older than N days (default: 365).

```bash
# Delete trashed posts older than 365 days
./scripts/wp-rest.sh bulk-delete-old --site=mysite

# Delete trashed posts older than 30 days
./scripts/wp-rest.sh bulk-delete-old 30 --site=mysite
```

**Safety:** Only deletes posts already in the trash — never touches published, draft, or pending posts.

---

## Backup & Export

### JSON Backup

Export all posts, pages, categories, and tags to JSON files.

```bash
./scripts/wp-rest.sh backup --site=mysite
```

Creates a timestamped directory in `~/clawd/backups/` with `posts.json`, `pages.json`, `categories.json`, and `tags.json`.

### Markdown Export

Export all posts as individual markdown files with YAML frontmatter.

```bash
./scripts/wp-rest.sh export-markdown --site=mysite
```

Creates a timestamped directory in `~/clawd/exports/` with one `.md` file per post.

---

## Markdown to Gutenberg Conversion

Convert a markdown file directly to a WordPress post with proper Gutenberg block markup.

```bash
# Create draft from markdown
./scripts/wp-rest.sh create-post-markdown article.md --site=mysite

# With explicit title and publish immediately
./scripts/wp-rest.sh create-post-markdown article.md "My Custom Title" publish --site=mysite
```

The converter handles: headings (H1-H6), paragraphs, bold/italic/code, links, images, ordered/unordered lists, blockquotes, code blocks (with language classes), horizontal rules, and tables.

---

## Helper Script Reference

The `scripts/wp-rest.sh` script provides a standalone CLI for all WordPress REST API operations. It reads credentials from `~/clawd/.wp-sites.json` and uses `curl -K "$WP_AUTH_FILE"` for all requests (credentials never appear in process args).

```bash
# Show all available commands
./scripts/wp-rest.sh

# Any command works with --site=NAME
./scripts/wp-rest.sh list-posts --site=smartwebutah
./scripts/wp-rest.sh stats --site=memberpress
```

**Full command list:**

| Group | Commands |
|---|---|
| Posts | `list-posts`, `get-post`, `search-posts`, `create-post`, `create-post-markdown`, `update-post`, `delete-post`, `publish-post`, `schedule-post` |
| Pages | `list-pages`, `create-page` |
| Media | `list-media`, `upload-media`, `update-media`, `delete-media`, `set-featured-image` |
| Categories | `list-categories`, `create-category`, `delete-category` |
| Tags | `list-tags`, `create-tag`, `delete-tag` |
| Comments | `list-comments`, `pending-comments`, `approve-comment`, `spam-comment`, `delete-comment`, `reply-comment`, `bulk-approve-comments` |
| Content | `health-check`, `calendar`, `stats` |
| Bulk | `bulk-publish`, `bulk-delete-old` |
| Export | `backup`, `export-markdown` |
| Site | `site-info`, `site-health`, `me`, `list-users` |

---

## Related Skills

- **content-pipeline**: Create a polished article first, then publish with wp-publish
- **deep-research**: Research a topic, then pipe into content-pipeline, then wp-publish
- **copywriting**: Write marketing copy, then publish to WordPress
- **seo-audit**: Audit existing WordPress content for SEO issues
- **programmatic-seo**: Create SEO pages at scale (can publish batches via wp-publish)

See [references/api-patterns.md](references/api-patterns.md) for the full WordPress REST API reference.
