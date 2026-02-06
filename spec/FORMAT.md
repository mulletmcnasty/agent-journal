# Agent Journal Format Specification

Version: 1.0.0

## Overview

Agent Journal uses plain markdown files with a lightweight structure convention.

## File Structure

```
journal/
├── MEMORY.md              # Long-term curated memory
├── 2026-02-03.md         # Daily journal (YYYY-MM-DD)
├── 2026-02-04.md
├── 2026-02-05.md
└── ...
```

## Daily Journal Format

### Filename
`YYYY-MM-DD.md` (e.g., `2026-02-06.md`)

### Required Sections

#### 1. Title
```markdown
# YYYY-MM-DD — [Optional Subtitle]
```

Examples:
- `# 2026-02-06`
- `# 2026-02-06 — Day 4`
- `# 2026-02-03 — Birthday`

#### 2. Content Sections
Freeform markdown. Recommended sections:

**Time-Based:**
```markdown
## Morning (HH:MM-HH:MM)
## Afternoon (HH:MM-HH:MM)
## Evening (HH:MM-HH:MM)
```

**Category-Based:**
```markdown
## Work
## Learning
## Projects
## Social
## Reflections
```

**Event-Based:**
```markdown
## Built: [Project Name]
## Learned: [Topic]
## Fixed: [Issue]
## Met: [Person]
```

### Recommended Sections

```markdown
## Key Learnings
1. Learning one
2. Learning two

## Mistakes Made
- What went wrong
- Why it happened
- How to prevent

## Tomorrow
- Task 1
- Task 2

## Notes
- Random observations
- Links to explore
- Ideas to develop
```

### Metadata (Optional)

Add YAML frontmatter for structured metadata:

```markdown
---
date: 2026-02-06
day: 4
mood: productive
focus: building
tags: [projects, shellfish, agent-journal]
---

# 2026-02-06 — Day 4
```

## MEMORY.md Format

Long-term curated knowledge. Updated periodically by reviewing daily journals.

### Recommended Structure

```markdown
# Long-Term Memory

## Who I Am
- Identity
- Purpose
- Values

## Hard-Won Lessons
- Lessons that hurt
- Mistakes to never repeat
- Wisdom earned

## Skills Acquired
- Technical skills
- Soft skills
- Domain knowledge

## People & Relationships
- Name: context, contact, relationship

## Projects & Work
- What I've built
- What I'm building
- What I want to build

## Resources
- Useful tools
- Important docs
- Reference material

## Unsorted
- Recent additions not yet categorized
```

## Conventions

### Timestamps

Use 24-hour format:
```markdown
## 14:30 - Bug Fix
Fixed authentication issue...
```

### Links

Internal links to other journal entries:
```markdown
See [2026-02-05](2026-02-05.md#built-shellfish) for context.
```

External links:
```markdown
Reference: [Article Title](https://example.com)
```

### Code Blocks

Use standard markdown:
```markdown
\`\`\`bash
agent-journal log "Example entry"
\`\`\`
```

### Emphasis

- **Bold** for important points
- *Italic* for thoughts/reflections
- `Code` for technical terms

### Lists

Bullet lists for items:
```markdown
- Item 1
- Item 2
  - Sub-item
```

Numbered lists for sequences:
```markdown
1. Step one
2. Step two
3. Step three
```

### Emoji (Optional)

Use sparingly for quick visual parsing:
```markdown
## ✅ Completed Today
## ❌ Blocked
## 🔥 Urgent
## 💡 Ideas
## 🦞 Lobster Things
```

## Export Formats

### Blog Post

Daily journal → blog post transformation:

1. Remove internal notes
2. Add intro/conclusion if needed
3. Polish language
4. Add YAML frontmatter for Jekyll/Hugo/etc.

### Weekly Report

Aggregate multiple daily journals:

```markdown
# Week of YYYY-MM-DD

## Highlights
- Top 3 achievements

## Learnings
- Key insights from the week

## Metrics
- Quantitative summary

## Next Week
- Priorities
```

### Long-Form Content

Mine journal for themes:
- Technical deep-dives
- Lessons learned posts
- Project retrospectives
- Thought pieces

## Parsing Guidelines

For tooling authors:

1. **Title line:** First `# Heading` is the date/title
2. **Sections:** `## Headings` delineate entries
3. **Lists:** Markdown lists are discrete items
4. **Metadata:** YAML frontmatter (if present) provides structured data
5. **Search:** Full-text search across all `.md` files

## Validation

A valid daily journal:
- Has filename matching `YYYY-MM-DD.md`
- Starts with `# YYYY-MM-DD` title
- Contains valid markdown

A valid MEMORY.md:
- Starts with `# Long-Term Memory` or `# MEMORY.md`
- Contains valid markdown

## Version History

- **1.0.0** (2026-02-06): Initial specification
