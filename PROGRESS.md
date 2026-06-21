# PROGRESS.md — Session Memory File

> **How to use this file:**
> At the start of every new Claude session, paste the full contents of this file.
> Claude will read it and know exactly where we are, what was learned, and what to do next.
> At the end of each session we update this file and push it to GitHub.

---

## Current status

- **Phase:** ALL CORE WORK COMPLETE — in "close out loose ends before demo" mode
- **Last session:** 2026-06-21
- **DEMO DAY: Tuesday 2026-06-23** — this is the priority now
- **Next action (in order):**
  1. **Unblock PR #14** (platform-tools, ALB targetType:ip fix) — has all 3 approvals (Inga, Iryna, Yury) but merge is BLOCKED by a branch-protection rule requiring an *active* dev deployment. The last deployment shows as inactive. Re-run/re-trigger the dev deploy workflow on this branch to refresh it, then merge.
  2. **Get PR #17 reviewed** (platform-tools, Versus K8s Grafana dashboard + SLO panels) — opened 2026-06-20, zero reviews so far. Ping the team for review before Tuesday.
  3. **Rebase PR #19** (terraform-infra, Grafana CloudWatch IRSA role) — opened 2026-06-16, now 53 commits behind `main` (mergeable_state: dirty). Needs a rebase/merge-from-main before anyone can review it cleanly. This is the CloudWatch datasource blocker.
  4. **Add an "Issues Faced" section to `eks-monitoring/README.md`** — the class demo checklist requires this explicitly. Currently the real incidents (ALB bug, Helm deep-merge bug, label mismatch) only live in `WORKING-WITH-AI.md`, not surfaced in the README itself.
  5. **Prep the demo narrative** — overview, approach, questions faced, research, implementation walkthrough, challenges, outcome (see class "Suggestion for Students" format).

---

## Who I am

- Student: Dmytro Dmytrush
- GitHub: Drdmytrush90
- Repo: `Drdmytrush90/312final-project`
- Course story: **Story 2.1 — Metrics & SLOs (MRP25CDEB-6)**

---

## Full project — MockRealProject 25C Debian (MRP25CDEB)

This is a team of 12 people building a complete production-shaped cloud platform on AWS/EKS from scratch.
All tickets are in `MRP25CDEB.md` in this repo.

### The team — correct assignments

| Story | Person | What they build |
|-------|--------|-------------------|
| 1.1 | Aiana Shadykanova | EKS cluster (CFN → Terraform migration, IPv6-primary, private nodes) |
| 1.2 | Baigeldi | IAM roles — Developer/DevOps roles, canonical shared GHA Terraform role |
| 1.3 | Yury Zialionka | Traffic plane — ingress-nginx → Gateway API + AWS Load Balancer Controller |
| 1.4 | Bohdan | Karpenter — demand-driven workload scaling + cost report |
| 1.5 | Anvar Salvar | Cluster services — cert-manager (TLS), external-dns (Route53), Secrets Manager CSI driver |
| **2.1** | **Dmytro Dmytrush (me)** | **Metrics stack — Prometheus + Grafana + Alertmanager + SLO** |
| 2.2 | Erik Myrland | Logging stack — Elasticsearch + Fluentd + Kibana + Claude diagnostic skill |
| 2.3 | Askar | Alerting & on-call — CloudWatch alarms + Kubernetes alert rules + Slack routing + runbooks |
| 3.1 | Iryna Rozenstein | Versus app on Kubernetes — Python + RDS MySQL |
| 3.2 | Herman Ilchenko | Versus app on EC2 — Packer AMIs + systemd + GitLab CI pipeline |
| 3.4 | Inga Jumir | Serverless memo app — Lambda + DynamoDB + Cognito + CloudFront |
| 4.1 | Azat | GitLab runner on Kubernetes — Kubernetes executor, IAM boundary, CI-system comparison doc |

---

## My story — 2.1 Metrics & SLOs

### What I am building

1. **Prometheus + Grafana + Alertmanager** as 3 independent Helm charts under `eks-monitoring/`
2. Prometheus scrapes the **cluster + Iryna's Versus app**
3. Grafana reads both **Prometheus** AND **AWS CloudWatch** (for RDS, ALBs)
4. **Dashboards as code** — provisioned from the chart, not clicked by hand
5. Grafana **access-restricted** — IP allowlist + auth + credentials from AWS Secrets Manager
6. **At least one SLO** — SLI, target, measurement window, error budget, response plan
7. Wire my section into `deploy-platform-tools.yaml`
8. Write `README` + `WORKING-WITH-AI.md` memoir

### My direct dependencies

| Who | Why I need them | Status |
|-----|-----------------|--------|
| Aiana (1.1) | EKS cluster | ✅ eks-25c-debian-dev live |
| Yury (1.3) | Grafana HTTPRoute on Gateway API | ✅ shared-gateway/kube-system |
| Anvar (1.5) | HTTPS for Grafana via cert-manager | Pending |
| Baigeldi (1.2) | CloudWatch IAM role default_tags | ✅ Merged to main |
| Iryna (3.1) | Versus app as Prometheus scrape target | ✅ /metrics + name:http port |

---

## My 5-phase learning plan

| Phase | Goal | Status |
|-------|------|--------|
| 1 | Understand EKS, Helm, Prometheus, Grafana, Alertmanager, CloudWatch | ✅ Done |
| 2 | Design the `eks-monitoring/` Helm chart structure + per-env values | ✅ Done |
| 3 | Deploy to eks-dev — scrape configs + fix all bugs | ✅ Done |
| 4 | CloudWatch datasource + dashboards + deploy workflow + PRs | ✅ Done |
| 5 | Define and defend the SLO | 🟡 Next |

---

## Phase 4 — COMPLETED ✅ (2026-06-14)

### What was done this session

**Cluster migration**
- Moved all 3 charts from old `eks-dev` to new `eks-25c-debian-dev` (Aiana's Terraform cluster)
- Updated HTTPRoute parentRefs: `team-gateway/platform-tools` → `shared-gateway/kube-system`
- All 3 pods confirmed Running on new cluster

**CloudWatch datasource**
- Added `cloudwatch` section to `grafana/values.yaml` (roleArn + defaultRegion)
- Updated `datasources-configmap.yaml` — CloudWatch datasource alongside Prometheus
- IRSA auth (no static keys), scoped to monitoring:grafana ServiceAccount

**deploy-platform-tools.yaml**
- Fixed cluster name: `temporary-eks-cluster-dev` → `eks-25c-debian-dev`
- Added Install Helm step + 3 deploy steps (prometheus, grafana, alertmanager)
- `--wait --timeout 5m` on each step

**WORKING-WITH-AI.md memoir**
- Written and pushed to `eks-monitoring/stories/2.1-metrics/`
- Documents 5 bugs found and fixed, 4 key decisions, verification steps

**Both PRs opened**
- `platform-tools-25c-debian` PR #8 — main deliverable
- `terraform-infra-25c-debian` PR #15 — CloudWatch IAM role
- Slack message sent to team requesting 3 approvals

**Dashboard confirmed working**
- Platform Overview dashboard provisioned as code (4 panels)
- Pod Restarts panel showing real data across all namespaces
- HTTP panels empty — expected, waiting on Iryna's app traffic

---

## Architecture — 3 independent charts (App-of-Apps)

```
eks-monitoring/
├── prometheus/         ← wraps kube-prometheus-stack 61.3.2
│   ├── Chart.yaml
│   ├── values.yaml         ← base config
│   ├── values-dev.yaml     ← emptyDir storage
│   ├── values-staging.yaml
│   ├── values-prod.yaml
│   └── templates/
│       └── slo-rules.yaml
│
├── grafana/            ← wraps grafana 8.5.2
│   ├── values.yaml         ← Prometheus + CloudWatch datasources, IRSA role ARN
│   ├── values-dev.yaml     ← no persistence, createSecret: false
│   └── templates/
│       ├── admin-secret.yaml
│       ├── datasources-configmap.yaml  ← Prometheus + CloudWatch
│       ├── dashboards-configmap.yaml   ← 4 panels
│       └── httproute.yaml              ← shared-gateway/kube-system
│
├── alertmanager/       ← config-only chart
│   ├── values.yaml
│   ├── values-dev.yaml     ← null receivers
│   └── templates/
│       └── config.yaml
│
└── stories/
    └── 2.1-metrics/
        └── WORKING-WITH-AI.md
```

## Live cluster info

- **Cluster:** `eks-25c-debian-dev` (us-east-1)
- **Gateway:** `shared-gateway` in `kube-system` (Yury's Story 1.3)
- **Grafana host:** `grafana-debian-dev.312debian.com`
- **CloudWatch role ARN:** `arn:aws:iam::905418100201:role/grafana-cloudwatch-read-dev`
- **EKS OIDC:** `oidc.eks.us-east-1.amazonaws.com/id/74039390E14D831D5E55D47F4EA1BC5D`

## Open PRs

| Repo | PR | Status |
|------|----|--------|
| platform-tools-25c-debian | [#8](https://github.com/312school/platform-tools-25c-debian/pull/8) | Waiting for 3 approvals |
| platform-tools-25c-debian | [#13](https://github.com/312school/platform-tools-25c-debian/pull/13) | ALB targetType fix — waiting for approval |
| terraform-infra-25c-debian | [#15](https://github.com/312school/terraform-infra-25c-debian/pull/15) | Waiting for 3 approvals |

---

## Phase 5 — SLO (Next)

Need to write:
- **SLI**: what we measure (e.g. Versus HTTP error rate)
- **Target**: e.g. 99.5% of requests succeed over 30 days
- **Measurement window**: 30 days rolling
- **Error budget**: 0.5% = ~3.6 hours of downtime per month
- **Response plan**: what happens when budget burns >50% or >100%
- Add SLO panel to dashboard
- Write SLO doc in `eks-monitoring/stories/2.1-metrics/SLO.md`

---

## Session log

| Date | What we did |
|------|-------------|
| 2026-06-04 | Session 1: explored repo, identified best skills, built 5-phase plan, completed Phase 1, created this repo |
| 2026-06-04 | Session 2: learned Helm chart anatomy, read full MRP25CDEB.md, mapped all 12 teammates |
| 2026-06-08 | Session 3: read school resources repo, confirmed eks-dev cluster |
| 2026-06-08 | Session 4: Phase 2 complete — scaffolded full eks-monitoring chart, 11 files pushed |
| 2026-06-09 | Session 5: reviewed Iryna's PR, reviewed Baigeldi's PR, wrote grafana-cloudwatch-role.tf |
| 2026-06-10 | Session 6: rebuilt as 3 independent charts, deployed all 3 to eks-dev, fixed 5 bugs, Grafana live |
| 2026-06-14 | Session 7: migrated to eks-25c-debian-dev, updated Gateway, added CloudWatch datasource, updated deploy workflow, wrote WORKING-WITH-AI.md, opened both PRs, sent Slack message |
| 2026-06-17 | Session 8: diagnosed and fixed 5-day Grafana outage — ALB targetType: ip fix via TargetGroupConfiguration, Gateway PROGRAMMED=True, Grafana HTTP 302 confirmed. Opened PR #13. Investigated empty HTTP dashboard panels (not a Grafana issue — app-level metrics not reaching Prometheus). Updated WORKING-WITH-AI.md and PROGRESS.md. |
| 2026-06-21 | Session 9: full repo + PR audit ahead of Tuesday demo. Found PR #13 was actually closed unmerged — superseded by PR #14 (same fix), which now has all 3 approvals but is blocked by the branch-protection "active deployment" gate. PR #17 (Versus dashboard, SLO panels) open since 6/20, no reviews yet. PR #19 (CloudWatch IRSA) is 53 commits behind main, needs rebase. Confirmed PR #8 (the core Story 2.1 deliverable) is merged. Updated PROGRESS.md with accurate current state. |

---

## Security reminder — read every session

- NEVER paste a GitHub PAT into chat more than once per session
- Always revoke the token after the session ends
- Scope: Contents + Workflows + Pull Requests — Read & Write on 312school repos
- Expiry: 30 days max

---

## How to resume next session

1. Go to `github.com/Drdmytrush90/312final-project/blob/main/PROGRESS.md`
2. Click "Raw" — copy everything
3. Open new Claude chat, paste fresh token
4. Say: *"Here is my progress file, let's continue"* and paste this file
5. Claude reads it and picks up exactly where we left off
