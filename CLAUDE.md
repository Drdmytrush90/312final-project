# Session Bootstrap

At the start of every session, load context in this order:

## 1. Read Skills
Scan the available skills directories so you know what generators and helpers exist:
- `skills/02-devops-advanced/` — Kubernetes, Helm, Prometheus, Grafana, ArgoCD, Terraform, and more
- `skills/13-aws-skills/` — EKS, IAM, Lambda, RDS, VPC, CloudWatch, CDK, and more

## 2. Read Project References
Read these files to resume where the last session ended:
1. `MRP25CDEB.md` — full list of Jira issues for the MockRealProject - 25C - Debian project
2. `PROGRESS.md` — running journal of completed work and next steps
3. `README.md` — project overview and structure
4. `slack.md` — Slack channel log (#final-project-25c-debian) — read this to catch up on team updates, standup notes, and any new decisions made between sessions
5. `tag.md` — team cost attribution tag schema (Story 1.4 / Bohdan) — use these tag keys when creating any AWS resources so spend can be attributed correctly

---

# Project Context

- **GitHub repo:** Drdmytrush90/312final-project
- **Jira project key:** MRP25CDEB
- **Jira site:** 312school.atlassian.net
- **18 stories** across 5 epics: cluster infra, observability, app deployments, CI/CD, AI/automation
- **User's own issue:** MRP25CDEB-6 — Story 2.1 — Metrics & SLOs
- **User email:** ddmytrush@gmail.com

---

# GitHub Tokens

This project uses **two separate tokens** — always use the correct one for the correct repo:

| Token | Stored in project file | Use for |
|-------|----------------------|---------|
| **GitHub repo** | `GitHub_repo` | `Drdmytrush90/*` — personal repos (312final-project, etc.) |
| **git 312 repo acces** | `git_312_repo_acces` | `312school/*` — school org repos (platform-tools, terraform-infra, versus-25c-debian, etc.) |

> ⚠️ Always load both token files at the start of a session. Never mix them up.

---

# Working Repos (where the real deliverables live)

| Repo | Branch | What goes there |
|------|--------|-----------------|
| `312school/platform-tools-25c-debian` | `feature/2.1-eks-monitoring` | Helm chart — Prometheus + Grafana + Alertmanager |
| `312school/terraform-infra-25c-debian` | `feature/2.1-—-Metrics-&-SLOs` | CloudWatch IAM role (Terraform) |
| `Drdmytrush90/312final-project` | `main` | Session memory, skills reference, progress journal |

---

# Teammate Repos (read access for coordination)

| Repo | Owner | Why it matters |
|------|-------|----------------|
| `312school/versus-25c-debian` | Iryna Rozenstein (Story 3.1) | My Prometheus scrape target — Python/Django backend + RDS MySQL on Kubernetes. Need her to add `django-prometheus` and expose `/metrics`. DM sent 2026-06-09. |
