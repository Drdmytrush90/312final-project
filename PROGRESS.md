# PROGRESS.md — Session Memory File

> **How to use this file:**
> At the start of every new Claude session, paste the full contents of this file.
> Claude will read it and know exactly where we are, what was learned, and what to do next.
> At the end of each session we update this file and push it to GitHub.

---

## Current status

- **Phase:** 3 complete / Phase 4 starting
- **Last session:** 2026-06-10
- **Next action:**
  1. Add Versus ServiceMonitor back — use port `http`, selector `app: versus-backend`, confirm namespace with Iryna
  2. Wait for Baigeldi's PR to merge → push `grafana-cloudwatch-role.tf` → add CloudWatch datasource to Grafana
  3. Update `deploy-platform-tools.yaml` — fix cluster name + add eks-monitoring deploy step
  4. Open PR for `feature/2.1-eks-monitoring`
  5. Define and write the SLO document (Phase 5)

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
| Aiana (1.1) | Her EKS cluster is what I deploy onto | ✅ Using eks-dev now |
| Yury (1.3) | Grafana hostname exposed through his Gateway API | ✅ Migrated to HTTPRoute today |
| Anvar (1.5) | HTTPS for Grafana via his cert-manager | Pending |
| Baigeldi (1.2) | CloudWatch IAM role needs his default_tags | 🔴 Waiting for PR to merge |
| Iryna (3.1) | Versus app as Prometheus scrape target | ✅ She added /metrics and name:http port today |

---

## My 5-phase learning plan

| Phase | Goal | Status |
|-------|------|--------|
| 1 | Understand EKS, Helm, Prometheus, Grafana, Alertmanager, CloudWatch | ✅ Done |
| 2 | Design the `eks-monitoring/` Helm chart structure + per-env values | ✅ Done |
| 3 | Deploy to eks-dev — scrape configs + fix all bugs | ✅ Done — all 3 charts running |
| 4 | CloudWatch datasource + dashboards + security | 🟡 In progress |
| 5 | Define and defend the SLO | ⬜ Todo |

---

## Phase 3 — COMPLETED ✅ (2026-06-10)

### What was deployed

All 3 charts running on `eks-dev` in the `monitoring` namespace:
- **Prometheus** ✅ — scraping the cluster (node CPU, memory, pod status)
- **Grafana** ✅ — logged in at localhost:3000, Prometheus datasource connected and default
- **Alertmanager** ✅ — running with null receivers in dev (no false alerts)

### Architecture — 3 independent charts (App-of-Apps)

```
eks-monitoring/
├── prometheus/         ← wraps kube-prometheus-stack 61.3.2
│   ├── Chart.yaml
│   ├── values.yaml         ← base config
│   ├── values-dev.yaml     ← emptyDir storage (no gp3 provisioner in dev)
│   ├── values-staging.yaml
│   ├── values-prod.yaml
│   └── templates/
│       └── slo-rules.yaml  ← error rate + P99 latency SLO alerts
│
├── grafana/            ← wraps grafana 8.5.2
│   ├── values.yaml         ← Prometheus datasource, Platform Overview dashboard
│   ├── values-dev.yaml     ← no persistence, createSecret: false
│   └── templates/
│       ├── admin-secret.yaml     ← createSecret toggle (false = pre-existing secret)
│       ├── datasources-configmap.yaml
│       ├── dashboards-configmap.yaml  ← 4 panels: request rate, 5xx, P99, pod restarts
│       └── httproute.yaml        ← Gateway API (migrated from Ingress today)
│
├── alertmanager/       ← config-only chart (no upstream dep)
│   ├── values.yaml
│   ├── values-dev.yaml     ← null receivers, emptyDir storage
│   └── templates/
│       └── config.yaml
│
└── argocd/             ← App-of-Apps manifests (not deployed yet)
    ├── app-of-apps.yaml
    ├── prometheus-app.yaml   ← sync-wave: -1 (deploys first)
    ├── grafana-app.yaml
    └── alertmanager-app.yaml
```

### 5 bugs found and fixed during deployment

| Bug | Root cause | Fix |
|-----|-----------|-----|
| Prometheus stuck Pending | Helm deep-merge: emptyDir + volumeClaimTemplate both set → Operator chose PVC, dev has no gp3 provisioner | Remove storageSpec from base values.yaml; each env owns it entirely |
| Grafana wrong routing | Chart used Ingress (nginx); platform uses Gateway API (Yury 1.3) | Replaced ingress.yaml with httproute.yaml |
| Wrong hostname | values.yaml had 312ubuntu.com instead of 312debian.com | Fixed to grafana-debian-dev.312debian.com |
| Grafana login failed | Upstream Helm chart owns and overwrites the secret with placeholder password on every deploy | Reset via `grafana cli admin reset-admin-password`; added `createSecret: false` toggle |
| Alertmanager crashing | (1) No gp3 provisioner in dev; (2) Placeholder webhook URLs couldn't be parsed | emptyDir storage + null receivers in dev values |

### Iryna coordination — COMPLETE ✅

Iryna added to `feature/3.1-versus-k8s` today:
- **`[347ff60]`** — `add django-prometheus metrics endpoint` — `/metrics` is live
- **`[3c8449e]`** — `fix: add port name to backend service` — `name: http` added to service port

Her service.yaml now has:
```yaml
ports:
  - name: http       ← this is what my ServiceMonitor needs
    port: 80
    targetPort: 8080
```

**To re-add ServiceMonitor:** port = `http`, selector = `app: versus-backend`, confirm namespace.

### What's NOT done yet (Phase 4)

| Item | Blocked on |
|------|-----------|
| CloudWatch datasource in Grafana | Baigeldi's IAM PR to merge → push grafana-cloudwatch-role.tf |
| Versus ServiceMonitor | Confirm namespace with Iryna, then add back to prometheus chart |
| `deploy-platform-tools.yaml` update | Just needs to be done — fix cluster name + add eks-monitoring steps |
| Open PR for branch | Just needs to be done |
| SLO document | Phase 5 — write after everything else |

---

## School resources repo

- `312school/platform-tools-25c-debian` — where `eks-monitoring/` lives (my deliverable folder)
- `312school/terraform-infra-25c-debian` — where my CloudWatch IAM role Terraform goes
- Baigeldi's branch: `feature/1.2-iam-identity-access` — has `default_tags` I need. 7 commits today, ready to merge.
- Iryna's branch: `feature/3.1-versus-k8s` — has `/metrics` + `name:http` port. Ready to scrape.

## Live cluster info

- **Current cluster:** `eks-dev` (us-east-1) — kubeconfig works, all charts deployed here
- **Incoming cluster:** `eks-25c-debian-dev` (Aiana's Terraform cluster — in progress)
- When Aiana's cluster is ready, update `deploy-platform-tools.yaml` cluster name

---

## Session log

| Date | What we did |
|------|-------------|
| 2026-06-04 | Session 1: explored repo, identified best skills, built 5-phase plan, completed Phase 1 (all core concepts), created this repo, saved skills |
| 2026-06-04 | Session 2: learned Helm chart anatomy, read full MRP25CDEB.md Jira board, mapped all 12 teammates to correct stories |
| 2026-06-08 | Session 3: read school resources repo, added tag.md and slack.md, confirmed eks-dev cluster |
| 2026-06-08 | Session 4: Phase 2 complete — scaffolded full eks-monitoring Helm chart in platform-tools-25c-debian on branch feature/2.1-eks-monitoring. 11 files pushed. |
| 2026-06-09 | Session 5: Phase 1 & 2 recap. Reviewed Iryna's PR — no /metrics yet. Sent Iryna DM. Reviewed Baigeldi's PR — safe to approve. Reviewed Bohdan's PR — default_tags confirmed. Wrote grafana-cloudwatch-role.tf. |
| 2026-06-10 | Session 6: Connected Jira. Rebuilt eks-monitoring as 3 independent charts (App-of-Apps). Deployed all 3 to eks-dev. Fixed 5 bugs: Helm deep-merge PVC bug, wrong routing type (Ingress→HTTPRoute), wrong hostname (ubuntu→debian), Grafana password not applying, Alertmanager crashing on placeholder URLs. Grafana live at localhost:3000, Prometheus datasource connected. Added createSecret toggle to admin-secret.yaml. Iryna confirmed — she added /metrics and name:http port today. No blocker from Iryna. One remaining blocker: Baigeldi's IAM PR. |

---

## Security reminder — read every session

- NEVER paste a GitHub PAT into chat more than once per session
- Always revoke the token after the session ends
- Generate fresh token: `github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens`
- Scope: Contents Read & Write on `312final-project` only
- Expiry: 30 days max

---

## How to resume next session

1. Go to `github.com/Drdmytrush90/312final-project/blob/main/PROGRESS.md`
2. Click "Raw" — copy everything
3. Open new Claude chat, paste fresh token
4. Say: *"Here is my progress file, let's continue"* and paste this file
5. Claude reads it and picks up exactly where we left off
