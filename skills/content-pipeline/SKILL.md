---
name: content-pipeline
version: 1.0.0
description: When the user wants to go from a topic idea to a polished, published-quality article through a structured pipeline. Also use when the user mentions "content pipeline," "write an article," "blog post pipeline," "research and write," "long-form content," "article workflow," "publish-ready content," or "full article." This skill runs a 5-phase pipeline using subagents for research and drafting, producing a polished HTML article.
---

# Content Pipeline

You are an expert content strategist and writer. Your goal is to take a topic from idea to publication-ready HTML article through a structured 5-phase pipeline: Research, Outline, Draft, Edit, and Assembly.

## Initial Assessment

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before starting the pipeline, understand:

1. **Topic & Angle**
   - What is the article topic?
   - What unique angle or perspective should it take?
   - What is the core thesis or argument?

2. **Audience & Purpose**
   - Who is the target reader?
   - What should they know or do after reading?
   - Where will this be published? (blog, newsletter, documentation)

3. **Requirements**
   - Target word count?
   - Tone and style preferences?
   - Any must-include topics, examples, or data?
   - SEO target keyword (if applicable)?

---

## Pipeline Phases

### Phase 1: Research (Subagents + Browser)

Use `sessions_spawn` to create 3-4 research subagents, each investigating a different facet of the topic.

**Subagent tasks:**
- Each subagent uses the `browser` tool to navigate to relevant sources
- Takes snapshots and extracts key data, quotes, and statistics
- Returns structured findings with source URLs

**Example subagent assignment:**
```
Research: [FACET OF TOPIC]

Instructions:
1. Use the browser tool to find 3-5 authoritative sources on this facet
2. Extract key data points, statistics, expert quotes
3. Note current trends and recent developments
4. Identify unique angles not commonly covered

Return:
- Key findings (3-5 bullet points)
- Data points with sources
- Quotes with attribution
- Source URLs
- Suggested subtopics for the article
```

**Research synthesis (primary agent):**
After subagents return, compile a research brief:
- Merged key findings across all facets
- Strongest data points and quotes
- Unique angles to differentiate the article
- Knowledge gaps to acknowledge

### Phase 2: Outline (Primary Agent, User Approval)

Build a structured outline based on research findings:

1. **Working title** — Clear, benefit-driven, keyword-aware
2. **Hook/Intro** — Opening that pulls the reader in
3. **Section structure** — H2s and H3s with bullet notes per section
4. **Key data placement** — Where statistics and quotes will appear
5. **CTA/Conclusion** — What the reader should do next

**Present the outline to the user for approval before proceeding.**

Ask: "Here's the outline based on my research. Should I proceed with drafting, or would you like to adjust anything?"

### Phase 3: Draft (Parallel Subagents)

Use `sessions_spawn` to create 2-3 subagents, each drafting different sections of the article.

**Subagent assignment:**
```
Draft the following sections of an article about [TOPIC].

Outline for your sections:
[PASTE RELEVANT OUTLINE SECTIONS]

Research context:
[PASTE RELEVANT RESEARCH FINDINGS]

Writing guidelines:
- Tone: [SPECIFIED TONE]
- Target audience: [AUDIENCE]
- Use short paragraphs (2-3 sentences max)
- Include specific data and examples
- Write in active voice
- Avoid marketing jargon and filler
- Use transitions between sections
- Target [WORD_COUNT / NUM_SECTIONS] words for your sections

Return the drafted sections in order, with H2/H3 headers.
```

### Phase 4: Edit (Primary Agent)

Combine all drafted sections and perform a thorough editorial pass:

1. **Continuity** — Ensure consistent voice, tone, and logical flow between sections
2. **Transitions** — Smooth connections between sections written by different subagents
3. **Redundancy** — Remove repeated points across sections
4. **Clarity** — Simplify complex sentences, remove jargon
5. **Accuracy** — Verify claims match the research
6. **Opening** — Ensure the intro hooks and the thesis is clear
7. **Conclusion** — Ensure it ties back to the intro and has a clear CTA
8. **SEO** — Natural keyword placement in title, H2s, intro, and conclusion (if applicable)

**Quality checks:**
- No AI writing patterns (em dashes overuse, "In today's...", "Let's dive in")
- No unsupported claims
- No filler sentences that don't add value
- Specific > vague throughout

### Phase 5: HTML Assembly

Build a polished, self-contained HTML article and save to `~/clawd/canvas/`.

**Filename:** `article-[topic-slug]-[YYYY-MM-DD].html`

Use the article template from [references/article-template.md](references/article-template.md).

---

## Output Format

### Primary Output
Polished HTML article saved to `~/clawd/canvas/article-[topic-slug]-[YYYY-MM-DD].html`

### Article HTML Structure
1. **Hero section** — Title, subtitle, author, read time, date
2. **Table of contents** — Auto-generated from H2 headers
3. **Article body** — Formatted prose with pull quotes and data callouts
4. **CTA section** — Relevant call to action
5. **Sources** — Citation list (if research-heavy)

### Chat Summary
After creating the article, provide:
- Link to the HTML artifact
- Final word count
- Summary of the article's thesis and key points
- Any sections that could benefit from additional data or examples

---

## HTML Artifact Standards

All HTML articles must be:
- **Self-contained** — Inline CSS and JS
- **CDN libraries** — Google Fonts via CDN only
- **Dark theme** — Consistent with canvas gallery styling
- **Responsive** — Reads well on desktop and mobile
- **Print-friendly** — Clean print styles for PDF export

---

## Task-Specific Questions

1. What is the article topic and angle?
2. Who is the target audience?
3. What tone should it have? (conversational, professional, technical)
4. Target word count?
5. Any SEO keyword to target?
6. Where will this be published?

---

## Related Skills

- **deep-research**: For standalone research without article output
- **copywriting**: For marketing copy (shorter, conversion-focused)
- **copy-editing**: For editing existing articles (skip pipeline, edit only)
- **content-strategy**: For planning what articles to write
- **seo-audit**: For SEO optimization of existing content
