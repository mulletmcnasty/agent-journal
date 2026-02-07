# Competitor Monitor — Matrix Dashboard Template

Use this HTML template for building competitor comparison dashboards. Customize the number of competitors and comparison dimensions.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{MARKET}} — Competitive Analysis</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Inter', system-ui, sans-serif;
      background: var(--bg-primary);
      color: var(--text-primary);
      line-height: 1.6;
      padding: 2rem;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
    }

    /* Header */
    .header {
      margin-bottom: 3rem;
      padding-bottom: 2rem;
      border-bottom: 1px solid var(--border);
    }

    .header h1 {
      font-size: 2rem;
      font-weight: 700;
      margin-bottom: 0.5rem;
    }

    .header .meta {
      color: var(--text-muted);
      font-size: 0.85rem;
    }

    /* Competitor Cards Row */
    .competitor-cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 1rem;
      margin-bottom: 3rem;
    }

    .competitor-card {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
      transition: border-color 0.2s;
    }

    .competitor-card:hover {
      border-color: var(--accent);
    }

    .competitor-card .name {
      font-size: 1.1rem;
      font-weight: 600;
      margin-bottom: 0.25rem;
    }

    .competitor-card .tagline {
      font-size: 0.85rem;
      color: var(--text-muted);
      margin-bottom: 1rem;
    }

    .competitor-card .stat-row {
      display: flex;
      justify-content: space-between;
      padding: 0.4rem 0;
      font-size: 0.85rem;
      border-top: 1px solid var(--border);
    }

    .competitor-card .stat-label { color: var(--text-muted); }
    .competitor-card .stat-value { font-weight: 500; }

    /* Feature Matrix */
    .matrix-section {
      margin-bottom: 3rem;
    }

    .section-title {
      font-size: 1.3rem;
      font-weight: 600;
      margin-bottom: 1.5rem;
    }

    .feature-matrix {
      width: 100%;
      border-collapse: collapse;
      background: var(--bg-secondary);
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid var(--border);
    }

    .feature-matrix thead th {
      padding: 1rem;
      text-align: center;
      font-weight: 600;
      font-size: 0.9rem;
      background: var(--bg-tertiary);
      border-bottom: 1px solid var(--border);
    }

    .feature-matrix thead th:first-child {
      text-align: left;
      min-width: 200px;
    }

    .feature-matrix tbody td {
      padding: 0.75rem 1rem;
      text-align: center;
      font-size: 0.9rem;
      border-bottom: 1px solid var(--border);
      color: var(--text-secondary);
    }

    .feature-matrix tbody td:first-child {
      text-align: left;
      font-weight: 500;
      color: var(--text-primary);
    }

    .feature-matrix tbody tr:hover td {
      background: var(--bg-tertiary);
    }

    /* Feature check/cross/partial icons */
    .check { color: var(--success); font-weight: 700; }
    .cross { color: var(--danger); }
    .partial { color: var(--warning); font-size: 0.8rem; }

    /* Category rows */
    .category-row td {
      background: var(--bg-tertiary) !important;
      font-weight: 600 !important;
      color: var(--accent) !important;
      font-size: 0.8rem !important;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    /* Pricing Section */
    .pricing-section {
      margin-bottom: 3rem;
    }

    .pricing-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1rem;
    }

    .pricing-card {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
    }

    .pricing-card .comp-name {
      font-weight: 600;
      margin-bottom: 1rem;
      padding-bottom: 0.75rem;
      border-bottom: 1px solid var(--border);
    }

    .plan {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.5rem 0;
      font-size: 0.9rem;
    }

    .plan .plan-name { color: var(--text-secondary); }

    .plan .plan-price {
      font-weight: 600;
      color: var(--text-primary);
    }

    .plan-highlight {
      background: var(--accent-dim);
      border-radius: 6px;
      padding: 0.5rem 0.75rem;
      margin: 0.25rem -0.75rem;
    }

    /* Chart Section */
    .chart-section {
      margin-bottom: 3rem;
    }

    .chart-container {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
      height: 350px;
    }

    /* Insights Section */
    .insights-section {
      margin-bottom: 3rem;
    }

    .insight-cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 1rem;
    }

    .insight-card {
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
    }

    .insight-card .insight-type {
      font-size: 0.75rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-bottom: 0.75rem;
    }

    .insight-card .insight-type.opportunity { color: var(--success); }
    .insight-card .insight-type.threat { color: var(--danger); }
    .insight-card .insight-type.trend { color: var(--warning); }
    .insight-card .insight-type.gap { color: var(--accent); }

    .insight-card h3 {
      font-size: 1rem;
      margin-bottom: 0.5rem;
    }

    .insight-card p {
      font-size: 0.9rem;
      color: var(--text-secondary);
    }

    /* Filter Tabs */
    .filter-tabs {
      display: flex;
      gap: 0.5rem;
      margin-bottom: 1.5rem;
      flex-wrap: wrap;
    }

    .filter-tab {
      padding: 0.4rem 1rem;
      border-radius: 6px;
      background: var(--bg-secondary);
      border: 1px solid var(--border);
      color: var(--text-secondary);
      font-size: 0.85rem;
      cursor: pointer;
      transition: all 0.2s;
    }

    .filter-tab:hover { border-color: var(--accent); color: var(--accent); }
    .filter-tab.active { background: var(--accent-dim); border-color: var(--accent); color: var(--accent); }

    /* Responsive */
    @media (max-width: 768px) {
      body { padding: 1rem; }
      .feature-matrix { font-size: 0.8rem; }
      .feature-matrix thead th,
      .feature-matrix tbody td { padding: 0.5rem; }
    }
  </style>
</head>
<body>
  <div class="container">

    <!-- Header -->
    <header class="header">
      <h1>{{MARKET}} — Competitive Analysis</h1>
      <div class="meta">
        Analyzed {{COMPETITOR_COUNT}} competitors &middot; {{DATE}}
      </div>
    </header>

    <!-- Competitor Overview Cards -->
    <div class="competitor-cards">
      <!-- Repeat per competitor -->
      <div class="competitor-card">
        <div class="name">{{COMPETITOR_NAME}}</div>
        <div class="tagline">{{TAGLINE}}</div>
        <div class="stat-row">
          <span class="stat-label">Starting Price</span>
          <span class="stat-value">{{STARTING_PRICE}}</span>
        </div>
        <div class="stat-row">
          <span class="stat-label">Free Tier</span>
          <span class="stat-value">{{FREE_TIER}}</span>
        </div>
        <div class="stat-row">
          <span class="stat-label">Target</span>
          <span class="stat-value">{{TARGET_AUDIENCE}}</span>
        </div>
      </div>
    </div>

    <!-- Feature Matrix -->
    <div class="matrix-section">
      <h2 class="section-title">Feature Comparison</h2>

      <div class="filter-tabs">
        <button class="filter-tab active" data-filter="all">All Features</button>
        <button class="filter-tab" data-filter="core">Core</button>
        <button class="filter-tab" data-filter="advanced">Advanced</button>
        <button class="filter-tab" data-filter="integrations">Integrations</button>
      </div>

      <table class="feature-matrix">
        <thead>
          <tr>
            <th>Feature</th>
            <th>{{COMP_1}}</th>
            <th>{{COMP_2}}</th>
            <th>{{COMP_3}}</th>
            <!-- Add columns as needed -->
          </tr>
        </thead>
        <tbody>
          <tr class="category-row" data-category="core">
            <td colspan="4">Core Features</td>
          </tr>
          <tr data-category="core">
            <td>{{FEATURE_NAME}}</td>
            <td><span class="check">&#10003;</span></td>
            <td><span class="cross">&#10007;</span></td>
            <td><span class="partial">Partial</span></td>
          </tr>
          <!-- Add more feature rows -->
        </tbody>
      </table>
    </div>

    <!-- Pricing Comparison -->
    <div class="pricing-section">
      <h2 class="section-title">Pricing Comparison</h2>
      <div class="chart-container">
        <canvas id="pricingChart"></canvas>
      </div>
    </div>

    <!-- Insights -->
    <div class="insights-section">
      <h2 class="section-title">Key Insights</h2>
      <div class="insight-cards">
        <div class="insight-card">
          <div class="insight-type opportunity">Opportunity</div>
          <h3>{{INSIGHT_TITLE}}</h3>
          <p>{{INSIGHT_DESCRIPTION}}</p>
        </div>
        <div class="insight-card">
          <div class="insight-type threat">Threat</div>
          <h3>{{INSIGHT_TITLE}}</h3>
          <p>{{INSIGHT_DESCRIPTION}}</p>
        </div>
        <div class="insight-card">
          <div class="insight-type gap">Gap</div>
          <h3>{{INSIGHT_TITLE}}</h3>
          <p>{{INSIGHT_DESCRIPTION}}</p>
        </div>
      </div>
    </div>

  </div>

  <script>
    // Pricing Chart
    const pricingCtx = document.getElementById('pricingChart').getContext('2d');
    new Chart(pricingCtx, {
      type: 'bar',
      data: {
        labels: [/* competitor names */],
        datasets: [
          {
            label: 'Starter Plan',
            data: [/* prices */],
            backgroundColor: 'rgba(108, 140, 255, 0.7)',
            borderColor: '#6c8cff',
            borderWidth: 1,
            borderRadius: 4
          },
          {
            label: 'Pro Plan',
            data: [/* prices */],
            backgroundColor: 'rgba(167, 139, 250, 0.7)',
            borderColor: '#a78bfa',
            borderWidth: 1,
            borderRadius: 4
          },
          {
            label: 'Enterprise Plan',
            data: [/* prices */],
            backgroundColor: 'rgba(52, 211, 153, 0.7)',
            borderColor: '#34d399',
            borderWidth: 1,
            borderRadius: 4
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
            labels: {
              color: '#9ca0b0',
              usePointStyle: true,
              padding: 20
            }
          },
          tooltip: {
            backgroundColor: '#1a1d27',
            titleColor: '#e4e6ef',
            bodyColor: '#9ca0b0',
            borderColor: '#2a2e3e',
            borderWidth: 1,
            padding: 12,
            cornerRadius: 8,
            callbacks: {
              label: (ctx) => `${ctx.dataset.label}: $${ctx.parsed.y}/mo`
            }
          }
        },
        scales: {
          x: {
            grid: { display: false },
            ticks: { color: '#9ca0b0' }
          },
          y: {
            beginAtZero: true,
            grid: { color: '#2a2e3e' },
            ticks: {
              color: '#9ca0b0',
              callback: (val) => '$' + val
            }
          }
        }
      }
    });

    // Feature filter tabs
    document.querySelectorAll('.filter-tab').forEach(tab => {
      tab.addEventListener('click', () => {
        document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        const filter = tab.dataset.filter;

        document.querySelectorAll('.feature-matrix tbody tr').forEach(row => {
          if (filter === 'all') {
            row.style.display = '';
          } else {
            row.style.display = row.dataset.category === filter ? '' : 'none';
          }
        });
      });
    });
  </script>
</body>
</html>
```

## Customization Notes

- **Competitor columns:** Add or remove `<th>` and `<td>` elements in the feature matrix to match competitor count
- **Feature categories:** Group features under category rows using `data-category` attributes
- **Pricing chart:** Update the Chart.js datasets with actual price data; adjust plan labels
- **Insight types:** Use `opportunity`, `threat`, `trend`, and `gap` classes for color coding
- **Filter tabs:** Match `data-filter` values to `data-category` values on table rows
- **Competitor cards:** Include the most relevant at-a-glance stats per competitor
