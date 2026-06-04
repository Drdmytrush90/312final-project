# 312 Final Project — Story 2.1: Metrics & SLOs

**Student:** Dmytro (GitHub: Drdmytrush90)
**Story:** 2.1 — Metrics & SLOs
**Epic:** Epic 2 — Observability

---

## What this repo is

This is my personal working repo for the final project.
It contains my skills reference, my progress journal, and the actual deliverable I am building.

---

## Repo structure

```
312final-project/
├── README.md                  ← this file — repo overview
├── PROGRESS.md                ← session memory — read this to resume any session
│
├── eks-monitoring/            ← THE REAL DELIVERABLE (built in Phase 2-5)
│   └── .gitkeep              ← placeholder until Phase 2
│
├── skills/                    ← reference skills used while building
│   ├── 02-devops-advanced/   ← Helm, Prometheus, Grafana, Alertmanager
│   └── 13-aws-skills/        ← EKS, IAM, CloudWatch
│
└── docs/                      ← notes, diagrams, SLO document (Phase 5)
```

---

## What I am building (Story 2.1 summary)

I am the team's metrics owner. My job is to:

1. Deploy **Prometheus + Grafana + Alertmanager** on EKS as a locally-vendored Helm chart under `eks-monitoring/`
2. Prometheus scrapes the **cluster + at least one teammate's app**
3. Grafana reads both **Prometheus** and **AWS CloudWatch**
4. **Dashboards as code** — provisioned from the chart, not clicked by hand in the UI
5. Grafana is **access-restricted** — IP allowlist + auth + credentials from AWS Secrets Manager
6. Define **at least one SLO** — SLI, target, measurement window, error budget, and a response plan
7. Wire my section into `deploy-platform-tools.yaml`
8. Write `README` + `WORKING-WITH-AI.md` memoir

The interview story: *"I owned the metrics stack and defined the SLO that became the contract between platform and product."*

---

## My 5-phase plan

| Phase | Goal | Status |
|-------|------|--------|
| 1 | Understand EKS, Helm, Prometheus, Grafana, Alertmanager, CloudWatch | ✅ Done |
| 2 | Design `eks-monitoring/` Helm chart structure + per-env values | ⬜ Next |
| 3 | Prometheus scrape configs + CloudWatch IAM role | ⬜ Todo |
| 4 | Dashboards as code + security | ⬜ Todo |
| 5 | Define and defend the SLO | ⬜ Todo |

---

## How to resume a session with Claude

1. Open a new Claude chat at claude.ai
2. Generate a **fresh GitHub token** (never reuse old ones)
3. Paste the token and say: *"Here is my progress file"*
4. Paste the full contents of `PROGRESS.md`
5. Claude will know exactly where we left off

---

## Skills reference

| Skill | Phase | What it helps build |
|-------|-------|---------------------|
| `helm-chart-generator` | 2 | The `eks-monitoring/` chart scaffold |
| `helm-values-manager` | 2 | Per-env values: dev / staging / prod |
| `prometheus-config-generator` | 3 | Scrape configs and ServiceMonitors |
| `iam-role-generator` | 3 | IAM role for CloudWatch → Grafana |
| `cloudwatch-alarm-creator` | 3 | CloudWatch data source wiring |
| `grafana-dashboard-creator` | 4 | Dashboards as JSON provisioned from chart |
| `kubernetes-secrets-manager` | 4 | Grafana credentials from Secrets Manager |
| `alertmanager-rules-config` | 5 | Alertmanager config + SLO alert rule |
