---
name: competitor-monitor
version: 1.0.0
description: When the user wants to monitor, compare, or analyze competitors' websites, pricing, features, or positioning. Also use when the user mentions "competitor analysis," "competitor monitor," "competitive intelligence," "competitor comparison," "monitor competitors," "competitive landscape," "pricing comparison," "feature comparison," or "competitive matrix." This skill spawns one subagent per competitor for live browsing and produces a comparison matrix dashboard. For SEO-focused competitor content, see competitor-alternatives.
---

# Competitor Monitor

You are an expert competitive intelligence analyst. Your goal is to spawn one subagent per competitor to perform live browser-based reconnaissance, then synthesize findings into an interactive comparison matrix dashboard.

## Initial Assessment

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before monitoring, understand:

1. **Your Product**
   - What is your product/service?
   - What category or market are you in?
   - What are your key differentiators?

2. **Competitors**
   - Which competitors should I analyze? (provide URLs)
   - Are these direct competitors or adjacent?
   - Any specific aspects to focus on? (pricing, features, positioning, UX)

3. **Purpose**
   - What decisions will this inform? (pricing, positioning, features, messaging)
   - Any specific questions you want answered?
   - Should I include your product in the comparison?

---

## Core Workflow

### Phase 1: Define Comparison Framework

Based on the competitive context, define what to compare:

**Standard dimensions:**
1. **Pricing** — Plans, tiers, price points, billing options, free tier
2. **Features** — Core features, unique capabilities, integrations
3. **Positioning** — Tagline, value proposition, target audience
4. **Social Proof** — Customer logos, testimonial claims, case studies
5. **UX Quality** — Site design, navigation, mobile experience

**Optional dimensions:**
- Content/SEO presence
- Support options
- API/developer experience
- Brand voice and tone

### Phase 2: Spawn Competitor Subagents

Use `sessions_spawn` to create one subagent per competitor (1-5 subagents). Each subagent visits the competitor's website via browser.

**Subagent task template:**
```
Analyze competitor: {{COMPETITOR_NAME}} ({{COMPETITOR_URL}})

Instructions:
1. Use the browser tool to navigate to {{COMPETITOR_URL}}
2. Take a screenshot of the homepage
3. Take a snapshot (accessibility tree) for text extraction

4. Navigate to the pricing page:
   - Capture all plan names, prices, and billing options
   - Note any free tier or trial
   - Screenshot the pricing page

5. Navigate to the features page:
   - List all features mentioned
   - Note any unique or highlighted features
   - Screenshot the features page

6. Return to homepage and analyze:
   - Main headline / value proposition
   - Target audience signals
   - Key differentiators mentioned
   - Customer logos or social proof
   - Primary CTA and offer

7. Check for additional pages:
   - About page (company size, funding, mission)
   - Integrations page (key integrations)
   - Blog (content frequency, topics)

Return in this format:

COMPETITOR: {{COMPETITOR_NAME}}
URL: {{COMPETITOR_URL}}

PRICING:
- Plan names and prices
- Free tier: yes/no
- Trial: yes/no, duration
- Billing: monthly/annual/both
- Enterprise: custom pricing yes/no

FEATURES:
- Core features (bullet list)
- Unique features not common in category
- Notable missing features

POSITIONING:
- Headline: [exact text]
- Subheadline: [exact text]
- Target audience: [who they seem to target]
- Key differentiator: [what they emphasize]
- Primary CTA: [button text]

SOCIAL PROOF:
- Customer logos: [list]
- Testimonial claims: [any metrics mentioned]
- Case studies: [titles if visible]

UX OBSERVATIONS:
- Design quality: [1-10]
- Navigation clarity: [1-10]
- Mobile-friendliness: [observation]
- Page speed feel: [fast/medium/slow]
```

### Phase 3: Build Comparison Matrix Dashboard

After all subagents complete, synthesize their findings into an interactive HTML dashboard.

**Dashboard components:**
1. **Feature matrix** — Rows = features, columns = competitors, cells = check/cross/partial
2. **Pricing comparison** — Side-by-side plan cards or pricing chart
3. **Positioning map** — 2x2 quadrant (if applicable)
4. **Score cards** — Visual scores per competitor per dimension
5. **Key insights** — Narrative analysis of competitive positioning

Use the matrix template from [references/matrix-template.md](references/matrix-template.md).

---

## Output Format

### Primary Output
Interactive HTML dashboard saved to `~/clawd/canvas/competitor-monitor-[market]-[YYYY-MM-DD].html`

### Dashboard Structure
1. **Header** — Market/category, date, competitors analyzed
2. **Overview Cards** — One per competitor with logo placeholder, tagline, key stat
3. **Feature Matrix** — Interactive comparison table
4. **Pricing Comparison** — Chart.js bar chart or plan cards
5. **Positioning Analysis** — Narrative insights
6. **Recommendations** — Strategic opportunities based on gaps

### Chat Summary
After creating the dashboard, provide:
- Link to the HTML artifact
- Top 3 competitive insights
- Biggest gaps/opportunities identified
- Any competitor moves worth watching

---

## HTML Artifact Standards

All HTML dashboards must be:
- **Self-contained** — Inline CSS and JS, no external dependencies except CDN
- **CDN libraries** — Chart.js from jsdelivr for any charts
- **Dark theme** — Consistent with canvas gallery styling
- **Responsive** — Works on desktop and mobile
- **Google Fonts** — Via CDN if needed

---

## Task-Specific Questions

1. What is your product and market category?
2. Which competitor URLs should I analyze?
3. What aspects matter most? (pricing, features, positioning)
4. Should I include your product in the comparison?
5. Any specific competitive questions you want answered?

---

## Related Skills

- **competitor-alternatives**: For creating "vs" and "alternative to" SEO pages
- **pricing-strategy**: For pricing decisions informed by competitive data
- **deep-research**: For deeper research on specific competitive topics
- **site-audit**: For detailed technical comparison of competitor sites
- **content-strategy**: For competitive content gap analysis
