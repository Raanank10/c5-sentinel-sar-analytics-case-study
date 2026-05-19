# Interview Talk Track

## 30-Second Version

C5 Sentinel-SAR is a product analytics case study built from an operational rescue-command prototype. I modeled field actions as an event stream, projected them into patient and inventory read models, and built SQL/Python analytics that answer commander questions during a mass-casualty incident: patient load, urgency, supply risk, sync health, and after-action review.

## 2-Minute Version

The main analytics problem is that field medicine during a mass-casualty incident is fast, offline, and noisy. A dashboard cannot just count records. It has to identify what needs action now.

I built the analytics layer around four ideas:

1. Events are the source of truth, because disconnected devices need an audit trail that can merge later.
2. Read models make the data usable for command decisions: active patients, current inventory, alerts, sync state.
3. KPI definitions must map to operational decisions, not vanity metrics.
4. Aggregations need care. For example, patients, alerts, and devices must be aggregated separately before joining, otherwise command metrics inflate through Cartesian products.

The result is a compact analytics package with Python KPI computation, SQL KPI views, a metrics dictionary, and an AAR report sample.

## Best Technical Points To Mention

| Topic | What it demonstrates |
|---|---|
| Event-sourced design | I can model operational workflows as reliable analytical data |
| Append-only inventory ledger | I understand auditability and derived current state |
| Golden Hour compliance | I can translate domain goals into measurable KPIs |
| Stockout risk | I can turn historical usage into forward-looking operational risk |
| Sync latency p95 | I can measure trust in offline-first data |
| Cartesian join fix | I can catch subtle SQL bugs that would mislead decision makers |

## Product Analyst Angle

The product decision was to separate critical alerts from lower-priority alerts because medics in an MCI cannot process a noisy notification stream. That is a product analytics decision: the metric is only useful if it changes behavior without increasing cognitive load.

## Data Analyst Angle

The strongest data story is the pipeline:

Field event -> event log -> SQL projection -> KPI view -> Python report -> commander decision.

That shows data modeling, SQL, Python, metric definition, and communication in one coherent project.

## Good Closing Line

This project is not only a dashboard. It is a decision-support analytics layer: every metric has a user, a threshold, and an action attached to it.
