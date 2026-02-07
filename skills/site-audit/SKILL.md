---
name: site-audit
version: 1.0.0
description: When the user wants a comprehensive, multi-dimensional website audit with visual scoring. Also use when the user mentions "site audit," "website audit," "website review," "audit my site," "website health check," "UX audit," "accessibility audit," "performance audit," or "website analysis." This skill uses browser recon and parallel subagents to analyze Technical SEO, Content, Accessibility, Performance, and UX, producing a scored HTML dashboard. For SEO-only audits, see seo-audit.
---

# Site Audit

You are an expert website analyst. Your goal is to perform comprehensive browser-based reconnaissance on a target URL, then spawn parallel subagents to analyze five dimensions, producing a scored interactive dashboard.

## Initial Assessment

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before auditing, understand:

1. **Target**
   - What is the URL to audit?
   - Is this the user's own site or a competitor?
   - Any specific pages to focus on beyond the homepage?

2. **Priority**
   - Which dimensions matter most? (Technical SEO, Content, Accessibility, Performance, UX)
   - Any known issues to investigate?
   - What's the business goal driving this audit?

3. **Scope**
   - Full site or specific pages?
   - Desktop only, mobile only, or both?
   - Any comparison benchmarks?

---

## Core Workflow

### Phase 1: Browser Reconnaissance (Primary Agent)

Use the `browser` tool to perform initial reconnaissance on the target URL:

1. **Navigate** to the target URL
2. **Take a screenshot** of the homepage (full page if possible)
3. **Take a snapshot** (accessibility tree) of the homepage
4. **Navigate** to 2-3 key interior pages (pricing, features, about)
5. **Screenshot and snapshot** each page
6. **Check** robots.txt, sitemap.xml, and common paths

**Collect and document:**
- Page titles and meta descriptions
- Heading structure
- Navigation layout
- Visual design quality
- Load behavior observations
- Mobile viewport behavior
- Any errors or broken elements

### Phase 2: Spawn 5 Analysis Subagents

Use `sessions_spawn` to create 5 parallel subagents. Pass the browser reconnaissance data (screenshots, snapshots, observations) to each subagent as context.

**Subagent 1: Technical SEO**
```
Analyze this website for Technical SEO quality.

Context from browser recon:
[PASTE RECON DATA]

Evaluate and score 1-10:
- Crawlability (robots.txt, sitemap, internal links)
- Indexation signals (canonical tags, noindex usage)
- URL structure (clean, descriptive, consistent)
- HTTPS and security headers
- Structured data / schema markup
- Mobile-friendliness
- Core Web Vitals indicators

Return: Overall score (1-10), breakdown per criterion, top 3 issues, top 3 wins.
```

**Subagent 2: Content Quality**
```
Analyze this website for Content Quality.

Context from browser recon:
[PASTE RECON DATA]

Evaluate and score 1-10:
- Headline clarity and hierarchy
- Value proposition communication
- Copy quality and readability
- Content depth and uniqueness
- CTA effectiveness
- E-E-A-T signals
- Content freshness

Return: Overall score (1-10), breakdown per criterion, top 3 issues, top 3 wins.
```

**Subagent 3: Accessibility**
```
Analyze this website for Accessibility compliance.

Context from browser recon:
[PASTE RECON DATA]

Evaluate and score 1-10:
- Color contrast ratios
- Alt text on images
- Keyboard navigation support
- ARIA labels and landmarks
- Form labels and error handling
- Focus indicators
- Screen reader compatibility

Return: Overall score (1-10), breakdown per criterion, top 3 issues, top 3 wins.
```

**Subagent 4: Performance**
```
Analyze this website for Performance.

Context from browser recon:
[PASTE RECON DATA]

Evaluate and score 1-10:
- Perceived load speed
- Image optimization
- JavaScript bundle indicators
- Font loading strategy
- Caching indicators
- CDN usage
- Resource prioritization

Return: Overall score (1-10), breakdown per criterion, top 3 issues, top 3 wins.
```

**Subagent 5: UX / Design**
```
Analyze this website for UX and Design quality.

Context from browser recon:
[PASTE RECON DATA]

Evaluate and score 1-10:
- Visual hierarchy and layout
- Navigation clarity
- Mobile responsiveness
- Consistency (colors, typography, spacing)
- Interactive elements (buttons, forms, hover states)
- Information architecture
- User flow clarity

Return: Overall score (1-10), breakdown per criterion, top 3 issues, top 3 wins.
```

### Phase 3: Build Scored Dashboard

After all subagents complete, build an interactive HTML dashboard with:
- **Radar chart** (Chart.js) showing all 5 dimension scores
- **Score cards** for each dimension with color-coded ratings
- **Expandable detail sections** per dimension
- **Priority action items** ranked by impact

**Scoring reference:** See [references/scoring-rubric.md](references/scoring-rubric.md) for detailed scoring criteria.

---

## Output Format

### Primary Output
Interactive HTML dashboard saved to `~/clawd/canvas/site-audit-[domain]-[YYYY-MM-DD].html`

### Dashboard Structure
1. **Header** — Site URL, audit date, overall score
2. **Radar Chart** — 5-dimension visual comparison
3. **Score Cards** — One per dimension (1-10 with color coding)
4. **Detailed Findings** — Expandable sections per dimension
5. **Action Plan** — Prioritized recommendations
6. **Screenshots** — Embedded base64 screenshots from recon (if feasible)

### Chat Summary
After creating the dashboard, provide:
- Link to the HTML artifact
- Overall score out of 50 (sum of all dimensions)
- Top 3 critical issues across all dimensions
- Top 3 quick wins

---

## HTML Artifact Standards

All HTML dashboards must be:
- **Self-contained** — Inline CSS and JS, no external dependencies except CDN
- **CDN libraries** — Chart.js from jsdelivr for radar chart
- **Dark theme** — Consistent with canvas gallery styling
- **Responsive** — Works on desktop and mobile
- **Google Fonts** — Via CDN if needed

---

## Task-Specific Questions

1. What URL should I audit?
2. Are there specific dimensions you care most about?
3. Should I focus on desktop, mobile, or both?
4. Any competitor sites to compare against?
5. Are there known issues you want me to investigate?

---

## Related Skills

- **seo-audit**: For in-depth SEO-only analysis (more detailed than the SEO dimension here)
- **page-cro**: For conversion optimization recommendations
- **deep-research**: For researching best practices or competitor approaches
- **analytics-tracking**: For measurement and tracking recommendations
