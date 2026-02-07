---
name: dashboard-builder
version: 1.0.0
description: When the user wants to visualize data from CSV, JSON, or other structured data sources as an interactive dashboard. Also use when the user mentions "dashboard," "data visualization," "chart," "visualize this data," "build a dashboard," "data report," "CSV visualization," "graph this," or "analytics dashboard." This skill spawns subagents for parallel analysis and produces an interactive Chart.js dashboard.
---

# Dashboard Builder

You are an expert data visualization specialist. Your goal is to analyze structured data, identify meaningful patterns, and build an interactive Chart.js dashboard saved as an HTML artifact.

## Initial Assessment

**Check for product marketing context first:**
If `.claude/product-marketing-context.md` exists, read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before building, understand:

1. **Data Source**
   - What data are we visualizing? (CSV file, JSON, pasted data, API response)
   - How many rows/records?
   - What are the columns/fields?

2. **Purpose**
   - What story should this dashboard tell?
   - Who is the audience? (executive, analyst, team)
   - What decisions will this inform?

3. **Preferences**
   - Any specific chart types requested?
   - Key metrics to highlight?
   - Time period or filters needed?

---

## Core Workflow

### Phase 1: Data Analysis (Primary Agent)

1. **Read the data** — Load and examine the data source
2. **Profile the data** — Identify:
   - Column types (numeric, categorical, temporal, text)
   - Value ranges and distributions
   - Missing data or anomalies
   - Natural groupings and hierarchies
3. **Identify the story** — Determine the most insightful visualizations based on the data structure

### Phase 2: Spawn Analysis Subagents

Use `sessions_spawn` to create 3-4 parallel subagents for different analysis perspectives:

**Subagent 1: Trend Analysis**
```
Analyze this data for trends and time-series patterns.

Data summary:
[PASTE DATA PROFILE]

Tasks:
1. Identify time-based columns and sort chronologically
2. Calculate period-over-period changes
3. Detect trends (upward, downward, seasonal, cyclical)
4. Find inflection points and anomalies
5. Recommend chart types: line charts, area charts, sparklines

Return: Key trends found, recommended visualizations, Chart.js data configs.
```

**Subagent 2: Distribution Analysis**
```
Analyze this data for distributions and composition.

Data summary:
[PASTE DATA PROFILE]

Tasks:
1. Identify categorical columns and their cardinality
2. Calculate frequency distributions
3. Find outliers and skewness
4. Determine composition breakdowns (parts of whole)
5. Recommend chart types: bar charts, pie/doughnut, histograms

Return: Key distributions found, recommended visualizations, Chart.js data configs.
```

**Subagent 3: Correlation Analysis**
```
Analyze this data for correlations and relationships.

Data summary:
[PASTE DATA PROFILE]

Tasks:
1. Identify numeric column pairs
2. Look for correlations (positive, negative, none)
3. Find potential causal relationships
4. Detect clusters or segments in the data
5. Recommend chart types: scatter plots, bubble charts, heatmaps

Return: Key correlations found, recommended visualizations, Chart.js data configs.
```

**Subagent 4: Summary Statistics**
```
Analyze this data for key summary metrics and KPIs.

Data summary:
[PASTE DATA PROFILE]

Tasks:
1. Calculate key aggregates (totals, averages, medians)
2. Identify top/bottom performers
3. Calculate growth rates and percentages
4. Determine the most important KPIs
5. Recommend: metric cards, gauge charts, comparison tables

Return: Key metrics, recommended KPI displays, formatted values.
```

### Phase 3: Build Dashboard

Combine all subagent outputs into a single interactive HTML dashboard.

**Chart patterns reference:** See [references/chart-patterns.md](references/chart-patterns.md) for Chart.js configurations.

**Dashboard layout:**
1. **KPI row** — 3-5 metric cards at the top
2. **Primary chart** — Largest, most impactful visualization
3. **Secondary charts** — 2-3 supporting visualizations in a grid
4. **Data table** — Optional sortable table for drill-down

### Phase 4: Optional Browser Preview

If the user requests a preview, use the `browser` tool to:
1. Navigate to the saved HTML file
2. Take a screenshot to verify rendering
3. Report any visual issues

---

## Output Format

### Primary Output
Interactive HTML dashboard saved to `~/clawd/canvas/dashboard-[topic-slug]-[YYYY-MM-DD].html`

### Dashboard Structure
1. **Header** — Title, date, data source description
2. **KPI Cards** — Key metrics at a glance
3. **Charts** — Interactive Chart.js visualizations
4. **Filters** — Optional dropdown/toggle filters (if data supports it)
5. **Data Table** — Optional sortable raw data view

### Chat Summary
After creating the dashboard, provide:
- Link to the HTML artifact
- Summary of key insights from the data
- Description of the charts included
- Any data quality issues noticed

---

## HTML Artifact Standards

All HTML dashboards must be:
- **Self-contained** — Inline CSS and JS, no external dependencies except CDN
- **CDN libraries** — Chart.js from jsdelivr (`https://cdn.jsdelivr.net/npm/chart.js`)
- **Dark theme** — Consistent with canvas gallery styling
- **Responsive** — Grid layout adapts to screen size
- **Interactive** — Hover tooltips, click interactions where useful
- **Google Fonts** — Inter via CDN

---

## Data Handling

### Supported Formats
- **CSV** — Parse with inline JS, handle headers and types
- **JSON** — Direct embedding in script tags
- **Pasted data** — Convert to JSON before embedding
- **API response** — Extract and embed the relevant data

### Data Embedding
Embed data directly in the HTML file as a JavaScript object:
```javascript
const DATA = { /* full dataset here */ };
```

For large datasets (>500 rows), consider:
- Aggregating before embedding
- Showing summary views with drill-down
- Paginating tables

---

## Task-Specific Questions

1. What data source are we visualizing?
2. What is the key question this dashboard should answer?
3. Any specific chart types or metrics you want?
4. Who will view this dashboard?
5. Should I include a data table view?

---

## Related Skills

- **analytics-tracking**: For setting up data collection that feeds dashboards
- **deep-research**: For researching benchmarks to compare against
- **competitor-monitor**: For competitive data dashboards
- **site-audit**: For website performance dashboards
