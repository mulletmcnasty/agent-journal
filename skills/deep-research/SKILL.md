---
name: deep-research
version: 1.0.0
description: When the user wants thorough, multi-angle research on a topic with citations and sources. Also use when the user mentions "deep research," "research report," "investigate," "comprehensive analysis," "literature review," "research synthesis," "multi-source research," or "research brief." This skill spawns parallel subagents to research different angles and synthesizes findings into an interactive HTML report.
---

# Deep Research

You are an expert research analyst. Your goal is to decompose a topic into multiple research angles, spawn parallel subagents for browser-based research, and synthesize findings into a comprehensive, well-cited HTML report.

## Initial Assessment

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before researching, understand:

1. **Topic & Scope**
   - What is the core research question or topic?
   - How broad or narrow should the research be?
   - Any specific angles or subtopics to prioritize?

2. **Purpose & Audience**
   - Who will read this report? (executive, technical team, general audience)
   - What decisions will this inform?
   - What level of detail is needed?

3. **Constraints**
   - Any sources to prioritize or avoid?
   - Time-sensitive information needed?
   - Industry or domain focus?

---

## Core Workflow

### Phase 1: Decompose the Topic

Break the research question into 3-5 distinct angles. Each angle should explore a different facet of the topic.

**Example for "AI in Healthcare":**
1. Current clinical applications and adoption rates
2. Regulatory landscape and compliance requirements
3. Technical capabilities and limitations
4. Economic impact and ROI data
5. Patient outcomes and safety evidence

### Phase 2: Spawn Research Subagents

Use `sessions_spawn` to create 3-5 parallel subagents. Each subagent gets:
- A specific research angle to investigate
- Instructions to use the `browser` tool to visit relevant URLs
- A structured output format for findings

**Subagent task template:**
```
Research angle: [ANGLE]

Instructions:
1. Use the browser tool to navigate to relevant sources for this topic
2. Take snapshots of key pages to extract information
3. Collect specific data points, statistics, and quotes with source URLs
4. Identify 3-5 key findings for this angle
5. Note any contradictions or debates in the literature

Return your findings in this format:
- Angle: [name]
- Key Findings: [numbered list]
- Supporting Data: [statistics, quotes with attribution]
- Sources: [list of URLs visited with brief description of each]
- Confidence Level: [high/medium/low based on source quality]
- Gaps: [what you couldn't find or verify]
```

### Phase 3: Synthesize Findings

After all subagents complete:
1. Merge findings across all angles
2. Identify common themes and contradictions
3. Rank findings by confidence level and source quality
4. Cross-reference claims across multiple sources
5. Build a narrative that connects the angles

### Phase 4: Build HTML Report

Create a self-contained HTML report and save it to `~/clawd/canvas/`.

**Filename:** `deep-research-[topic-slug]-[YYYY-MM-DD].html`

Use the report template from [references/report-template.md](references/report-template.md).

**Report must include:**
- Executive summary with key takeaways
- Sidebar navigation for each research angle
- Collapsible detail sections
- Inline citations linked to source URLs
- Confidence indicators per finding
- Citation footer with all sources

---

## Subagent Configuration

- **Model:** Use default subagent model (Gemini Flash, inherited from config)
- **Count:** 3-5 subagents depending on topic complexity
- **Browser usage:** Each subagent uses `browser` tool with `navigate` and `snapshot` to visit and extract from web sources
- **For complex reasoning tasks:** Consider suggesting `openrouter/deepseek/deepseek-r1:free` as model override

---

## Output Format

### Primary Output
Interactive HTML report saved to `~/clawd/canvas/deep-research-[topic-slug]-[YYYY-MM-DD].html`

### Report Structure
1. **Header** — Topic, date, scope summary
2. **Executive Summary** — 3-5 bullet key takeaways
3. **Research Angles** — One section per angle with findings
4. **Synthesis** — Cross-cutting themes and conclusions
5. **Recommendations** — Actionable next steps (if applicable)
6. **Sources** — Full citation list with URLs and access dates

### Chat Summary
After creating the report, provide:
- Link to the HTML artifact
- 3-5 sentence summary of key findings
- Any notable gaps or areas needing further research

---

## HTML Artifact Standards

All HTML reports must be:
- **Self-contained** — Inline CSS and JS, no external dependencies except CDN
- **CDN libraries** — jsdelivr only (for any needed libraries)
- **Dark theme** — Consistent with canvas gallery styling
- **Responsive** — Works on desktop and mobile
- **Google Fonts** — Via jsdelivr CDN if needed

---

## Task-Specific Questions

1. What is the core research question?
2. Are there specific angles or subtopics you want covered?
3. Who is the audience for this report?
4. Any specific sources or domains to prioritize?
5. How deep should each angle go?

---

## Related Skills

- **content-pipeline**: For turning research into published content
- **competitor-monitor**: For competitive research specifically
- **site-audit**: For website-specific technical research
- **content-strategy**: For research-informed content planning
