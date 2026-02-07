# Content Pipeline Article — HTML Template

Use this HTML skeleton when assembling the final article. Customize the hero, TOC, and sections based on content.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ARTICLE_TITLE}}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Merriweather:ital,wght@0,300;0,400;0,700;1,400&display=swap');

    :root {
      --bg-primary: #0f1117;
      --bg-secondary: #1a1d27;
      --bg-tertiary: #242837;
      --text-primary: #e4e6ef;
      --text-secondary: #9ca0b0;
      --text-muted: #6b7084;
      --accent: #6c8cff;
      --accent-hover: #8ba3ff;
      --accent-dim: rgba(108, 140, 255, 0.15);
      --border: #2a2e3e;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Merriweather', Georgia, serif;
      background: var(--bg-primary);
      color: var(--text-primary);
      line-height: 1.85;
      font-size: 1.05rem;
    }

    /* Hero Section */
    .hero {
      max-width: 780px;
      margin: 0 auto;
      padding: 5rem 2rem 3rem;
      text-align: center;
    }

    .hero .category {
      font-family: 'Inter', sans-serif;
      font-size: 0.75rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.15em;
      color: var(--accent);
      margin-bottom: 1.5rem;
    }

    .hero h1 {
      font-size: 2.5rem;
      font-weight: 700;
      line-height: 1.3;
      margin-bottom: 1.25rem;
      letter-spacing: -0.02em;
    }

    .hero .subtitle {
      font-size: 1.2rem;
      color: var(--text-secondary);
      font-weight: 300;
      line-height: 1.6;
      margin-bottom: 2rem;
    }

    .hero .meta {
      font-family: 'Inter', sans-serif;
      font-size: 0.85rem;
      color: var(--text-muted);
      display: flex;
      justify-content: center;
      gap: 1.5rem;
    }

    .hero .meta span {
      display: flex;
      align-items: center;
      gap: 0.4rem;
    }

    .divider {
      max-width: 780px;
      margin: 0 auto;
      border: none;
      border-top: 1px solid var(--border);
    }

    /* Table of Contents */
    .toc {
      max-width: 780px;
      margin: 2.5rem auto;
      padding: 0 2rem;
    }

    .toc-inner {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.75rem 2rem;
    }

    .toc h2 {
      font-family: 'Inter', sans-serif;
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: var(--text-muted);
      margin-bottom: 1rem;
    }

    .toc ol {
      list-style: none;
      counter-reset: toc;
    }

    .toc li {
      counter-increment: toc;
      margin-bottom: 0.5rem;
    }

    .toc li a {
      font-family: 'Inter', sans-serif;
      font-size: 0.95rem;
      color: var(--text-secondary);
      text-decoration: none;
      display: flex;
      align-items: baseline;
      gap: 0.75rem;
      transition: color 0.2s;
    }

    .toc li a::before {
      content: counter(toc, decimal-leading-zero);
      font-size: 0.8rem;
      color: var(--accent);
      font-weight: 600;
      min-width: 1.5rem;
    }

    .toc li a:hover { color: var(--accent); }

    /* Article Body */
    .article {
      max-width: 780px;
      margin: 0 auto;
      padding: 2rem 2rem 4rem;
    }

    .article h2 {
      font-size: 1.6rem;
      font-weight: 700;
      margin-top: 3rem;
      margin-bottom: 1.25rem;
      line-height: 1.3;
      scroll-margin-top: 2rem;
    }

    .article h3 {
      font-size: 1.2rem;
      font-weight: 600;
      margin-top: 2rem;
      margin-bottom: 0.75rem;
    }

    .article p {
      margin-bottom: 1.25rem;
      color: var(--text-secondary);
    }

    .article a {
      color: var(--accent);
      text-decoration: underline;
      text-decoration-color: var(--accent-dim);
      text-underline-offset: 3px;
    }

    .article a:hover {
      text-decoration-color: var(--accent);
    }

    .article ul, .article ol {
      margin-bottom: 1.25rem;
      padding-left: 1.5rem;
      color: var(--text-secondary);
    }

    .article li { margin-bottom: 0.5rem; }

    .article strong { color: var(--text-primary); }

    .article code {
      font-family: 'JetBrains Mono', monospace;
      background: var(--bg-tertiary);
      padding: 0.15rem 0.4rem;
      border-radius: 4px;
      font-size: 0.9em;
    }

    .article blockquote {
      border-left: 3px solid var(--accent);
      padding: 0.5rem 0 0.5rem 1.5rem;
      margin: 1.5rem 0;
      font-style: italic;
      color: var(--text-secondary);
    }

    /* Pull Quote */
    .pull-quote {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 2rem;
      margin: 2rem 0;
      text-align: center;
    }

    .pull-quote p {
      font-size: 1.3rem;
      font-weight: 400;
      color: var(--text-primary);
      line-height: 1.6;
      margin-bottom: 0.75rem;
    }

    .pull-quote cite {
      font-family: 'Inter', sans-serif;
      font-size: 0.85rem;
      color: var(--text-muted);
      font-style: normal;
    }

    /* Data Callout */
    .data-callout {
      display: flex;
      align-items: center;
      gap: 1.5rem;
      background: var(--accent-dim);
      border-radius: 12px;
      padding: 1.5rem 2rem;
      margin: 2rem 0;
    }

    .data-callout .stat {
      font-family: 'Inter', sans-serif;
      font-size: 2.5rem;
      font-weight: 700;
      color: var(--accent);
      line-height: 1;
      min-width: fit-content;
    }

    .data-callout .context {
      font-size: 0.95rem;
      color: var(--text-secondary);
    }

    /* CTA Section */
    .cta-section {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 3rem;
      margin: 3rem 0;
      text-align: center;
    }

    .cta-section h2 {
      font-size: 1.5rem;
      margin-top: 0;
      margin-bottom: 0.75rem;
    }

    .cta-section p {
      margin-bottom: 1.5rem;
      max-width: 500px;
      margin-left: auto;
      margin-right: auto;
    }

    .cta-button {
      display: inline-block;
      font-family: 'Inter', sans-serif;
      background: var(--accent);
      color: #fff;
      padding: 0.85rem 2rem;
      border-radius: 8px;
      text-decoration: none;
      font-weight: 600;
      font-size: 0.95rem;
      transition: background 0.2s;
    }

    .cta-button:hover { background: var(--accent-hover); }

    /* Sources */
    .sources {
      max-width: 780px;
      margin: 0 auto;
      padding: 2rem;
      border-top: 1px solid var(--border);
    }

    .sources h2 {
      font-family: 'Inter', sans-serif;
      font-size: 0.85rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: var(--text-muted);
      margin-bottom: 1rem;
    }

    .sources ol {
      font-family: 'Inter', sans-serif;
      font-size: 0.85rem;
      color: var(--text-muted);
      padding-left: 1.5rem;
    }

    .sources li { margin-bottom: 0.5rem; }
    .sources a { color: var(--accent); }

    /* Responsive */
    @media (max-width: 600px) {
      .hero h1 { font-size: 1.8rem; }
      .hero { padding: 3rem 1.5rem 2rem; }
      .article { padding: 1.5rem 1.5rem 3rem; }
      .data-callout { flex-direction: column; text-align: center; }
    }

    /* Print */
    @media print {
      body { background: #fff; color: #111; }
      .hero, .article, .sources { max-width: 100%; }
      .toc-inner, .pull-quote, .cta-section, .data-callout {
        background: #f9f9f9;
        border-color: #ddd;
      }
      a { color: #111; }
    }
  </style>
</head>
<body>

  <!-- Hero -->
  <header class="hero">
    <div class="category">{{CATEGORY}}</div>
    <h1>{{ARTICLE_TITLE}}</h1>
    <p class="subtitle">{{SUBTITLE}}</p>
    <div class="meta">
      <span>{{AUTHOR}}</span>
      <span>{{READ_TIME}} min read</span>
      <span>{{DATE}}</span>
    </div>
  </header>

  <hr class="divider">

  <!-- Table of Contents -->
  <div class="toc">
    <div class="toc-inner">
      <h2>In This Article</h2>
      <ol>
        <li><a href="#section-1">{{SECTION_1_TITLE}}</a></li>
        <li><a href="#section-2">{{SECTION_2_TITLE}}</a></li>
        <li><a href="#section-3">{{SECTION_3_TITLE}}</a></li>
        <!-- Add more sections as needed -->
      </ol>
    </div>
  </div>

  <!-- Article Body -->
  <article class="article">

    <p>{{INTRO_PARAGRAPH}}</p>

    <h2 id="section-1">{{SECTION_1_TITLE}}</h2>
    <p>{{SECTION_1_CONTENT}}</p>

    <!-- Pull Quote Example -->
    <div class="pull-quote">
      <p>"{{QUOTE_TEXT}}"</p>
      <cite>— {{QUOTE_ATTRIBUTION}}</cite>
    </div>

    <h2 id="section-2">{{SECTION_2_TITLE}}</h2>
    <p>{{SECTION_2_CONTENT}}</p>

    <!-- Data Callout Example -->
    <div class="data-callout">
      <div class="stat">{{STAT_NUMBER}}</div>
      <div class="context">{{STAT_CONTEXT}}</div>
    </div>

    <h2 id="section-3">{{SECTION_3_TITLE}}</h2>
    <p>{{SECTION_3_CONTENT}}</p>

    <!-- CTA Section -->
    <div class="cta-section">
      <h2>{{CTA_HEADLINE}}</h2>
      <p>{{CTA_DESCRIPTION}}</p>
      <a href="{{CTA_URL}}" class="cta-button">{{CTA_BUTTON_TEXT}}</a>
    </div>

  </article>

  <!-- Sources -->
  <div class="sources">
    <h2>Sources</h2>
    <ol>
      <li><a href="{{SOURCE_1_URL}}" target="_blank" rel="noopener">{{SOURCE_1_TITLE}}</a></li>
      <!-- Add more sources as needed -->
    </ol>
  </div>

  <script>
    // Smooth scroll for TOC links
    document.querySelectorAll('.toc a').forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const target = document.querySelector(link.getAttribute('href'));
        if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    });

    // Reading progress bar (optional enhancement)
    const progress = document.createElement('div');
    progress.style.cssText = 'position:fixed;top:0;left:0;height:3px;background:var(--accent);z-index:9999;transition:width 0.1s';
    document.body.prepend(progress);

    window.addEventListener('scroll', () => {
      const scrolled = window.scrollY;
      const height = document.documentElement.scrollHeight - window.innerHeight;
      progress.style.width = `${(scrolled / height) * 100}%`;
    });
  </script>
</body>
</html>
```

## Customization Notes

- **Sections:** Add or remove `h2` sections based on the article outline
- **Pull quotes:** Use for impactful statements — limit to 1-2 per article
- **Data callouts:** Use for striking statistics — limit to 2-3 per article
- **CTA:** Customize based on the publication context (signup, download, contact)
- **Sources:** Include all cited sources; omit section if no external sources used
- **Reading time:** Calculate as `word_count / 230` rounded up
- **Print styles:** Already included — article prints cleanly in black and white
