# PROGRESS.md — Session Memory File

> **How to use this file:**
> At the start of every new Claude session, paste the full contents of this file.
> Claude will read it and know exactly where we are, what was learned, and what to do next.
> At the end of each session we update this file and push it to GitHub.

---

## Current status

- **Phase:** 1 complete — ready to start Phase 2
- **Last session:** 2026-06-04
- **Next action:** Design the `eks-monitoring/` Helm chart folder structure

---

## Who I am

- Student: Dmytro
- GitHub: Drdmytrush90
- Repo: `Drdmytrush90/312final-project`
- Course story: **Story 2.1 — Metrics & SLOs**

---

## Phase 1 — COMPLETED ✅

### Core concepts I now understand

**EKS**
- Kubernetes = OS for containers. Runs apps across servers, auto-restarts crashes, balances traffic.
- EKS = AWS managed Kubernetes. AWS runs the control plane, I manage the apps.
- I do NOT create the cluster — Story 1.1 owns that. I deploy my monitoring stack on top of it.

**Helm**
- Package manager for Kubernetes. Bundles all YAML into one reusable chart.
- My chart must be **locally-vendored** — files live in `eks-monitoring/` in my repo.
- NOT pulling from the internet at deploy time — if upstream changes, my deploy breaks.

**Prometheus**
- Time-series database. Works by **PULLING** — goes to each app every ~15s asking for metrics.
- Apps expose a `/metrics` HTTP endpoint.
- Uses **ServiceMonitors** (a Kubernetes resource) to discover which apps to scrape.
- Different from Datadog which pushes data to Datadog's servers.

**Grafana**
- Reads from Prometheus + CloudWatch and shows dashboards.
- Dashboards must be **provisioned as code** (JSON in Git repo).
- If the Grafana pod dies and restarts, dashboards come back automatically.

**Alertmanager**
- Receives firing alerts from Prometheus and routes them to Slack / PagerDuty / email.
- Story 2.3 adds its own rules ON TOP of my Alertmanager — shared seam.
- I deploy it even with minimal rules, because 2.3 depends on it.

**CloudWatch**
- AWS services (RDS, ALB) publish metrics here — no `/metrics` endpoint.
- Grafana needs CloudWatch data source + IAM role to read it.
- Goal: one dashboard showing app metrics (Prometheus) AND AWS metrics (CloudWatch).

### Datadog vs open-source — PM answer
- Gained: cost savings, full control, data ownership, PromQL flexibility
- Gave up: a managed service someone else keeps running
- Honest framing: "The bet is that our team is capable enough to run it ourselves."

### Pull vs Push — key insight
- Prometheus PULLS — it initiates the connection to the app
- The app doesn't know about Prometheus — it just exposes `/metrics` and waits
- In Kubernetes, ServiceMonitors tell Prometheus which services to scrape

---

## Phase 2 — NEXT ⬜

### What I need to decide before writing any YAML

Before Claude and I write a single file, I need to answer these myself:

1. What is the folder structure inside `eks-monitoring/`? (Sketch it on paper first)
2. What changes between dev, staging, and prod values?
3. Which teammate's app will I scrape? (Coordinate with Story 3.1, 3.3, or 3.5)
4. What is my SLO candidate? (Start thinking — what user journey, what number, why?)

### What a Helm chart folder looks like (to learn)
```
eks-monitoring/
├── Chart.yaml          ← chart name, version, description
├── values.yaml         ← default values
├── values-dev.yaml     ← dev overrides
├── values-staging.yaml ← staging overrides
├── values-prod.yaml    ← prod overrides
└── templates/          ← the actual Kubernetes YAML files (templated)
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    └── ...
```

### Phase 2 checkpoint question (Claude will ask me this)
> "Sketch the folder structure of `eks-monitoring/` before we write a single file.
> What goes inside a Helm chart and why?"

---

## Session log

### Session 1 — 2026-06-04
- Explored the repo `claude-code-plugins-Dmytro_plus-skills`
- Identified best skills: `02-devops-advanced` and `13-aws-skills`
- Built the 5-phase learning plan
- Completed Phase 1 — learned all core concepts
- Learned about GitHub token security — always rotate after each session
- Created this new repo `312final-project` with clean structure
- Skills copied to `skills/` folder for reference

---

## Security reminder — read every session

- NEVER paste a GitHub PAT into chat more than once per session
- Always revoke the token after the session ends
- Generate fresh token at: `github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens`
- Scope: Contents Read & Write on `312final-project` only
- Expiry: 30 days max
- Store on your machine in `~/.zshrc` as `export GITHUB_PAT="your_token_here"`
