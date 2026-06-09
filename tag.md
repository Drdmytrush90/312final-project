# Team Cost Attribution — Tag Schema (Story 1.4)

As part of Story 1.4, Bohdan owns cost attribution for the team.
We need consistent tags on all AWS resources so we can read the bill and know what's spending what.

---

## Our Tag Schema

```
Project     = "25c-debian"
Team        = "debian"
Environment = "dev"
Story       = "your-story-number"  ← you set this
Component   = "see lookup table"   ← you set this
ManagedBy   = "terraform|helm|karpenter|manual"
```

---

## Component Lookup Table

Match your resource to the right Component value:

| Resource Types                        | Component value |
|---------------------------------------|-----------------|
| EC2, ASG, Lambda                      | `compute`       |
| RDS, DocumentDB, DynamoDB             | `database`      |
| VPC, Subnets, ALB, Route53            | `networking`    |
| S3, EBS                               | `storage`       |
| IAM roles, policies                   | `security`      |
| ECR repositories                      | `registry`      |
| SQS, SNS, EventBridge                 | `messaging`     |

---

## Story Values

Use the value that matches your story:

```
1.1-cluster | 1.2-iam | 1.3-traffic | 1.4-karpenter | 1.5-services
2.1-metrics | 2.2-logging | 2.3-alerting
3.1-versus  | 3.2-versus-ec2 | 3.3-proshop | 3.4-serverless | 3.5-weather
4.1-gitlab  | 4.2-kafka | 5.1-incident | 5.2-pr-review | 5.3-mcp
```

**My story:** `2.1-metrics`

---

## What Bohdan Already Did

Added `default_tags` to `providers.tf` — this automatically applies `Project`, `Team`, `Environment`,
and `ManagedBy` to every Terraform resource. `Story` and `Component` default to `"unset"` so
anything untagged is easy to spot in the bill.

---

## What I Need to Do (Story 2.1)

### In Terraform
Only add these two tags to my Terraform resources — the other four come from `default_tags` automatically:

```hcl
tags = {
  Story     = "2.1-metrics"
  Component = "security"      # for my CloudWatch IAM role
}
```

Example for my CloudWatch → Grafana IAM role:
```hcl
resource "aws_iam_role" "grafana_cloudwatch" {
  name = "grafana-cloudwatch-read-dev"
  # ... trust policy etc.

  tags = {
    Story     = "2.1-metrics"
    Component = "security"
  }
}
```

### If I Create Anything Manually in the AWS Console
Add all 6 tags by hand:

| Key         | Value         |
|-------------|---------------|
| Project     | 25c-debian    |
| Team        | debian        |
| Environment | dev           |
| Story       | 2.1-metrics   |
| Component   | security      |
| ManagedBy   | manual        |

---

## PR to Review

Pipeline check is pending but code review is open:
https://github.com/312school/terraform-infra-25c-debian/pull/1

---

## Notes

- Helm-deployed resources (Prometheus, Grafana, Alertmanager pods) are tagged via Helm labels,
  not AWS tags — the AWS tag schema applies to AWS-level resources only (IAM roles, etc.).
- My only AWS-level resource in Phase 3 is the CloudWatch IAM role → `Component = "security"`.
- If I add an S3 bucket for alert storage later → `Component = "storage"`.
