# Working with AI — MRP25CDEB-6 Story 2.1 — Metrics & SLOs

*Author: Dmytro Dmytrush. Story assigned: 2026-06-04. Last updated: 2026-06-10.
Cluster / repo: 312school/platform-tools-25c-debian / eks-monitoring*

---

## 1. My role vs. Claude's role

**I directed:**
- The decision to use 3 independent Helm charts instead of a single umbrella chart — Claude presented the option; I understood that bundling them means a Grafana config change forces a Prometheus restart in production, so I chose the independent chart pattern
- Choosing Iryna's Versus app (Story 3.1) as the primary Prometheus scrape target — I read the Jira board, noticed Story 3.3 had no owner, and made the call myself
- The decision to deploy to the existing `eks-dev` cluster instead of waiting for Aiana's Terraform cluster — I was unblocked, I chose not to wait
- Deciding to hold the Terraform CloudWatch IAM role PR until Baigeldi's `feature/1.2-iam-identity-access` PR merged — I read his branch, confirmed his `providers.tf` has `default_tags`, and decided it was cleaner to layer on top
- Switching Grafana routing from Ingress to Gateway API HTTPRoute — I knew Yury (Story 1.3) had already migrated the platform to Gateway API, so using old-style Ingress would mean Grafana traffic never reaches the pod
- The PROGRESS.md session memory system — storing session state in a GitHub repo so Claude can resume with full context across sessions

**Claude generated:**
- The full 3-chart Helm scaffold: all Chart.yaml, values.yaml, values-dev/staging/prod.yaml, and all template files
- The `grafana-cloudwatch-role.tf` IAM Terraform file with trust policy and CloudWatch read permissions
- The `createSecret: false` toggle design for the admin-secret.yaml template
- The standup messages posted to the team Slack channel
- The DM sent to Iryna asking her to expose `/metrics` via `django-prometheus`
- Debugging analysis for all 5 deployment bugs found during the eks-dev deploy

---

## 2. Decisions I made

**Decision 1 — 3 independent charts, not an umbrella chart**

I rebuilt the monitoring stack from a single umbrella chart into 3 independent charts: prometheus, grafana, alertmanager.
With an umbrella chart, all 3 components share a single Helm release. A change to Grafana forces Prometheus to restart. A failed alertmanager update rolls back the entire stack.
With independent charts, each one has its own lifecycle, upgrade path, and rollback. This is the correct production pattern.
Trade-off accepted: 3 `helm install` commands instead of 1, and 3 separate ArgoCD applications. Small operational cost for a much cleaner architecture.

**Decision 2 — Iryna's Versus app as the primary scrape target, not Proshop**

Options: Proshop (Story 3.3), Versus (Story 3.1, Iryna), Weather backend (Story 3.5).
I chose Versus because it had an assigned owner, was actively worked, and runs on Kubernetes — standard ServiceMonitor discovery works.
Proshop (Story 3.3) had no assigned owner on the Jira board.

**Decision 3 — Deploy to `eks-dev` now, migrate to Aiana's cluster later**

Options: wait for Aiana's Terraform cluster or use the coordinator-created `eks-dev` cluster now.
I chose to deploy to `eks-dev` immediately. Waiting costs weeks of unverified chart code sitting on a branch with no feedback.
Trade-off accepted: one-line cluster name change in `deploy-platform-tools.yaml` when Aiana's cluster is ready.

**Decision 4 — Hold Terraform PR until Baigeldi's IAM PR merges**

Baigeldi's `providers.tf` adds `default_tags` — Project, Team, Environment, ManagedBy — that auto-apply to every resource.
If I push my `grafana-cloudwatch-role.tf` before his PR merges, I own a merge conflict when his tags land and I'd have to delete duplicate tags.
Trade-off accepted: Phase 4 Terraform work is blocked on someone else's PR for a day.

**Decision 5 — `createSecret: false` as the default for Grafana admin Secret**

The upstream Grafana Helm chart creates and owns the admin Secret. It writes whatever value is in `values.yaml` on every `helm upgrade`.
I added a `{{- if .Values.adminCredentials.createSecret }}` guard to our `admin-secret.yaml` template.
In dev: Secret is created manually with `kubectl create secret`, Helm never touches it.
In staging/prod: External Secrets Operator creates it from AWS Secrets Manager, Helm never touches it.
This means the password can never be accidentally overwritten by a helm upgrade.

**Decision 6 — PROGRESS.md as session memory**

I noticed Claude had no recollection of anything from the previous session. Built a structured session memory file in GitHub that Claude reads at the start of every session. Saves 15+ minutes of re-orientation per session.

---

## 3. What Claude got wrong

**Incident 1 — EKS access entry not considered for the GitHub Actions role**

Claude wrote the `grafana-cloudwatch-role.tf` IAM role for CloudWatch read access without raising the separate question: does the GitHub Actions role that runs `deploy-platform-tools.yaml` have an EKS access entry?
The deploy chain only works if the IAM role is in the cluster's access entries. Claude wrote the CloudWatch role correctly but never mentioned that a separate access entry fix was also needed.
This was caught when the workflow started failing at the `helm upgrade` step with a permissions error even though the AWS credentials step succeeded.

**Incident 2 — Namespace not included in ServiceMonitor coordination ask to Iryna**

Claude drafted the DM I sent Iryna asking her to expose `/metrics`. The message listed library, route, and port name — but did not ask for the Kubernetes namespace her app would be deployed in.
ServiceMonitor selectors use `namespaceSelector` — wrong namespace means Prometheus silently ignores the target.
I had to send a follow-up message. Claude had the ServiceMonitor YAML with `namespaceSelector` in it — it should have included namespace as a required field in the coordination ask.

**Incident 3 — Default_tags conflict not flagged proactively**

When Claude wrote `grafana-cloudwatch-role.tf`, it included explicit `tags = {}` blocks on each resource. Baigeldi's `providers.tf` already adds `default_tags` at the provider level — my explicit tags would duplicate them.
Claude had access to Baigeldi's PR and did not cross-reference his `providers.tf` before writing my resource tags. I caught this myself by re-reading his PR.

**Incident 4 — Helm deep-merge storage bug not anticipated**

Claude wrote the initial `values-dev.yaml` with `storageSpec.emptyDir` as an override for the base `values.yaml` which had `storageSpec.volumeClaimTemplate`. Helm deep-merges these — both fields end up in the final config simultaneously. The Prometheus Operator sees both, picks the PVC, and the PVC never binds in dev (no gp3 provisioner).
Claude should have warned: when overriding storage config in Helm, remove the base value entirely — don't just add an override. Each env file should own the full storageSpec.

**Incident 5 — Grafana Ingress not flagged as wrong for this platform**

Claude generated `grafana/templates/ingress.yaml` using classic Ingress (nginx). It should have asked: what routing type does this platform use? Yury (Story 1.3) migrated the entire platform to Gateway API weeks ago. Any new chart using Ingress will silently get no traffic.
I caught this when Grafana deployed but was unreachable — port-forward worked but the hostname routing didn't.

---

## 4. What I verified, and how

**Verified during Phase 1–2 (pre-cluster):**
- Read every line of the generated Helm chart scaffold
- Read Iryna's Story 3.1 branch directly to confirm she had not yet added `django-prometheus`
- Read Baigeldi's branch to confirm `default_tags` are present before deciding to wait
- Confirmed the Helm chart branch was live on `platform-tools-25c-debian` before ending the session

**Verified during Phase 3 (eks-dev deployment):**
- Decoded the Grafana admin secret with `kubectl get secret -o yaml` — confirmed the placeholder password was the root cause of the login failure
- Watched Prometheus pods go from `Pending` to `Running` after the storageSpec fix
- Ran `curl -s http://admin:DevGrafana2026!@localhost:3000/api/org` — confirmed 200 OK after password reset
- Ran `curl -s http://admin:DevGrafana2026!@localhost:3000/api/datasources` — confirmed Prometheus datasource connected at the correct URL
- Read Iryna's `service.yaml` directly to confirm `name: http` was added — didn't trust the commit message alone
- Decoded Iryna's `urls.py` to confirm `django_prometheus.urls` is wired at the root path

**To verify when CloudWatch is wired:**
- [ ] Query CloudWatch datasource via Grafana API and confirm data returns — not just "connected" status
- [ ] Confirm RDS panel shows real metrics from eks-dev environment
- [ ] Confirm ALB request count appears in the Platform Overview dashboard

---

## 5. What I'd do differently next time

- Build the session memory system before the first session — not after losing context at session 2
- Map all cross-team dependencies before writing any code — specifically check routing type before generating any ingress/route templates
- Ask for all required coordination fields in a single message — namespace + service name + port name in one DM to Iryna
- When overriding Helm storageSpec: always remove the base value, never just add an env override on top
- Read all shared `providers.tf` files before generating any Terraform — prevents the `default_tags` duplication incident

---

## How to use this document before an interview

Pick one incident from §3 or §4 and rehearse it in STAR format — Situation, Task, Action, Result. ~90 seconds out loud.

Example using Incident 4 (Helm deep-merge):
- **Situation:** Prometheus pod was stuck `Pending` after deploying to eks-dev
- **Task:** Diagnose why the pod wouldn't start
- **Action:** Checked PVC status — saw a PVC was created but never bound. Traced back to Helm deep-merging `emptyDir` from values-dev.yaml with `volumeClaimTemplate` from values.yaml — both fields present, Operator chose PVC, dev has no storage provisioner. Fix: removed storageSpec from base values.yaml entirely, each env file owns the full storageSpec.
- **Result:** Prometheus started. Learned that Helm deep-merges don't replace — they combine. Any storage or complex nested config must be owned entirely by one values file.

---

*Last updated: 2026-06-10. Continue updating as the project progresses.*
