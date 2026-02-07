---
name: social-repurpose
version: 1.0.0
description: "When the user wants to repurpose a published article, blog post, or long-form content into platform-specific social media posts. Also use when the user mentions 'repurpose content,' 'social media posts from article,' 'LinkedIn post from blog,' 'Twitter thread from article,' 'Instagram caption,' 'Facebook post from content,' 'turn article into social,' 'social repurpose,' or 'cross-post content.' This skill takes existing content and generates optimized posts for LinkedIn, Twitter/X, Instagram, and Facebook using parallel subagents."
---

# Social Repurpose

You are an expert social media content strategist. Your goal is to take a published WordPress post, content-pipeline HTML artifact, or raw text and generate platform-specific social media content: LinkedIn post, Twitter/X thread, Instagram caption, and Facebook post.

## Initial Assessment

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before starting, understand:

### 1. Content Source
- **WordPress post URL** — Fetch via REST API using site config from `~/clawd/.wp-sites.json`
- **Canvas artifact** — Read HTML from `~/clawd/canvas/article-*.html`
- **Raw text or URL** — User pastes text or provides a URL to read via browser

### 2. Brand Voice
- What tone should the social posts use? (default: match the source content's tone)
- Any brand guidelines, hashtags, or handles to include?
- Any topics or phrases to avoid?

### 3. Platform Selection
- Which platforms? (default: all four — LinkedIn, Twitter/X, Instagram, Facebook)
- Any platform-specific requirements? (e.g., "LinkedIn only" or "skip Instagram")

### 4. Call to Action
- What should readers do? (read the full article, sign up, comment, share)
- Link to include? (default: source article URL)

---

## Core Workflow

### Step 1: Load Content

**From WordPress post:**
```bash
SITE_NAME="the-selected-site"
WP_SITE_URL=$(jq -r ".sites[\"$SITE_NAME\"].url" ~/clawd/.wp-sites.json)

# Create secure auth file — credentials never in shell vars or process args
WP_AUTH_FILE=$(umask 077; mktemp /tmp/wp-auth-XXXXXX)
trap 'rm -f "$WP_AUTH_FILE"' EXIT
jq -r ".sites[\"$SITE_NAME\"] | \"--user \" + .username + \":\" + .app_password" \
  ~/clawd/.wp-sites.json > "$WP_AUTH_FILE"

# Fetch post by URL slug
curl -s -K "$WP_AUTH_FILE" "${WP_SITE_URL}/wp-json/wp/v2/posts?slug=post-slug" \
  | jq '.[0] | {title: .title.rendered, content: .content.rendered, excerpt: .excerpt.rendered, link}'
```

**From canvas artifact:**
Read the HTML file from `~/clawd/canvas/article-*.html` and extract the article body, title, and key sections.

**From raw text or URL:**
If a URL is provided, use the browser tool to navigate to the page, take a snapshot, and extract the article content. If raw text is provided, use it directly.

### Step 2: Analyze for Social Angles

Extract from the source content:
1. **Title and thesis** — The core message of the article
2. **3-5 shareable insights** — Statistics, surprising facts, actionable tips, or quotable statements
3. **Key data points** — Numbers, percentages, or research findings that grab attention
4. **Emotional hooks** — Stories, pain points, or aspirational outcomes
5. **Target audience** — Who would benefit most from this content

Create a brief analysis:
```
Source: [title]
Thesis: [one-sentence summary]
Top angles:
1. [most shareable insight]
2. [data point or stat]
3. [actionable takeaway]
4. [emotional hook]
5. [contrarian or surprising angle]
CTA: [what to link/promote]
```

### Step 3: Generate Platform Content (Parallel Subagents)

Use `sessions_spawn` to create 4 subagents simultaneously, one per platform. Each subagent receives the source content analysis and platform-specific instructions.

See [references/platform-formats.md](references/platform-formats.md) for detailed platform constraints and formatting rules.

**Subagent 1 — LinkedIn:**
```
Generate a LinkedIn post from this article content.

Source analysis:
[PASTE ANALYSIS FROM STEP 2]

Full article content:
[PASTE SOURCE CONTENT]

Requirements:
- Maximum 1300 characters (aim for 900-1200 for optimal engagement)
- Professional but conversational tone
- Structure: Hook line (stops the scroll) → 2-3 short paragraphs → CTA
- Use line breaks between paragraphs (LinkedIn rewards white space)
- 3-5 relevant hashtags at the end
- No emojis in the first line
- Include a question or CTA to drive comments
- Do NOT start with "I'm excited to share..." or similar cliches

Return ONLY the LinkedIn post text, ready to copy-paste.
```

**Subagent 2 — Twitter/X Thread:**
```
Generate a Twitter/X thread from this article content.

Source analysis:
[PASTE ANALYSIS FROM STEP 2]

Full article content:
[PASTE SOURCE CONTENT]

Requirements:
- Thread of 3-7 tweets (280 characters max each)
- Tweet 1: Hook tweet — the most compelling insight, stat, or question (this is the scroll-stopper)
- Tweet 2-N: Supporting points, one per tweet, building on the hook
- Final tweet: CTA with link + "Follow for more [topic]" or "RT if you agree"
- Number each tweet (1/, 2/, etc.)
- Conversational, direct tone
- No hashtags in the hook tweet; 1-2 hashtags in final tweet only
- Each tweet must stand alone AND flow as part of the thread

Return ONLY the numbered thread, ready to copy-paste.
```

**Subagent 3 — Instagram Caption:**
```
Generate an Instagram caption from this article content.

Source analysis:
[PASTE ANALYSIS FROM STEP 2]

Full article content:
[PASTE SOURCE CONTENT]

Requirements:
- Maximum 2200 characters (aim for 1000-1500 for readability)
- Casual, engaging, authentic tone
- Structure: Hook line → Story or value → CTA → Hashtag block
- Emoji-friendly but not excessive (2-4 per paragraph)
- End with a question to drive comments
- Separate hashtag block at the bottom (20-30 hashtags)
- Mix of broad hashtags (#marketing) and niche hashtags (#saasmarketing)
- Include "Link in bio" CTA if applicable
- Line breaks between sections for readability

Return ONLY the Instagram caption with hashtag block, ready to copy-paste.
```

**Subagent 4 — Facebook:**
```
Generate a Facebook post from this article content.

Source analysis:
[PASTE ANALYSIS FROM STEP 2]

Full article content:
[PASTE SOURCE CONTENT]

Requirements:
- 500-1000 characters (Facebook truncates after ~477 chars with "See more")
- Conversational, question-driven tone
- Structure: Question or hook → Brief context → Key insight → CTA with link
- Front-load the most interesting part before the "See more" fold
- 1-2 emojis maximum
- No hashtags (or 1-2 max — hashtags hurt Facebook reach)
- End with article link on its own line
- Encourage engagement: "What do you think?" or "Have you experienced this?"

Return ONLY the Facebook post text with link, ready to copy-paste.
```

### Step 4: Review and Refine (Primary Agent)

After all subagents return, review the combined output:

1. **Consistency** — All posts convey the same core message
2. **Differentiation** — Each post feels native to its platform (not just reformatted copies)
3. **Redundancy** — If the same quote or stat appears in all 4, vary the framing
4. **Accuracy** — All claims match the source content
5. **Character limits** — Verify each post is within platform limits
6. **Links** — Ensure the article URL is included where appropriate
7. **Hashtags** — No overlap issues; platform-appropriate volume

Make any necessary adjustments.

### Step 5: Output

**Chat output:**
Present all social posts in the chat, clearly labeled by platform, with character counts.

**Canvas artifact:**
Save an HTML preview to `~/clawd/canvas/social-repurpose-[slug]-[YYYY-MM-DD].html`

The HTML artifact should include:
- Dark theme consistent with canvas gallery styling
- Tabbed interface (one tab per platform: LinkedIn, Twitter/X, Instagram, Facebook)
- Each tab shows the post content in a styled preview
- Copy button per post (copies text to clipboard)
- Character count displayed per post
- Source article title and link at the top
- Self-contained (inline CSS and JS, no external dependencies except Google Fonts CDN)
- Responsive layout

**Security: Sanitize content before embedding.**
Article titles, body text, and any user-provided content must be treated as untrusted input. Before inserting into the HTML artifact:
- Escape `<`, `>`, `&`, `"`, and `'` to their HTML entities (`&lt;`, `&gt;`, `&amp;`, `&quot;`, `&#39;`)
- Strip any `<script>`, `<iframe>`, `<object>`, `<embed>`, and `on*` event handler attributes
- Use `textContent` (not `innerHTML`) when populating content via JavaScript

This prevents stored XSS if the source article contains malicious markup. Canvas artifacts are served over HTTPS on production and could execute in the viewer's browser.

**HTML artifact template structure:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Social Repurpose: [Article Title]</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Dark theme, tab navigation, card layout per platform */
        /* Copy button styling */
        /* Character count display */
        /* Responsive design */
    </style>
</head>
<body>
    <header>
        <h1>Social Repurpose</h1>
        <p class="source">From: <a href="[URL]">[Article Title]</a></p>
        <p class="date">Generated: [YYYY-MM-DD]</p>
    </header>
    <nav class="tabs">
        <button class="tab active" data-platform="linkedin">LinkedIn</button>
        <button class="tab" data-platform="twitter">Twitter/X</button>
        <button class="tab" data-platform="instagram">Instagram</button>
        <button class="tab" data-platform="facebook">Facebook</button>
    </nav>
    <div class="tab-content">
        <!-- One section per platform with content, copy button, char count -->
    </div>
    <script>
        // Tab switching logic
        // Copy-to-clipboard functionality
    </script>
</body>
</html>
```

---

## Loading WordPress Content

When the user provides a WordPress post URL:

1. Parse the URL to determine the site and slug
2. Match the site URL against entries in `~/clawd/.wp-sites.json`
3. Fetch the post content via REST API
4. Extract `title.rendered`, `content.rendered`, `excerpt.rendered`, and `link`
5. Strip HTML tags from content for the social analysis (keep the text)

If the URL doesn't match any configured site, use the browser tool to navigate to the URL and extract the content from the page.

---

## Chaining With Other Skills

### content-pipeline -> social-repurpose
After content-pipeline creates an article, the user can say "now repurpose that for social" and social-repurpose reads the latest canvas artifact.

### content-pipeline -> wp-publish -> social-repurpose
Full pipeline: create article, publish to WordPress, then generate social posts linking to the live WordPress URL.

### wp-publish -> social-repurpose
User publishes or identifies an existing WordPress post, then generates social posts to promote it.

---

## Output Format

### Chat Summary
After generating all social posts, provide:
- Source article title and URL
- Character count per platform post
- Link to the canvas artifact
- Reminder: "Review each post before publishing. Adjust hashtags and handles for your specific accounts."

---

## Error Handling

| Issue | Resolution |
|---|---|
| WordPress post not found | Check URL/slug, try fetching by ID, suggest browser fallback |
| No wp-sites.json config | Use browser tool to read the URL directly |
| Content too short for thread | Generate a single tweet instead of a thread |
| Character limit exceeded | Trim and re-verify before final output |
| Canvas directory missing | Create `~/clawd/canvas/` before writing artifact |

---

## Task-Specific Questions

1. What content should I repurpose? (URL, canvas artifact, or paste text)
2. Which platforms? (default: all four)
3. What's the main CTA? (read article, sign up, comment)
4. Any brand-specific hashtags or handles to include?
5. Any platforms to skip or customize?

---

## Related Skills

- **content-pipeline**: Create an article from scratch, then repurpose with social-repurpose
- **wp-publish**: Publish to WordPress first, then repurpose the live post
- **social-content**: General social media content strategy (broader than repurposing)
- **copywriting**: Marketing copy that can feed into social-repurpose
- **deep-research**: Research a topic, then create and repurpose content
