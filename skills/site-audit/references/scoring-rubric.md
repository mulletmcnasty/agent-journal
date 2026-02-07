# Site Audit Scoring Rubric

Use this rubric to score each dimension consistently on a 1-10 scale.

---

## Score Scale

| Score | Label | Meaning |
|-------|-------|---------|
| 9-10 | Excellent | Industry-leading, minimal issues |
| 7-8 | Good | Solid implementation, minor improvements possible |
| 5-6 | Average | Functional but with notable gaps |
| 3-4 | Below Average | Significant issues impacting effectiveness |
| 1-2 | Poor | Critical failures, needs major overhaul |

---

## Technical SEO (1-10)

### Criteria Breakdown

| Criterion | Weight | Score Guide |
|-----------|--------|-------------|
| Crawlability | 20% | 10: Clean robots.txt, XML sitemap, logical internal links. 5: Sitemap exists but issues. 1: No sitemap, blocked resources. |
| Indexation | 15% | 10: Proper canonicals, no noindex issues. 5: Some canonical issues. 1: Major indexation problems. |
| URL Structure | 15% | 10: Clean, descriptive, consistent. 5: Mostly clean, some oddities. 1: Dynamic params, no structure. |
| HTTPS / Security | 10% | 10: Full HTTPS, security headers. 5: HTTPS but missing headers. 1: HTTP or mixed content. |
| Structured Data | 15% | 10: Rich schema on all relevant pages. 5: Basic schema present. 1: No structured data. |
| Mobile-Friendliness | 15% | 10: Fully responsive, fast mobile. 5: Responsive but slow. 1: Not mobile-friendly. |
| Core Web Vitals | 10% | 10: All green. 5: Mixed. 1: All failing. |

---

## Content Quality (1-10)

### Criteria Breakdown

| Criterion | Weight | Score Guide |
|-----------|--------|-------------|
| Headline Clarity | 15% | 10: Clear, specific, benefit-driven. 5: Generic but functional. 1: Confusing or missing. |
| Value Proposition | 20% | 10: Immediately clear what you get and why. 5: Somewhat clear. 1: Can't tell what the product does. |
| Copy Quality | 20% | 10: Concise, specific, natural. 5: Readable but generic. 1: Jargon-heavy, unclear. |
| Content Depth | 15% | 10: Comprehensive, answers all questions. 5: Covers basics. 1: Thin, unhelpful. |
| CTA Effectiveness | 15% | 10: Clear action, compelling reason. 5: Present but generic. 1: Missing or confusing. |
| E-E-A-T Signals | 10% | 10: Author creds, real data, trust signals. 5: Some signals. 1: Anonymous, no proof. |
| Freshness | 5% | 10: Recently updated, current info. 5: Somewhat dated. 1: Clearly outdated. |

---

## Accessibility (1-10)

### Criteria Breakdown

| Criterion | Weight | Score Guide |
|-----------|--------|-------------|
| Color Contrast | 20% | 10: All text meets WCAG AA (4.5:1). 5: Most passes. 1: Widespread failures. |
| Alt Text | 15% | 10: All images have descriptive alt text. 5: Some present. 1: Missing on most images. |
| Keyboard Navigation | 20% | 10: Full keyboard access, logical tab order. 5: Mostly works. 1: Keyboard traps or inaccessible. |
| ARIA & Landmarks | 15% | 10: Proper landmarks, roles, labels. 5: Basic structure. 1: No ARIA usage. |
| Form Accessibility | 15% | 10: Labels, error messages, required fields. 5: Labels present. 1: No labels, poor errors. |
| Focus Indicators | 10% | 10: Visible focus on all interactive elements. 5: Default browser focus. 1: Focus removed with no replacement. |
| Screen Reader | 5% | 10: Logical reading order, skip nav. 5: Mostly readable. 1: Confusing order, hidden content. |

---

## Performance (1-10)

### Criteria Breakdown

| Criterion | Weight | Score Guide |
|-----------|--------|-------------|
| Perceived Speed | 25% | 10: Instant feel, no loading states. 5: Noticeable delay. 1: Multi-second blank screen. |
| Image Optimization | 20% | 10: WebP/AVIF, lazy loading, responsive. 5: Some optimization. 1: Uncompressed, no lazy load. |
| JavaScript | 15% | 10: Minimal JS, async/defer, code-split. 5: Some blocking JS. 1: Large render-blocking bundles. |
| Font Loading | 10% | 10: font-display swap, preloaded. 5: Loads but FOUT/FOIT. 1: Multiple large font files. |
| Caching | 15% | 10: Proper cache headers, immutable assets. 5: Some caching. 1: No cache headers. |
| CDN | 10% | 10: All assets CDN-delivered. 5: Partial CDN. 1: No CDN. |
| Resource Priority | 5% | 10: Critical CSS inlined, preloads. 5: Some optimization. 1: No prioritization. |

---

## UX / Design (1-10)

### Criteria Breakdown

| Criterion | Weight | Score Guide |
|-----------|--------|-------------|
| Visual Hierarchy | 20% | 10: Clear focal points, logical flow. 5: Somewhat guided. 1: Cluttered, no hierarchy. |
| Navigation | 20% | 10: Intuitive, clear labels, breadcrumbs. 5: Functional but confusing. 1: Hard to find pages. |
| Mobile Responsive | 15% | 10: Feels native on mobile. 5: Works but cramped. 1: Broken on mobile. |
| Consistency | 15% | 10: Unified colors, type, spacing. 5: Mostly consistent. 1: Multiple conflicting styles. |
| Interactive Elements | 15% | 10: Clear affordances, feedback. 5: Functional basics. 1: Dead clicks, no feedback. |
| Information Architecture | 10% | 10: Logical grouping, findable content. 5: Mostly organized. 1: Random page structure. |
| User Flow | 5% | 10: Clear path from landing to action. 5: Path exists but unclear. 1: Dead ends everywhere. |

---

## Color Coding for Scores

Use these colors in the dashboard:

```css
/* Score color mapping */
.score-excellent { color: #4ade80; } /* 9-10 */
.score-good      { color: #6c8cff; } /* 7-8 */
.score-average   { color: #fbbf24; } /* 5-6 */
.score-below     { color: #fb923c; } /* 3-4 */
.score-poor      { color: #f87171; } /* 1-2 */
```

---

## Radar Chart Configuration

```javascript
// Chart.js radar config for site audit
const config = {
  type: 'radar',
  data: {
    labels: ['Technical SEO', 'Content', 'Accessibility', 'Performance', 'UX/Design'],
    datasets: [{
      label: 'Site Score',
      data: [/* scores 1-10 */],
      backgroundColor: 'rgba(108, 140, 255, 0.2)',
      borderColor: 'rgba(108, 140, 255, 1)',
      borderWidth: 2,
      pointBackgroundColor: 'rgba(108, 140, 255, 1)',
      pointRadius: 5
    }]
  },
  options: {
    responsive: true,
    scales: {
      r: {
        min: 0,
        max: 10,
        ticks: {
          stepSize: 2,
          color: '#6b7084'
        },
        grid: { color: '#2a2e3e' },
        angleLines: { color: '#2a2e3e' },
        pointLabels: {
          color: '#e4e6ef',
          font: { size: 13, family: 'Inter' }
        }
      }
    },
    plugins: {
      legend: { display: false }
    }
  }
};
```
