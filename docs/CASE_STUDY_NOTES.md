# Case Study Notes

## Positioning

This repo is designed for data analyst and product analyst interviews. It intentionally narrows the full C5 Sentinel-SAR operational system into the parts that show analytical judgment:

- translating field workflows into measurable events
- defining KPIs that support command decisions
- preventing misleading metrics during aggregation
- communicating risk through thresholds and prioritization
- turning operational history into an after-action review

## Product Analytics Framing

The system is used during mass-casualty incidents, so the analytics layer has to answer questions that are immediate and decision-oriented:

| Product question | Metric response |
|---|---|
| Are the most critical patients being handled first? | Active priority score, Red patient load, reassessment age |
| Are patients moving fast enough? | Golden Hour compliance, time to first vitals, evacuation lag |
| Are medics overloaded? | Red patients per active medic, active patient count by sector |
| Are supplies becoming a blocker? | Inventory burn rate, stockout risk, open resupply requests |
| Is offline sync trustworthy? | Sync latency p95, stale device count, unprocessed outbox count |

## Interview Story

The strongest interview story is not "I built a dashboard." It is:

1. I modeled a chaotic field workflow as an event stream.
2. I projected the event stream into operational read models.
3. I defined KPIs that match commander decisions.
4. I built a Python analytics package to compute and report those KPIs.
5. I separated clinical/operational events from analytics telemetry to keep audit trails clean.

## Why The Repo Is Separate

The full operational repository is valuable, but it is broad: UX, schema, API, mobile workflow, security, offline sync, and product documentation.

This repository is focused. A recruiter or hiring manager can quickly see SQL, Python, KPI thinking, product metrics, and evidence of analytical communication without needing to understand the entire emergency-response system.
