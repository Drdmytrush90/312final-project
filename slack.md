# Slack Channel Log — #final-project-25c-debian

> **How to use this file:**
> At the start of every new session, ask Claude to read the Slack channel `#final-project-25c-debian`
> and update this file with anything new. This keeps you caught up without losing context between sessions.
> Last updated: 2026-06-09

---

## 🔴 Action Items for Dmytro

| Item | From | Status |
|------|------|--------|
| Approve Bohdan's PR #1 (cost tags) | Bohdan | ⬜ Pending |
| Update Jira ticket 2.1 progress before tonight's meeting | Tony | ⬜ Pending |
| Tonight's standup meeting — 9pm CST | Tony | ⬜ Tonight |
| Coordinate scrape target with Iryna (3.1) — ask her to expose `/metrics` | Dmytro | ✅ Done — DM sent 2026-06-09 |

---

## 📌 Critical Team Updates

### Cluster — Aiana (1.1) — 2026-06-07
- **Current cluster:** `eks-dev` — created by school/coordinator. **Deploy here now, you are not blocked.**
- **New cluster name:** `eks-25c-debian-dev` — Aiana's Terraform-managed cluster (in progress)
- Plan for the name change — your Helm chart's `deploy-platform-tools.yaml` section will need the right cluster name
- She will post when cutover is ready. DM her if you have specific requirements (annotations, IAM, etc.)

### Cost Tagging — Bohdan (1.4) — 2026-06-07
- `default_tags` added to `providers.tf` — auto-applies `Project`, `Team`, `Environment`, `ManagedBy`
- You only need to add `Story = "2.1-metrics"` and `Component = "security"` to your IAM role
- Full schema saved in `tag.md` in this repo
- PR to approve: https://github.com/312school/terraform-infra-25c-debian/pull/1

### Iryna (3.1) — ECR + Cluster — 2026-06-07
- Created ECR repos manually: `versus-25c-debian-backend` and `versus-25c-debian-frontend`
- Asked Aiana whether worker nodes have ECR pull permissions — **check thread for answer**
- Asked about OIDC provider URL for her IAM trust policy — depends on which cluster ends up permanent
- **Relevant to you:** Iryna's Versus app is your planned Prometheus scrape target — coordinate `/metrics` endpoint

### Erik (2.2) — 2026-06-07
- Asked whether team has a GitHub org or everyone works locally — **check thread for answer**
- Relevant to you since your `eks-monitoring/` work lives in the shared platform-tools repo

---

## 📅 Meeting Log

| Date | Time | Notes |
|------|------|-------|
| 2026-06-03 | 9pm CST | Kickoff meeting — story assignments confirmed |
| 2026-06-05 | 9pm CST | Standup — Dmytro posted update (couldn't attend) |
| 2026-06-08 | 9pm CST | Standup tonight — update Jira before meeting |

---

## 💬 Dmytro's Posts (for reference)

**2026-06-05 standup update (posted in channel):**
> Working on Story 2.1 metrics stack. Planning first — mapping dependencies (Aiana for cluster,
> Yury for ingress, Anvar for TLS). Askar depends on my Alertmanager. Learning Prometheus/Grafana/Helm
> vendoring. Currently in Phase 1 (learning), moving to Phase 2 (chart design) next.

**2026-06-04 — shared Claude workflow tip** (got 🔥🔥 from team):
> Create a GitHub repo, give Claude access, store skills/notes/progress there. Add `CLAUDE.md`
> with project context. Read it at the start of every session. Use Sonnet model.

**2026-06-04 — shared MRP25CDEB.md** (all Jira tickets as markdown — got 🙌🙌🙌🔥):
> Shared full ticket file so Claude understands all dependencies between stories.

---

## 👥 Team Roster (confirmed 2026-06-03)

| Story | Person | Status |
|-------|--------|--------|
| 1.1 | Aiana Shadykanova | 🟡 In progress — building Terraform cluster |
| 1.2 | Baigeldi Akylbek uulu | ⬜ To do |
| 1.3 | Yury Zialionka | ⬜ To do |
| 1.4 | Bohdan Voloshchuk | 🟡 In progress — cost tags PR open |
| 1.5 | Anvar Salvar | ⬜ To do |
| **2.1** | **Dmytro Dmytrush (me)** | **🟡 Phase 1 done — Phase 2 next** |
| 2.2 | Erik Myrland | ⬜ To do |
| 2.3 | Askar | ⬜ To do |
| 3.1 | Iryna Rozenstein | 🟡 In progress — ECR repos created |
| 3.2 | Herman Ilchenko | ⬜ To do |
| 3.4 | Inga Jumir | ⬜ To do |
| 4.1 | Azat Dzhanov | ⬜ To do |

---

## 🔗 Important Links

- Zoom meeting: https://us02web.zoom.us/j/85674766839?pwd=bqqZgkk73abbE8Dm1TANqqYNKhkM51.1
- AWS SSO: https://312school.awsapps.com/start
- Bohdan's cost tags PR: https://github.com/312school/terraform-infra-25c-debian/pull/1
- My working repo: https://github.com/Drdmytrush90/312final-project

---

## 📝 Session Log

| Date | What was checked | New items found |
|------|-----------------|-----------------|
| 2026-06-08 | Full channel read (session 3) | Bohdan PR reminder, Aiana cluster update, Iryna ECR, tonight's meeting |
