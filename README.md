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
├── CLAUDE.md                  ← Claude session bootstrap instructions
├── MRP25CDEB.md               ← full Jira board — all 18 team tickets
├── slack.md                   ← Slack channel log
├── tag.md                     ← team cost attribution tag schema (Story 1.4 / Bohdan)
├── working-with-ai.md         ← WORKING-WITH-AI.md memoir (Story 2.1 deliverable)
│
├── terraform/
│   └── grafana-cloudwatch-role.tf  ← CloudWatch IAM role (ready to push after Baigeldi merges)
│
├── eks-monitoring/            ← placeholder (real deliverable in platform-tools repo)
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

1. Deploy **Prometheus + Grafana + Alertmanager** on EKS as 3 independent Helm charts under `eks-monitoring/`
2. Prometheus scrapes the **cluster + Iryna's Versus app**
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
| 2 | Design `eks-monitoring/` Helm chart structure + per-env values | ✅ Done |
| 3 | Deploy to eks-dev — scrape configs + fix all bugs | ✅ Done (2026-06-10) |
| 4 | CloudWatch datasource + dashboards + security | 🟡 In progress |
| 5 | Define and defend the SLO | ⬜ Todo |

---

## Current state (as of 2026-06-10)

All 3 charts deployed and running on `eks-dev`:

| Chart | Status | Notes |
|-------|--------|-------|
| Prometheus | ✅ Running | Scraping cluster, emptyDir in dev |
| Grafana | ✅ Running | Logged in, Prometheus datasource connected, Platform Overview dashboard live |
| Alertmanager | ✅ Running | Null receivers in dev, no false alerts |

**Grafana:** accessible at `localhost:3000` via port-forward. Login: `admin / DevGrafana2026!`

**One remaining blocker:** Baigeldi's IAM PR must merge before I can push `grafana-cloudwatch-role.tf` and wire CloudWatch.

---

## Working repos

| Repo | Branch | Purpose |
|------|--------|---------|
| `312school/platform-tools-25c-debian` | `feature/2.1-eks-monitoring` | Helm charts (main deliverable) |
| `312school/terraform-infra-25c-debian` | `feature/2.1-—-Metrics-&-SLOs` | CloudWatch IAM role (Phase 4) |
| `Drdmytrush90/312final-project` | `main` | Session memory + skills reference |
| `312school/versus-25c-debian` | `feature/3.1-versus-k8s` | Iryna's app — my Prometheus scrape target ✅ Ready |

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
| `cloudwatch-alarm-creator` | 4 | CloudWatch data source wiring |
| `grafana-dashboard-creator` | 4 | Dashboards as JSON provisioned from chart |
| `kubernetes-secrets-manager` | 4 | Grafana credentials from Secrets Manager |
| `alertmanager-rules-config` | 5 | Alertmanager config + SLO alert rule |
