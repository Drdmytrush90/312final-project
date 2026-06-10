# Working with AI — MRP25CDEB-6 Story 2.1 — Metrics & SLOs

*Author: Dmytro Dmytrush. Story assigned: 2026-06-04. Story completed: [date].
Cluster / repo: [link to platform-tools-25c-debian / eks-monitoring]*

---

## 1. My role vs. Claude's role

**I directed:**
- The decision to use a locally-vendored Helm chart instead of a remote `helm add repo` pull — Claude presented the option; I understood that in a CI/CD workflow pulling from the internet at deploy time is a reliability and security risk, so I locked the choice down
- Choosing Iryna's Versus app (Story 3.1) as the primary Prometheus scrape target over waiting for Proshop (Story 3.3, unassigned) — I read the Jira board, noticed 3.3 had no owner, and made the call myself
- The decision to deploy to the existing `eks-dev` cluster (school-created) instead of waiting for Aiana's Terraform cluster — I was unblocked, I chose not to wait
- The decision to coordinate with Iryna, Nikita (if applicable), and Vera on day one for `/metrics` instrumentation rather than deferring it — my call after understanding the dependency chain
- Deciding to hold the Terraform CloudWatch IAM role PR until Bohdan's `feature/add-default-tags-providers` PR merged — I read Bohdan's PR, understood the `default_tags` schema, and decided it was cleaner to layer on top of his work than create a separate tags block I'd have to remove later
- The PROGRESS.md system — storing session state in a GitHub repo so Claude can resume with full context across sessions. Claude didn't suggest this pattern; I built it because I noticed Claude had no memory between sessions and was wasting the first 15 minutes of every session re-explaining the project

**Claude generated:**
- The full Helm chart scaffold: `Chart.yaml`, `values.yaml`, `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml`, and all six templates (`deployment.yaml`, `service.yaml`, `configmap.yaml`, `ingress.yaml`, `servicemonitor.yaml`, `prometheusrule.yaml`)
- The `grafana-cloudwatch-role.tf` IAM Terraform file with the trust policy and CloudWatch read permissions
- The Phase 1 concept explanations (pull vs. push model, ServiceMonitor mechanics, Prometheus → Alertmanager → Askar dependency chain)
- The standup messages I posted to the team Slack channel
- The DM I sent Iryna asking her to expose `/metrics` via `django-prometheus`
- The explanation of the `default_tags` schema from Bohdan's PR that I then used to write the correct Story/Component tags for my IAM role

---

## 2. Decisions I made

**Decision 1 — Iryna's Versus app as the primary scrape target, not Proshop**

Options: Proshop (Story 3.3), Versus (Story 3.1, Iryna), Weather backend (Story 3.5, unassigned).
I chose Versus because it had an assigned owner (Iryna), was already being actively worked (ECR repos created), and runs on Kubernetes — which means standard ServiceMonitor discovery works without hacking around EC2 IPs or Lambda endpoints.
Proshop (Story 3.3) had no assigned owner on the Jira board; I couldn't coordinate with a person who didn't exist yet.
Trade-off accepted: Versus backend is Python/Django, which means `django-prometheus` middleware — an extra ask to Iryna and a library she may not have used. Proshop (Node.js) uses `prom-client`, which Diana would have known from other projects. Chose the app with a person, not the app with a familiar library.

**Decision 2 — Deploy to `eks-dev` now, migrate to Aiana's cluster later**

Options: wait for Aiana's Terraform cluster (`eks-25c-debian-dev`) or use the coordinator-created `eks-dev` cluster now.
I chose to deploy to `eks-dev` immediately. Aiana's cluster has no ETA. The deploy workflow already points at `temporary-eks-cluster-${ENVIRONMENT_STAGE}`. Waiting costs me weeks of unverified chart code sitting on a branch with no feedback.
Trade-off accepted: I will have to update the cluster name in `deploy-platform-tools.yaml` when Aiana's cluster is ready — one-line change, small cost. Getting two phases of chart work verified on a live cluster is worth it.

**Decision 3 — Hold Terraform PR until Bohdan's tags PR merges**

Options: push `grafana-cloudwatch-role.tf` now with manual tags, or wait for Bohdan's `default_tags` block to land in `providers.tf`.
I chose to wait. Bohdan's PR (`feature/add-default-tags-providers`) adds `default_tags` to the AWS provider — `Project`, `Team`, `Environment`, `ManagedBy` auto-apply to every resource. If I push now with manually duplicated tags, I'll own a merge conflict when his PR lands, and I'll have to delete the duplicate tags.
Trade-off accepted: my Phase 3 Terraform work is blocked on someone else's PR for a day. The cleaner final state is worth it.

**Decision 4 — PROGRESS.md as session memory**

I noticed Claude had no recollection of anything from the previous session. In session 2, I spent ~15 minutes re-establishing context. I decided to build a structured session memory file in the GitHub repo that Claude reads at the start of every session. It includes current phase, teammate assignments, decisions made, and next actions.
Trade-off accepted: I spend 5–10 minutes updating PROGRESS.md at the end of each session. It saves more than that on re-orientation every time. I shared the pattern in the team Slack channel and it got significant positive response — several teammates adopted it.

**Decision 5 — Per-environment values files from day one**

Options: start with a single `values.yaml` and split later, or build `values-dev/staging/prod.yaml` upfront.
I built all four from the start because the `deploy-platform-tools.yaml` workflow runs on every push to `feature/**` — which means it will hit the dev environment immediately. If I defer the per-env split, I'm deploying production-sized resource requests to a dev cluster and paying for it on the team's AWS bill. Bohdan's cost tag schema also requires environment-level tagging, which only makes sense if environments are separate from the start.
Trade-off accepted: more files to maintain. Correct state is worth it.

---

## 3. What Claude got wrong

*[Continue updating as the project progresses — include commit SHAs, error messages, PR comments as evidence]*

**Incident 1 — EKS access entry not considered for the GitHub Actions role**

Claude wrote the `grafana-cloudwatch-role.tf` IAM role for CloudWatch read access without raising the separate question: does the GitHub Actions role that runs `deploy-platform-tools.yaml` have an EKS access entry so it can actually `helm upgrade` to the cluster?
The deploy workflow uses `aws-actions/configure-aws-credentials@v4` → assumes `IAM_ROLE` → runs `aws eks update-kubeconfig` → runs `helm upgrade`. That chain only works if the IAM role is in the cluster's access entries (modern EKS) or `aws-auth` ConfigMap (legacy). Claude wrote the CloudWatch role correctly but never mentioned that a separate access entry fix was also needed — that the GitHub Actions role must be registered with the cluster, not just trusted by the IAM trust policy.
This was caught when the workflow started failing at the `helm upgrade` step with a permissions error even though the AWS credentials step succeeded. Aiana (Story 1.1) needed to add the GitHub Actions role to the EKS access entries before the deploy step could actually reach the cluster.
Claude should have flagged this as a required coordination item with Story 1.1 before I ran the workflow — it is a well-known EKS onboarding gotcha.
*[Update with exact error message and PR/commit evidence when the cluster cutover happens]*

**Incident 2 — Namespace not included in ServiceMonitor coordination ask to Iryna**

Claude drafted the DM I sent Iryna asking her to expose `/metrics` via `django-prometheus`. The message listed what I needed: the library, the route, and the Service port name. It did not ask for the Kubernetes namespace her app would be deployed in.
ServiceMonitor selectors use `namespaceSelector` — if the namespace is wrong, Prometheus silently ignores the target with no error shown. I noticed the gap after sending the message and had to send a follow-up asking for the namespace. A second DM looks disorganized and signals I didn't think it through the first time.
Claude had just generated the ServiceMonitor YAML with `namespaceSelector` in it — it should have included namespace as a required field in the coordination ask.

**Incident 3 — Default_tags conflict not flagged proactively**

When I asked Claude to write `grafana-cloudwatch-role.tf`, Claude included explicit `tags = {}` blocks on each resource. Bohdan's `providers.tf` already adds `default_tags` at the provider level — meaning my explicit tags would duplicate them, causing a Terraform plan diff that would never be clean and creating a future merge conflict.
Claude had access to Bohdan's PR (I pasted it in context) and did not cross-reference his `providers.tf` before writing my resource tags. I caught this myself by re-reading Bohdan's PR and noticing the `default_tags` block. Claude then explained the fix — use `tags` only for Story/Component, omit the fields covered by `default_tags` — but should have said this upfront.

**Incident 4 — `grafana-cloudwatch-role.tf` written before Bohdan's PR merged**

Claude and I wrote the full CloudWatch IAM role Terraform file during a session where Bohdan's PR was still open and unreviewed. The file was ready to push but pushing it without Bohdan's tags landing first would have meant an immediate merge conflict on `providers.tf`.
Claude did not raise this sequencing issue. I caught it by reading my own PROGRESS.md action items at the start of the next session ("Wait for Bohdan's PR to merge"). Had I pushed immediately after the session the conflict would have been on the shared `main` branch, not just my branch.

*[Add more incidents as the project progresses — especially once the cluster is live and the Helm chart is deployed]*

---

## 4. What I verified, and how

*[Update as the project progresses — green CI is not verification]*

**Verified during Phase 1–2 (pre-cluster):**
- Read every line of the generated Helm chart scaffold — understood what `Chart.yaml` vs `values.yaml` does, why `templates/` uses `{{ .Values.x }}` placeholders, and why `service.yaml` is required (how Grafana finds Prometheus by internal DNS, not IP)
- Read Iryna's Story 3.1 PR directly to confirm she had not yet added `django-prometheus` — rather than assuming she had acted on my message
- Read Bohdan's PR #1 (`feature/add-default-tags-providers`) myself to map the `default_tags` schema before writing my IAM role's tags — didn't just take Claude's summary
- Read Tony's PR #4 (`feature/fix-terraform-backend-locking`) to confirm `use_lockfile = true` was the right fix before approving — understood the DynamoDB lock table deprecation context
- Confirmed the Helm chart branch (`feature/2.1-eks-monitoring`) was live on `platform-tools-25c-debian` before ending the session — ran `git log` and confirmed the push, didn't trust the terminal output alone

**To verify when cluster is live:**
- [ ] Query Prometheus directly (`kubectl port-forward`) and confirm Versus scrape target shows `UP`
- [ ] Open Grafana and confirm both Prometheus and CloudWatch data sources return data — not just that they show "connected"
- [ ] Hit Grafana from a different IP (phone on mobile data) and confirm the allowlist blocks it
- [ ] Confirm dashboards loaded from the ConfigMap — not hand-clicked
- [ ] Read `kubectl describe servicemonitor` output and confirm selector labels match Iryna's Service labels
- [ ] Check `kubectl get events -n monitoring` after the first deploy to confirm no image pull errors or resource limit evictions

---

## 5. What I'd do differently next time

*[Fill in honestly at the end of the project — notes so far below]*

**Notes so far (Sessions 1–5):**
- Build the session memory system (PROGRESS.md equivalent) before the first session, not after losing context at the start of session 2. The cost is 10 minutes of setup; the payoff is every subsequent session starting at full context.
- Map all cross-team dependencies before writing any code — specifically: who has to do what before my deploy step can work end-to-end. The EKS access entry issue (Incident 1) was a coordination item with Aiana that neither Claude nor I raised until the workflow failed.
- Ask for all required coordination fields in a single message. The two-message situation with Iryna (forgot to ask for namespace) was avoidable and looked disorganized.
- Read other PRs in the shared repos before generating anything that touches shared files — Bohdan's `providers.tf` was open and visible; I should have read it first, not after Claude had already generated the tags block.
- Use `CLAUDE.md` to encode team-specific conventions (tag schema, branch naming, shared-file merge sequencing) so Claude doesn't have to be re-told these every session.

*[Add more reflections as the project progresses]*

---

## How to use this document before an interview

Pick one incident from §3 or §4 and rehearse it in STAR format — Situation, Task, Action, Result. ~90 seconds out loud.

Example using Incident 1:
- **Situation:** GitHub Actions workflow for deploying the monitoring stack to EKS was failing at the `helm upgrade` step even though the AWS credentials step succeeded
- **Task:** Diagnose why a correctly-scoped IAM role couldn't reach the cluster
- **Action:** Traced the call chain: `configure-aws-credentials` → `update-kubeconfig` → `helm upgrade` — realized the IAM role was trusted by the policy but not in the cluster's access entries. Coordinated with Aiana (Story 1.1) to add the role to EKS access entries
- **Result:** Workflow could reach the cluster. Learned that EKS access entries are a separate authorization layer from IAM trust policy — one lets you assume the role, the other lets the cluster recognize it

---

*Last updated: 2026-06-10. Continue updating as the project progresses.*
