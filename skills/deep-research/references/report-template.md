# Deep Research Report — HTML Template

Use this HTML skeleton when building deep research reports. Customize sections based on the number of research angles.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{TOPIC}} — Deep Research Report</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

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
      --success: #4ade80;
      --warning: #fbbf24;
      --danger: #f87171;
      --border: #2a2e3e;
      --sidebar-width: 260px;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Inter', system-ui, sans-serif;
      background: var(--bg-primary);
      color: var(--text-primary);
      line-height: 1.7;
      display: flex;
      min-height: 100vh;
    }

    /* Sidebar Navigation */
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      width: var(--sidebar-width);
      height: 100vh;
      background: var(--bg-secondary);
      border-right: 1px solid var(--border);
      padding: 2rem 1.25rem;
      overflow-y: auto;
      z-index: 100;
    }

    .sidebar h2 {
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: var(--text-muted);
      margin-bottom: 1rem;
    }

    .sidebar nav a {
      display: block;
      padding: 0.5rem 0.75rem;
      margin-bottom: 0.25rem;
      color: var(--text-secondary);
      text-decoration: none;
      font-size: 0.875rem;
      border-radius: 6px;
      transition: all 0.2s;
    }

    .sidebar nav a:hover,
    .sidebar nav a.active {
      background: var(--accent-dim);
      color: var(--accent);
    }

    /* Main Content */
    .main {
      margin-left: var(--sidebar-width);
      flex: 1;
      padding: 3rem 4rem;
      max-width: 900px;
    }

    /* Header */
    .report-header {
      margin-bottom: 3rem;
      padding-bottom: 2rem;
      border-bottom: 1px solid var(--border);
    }

    .report-header h1 {
      font-size: 2rem;
      font-weight: 700;
      margin-bottom: 0.75rem;
      line-height: 1.3;
    }

    .report-meta {
      display: flex;
      gap: 1.5rem;
      color: var(--text-muted);
      font-size: 0.85rem;
    }

    .report-meta span {
      display: flex;
      align-items: center;
      gap: 0.4rem;
    }

    /* Executive Summary */
    .executive-summary {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 2rem;
      margin-bottom: 3rem;
    }

    .executive-summary h2 {
      font-size: 1.1rem;
      font-weight: 600;
      margin-bottom: 1rem;
      color: var(--accent);
    }

    .executive-summary ul {
      list-style: none;
      padding: 0;
    }

    .executive-summary li {
      padding: 0.5rem 0;
      padding-left: 1.5rem;
      position: relative;
      color: var(--text-secondary);
    }

    .executive-summary li::before {
      content: '';
      position: absolute;
      left: 0;
      top: 0.9rem;
      width: 8px;
      height: 8px;
      background: var(--accent);
      border-radius: 50%;
    }

    /* Section */
    .section {
      margin-bottom: 3rem;
    }

    .section h2 {
      font-size: 1.4rem;
      font-weight: 600;
      margin-bottom: 1.5rem;
      padding-bottom: 0.5rem;
      border-bottom: 2px solid var(--accent-dim);
    }

    .section h3 {
      font-size: 1.1rem;
      font-weight: 500;
      margin-top: 1.5rem;
      margin-bottom: 0.75rem;
      color: var(--text-primary);
    }

    .section p {
      color: var(--text-secondary);
      margin-bottom: 1rem;
    }

    /* Collapsible */
    details {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 8px;
      margin-bottom: 1rem;
      overflow: hidden;
    }

    summary {
      padding: 1rem 1.25rem;
      cursor: pointer;
      font-weight: 500;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      user-select: none;
    }

    summary:hover { background: var(--bg-tertiary); }

    summary::marker { content: ''; }

    summary::before {
      content: '\25B6';
      font-size: 0.7rem;
      transition: transform 0.2s;
      color: var(--text-muted);
    }

    details[open] summary::before {
      transform: rotate(90deg);
    }

    details .detail-content {
      padding: 0 1.25rem 1.25rem;
      color: var(--text-secondary);
    }

    /* Confidence Badge */
    .confidence {
      display: inline-flex;
      align-items: center;
      gap: 0.3rem;
      padding: 0.2rem 0.6rem;
      border-radius: 4px;
      font-size: 0.75rem;
      font-weight: 500;
    }

    .confidence.high { background: rgba(74, 222, 128, 0.15); color: var(--success); }
    .confidence.medium { background: rgba(251, 191, 36, 0.15); color: var(--warning); }
    .confidence.low { background: rgba(248, 113, 113, 0.15); color: var(--danger); }

    /* Citation */
    .citation {
      color: var(--accent);
      cursor: pointer;
      font-size: 0.75rem;
      vertical-align: super;
      text-decoration: none;
    }

    .citation:hover { text-decoration: underline; }

    /* Sources Footer */
    .sources {
      margin-top: 4rem;
      padding-top: 2rem;
      border-top: 1px solid var(--border);
    }

    .sources h2 {
      font-size: 1.2rem;
      margin-bottom: 1.5rem;
    }

    .source-item {
      display: flex;
      gap: 0.75rem;
      padding: 0.75rem 0;
      border-bottom: 1px solid var(--border);
      font-size: 0.875rem;
    }

    .source-num {
      color: var(--accent);
      font-weight: 600;
      min-width: 2rem;
    }

    .source-item a {
      color: var(--accent);
      text-decoration: none;
    }

    .source-item a:hover { text-decoration: underline; }

    /* Finding Card */
    .finding-card {
      background: var(--bg-tertiary);
      border-radius: 8px;
      padding: 1.25rem;
      margin-bottom: 1rem;
    }

    .finding-card .finding-title {
      font-weight: 600;
      margin-bottom: 0.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .finding-card p {
      font-size: 0.9rem;
      margin-bottom: 0.5rem;
    }

    /* Responsive */
    @media (max-width: 900px) {
      .sidebar { display: none; }
      .main { margin-left: 0; padding: 2rem 1.5rem; }
    }
  </style>
</head>
<body>

  <!-- Sidebar -->
  <aside class="sidebar">
    <h2>Contents</h2>
    <nav>
      <a href="#summary">Executive Summary</a>
      <!-- Repeat for each angle: -->
      <a href="#angle-1">{{ANGLE_1_NAME}}</a>
      <a href="#angle-2">{{ANGLE_2_NAME}}</a>
      <a href="#angle-3">{{ANGLE_3_NAME}}</a>
      <!-- Add more as needed -->
      <a href="#synthesis">Synthesis</a>
      <a href="#recommendations">Recommendations</a>
      <a href="#sources">Sources</a>
    </nav>
  </aside>

  <!-- Main Content -->
  <div class="main">

    <!-- Header -->
    <header class="report-header">
      <h1>{{TOPIC}}</h1>
      <div class="report-meta">
        <span>{{DATE}}</span>
        <span>{{ANGLE_COUNT}} research angles</span>
        <span>{{SOURCE_COUNT}} sources</span>
      </div>
    </header>

    <!-- Executive Summary -->
    <div id="summary" class="executive-summary">
      <h2>Executive Summary</h2>
      <ul>
        <li>{{TAKEAWAY_1}}</li>
        <li>{{TAKEAWAY_2}}</li>
        <li>{{TAKEAWAY_3}}</li>
      </ul>
    </div>

    <!-- Research Angle Section (repeat per angle) -->
    <div id="angle-1" class="section">
      <h2>{{ANGLE_1_NAME}}</h2>
      <p>{{ANGLE_1_OVERVIEW}}</p>

      <div class="finding-card">
        <div class="finding-title">
          {{FINDING_TITLE}}
          <span class="confidence high">High confidence</span>
        </div>
        <p>{{FINDING_DETAIL}} <a href="#src-1" class="citation">[1]</a></p>
      </div>

      <details>
        <summary>Supporting Evidence</summary>
        <div class="detail-content">
          <p>{{DETAILED_EVIDENCE}}</p>
        </div>
      </details>
    </div>

    <!-- Synthesis -->
    <div id="synthesis" class="section">
      <h2>Synthesis</h2>
      <p>{{CROSS_CUTTING_THEMES}}</p>
    </div>

    <!-- Recommendations -->
    <div id="recommendations" class="section">
      <h2>Recommendations</h2>
      <p>{{ACTIONABLE_RECOMMENDATIONS}}</p>
    </div>

    <!-- Sources -->
    <div id="sources" class="sources">
      <h2>Sources</h2>
      <div class="source-item" id="src-1">
        <span class="source-num">[1]</span>
        <div>
          <strong>{{SOURCE_TITLE}}</strong><br>
          <a href="{{SOURCE_URL}}" target="_blank" rel="noopener">{{SOURCE_URL}}</a>
          <br><span style="color: var(--text-muted); font-size: 0.8rem;">Accessed {{DATE}}</span>
        </div>
      </div>
      <!-- Repeat for each source -->
    </div>

  </div>

  <script>
    // Sidebar active state on scroll
    const sections = document.querySelectorAll('.section, .executive-summary, .sources');
    const navLinks = document.querySelectorAll('.sidebar nav a');

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          navLinks.forEach(link => link.classList.remove('active'));
          const id = entry.target.id;
          const activeLink = document.querySelector(`.sidebar nav a[href="#${id}"]`);
          if (activeLink) activeLink.classList.add('active');
        }
      });
    }, { rootMargin: '-20% 0px -70% 0px' });

    sections.forEach(section => {
      if (section.id) observer.observe(section);
    });
  </script>
</body>
</html>
```

## Customization Notes

- **Angles:** Add or remove `#angle-N` sections based on the number of research angles (3-5)
- **Findings:** Each angle should have 3-5 finding cards with confidence badges
- **Citations:** Use `[N]` format linking to `#src-N` in the sources footer
- **Confidence levels:** `high` (multiple reliable sources agree), `medium` (limited sources or some conflict), `low` (single source or unverified)
- **Collapsible sections:** Use `<details>` for supporting evidence, raw data, or lengthy quotes
- **Colors:** Maintain the dark theme variables — do not change the color scheme
