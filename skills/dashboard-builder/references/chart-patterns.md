# Chart.js Dark Theme Patterns

Reusable Chart.js configurations for dark-themed dashboards. All charts use the canvas gallery color scheme.

---

## Global Defaults

Apply these defaults before creating any charts:

```javascript
// Global Chart.js defaults for dark theme
Chart.defaults.color = '#9ca0b0';
Chart.defaults.borderColor = '#2a2e3e';
Chart.defaults.font.family = "'Inter', system-ui, sans-serif";

// Color palette (use in order)
const COLORS = {
  primary: '#6c8cff',
  secondary: '#a78bfa',
  tertiary: '#34d399',
  quaternary: '#fbbf24',
  quinary: '#f87171',
  senary: '#fb923c',
  // Extended palette
  palette: [
    '#6c8cff', '#a78bfa', '#34d399', '#fbbf24',
    '#f87171', '#fb923c', '#38bdf8', '#e879f9',
    '#4ade80', '#facc15'
  ],
  // With alpha
  primaryAlpha: (a) => `rgba(108, 140, 255, ${a})`,
  secondaryAlpha: (a) => `rgba(167, 139, 250, ${a})`,
  tertiaryAlpha: (a) => `rgba(52, 211, 153, ${a})`
};
```

---

## Line Chart (Trends)

```javascript
new Chart(ctx, {
  type: 'line',
  data: {
    labels: [/* time labels */],
    datasets: [{
      label: 'Metric Name',
      data: [/* values */],
      borderColor: COLORS.primary,
      backgroundColor: COLORS.primaryAlpha(0.1),
      fill: true,
      tension: 0.3,
      pointRadius: 3,
      pointHoverRadius: 6,
      borderWidth: 2
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    interaction: { intersect: false, mode: 'index' },
    plugins: {
      legend: {
        position: 'top',
        labels: { usePointStyle: true, padding: 20 }
      },
      tooltip: {
        backgroundColor: '#1a1d27',
        titleColor: '#e4e6ef',
        bodyColor: '#9ca0b0',
        borderColor: '#2a2e3e',
        borderWidth: 1,
        padding: 12,
        cornerRadius: 8
      }
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { maxTicksLimit: 10 }
      },
      y: {
        beginAtZero: true,
        grid: { color: '#2a2e3e' }
      }
    }
  }
});
```

---

## Bar Chart (Comparisons)

```javascript
new Chart(ctx, {
  type: 'bar',
  data: {
    labels: [/* categories */],
    datasets: [{
      label: 'Metric',
      data: [/* values */],
      backgroundColor: COLORS.palette.map(c => c + '99'), // 60% opacity
      borderColor: COLORS.palette,
      borderWidth: 1,
      borderRadius: 6,
      borderSkipped: false
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: '#1a1d27',
        borderColor: '#2a2e3e',
        borderWidth: 1,
        padding: 12,
        cornerRadius: 8
      }
    },
    scales: {
      x: { grid: { display: false } },
      y: {
        beginAtZero: true,
        grid: { color: '#2a2e3e' }
      }
    }
  }
});
```

---

## Doughnut Chart (Composition)

```javascript
new Chart(ctx, {
  type: 'doughnut',
  data: {
    labels: [/* categories */],
    datasets: [{
      data: [/* values */],
      backgroundColor: COLORS.palette.slice(0, /* num categories */),
      borderColor: '#0f1117',
      borderWidth: 3,
      hoverBorderColor: '#242837'
    }]
  },
  options: {
    responsive: true,
    cutout: '65%',
    plugins: {
      legend: {
        position: 'right',
        labels: {
          usePointStyle: true,
          padding: 16,
          font: { size: 13 }
        }
      },
      tooltip: {
        backgroundColor: '#1a1d27',
        borderColor: '#2a2e3e',
        borderWidth: 1,
        padding: 12,
        cornerRadius: 8,
        callbacks: {
          label: (ctx) => {
            const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
            const pct = ((ctx.parsed / total) * 100).toFixed(1);
            return `${ctx.label}: ${ctx.formattedValue} (${pct}%)`;
          }
        }
      }
    }
  }
});
```

---

## Horizontal Bar (Rankings)

```javascript
new Chart(ctx, {
  type: 'bar',
  data: {
    labels: [/* items */],
    datasets: [{
      data: [/* values */],
      backgroundColor: COLORS.primaryAlpha(0.6),
      borderColor: COLORS.primary,
      borderWidth: 1,
      borderRadius: 4
    }]
  },
  options: {
    indexAxis: 'y',
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: {
        beginAtZero: true,
        grid: { color: '#2a2e3e' }
      },
      y: {
        grid: { display: false }
      }
    }
  }
});
```

---

## Multi-line (Comparison Over Time)

```javascript
new Chart(ctx, {
  type: 'line',
  data: {
    labels: [/* time labels */],
    datasets: [
      {
        label: 'Series A',
        data: [/* values */],
        borderColor: COLORS.primary,
        backgroundColor: 'transparent',
        tension: 0.3,
        borderWidth: 2,
        pointRadius: 2
      },
      {
        label: 'Series B',
        data: [/* values */],
        borderColor: COLORS.secondary,
        backgroundColor: 'transparent',
        tension: 0.3,
        borderWidth: 2,
        pointRadius: 2
      }
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    interaction: { intersect: false, mode: 'index' },
    plugins: {
      legend: {
        position: 'top',
        labels: { usePointStyle: true }
      }
    },
    scales: {
      x: { grid: { display: false } },
      y: { grid: { color: '#2a2e3e' } }
    }
  }
});
```

---

## KPI Card (HTML/CSS)

```html
<div class="kpi-card">
  <div class="kpi-label">Total Revenue</div>
  <div class="kpi-value">$142,580</div>
  <div class="kpi-change positive">+12.3% vs last month</div>
</div>

<style>
.kpi-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.kpi-card {
  background: #1a1d27;
  border: 1px solid #2a2e3e;
  border-radius: 12px;
  padding: 1.5rem;
}

.kpi-label {
  font-size: 0.8rem;
  color: #6b7084;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.5rem;
}

.kpi-value {
  font-size: 2rem;
  font-weight: 700;
  color: #e4e6ef;
  line-height: 1.2;
}

.kpi-change {
  font-size: 0.85rem;
  margin-top: 0.5rem;
}

.kpi-change.positive { color: #4ade80; }
.kpi-change.negative { color: #f87171; }
.kpi-change.neutral  { color: #9ca0b0; }
</style>
```

---

## Chart Container (HTML/CSS)

```html
<div class="chart-grid">
  <div class="chart-card full-width">
    <h3 class="chart-title">Revenue Over Time</h3>
    <div class="chart-wrap"><canvas id="chart1"></canvas></div>
  </div>
  <div class="chart-card">
    <h3 class="chart-title">Revenue by Category</h3>
    <div class="chart-wrap"><canvas id="chart2"></canvas></div>
  </div>
  <div class="chart-card">
    <h3 class="chart-title">Top Products</h3>
    <div class="chart-wrap"><canvas id="chart3"></canvas></div>
  </div>
</div>

<style>
.chart-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.chart-card {
  background: #1a1d27;
  border: 1px solid #2a2e3e;
  border-radius: 12px;
  padding: 1.5rem;
}

.chart-card.full-width {
  grid-column: 1 / -1;
}

.chart-title {
  font-size: 1rem;
  font-weight: 600;
  color: #e4e6ef;
  margin-bottom: 1rem;
}

.chart-wrap {
  position: relative;
  height: 300px;
}

.chart-card.full-width .chart-wrap {
  height: 350px;
}

@media (max-width: 768px) {
  .chart-grid { grid-template-columns: 1fr; }
}
</style>
```

---

## Sortable Data Table (HTML/CSS/JS)

```html
<div class="table-card">
  <h3 class="chart-title">Data Details</h3>
  <table class="data-table" id="dataTable">
    <thead>
      <tr>
        <th data-sort="string">Name</th>
        <th data-sort="number">Value</th>
        <th data-sort="number">Change</th>
      </tr>
    </thead>
    <tbody>
      <!-- Rows populated by JS -->
    </tbody>
  </table>
</div>

<style>
.table-card {
  background: #1a1d27;
  border: 1px solid #2a2e3e;
  border-radius: 12px;
  padding: 1.5rem;
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.data-table th {
  text-align: left;
  padding: 0.75rem 1rem;
  color: #6b7084;
  font-weight: 500;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  border-bottom: 1px solid #2a2e3e;
  cursor: pointer;
  user-select: none;
}

.data-table th:hover { color: #e4e6ef; }

.data-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #2a2e3e;
  color: #9ca0b0;
}

.data-table tr:hover td {
  background: #242837;
}
</style>

<script>
// Simple sortable table
document.querySelectorAll('.data-table th[data-sort]').forEach(th => {
  th.addEventListener('click', () => {
    const table = th.closest('table');
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.rows);
    const idx = th.cellIndex;
    const type = th.dataset.sort;
    const asc = th.dataset.dir !== 'asc';
    th.dataset.dir = asc ? 'asc' : 'desc';

    rows.sort((a, b) => {
      const av = a.cells[idx].textContent.trim();
      const bv = b.cells[idx].textContent.trim();
      if (type === 'number') {
        return asc
          ? parseFloat(av.replace(/[^0-9.-]/g, '')) - parseFloat(bv.replace(/[^0-9.-]/g, ''))
          : parseFloat(bv.replace(/[^0-9.-]/g, '')) - parseFloat(av.replace(/[^0-9.-]/g, ''));
      }
      return asc ? av.localeCompare(bv) : bv.localeCompare(av);
    });

    rows.forEach(row => tbody.appendChild(row));
  });
});
</script>
```
