# WordPress REST API Patterns

Quick reference for WordPress REST API endpoints used by the wp-publish skill. All commands use `curl` with Application Password authentication.

## Authentication

All requests use HTTP Basic Auth via a secure config file (`curl -K`). Credentials are written to a temporary file by `jq` — they never appear in shell variables or process arguments. See **Step 0** in SKILL.md for the setup pattern.

```bash
# Created in Step 0 — reused for all curl calls in the session
-K "$WP_AUTH_FILE"
```

## Posts

### Create Post
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d @/tmp/wp-post.json
```

Post JSON fields:
```json
{
  "title": "Post Title",
  "content": "<!-- wp:paragraph --><p>Content</p><!-- /wp:paragraph -->",
  "excerpt": "Brief summary",
  "status": "draft",
  "slug": "url-slug",
  "categories": [1, 5],
  "tags": [10, 15],
  "featured_media": 123,
  "format": "standard",
  "meta": {}
}
```

**Status values:** `draft`, `publish`, `pending`, `private`, `future`

For scheduled posts, set `status: "future"` and add `"date": "2025-03-15T09:00:00"`.

### Update Post
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Title", "content": "Updated content"}'
```

### Get Posts
```bash
# Recent posts
curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=10&orderby=date&order=desc" \
  -K "$WP_AUTH_FILE"

# Search posts
curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?search=keyword" \
  -K "$WP_AUTH_FILE"

# Filter by category
curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?categories=5" \
  -K "$WP_AUTH_FILE"

# Get single post
curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}" \
  -K "$WP_AUTH_FILE"
```

### Delete Post
```bash
# Move to trash
curl -s -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}" \
  -K "$WP_AUTH_FILE"

# Permanent delete
curl -s -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}?force=true" \
  -K "$WP_AUTH_FILE"
```

## Pages

### Create Page
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/pages" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Page Title",
    "content": "Page content",
    "status": "draft",
    "parent": 0,
    "template": ""
  }'
```

## Media

### Upload Image
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/media" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Disposition: attachment; filename=image.jpg" \
  -H "Content-Type: image/jpeg" \
  --data-binary @/path/to/image.jpg
```

Content-Type by extension:
- `.jpg`, `.jpeg` → `image/jpeg`
- `.png` → `image/png`
- `.gif` → `image/gif`
- `.webp` → `image/webp`
- `.svg` → `image/svg+xml`
- `.pdf` → `application/pdf`
- `.mp4` → `video/mp4`

### Update Media Alt Text
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/media/{MEDIA_ID}" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{"alt_text": "Descriptive alt text", "caption": "Image caption"}'
```

## Categories

### List Categories
```bash
curl -s "${WP_SITE_URL}/wp-json/wp/v2/categories?per_page=100" \
  -K "$WP_AUTH_FILE" | jq '.[] | {id, name, slug, count}'
```

### Create Category
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/categories" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{"name": "Category Name", "slug": "category-slug", "description": "Category description", "parent": 0}'
```

## Tags

### List Tags
```bash
curl -s "${WP_SITE_URL}/wp-json/wp/v2/tags?per_page=100&search=keyword" \
  -K "$WP_AUTH_FILE" | jq '.[] | {id, name, slug}'
```

### Create Tag
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/tags" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{"name": "Tag Name"}'
```

## SEO Metadata

### Yoast SEO
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "_yoast_wpseo_title": "SEO Title — %%sitename%%",
      "_yoast_wpseo_metadesc": "Meta description under 160 characters",
      "_yoast_wpseo_focuskw": "target keyword",
      "_yoast_wpseo_canonical": "https://example.com/canonical-url"
    }
  }'
```

Yoast title variables: `%%title%%`, `%%sitename%%`, `%%sep%%`, `%%primary_category%%`

### RankMath SEO
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/{POST_ID}" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "rank_math_title": "SEO Title %sep% %sitename%",
      "rank_math_description": "Meta description under 160 characters",
      "rank_math_focus_keyword": "target keyword",
      "rank_math_canonical_url": "https://example.com/canonical-url",
      "rank_math_robots": ["index", "follow"]
    }
  }'
```

## Gutenberg Block Markup

Standard block patterns for content conversion:

```html
<!-- Paragraph -->
<!-- wp:paragraph -->
<p>Text content here.</p>
<!-- /wp:paragraph -->

<!-- Heading (H2) -->
<!-- wp:heading {"level":2} -->
<h2 class="wp-block-heading">Heading Text</h2>
<!-- /wp:heading -->

<!-- Heading (H3) -->
<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">Subheading Text</h3>
<!-- /wp:heading -->

<!-- Unordered List -->
<!-- wp:list -->
<ul class="wp-block-list">
<li>Item one</li>
<li>Item two</li>
</ul>
<!-- /wp:list -->

<!-- Ordered List -->
<!-- wp:list {"ordered":true} -->
<ol class="wp-block-list">
<li>First</li>
<li>Second</li>
</ol>
<!-- /wp:list -->

<!-- Image -->
<!-- wp:image {"id":123,"sizeSlug":"large"} -->
<figure class="wp-block-image size-large">
<img src="https://example.com/image.jpg" alt="Alt text" class="wp-image-123"/>
<figcaption class="wp-element-caption">Caption text</figcaption>
</figure>
<!-- /wp:image -->

<!-- Quote -->
<!-- wp:quote -->
<blockquote class="wp-block-quote">
<p>Quote text here.</p>
<cite>Attribution</cite>
</blockquote>
<!-- /wp:quote -->

<!-- Code Block -->
<!-- wp:code -->
<pre class="wp-block-code"><code>code here</code></pre>
<!-- /wp:code -->

<!-- Separator -->
<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity"/>
<!-- /wp:separator -->

<!-- Table -->
<!-- wp:table -->
<figure class="wp-block-table">
<table>
<thead><tr><th>Header 1</th><th>Header 2</th></tr></thead>
<tbody><tr><td>Cell 1</td><td>Cell 2</td></tr></tbody>
</table>
</figure>
<!-- /wp:table -->
```

## Useful Queries

### Check REST API availability
```bash
curl -s "${WP_SITE_URL}/wp-json/" | jq '.name, .description, .url'
```

### List available post types
```bash
curl -s "${WP_SITE_URL}/wp-json/wp/v2/types" \
  -K "$WP_AUTH_FILE" | jq 'keys'
```

### Get site settings
```bash
curl -s "${WP_SITE_URL}/wp-json/wp/v2/settings" \
  -K "$WP_AUTH_FILE"
```

### List users (for author assignment)
```bash
curl -s "${WP_SITE_URL}/wp-json/wp/v2/users?per_page=50" \
  -K "$WP_AUTH_FILE" | jq '.[] | {id, name, slug}'
```

## Comments

### List Comments
```bash
# Approved comments
curl -s "${WP_SITE_URL}/wp-json/wp/v2/comments?status=approve&per_page=20" \
  -K "$WP_AUTH_FILE"

# Pending (held for moderation)
curl -s "${WP_SITE_URL}/wp-json/wp/v2/comments?status=hold&per_page=100" \
  -K "$WP_AUTH_FILE"

# Comments on a specific post
curl -s "${WP_SITE_URL}/wp-json/wp/v2/comments?post=123&per_page=50" \
  -K "$WP_AUTH_FILE"

# Spam comments
curl -s "${WP_SITE_URL}/wp-json/wp/v2/comments?status=spam&per_page=50" \
  -K "$WP_AUTH_FILE"
```

**Comment status values:** `approve`, `hold`, `spam`, `trash`

### Approve / Spam a Comment
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/comments/{COMMENT_ID}" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{"status":"approved"}'

# Mark as spam
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/comments/{COMMENT_ID}" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{"status":"spam"}'
```

### Reply to a Comment
```bash
curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/comments" \
  -K "$WP_AUTH_FILE" \
  -H "Content-Type: application/json" \
  -d '{
    "post": 123,
    "parent": 42,
    "content": "Reply text here"
  }'
```

### Delete a Comment
```bash
# Move to trash
curl -s -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/comments/{COMMENT_ID}" \
  -K "$WP_AUTH_FILE"

# Permanent delete
curl -s -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/comments/{COMMENT_ID}?force=true" \
  -K "$WP_AUTH_FILE"
```

## Content Calendar Queries

### Filter Posts by Date Range
```bash
# Posts in a specific month (February 2026)
curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?after=2026-02-01T00:00:00&before=2026-03-01T00:00:00&status=publish&per_page=100&orderby=date&order=asc" \
  -K "$WP_AUTH_FILE"

# Scheduled posts in date range
curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?after=2026-02-01T00:00:00&before=2026-03-01T00:00:00&status=future&per_page=100" \
  -K "$WP_AUTH_FILE"

# Drafts in date range
curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?after=2026-02-01T00:00:00&before=2026-03-01T00:00:00&status=draft&per_page=100" \
  -K "$WP_AUTH_FILE"
```

**Date format:** ISO 8601 — `YYYY-MM-DDTHH:MM:SS`

**Useful filter params:**
- `after` / `before` — date range boundaries
- `status` — `publish`, `draft`, `pending`, `private`, `future`, `trash`, `any`
- `orderby` — `date`, `modified`, `title`, `id`
- `order` — `asc`, `desc`

## Bulk Operations

### Bulk Status Update (loop pattern)
```bash
# Get all draft post IDs, then publish each
for PID in $(curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?status=draft&per_page=100" \
  -K "$WP_AUTH_FILE" | jq -r '.[].id'); do
  curl -s -X POST "${WP_SITE_URL}/wp-json/wp/v2/posts/${PID}" \
    -K "$WP_AUTH_FILE" \
    -H "Content-Type: application/json" \
    -d '{"status":"publish"}'
done
```

### Bulk Delete Old Trashed Posts
```bash
# Get trashed posts older than a date, then permanently delete
CUTOFF="2025-01-01T00:00:00"
for PID in $(curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?before=${CUTOFF}&status=trash&per_page=100" \
  -K "$WP_AUTH_FILE" | jq -r '.[].id'); do
  curl -s -X DELETE "${WP_SITE_URL}/wp-json/wp/v2/posts/${PID}?force=true" \
    -K "$WP_AUTH_FILE"
done
```

## Stats via Headers

The WordPress REST API returns total counts in response headers. Use `curl -I` (HEAD request) for efficient counting without downloading full responses.

```bash
# Get total post count for a status
curl -s -I "${WP_SITE_URL}/wp-json/wp/v2/posts?status=publish&per_page=1" \
  -K "$WP_AUTH_FILE" | grep -i 'x-wp-total'
# → X-WP-Total: 247

# Total pages in results (for pagination)
curl -s -I "${WP_SITE_URL}/wp-json/wp/v2/posts?status=publish&per_page=10" \
  -K "$WP_AUTH_FILE" | grep -i 'x-wp-totalpages'
# → X-WP-TotalPages: 25
```

**Headers returned:**
- `X-WP-Total` — total number of items matching the query
- `X-WP-TotalPages` — total number of pages at current `per_page`

Works on all collection endpoints: `/posts`, `/pages`, `/media`, `/categories`, `/tags`, `/comments`, `/users`.

## Export Patterns

### Paginated Full Export
```bash
# Export all posts (paginated for large sites)
PAGE=1
while true; do
  BATCH=$(curl -s "${WP_SITE_URL}/wp-json/wp/v2/posts?per_page=100&page=${PAGE}&status=any&context=edit" \
    -K "$WP_AUTH_FILE")
  [ "$(echo "$BATCH" | jq 'length')" -eq 0 ] && break
  echo "$BATCH" >> /tmp/all-posts.json
  PAGE=$((PAGE + 1))
done
```

### Context Parameter
Use `context=edit` for full field access (requires authentication):
- `context=view` (default) — public fields only
- `context=edit` — includes raw content, all meta, private fields
- `context=embed` — minimal fields for embedding

## Error Codes

| Code | Meaning |
|---|---|
| 200 | Success (GET, UPDATE) |
| 201 | Created (POST) |
| 400 | Bad request (check JSON) |
| 401 | Auth failed (check credentials) |
| 403 | Forbidden (insufficient role) |
| 404 | Not found (check URL/ID) |
| 413 | Payload too large (reduce file size) |
| 500 | Server error (check WP logs) |
| `rest_cannot_create` | Missing required fields or bad values |
| `rest_post_invalid_id` | Post ID doesn't exist |
| `rest_upload_no_data` | Empty file upload |
