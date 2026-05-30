# Enterprise-Grade Media Processing Pipeline with Dynamic Compute Elasticity

## 📐 Systems Architecture Overview
This repository contains the infrastructure configuration, runtime logic, and verification metrics for an event-driven, compute-elastic media processing tier. 

The architecture solves a common operational bottleneck: unpredictable, high-volume batch media ingestion routines from upstream teams. Instead of over-provisioning static compute servers—which incurs high idle costs—this solution introduces a **Compete-and-Consume Polling Pattern**. Worker instances safely isolate and process target objects directly from an object storage queue, utilizing a custom optimized Python background daemon. The underlying compute tier dynamically scales in real-time to match processing demand, dropping operational costs to the statutory minimum when idle.

### Key Architectural Advantages
* **Decoupled Architecture:** Eliminates the intermediate state management, overhead, and API tracking layers of an external message queue broker during baseline evaluation.
* **Race-Condition Avoidance:** Uses direct, low-latency metadata API polling (`ListObjectsV2` constrained via `MaxKeys=1`) to ensure workers pick targets atomically.
* **Strict Least-Privilege IAM Boundary:** Eliminates hardcoded service keys by utilizing an active IAM Instance Profile attached directly to the EC2 hypervisor core.

---

## 📊 System Configuration Blueprint

| Component Layer | Parameter Directive | Functional Engineering Value |
| :--- | :--- | :--- |
| **Data Storage Tier** | Global S3 Bucket Name | `company-ingest-bucket-hassan-96` |
| **Compute Micro-Tier** | Virtual Architecture Instance Sizing | `t3.micro` (1 vCPU, 1 GiB RAM Engine Burst Profile) |
| **Compute Fleet Bounds** | Auto Scaling Group Sizing Grid | Minimum: 1 | Desired: 1 | Maximum Cap: 3 |
| **Dynamic Scaling Metric** | Auto Scaling Policy Strategy | Target Tracking based on `ASGAverageCPUUtilization` |
| **Metric Control Point** | Utilization Upper Ceiling Limit | **60%** Target Average Capacity over 120s warmups |

---

## 🛠️ Infrastructure Core Configurations

### 1. Least-Privilege IAM S3 Execution Policy
Instances dynamically assume identity rights through an IAM instance profile using this resource-scoped JSON policy framework:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::company-ingest-bucket-hassan-96",
                "arn:aws:s3:::company-ingest-bucket-hassan-96/*"
            ]
        }
    ]
}
