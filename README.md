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
├── slack.md                   ← Slack channel log (#final-project-25c-debian)
├── tag.md                     ← team cost attribution tag schema (Story 1.4 / Bohdan)
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
| 2 | Design `eks-monitoring/` Helm chart structure + per-env values | ✅ Done |
| 3 | Prometheus scrape configs + CloudWatch IAM role | ⬜ Next |
| 4 | Dashboards as code + security | ⬜ Todo |
| 5 | Define and defend the SLO | ⬜ Todo |

---

## What was built (Phase 2 — Session 4, 2026-06-08)

Full Helm chart scaffolded in `platform-tools-25c-debian` on branch `feature/2.1-eks-monitoring`:

```
eks-monitoring/
├── Chart.yaml                 ← chart identity: name, version, description
├── values.yaml                ← default values for all environments
├── values-dev.yaml            ← dev: 7d retention, small resources, 1 replica
├── values-staging.yaml        ← staging: 14d retention, medium resources
├── values-prod.yaml           ← prod: 30d retention, large resources, 2 replicas
└── templates/
    ├── deployment.yaml        ← Prometheus + Grafana + Alertmanager deployments
    ├── service.yaml           ← internal cluster routing between pods
    ├── configmap.yaml         ← Prometheus scrape configuration
    ├── ingress.yaml           ← Grafana hostname routing
    ├── servicemonitor.yaml    ← tells Prometheus what to scrape
    └── prometheusrule.yaml    ← alert rules (Askar / Story 2.3 builds on this)
```

### Key decisions made in Phase 2

| Setting | dev | staging | prod |
|---------|-----|---------|------|
| Hostname | grafana-debian-dev.312debian.com | grafana-debian-staging.312debian.com | grafana-debian-prod.312debian.com |
| Retention | 7 days | 14 days | 30 days |
| Replicas | 1 | 1 | 2 |
| CPU request | 100m | 200m | 500m |
| Memory request | 256Mi | 512Mi | 1Gi |

---

## Working repos

| Repo | Branch | Purpose |
|------|--------|---------|
| `312school/platform-tools-25c-debian` | `feature/2.1-eks-monitoring` | Helm chart (main deliverable) |
| `312school/terraform-infra-25c-debian` | `feature/2.1-—-Metrics-&-SLOs` | CloudWatch IAM role (Phase 3) |
| `Drdmytrush90/312final-project` | `main` | Session memory + skills reference |

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
