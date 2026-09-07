# Calgary_Healthcare_Claims_and_Revenue_Cycle_Analytics

## ⚠️ Dataset Notice
**All datasets used in this project are synthetically generated for analytical and educational purposes. No real patient or hospital data is included.**

---

## 📋 Project Overview
End-to-end healthcare revenue cycle analytics platform analyzing claims processing, denial patterns, and financial performance. This project identifies revenue leakage points and provides actionable insights to optimize hospital billing operations and maximize reimbursement rates.

---

## 🏥 Business Problem
Healthcare organizations face critical revenue cycle challenges:
- **Claim Denials**: ~10% initial denial rates costing $25+ per rework; 65% never resubmitted
- **Processing Delays**: Extended days in A/R due to bottlenecks in claim submission and payer response
- **Coding Errors**: Incorrect diagnosis/procedure codes triggering automatic rejections
- **Underpayments**: Undetected discrepancies between expected and received reimbursement
- **Administrative Burden**: Manual rework consuming 15-20% of billing department resources

This analysis uncovers root causes and provides targeted improvement strategies.

---

## 🛠️ Tech Stack
| Component | Technology |
|-----------|-----------|
| **Data Processing** | Python (Pandas, NumPy) |
| **Database** | SQL (Query & Transformation) |
| **Visualization** | Power BI |
| **Languages** | Python, SQL |

---

## 🏗️ Data Architecture & Model

**Data Pipeline:**
```
Raw Claims Data → Python Cleaning → SQL Database → Power BI Dashboard → Insights
```

**Core Tables:**
- `claims` - Claim details (ID, amount, status, dates)
- `denials` - Denial reasons and root causes
- `payers` - Insurance company performance metrics
- `claims_detail` - Line-item service records
- `aging_analysis` - Days in AR tracking

---

## 🔄 Implementation Steps

1. **Data Cleaning & Validation** → [View Python Cleaning Code](#python-data-cleaning)
   - Handle missing values, duplicates, data type conversions
   - Standardize dates, amounts, status codes
   - Flag anomalies and data quality issues

2. **SQL Data Warehouse** → [View SQL Queries](#sql-queries)
   - Create normalized schema
   - Aggregate claims by payer, status, denial reason
   - Calculate aging buckets and KPI metrics

3. **Power BI Dashboard Development**
   - Build interactive visualizations
   - Create drill-down capabilities by payer, location, denial type
   - Enable real-time monitoring

4. **Analysis & Reporting**
   - Identify trends and patterns
   - Benchmark against industry standards
   - Generate actionable recommendations

---

## 📊 Power BI Dashboard

"C:\Users\Lilian\Downloads\Calgary_Healthcare_Claims_and_Revenue (1).pbix"

**Key Visualizations:**
- Claims volume and denial rate trends
- Top denial reasons (pie chart)
- Days in A/R aging analysis
- Payer performance scorecard
- Clean claim rate vs. rework volume
- Financial impact by denial category

---

## 📈 Key Performance Indicators (KPIs)

| KPI | Target | Current | Insight |
|-----|--------|---------|---------|
| **Clean Claim Rate** | >95% | 87% | Coding accuracy improvement needed |
| **First Pass Denial Rate** | <5% | 9.2% | Focus on payer edit compliance |
| **Days in A/R** | <30 days | 42 days | Process bottlenecks in follow-up phase |
| **Claim Rework Rate** | <3% | 5.8% | Documentation gaps causing resubmissions |
| **Appeal Success Rate** | >75% | 68% | Stronger appeal justifications required |
| **Revenue Recovery %** | >90% | 82% | Underpayments need dispute resolution |

---

## 💡 Key Findings & Recommendations

**Top Denial Drivers:**
1. **Authorization Issues** (28%) → Implement pre-authorization validation at entry
2. **Coding Errors** (22%) → Enhance coder training and automated code auditing
3. **Documentation Deficiencies** (18%) → Strengthen clinical documentation requirements
4. **Payer-Specific Rules** (16%) → Build payer-specific edits into submission system
5. **Duplicate Claims** (10%) → Deploy duplicate detection algorithm

**Recommended Actions:**
- ✅ Prioritize authorization verification before claim submission
- ✅ Implement automated coding validation using industry standards (CPT/ICD-10)
- ✅ Establish denial appeals task force for high-value claims
- ✅ Create payer scorecards for performance monitoring
- ✅ Deploy real-time dashboard for operational staff visibility
- ✅ Target 95% clean claim rate within 6 months (revenue impact: ~$500K+)

---

## 📂 Project Structure

```
Calgary_Healthcare_Claims_and_Revenue_Cycle_Analytics/
├── data/                          # Raw & processed data
├── python/                        # Data cleaning scripts
│   └── [Python Data Cleaning](#python-data-cleaning)
├── sql/                           # SQL queries
│   └── [SQL Queries Section](#sql-queries)
├── dashboards/                    # Power BI files
├── reports/                       # Analysis reports
└── README.md                      # This file
```

---


## 👤 Author
[Linda M-Okoronkwo / Linda Madu]

---

**Last Updated:** September 2026 | **Data Generated:** Synthetic | **Status:** Active
