# Story 2.1 — Metrics & SLOs
# IAM Role for Grafana to read CloudWatch metrics (RDS, ALB, EKS)
# Uses IRSA (IAM Roles for Service Accounts) — links Kubernetes Service Account to this role
# Default tags (Project, Team, Environment, ManagedBy) come automatically from Bohdan's providers.tf
# Only Story and Component are set here manually

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster (without https://)"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

# ─────────────────────────────────────────────
# IAM Role — Grafana CloudWatch Read
# ─────────────────────────────────────────────

resource "aws_iam_role" "grafana_cloudwatch" {
  name = "grafana-cloudwatch-read-${var.environment}"

  # IRSA trust policy — only Grafana's service account can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_issuer_url}:aud" = "sts.amazonaws.com"
            "${var.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:monitoring:grafana"
          }
        }
      }
    ]
  })

  tags = {
    Story     = "2.1-metrics"
    Component = "security"
  }
}

# ─────────────────────────────────────────────
# IAM Policy — CloudWatch Read Only
# ─────────────────────────────────────────────

resource "aws_iam_role_policy" "grafana_cloudwatch_read" {
  name = "grafana-cloudwatch-read-policy-${var.environment}"
  role = aws_iam_role.grafana_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchReadOnly"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DescribeAlarmsForMetric"
        ]
        Resource = "*"
      },
      {
        Sid    = "TagsReadOnly"
        Effect = "Allow"
        Action = [
          "tag:GetResources"
        ]
        Resource = "*"
      }
    ]
  })
}

# ─────────────────────────────────────────────
# Output — Role ARN (needed in Helm values)
# ─────────────────────────────────────────────

output "grafana_cloudwatch_role_arn" {
  description = "ARN of the Grafana CloudWatch IAM role — paste this into eks-monitoring values.yaml"
  value       = aws_iam_role.grafana_cloudwatch.arn
}
