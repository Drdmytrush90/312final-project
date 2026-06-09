# PROGRESS.md — Session Memory File

> **How to use this file:**
> At the start of every new Claude session, paste the full contents of this file.
> Claude will read it and know exactly where we are, what was learned, and what to do next.
> At the end of each session we update this file and push it to GitHub.

---

## Current status

- **Phase:** 1 complete — ready to start Phase 2
- **Last session:** 2026-06-08
- **Next action:** Design the `eks-monitoring/` Helm chart folder structure (on paper before any YAML)

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
|-------|--------|-----------------|
| 1.1 | Aiana Shadykanova | EKS cluster (CFN → Terraform migration, IPv6-primary, private nodes) |
| 1.2 | Baigeldi | IAM roles — Developer/DevOps roles, canonical shared GHA Terraform role, consolidates all ad-hoc roles |
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

### Unassigned stories (no owner yet)
- 3.3 — Proshop on Kubernetes (MERN + DocumentDB)
- 3.5 — Weather backend on Kubernetes (Node.js + external APIs)
- 4.2 — Kafka via ArgoCD (GitOps)
- 5.1 — Auto incident-response skill (Claude Code agent)
- 5.2 — Claude PR review task
- 5.3 — Platform MCP suite

### The 5 epics in plain English

**Epic 1 — Platform Foundation:** Build the ground floor — EKS cluster, IAM security, traffic routing, auto-scaling, TLS/DNS/secrets. Everything else sits on top of this.

**Epic 2 — Observability (my epic):** Give the team eyes. Metrics (me), logs (Erik), alerts (Askar). Without this the team is blind.

**Epic 3 — App Delivery:** Run real apps on the platform — Versus (K8s + EC2), Proshop (MERN), Weather backend, serverless memo.

**Epic 4 — Alternative Paths:** GitLab CI runner (Azat) and Kafka/ArgoCD GitOps (unassigned) — contrast with the GitHub Actions + Helm default.

**Epic 5 — AI Ops:** Claude Code skills for incident response, PR review, and MCP servers that talk directly to the platform.

---

## My story — 2.1 Metrics & SLOs

### What I am building

1. **Prometheus + Grafana + Alertmanager** as a locally-vendored Helm chart under `eks-monitoring/`
2. Prometheus scrapes the **cluster + at least one teammate's app**
3. Grafana reads both **Prometheus** AND **AWS CloudWatch** (for RDS, ALBs)
4. **Dashboards as code** — provisioned from the chart, not clicked by hand
5. Grafana **access-restricted** — IP allowlist + auth + credentials from AWS Secrets Manager
6. **At least one SLO** — SLI, target, measurement window, error budget, response plan
7. Wire my section into `deploy-platform-tools.yaml`
8. Write `README` + `WORKING-WITH-AI.md` memoir

Interview story: *"I owned the metrics stack and defined the SLO that became the contract between platform and product."*

### My direct dependencies

| Who | Why I need them | When |
|-----|-----------------|------|
| Aiana (1.1) | Her EKS cluster is what I deploy onto | Must wait for cluster |
| Yury (1.3) | Grafana hostname exposed through his Gateway API | Week 1: ingress-nginx → adopt his HTTPRoute when ready |
| Anvar (1.5) | HTTPS for Grafana via his cert-manager | Add TLS when his cert-manager lands |
| Baigeldi (1.2) | Consolidates my CloudWatch IAM role | I create ad-hoc first, he normalises later |

### Who depends on ME

| Who | Why they need me |
|-----|-----------------|
| Askar (2.3) | His alert rules layer onto MY Alertmanager — I am his upstream |
| Iryna/Herman/Inga (3.x) | I need to pick one of their apps as my Prometheus scrape target |

### The app I will scrape
**Best candidate: Iryna (3.1) — Versus app** — Python backend, RDS MySQL, on Kubernetes.
Need to coordinate with Iryna: ask her to expose a `/metrics` endpoint.
Don't wait on her — scrape the cluster itself meanwhile.

---

## My 5-phase learning plan

| Phase | Goal | Status |
|-------|------|--------|
| 1 | Understand EKS, Helm, Prometheus, Grafana, Alertmanager, CloudWatch | ✅ Done |
| 2 | Design the `eks-monitoring/` Helm chart structure + per-env values | ⬜ Next |
| 3 | Prometheus scrape configs + CloudWatch IAM role | ⬜ Todo |
| 4 | Dashboards as code + security | ⬜ Todo |
| 5 | Define and defend the SLO | ⬜ Todo |

---

## Phase 1 — COMPLETED ✅

### Core concepts I now understand

**EKS** — Kubernetes = OS for containers. EKS = AWS managed Kubernetes. I deploy monitoring stack on top of Aiana's cluster. I do NOT create the cluster.

**Helm** — Package manager for Kubernetes. Bundles all YAML into one chart. Must be **locally-vendored** — files live in `eks-monitoring/` in my repo, NOT pulled from internet at deploy time.

**Prometheus** — Time-series database. Works by **PULLING** — goes to each app every ~15s asking for metrics. Apps expose `/metrics` HTTP endpoint. Uses **ServiceMonitors** to discover scrape targets. Different from Datadog which pushes to Datadog's servers.

**Grafana** — Reads Prometheus + CloudWatch. Shows dashboards. Dashboards must be **provisioned as code** (JSON in Git) — if pod dies and restarts, dashboards come back automatically.

**Alertmanager** — Receives alerts from Prometheus and routes them (Slack, PagerDuty). Askar (2.3) adds his rules ON TOP of my Alertmanager. I deploy it even with minimal rules.

**CloudWatch** — AWS services (RDS, ALB) publish metrics here — no `/metrics` endpoint. Grafana needs CloudWatch data source + IAM role. Goal: one dashboard showing cluster metrics (Prometheus) AND AWS metrics (CloudWatch).

### Pull vs Push — key insight
Prometheus PULLS — it goes to the app. The app just waits at `/metrics`. ServiceMonitors tell Prometheus which services to scrape.

### Datadog vs open-source — PM answer
- Gained: cost savings, full control, data ownership, PromQL flexibility
- Gave up: managed service, someone else's reliability guarantee
- Honest framing: "The bet is our team is capable enough to run it ourselves."

### Helm chart anatomy (what I learned)
```
eks-monitoring/
├── Chart.yaml          ← identity: name, version, description
├── values.yaml         ← default config (all environments)
├── values-dev.yaml     ← dev overrides only (hostname, small resources, 7d retention)
├── values-staging.yaml ← staging overrides
├── values-prod.yaml    ← prod overrides (bigger resources, 30d retention, 2 replicas)
└── templates/          ← Kubernetes YAML files with {{ .Values.x }} placeholders
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    ├── ingress.yaml
    ├── servicemonitor.yaml   ← tells Prometheus what to scrape
    └── prometheusrule.yaml   ← alert rules
```

---

## School resources repo (added session 3)

The school provided a reference repo: `Drdmytrush90/25c-debian-final`
It contains the actual scaffold for the two shared repos I'll be working in:

- **`platform-tools-25c-debian`** — where `eks-monitoring/` lives (my deliverable folder)
- **`terraform-infra-25c-debian`** — where my CloudWatch IAM role Terraform goes

Key things learned:
- My Helm chart goes under `platform-tools-25c-debian/eks-monitoring/`
- The `deploy-platform-tools.yaml` workflow is shared — I add my section to it
- Terraform follows root-per-env pattern: `roots/devops-project-main/` with `dev.tfvars`, `staging.tfvars`, `production.tfvars`
- S3 state backend uses branch name as key — no conflicts between teammates' feature branches
- Terraform destroy runs on PR approval, apply runs on merge (prevents resource conflicts)

## Live cluster info (updated session 3)

- **Current cluster:** `eks-dev` (school-created, use this now — not blocked)
- **Incoming cluster:** `eks-25c-debian-dev` (Aiana's Terraform cluster — in progress)
- When Aiana's cluster is ready, update `deploy-platform-tools.yaml` to point at `eks-25c-debian-dev`

### What I need to decide BEFORE writing any YAML

1. What is the folder structure inside `eks-monitoring/`?
2. What changes between dev, staging, and prod?
3. Which teammate's app will I scrape? (Iryna 3.1 — need to coordinate)
4. What is my SLO candidate? (start thinking NOW — what user journey, what target, why?)

### Phase 2 checkpoint question (Claude will ask me this)
> "What do you think changes between `values-dev.yaml` and `values-prod.yaml` for Grafana? Give me 2-3 differences in your own words."

---

## Skills reference (saved in this repo)

Location: `skills/`

| Skill | Phase | What it helps build |
|-------|-------|---------------------|
| `02-devops-advanced/helm-chart-generator` | 2 | `eks-monitoring/` chart scaffold |
| `02-devops-advanced/helm-values-manager` | 2 | Per-env values dev/staging/prod |
| `02-devops-advanced/prometheus-config-generator` | 3 | Scrape configs + ServiceMonitors |
| `13-aws-skills/iam-role-generator` | 3 | IAM role for CloudWatch → Grafana |
| `13-aws-skills/cloudwatch-alarm-creator` | 3 | CloudWatch data source wiring |
| `02-devops-advanced/grafana-dashboard-creator` | 4 | Dashboards as JSON from chart |
| `02-devops-advanced/kubernetes-secrets-manager` | 4 | Grafana creds from Secrets Manager |
| `02-devops-advanced/alertmanager-rules-config` | 5 | Alertmanager config + SLO alert |

---

## Repo structure

```
312final-project/
├── README.md           ← project overview
├── PROGRESS.md         ← THIS FILE — session memory
├── CLAUDE.md           ← Claude instructions
├── MRP25CDEB.md        ← ALL team tickets (full Jira board)
├── slack.md            ← Slack channel log — READ THIS + update at start of each session
├── tag.md              ← Team cost attribution tag schema (Story 1.4 / Bohdan)
├── eks-monitoring/     ← THE REAL DELIVERABLE (built Phase 2-5)
├── docs/               ← SLO doc and notes (Phase 5)
└── skills/
    ├── 02-devops-advanced/
    └── 13-aws-skills/
```

---

## Session log

| Date | What we did |
|------|-------------|
| 2026-06-04 | Session 1: explored repo, identified best skills, built 5-phase plan, completed Phase 1 (all core concepts), created this repo, saved skills |
| 2026-06-04 | Session 2: learned Helm chart anatomy (Chart.yaml, values.yaml, templates/), read full MRP25CDEB.md Jira board, mapped all 12 teammates to correct stories, understood the full project picture across all 5 epics |
| 2026-06-08 | Session 3: read school resources repo (25c-debian-final) — got scaffold structure for platform-tools and terraform-infra. Added tag.md (Bohdan's cost attribution schema, Story 1.4). Added slack.md (Slack channel memory file). Read #final-project-25c-debian — key updates: Aiana's cluster is eks-dev now / eks-25c-debian-dev coming, tonight's standup at 9pm CST, Bohdan's PR #1 needs approval |

---

## Security reminder — read every session

- NEVER paste a GitHub PAT into chat more than once per session
- Always revoke the token after the session ends
- Generate fresh token: `github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens`
- Scope: Contents Read & Write on `312final-project` only
- Expiry: 30 days max
- Store on machine: `~/.zshrc` as `export GITHUB_PAT="your_token_here"`

---

## How to resume next session

1. Go to `github.com/Drdmytrush90/312final-project/blob/main/PROGRESS.md`
2. Click "Raw" — copy everything
3. Open new Claude chat, paste fresh token
4. Say: *"Here is my progress file, let's continue"* and paste this file
5. Claude reads it and picks up exactly where we left off
