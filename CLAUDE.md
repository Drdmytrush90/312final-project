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

| Token | Use for |
|-------|---------|
| **Token 1 (personal)** | `Drdmytrush90/*` — personal repos (312final-project, etc.) |
| **Token 2 (312school)** | `312school/*` — school org repos (platform-tools, terraform-infra, etc.) |

Token 2 needs these permissions: **Contents + Workflows + Pull Requests** — Read & Write.

> ⚠️ Always ask user to paste both tokens at the start of a session. Never mix them up.

---

# Working Repos (where the real deliverables live)

| Repo | Branch | What goes there |
|------|--------|-----------------|
| `312school/platform-tools-25c-debian` | `feature/2.1-eks-monitoring` | Helm charts — Prometheus + Grafana + Alertmanager |
| `312school/terraform-infra-25c-debian` | `feature/2.1-metrics-slos` | CloudWatch IAM role (Terraform module) |
| `Drdmytrush90/312final-project` | `main` | Session memory, skills reference, progress journal |

---

# Open PRs (waiting for approvals)

| Repo | PR | Title |
|------|----|-------|
| `platform-tools-25c-debian` | [#8](https://github.com/312school/platform-tools-25c-debian/pull/8) | feat(2.1): Metrics & SLOs — Prometheus + Grafana + Alertmanager |
| `terraform-infra-25c-debian` | [#15](https://github.com/312school/terraform-infra-25c-debian/pull/15) | feat(2.1): add Grafana CloudWatch IRSA role |

---

# Live Cluster Info

- **Cluster:** `eks-25c-debian-dev` (us-east-1)
- **Connect:** `aws eks update-kubeconfig --name eks-25c-debian-dev --region us-east-1`
- **Gateway:** `shared-gateway` in `kube-system` (Yury's Story 1.3)
- **Grafana host:** `grafana-debian-dev.312debian.com`
- **CloudWatch role ARN:** `arn:aws:iam::905418100201:role/grafana-cloudwatch-read-dev`
- **EKS OIDC:** `oidc.eks.us-east-1.amazonaws.com/id/74039390E14D831D5E55D47F4EA1BC5D`
- **AWS Account:** `905418100201`

---

# Teammate Repos (read access for coordination)

| Repo | Owner | Why it matters |
|------|-------|----------------|
| `312school/versus-25c-debian` | Iryna Rozenstein (3.1) | Prometheus scrape target — `/metrics` live, `name: http` port added |

---

# Tag Schema (Bohdan Story 1.4)

All AWS resources must have these tags:
```
Project     = "25c-debian"
Team        = "debian"
Environment = "dev"
Story       = "2.1-metrics"
Component   = "security" (IAM) / "compute" (EKS) / "storage" (EBS)
ManagedBy   = "terraform" / "helm"
```
