# 🎓 UniGuard — Setup Guide

## Overview

This guide covers the SharePoint list schemas, engagement scoring formula, and default alert rules for UniGuard.
Total setup time: ~25 minutes.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Microsoft 365 E3/E5** | SharePoint, Teams, Outlook |
| **Copilot Studio** | Per-user or capacity-based license |
| **Power Automate Premium** | For Copilot Studio connector |
| **SharePoint Admin** | Create sites, manage lists |

---

## SharePoint Site

Create a SharePoint Communication Site:

| Setting | Value |
|---|---|
| **Site name** | UniGuard |
| **Site URL** | `https://m365cpi30732412.sharepoint.com/sites/UniGuard` |
| **Template** | Communication Site (or Team Site) |

---

## SharePoint Lists (9 Total)

### Tier 1: People & Roles

#### 📋 1. User Roles

Maps M365 users to their UniGuard role and data scope.

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Display name |
| UserEmail | Single line of text | M365 email (primary lookup key) |
| Role | Choice: `Faculty` / `Advisor` / `Student` / `Admin` | User's persona |
| LinkedStudentID | Single line of text | If Student — their student ID |
| LinkedCourses | Multiple lines of text | If Faculty — comma-separated course IDs they teach |
| LinkedAdvisees | Multiple lines of text | If Advisor — comma-separated student IDs |
| Department | Single line of text | Department name |

#### 📋 2. Student Profiles

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Student full name |
| StudentID | Single line of text | Unique ID (e.g., STU001) |
| Major | Single line of text | Declared major |
| Track | Single line of text | Specialization (e.g., "Pre-Med") |
| GPA | Number (2 decimals) | Current cumulative GPA |
| PriorGPA | Number (2 decimals) | Previous semester GPA (for trend analysis) |
| AdvisorName | Single line of text | Advisor display name |
| AdvisorEmail | Single line of text | Advisor's M365 email |
| EnrollmentStatus | Choice: `Active` / `Probation` / `Suspended` / `Graduated` / `Withdrawn` | Current status |
| RiskLevel | Choice: `Low` / `Medium` / `High` / `Critical` | Current risk level |
| EngagementScore | Number (0–100) | Weighted engagement score |
| CareerGoal | Multiple lines of text | Self-reported career aspiration |
| YearLevel | Choice: `Freshman` / `Sophomore` / `Junior` / `Senior` / `Graduate` | Academic year |
| Email | Single line of text | Student email |
| Phone | Single line of text | Phone number |

---

### Tier 2: Academic Data

#### 📋 3. Course Catalog

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Course name |
| CourseID | Single line of text | Course code (e.g., CS101) |
| Department | Single line of text | Department name |
| Prerequisites | Multiple lines of text | Required prior courses (comma-separated) |
| Credits | Number | Credit hours |
| Semester | Choice: `Fall` / `Spring` / `Summer` / `All` | When offered |
| Instructor | Single line of text | Faculty name |
| InstructorEmail | Single line of text | Faculty M365 email |
| MaxEnrollment | Number | Seat capacity |

#### 📋 4. Degree Plans

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Plan name (e.g., "Biology BS — Pre-Med") |
| Major | Single line of text | Major name |
| Track | Single line of text | Track/specialization |
| RequiredCourses | Multiple lines of text | Comma-separated course IDs |
| ElectiveCredits | Number | Elective credits needed |
| TotalCredits | Number | Total credits to graduate |
| Notes | Multiple lines of text | Additional requirements |

#### 📋 5. Student Enrollments

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Label: "STU003 → BIO301 (Spring 2026)" |
| StudentRef | Single line of text | Student ID |
| CourseRef | Single line of text | Course ID |
| Semester | Single line of text | e.g., "Spring 2026" |
| Grade | Single line of text | Current letter grade |
| AttendanceRate | Number (0–100) | % attendance (null if not tracked) |
| AssignmentCompletionRate | Number (0–100) | % assignments submitted |
| Status | Choice: `Enrolled` / `Completed` / `Withdrawn` / `Failed` | Enrollment status |

---

### Tier 3: Intervention & Alerting

#### 📋 6. Alert Rules

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Rule name |
| Metric | Choice: `EngagementScore` / `GPA` / `AssignmentCompletion` / `GradeDrop` / `WeeksInactive` | What to check |
| Threshold | Number | Numeric threshold value |
| Operator | Choice: `LessThan` / `GreaterThan` / `Equals` | Comparison operator |
| Severity | Choice: `Low` / `Medium` / `High` / `Critical` | Alert severity |
| ActionTemplate | Multiple lines of text | Default intervention suggestion |

#### 📋 7. Intervention History

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Brief description |
| StudentRef | Single line of text | Student ID |
| InterventionType | Choice: `Email` / `Meeting` / `PhoneCall` / `Referral` / `AcademicPlan` / `CourseWithdrawal` | Type of intervention |
| Notes | Multiple lines of text | Details |
| Outcome | Choice: `Pending` / `Improved` / `NoChange` / `Escalated` / `Resolved` | Result |
| FollowUpDate | Date and Time | When to follow up |

---

### Tier 4: System

#### 📋 8. Agent Config

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Config key |
| Value | Multiple lines of text | Config value |
| ConfigDescription | Single line of text | What this setting does |

Default entries:

| Key | Default Value | Description |
|---|---|---|
| AlertScanFrequencyHours | 6 | How often EarlyAlertScan runs |
| EngagementWeights | `assign:50,attend:10,lms:30,grade:10` | Engagement score weights |
| RiskThresholdCritical | 25 | Engagement score below this = Critical |
| RiskThresholdHigh | 40 | Engagement score below this = High |
| RiskThresholdMedium | 60 | Engagement score below this = Medium |
| OutreachCCAdvisor | true | CC the advisor on outreach emails |
| AuditRetentionDays | 365 | How long audit log entries are kept |

#### 📋 9. Audit Log

| Column | Type | Description |
|---|---|---|
| Title | Single line of text | Action description |
| ActionType | Choice: `EarlyAlert` / `Outreach` / `StudentPulse` / `DegreePlan` / `CourseAdvice` / `Report` / `Nudge` / `Config` | What happened |
| Details | Multiple lines of text | Full details |
| Timestamp | Date and Time | When it happened |

---

## Engagement Score Formula

The Engagement Score is a weighted composite of per-enrollment metrics:

```
EngagementScore = (AssignmentCompletionRate × 0.50)
                + (AttendanceRate           × 0.10)
                + (LMSActivityScore         × 0.30)
                + (GradePoints / 4.0 × 100  × 0.10)
```

| Component | Weight | Source | Notes |
|---|---|---|---|
| Assignment Completion | 50% | AssignmentCompletionRate (0–100) | Primary signal — most predictive of success |
| LMS Activity | 30% | LMSActivityScore (0–100) | Logins, resource access, video views |
| Attendance | 10% | AttendanceRate (0–100) | Optional — null if not tracked (weight redistributed) |
| Grade Performance | 10% | GradePoints mapped to 0–100 | 4.0 → 100, 3.0 → 75, 2.0 → 50, etc. |

**When AttendanceRate is null:** redistribute its 10% weight equally to Assignment Completion (55%) and LMS Activity (35%).

### Risk Mapping

| Engagement Score | Risk Level | Color |
|---|---|---|
| 0–25 | 🔴 Critical | Red |
| 26–40 | 🟠 High | Orange |
| 41–60 | 🟡 Medium | Yellow |
| 61–100 | 🟢 Low | Green |

---

## Default Alert Rules

Populate the **Alert Rules** list with these starting rules:

| Title | Metric | Threshold | Operator | Severity | ActionTemplate |
|---|---|---|---|---|---|
| Critical Engagement Drop | EngagementScore | 25 | LessThan | Critical | Immediate advisor outreach + dean notification |
| High Risk Engagement | EngagementScore | 40 | LessThan | High | Schedule advisor meeting within 48 hours |
| Low GPA Warning | GPA | 2.0 | LessThan | High | Academic probation review + support referral |
| Assignment Completion Alert | AssignmentCompletion | 50 | LessThan | Medium | Email student + notify faculty |
| Inactive Student | WeeksInactive | 2 | GreaterThan | High | Wellness check + engagement outreach |
| Grade Drop Alert | GradeDrop | 1.0 | GreaterThan | Medium | Faculty notification + student check-in |

---

## Troubleshooting

| Issue | Solution |
|---|---|
| Lists not appearing in flow | Verify the site URL is exact: `https://m365cpi30732412.sharepoint.com/sites/UniGuard` |
| Choice columns not matching | Ensure choice values are entered exactly as shown (case-sensitive) |
| Engagement Score always 0 | Check that enrollment rows have AssignmentCompletionRate populated |
| Alerts not firing | Verify Alert Rules list has `IsActive = Yes` on each rule |

---

## Security Notes

- All data stays within your M365 tenant — no external API calls
- SharePoint permissions enforce row-level visibility
- The User Roles list controls what the agent shows to each persona
- Audit Log tracks every agent action for compliance
