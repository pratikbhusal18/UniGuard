# 🎓 UniGuard — Revised Use Case Concept (v2)

---

## Core Concept

UniGuard is a **Student Success Agent** that detects struggling students early
by analyzing signals that **every university already has** — assignments, grades,
and LMS activity — not attendance.

```
THE PROBLEM:
  A student stops submitting assignments in Week 3.
  Nobody notices until Week 8 when midterm grades post.
  By then it's too late — they fail or drop out.
  The university loses tuition. The student loses a semester.

UNIGUARD:
  Detects the pattern in Week 3.
  Alerts the advisor immediately.
  Drafts outreach. Connects student to help.
  Student recovers — or at minimum, makes an informed decision early.
```

---

## The Engagement Score (replaces attendance-based alerts)

Every student gets a score calculated from **signals that exist in every university**:

```
┌─────────────────────────────────────────────────────────┐
│                  ENGAGEMENT SCORE                        │
│                  (calculated per student per course)      │
│                                                          │
│   ┌────────────────────────────┐                        │
│   │  40%  Assignment Rate       │  Submitted / Total     │
│   │       + Timeliness          │  On-time vs Late       │
│   └────────────────────────────┘                        │
│   ┌────────────────────────────┐                        │
│   │  30%  Grade Performance     │  Current grade vs.     │
│   │                             │  passing threshold     │
│   └────────────────────────────┘                        │
│   ┌────────────────────────────┐                        │
│   │  20%  LMS Activity          │  Logins, downloads,    │
│   │                             │  resource access       │
│   └────────────────────────────┘                        │
│   ┌────────────────────────────┐                        │
│   │  10%  Attendance            │  IF available          │
│   │       (optional)            │  (online/hybrid only)  │
│   └────────────────────────────┘                        │
│                                                          │
│   Score 0-100:                                           │
│   🟢 75-100  On Track                                   │
│   🟡 60-74   Needs Monitoring                           │
│   🟠 40-59   At Risk                                    │
│   🔴 0-39    Critical — Immediate Intervention           │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Why This Works for Every University

| University Type | Attendance Data? | Assignments? | Grades? | LMS? | Score Works? |
|---|---|---|---|---|---|
| Traditional in-person | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (out of 90) |
| Hybrid | ✅ Partial | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (full 100) |
| Fully online | ✅ Yes (login) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (full 100) |
| Large lecture hall | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (out of 90) |
| Lab/clinical | ✅ Yes (swipe) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (full 100) |

---

## Revised Alert Rules

| Rule | Trigger | Severity | Why |
|---|---|---|---|
| Engagement Score < 40% | Per course | 🔴 Critical | Student is barely participating |
| Engagement Score < 60% | Per course | 🟠 High | Student needs help now |
| GPA < 2.0 | Overall | 🔴 Critical | Academic probation territory |
| Grade drop > 1.0 | vs. prior semester | 🟠 High | Something changed in student's life |
| 0 assignments submitted in 2 weeks | Per course | 🔴 Critical | Student may have "ghosted" the class |
| 3+ late submissions in a row | Per course | 🟡 Medium | Early warning of disengagement |
| No LMS login in 7 days | Overall | 🟠 High | Student may be checked out entirely |
| Engagement Score dropped 20+ pts | Week over week | 🟠 High | Sudden change — possible crisis |

---

## 6 Use Cases (Revised)

### Use Case 1: 🚨 Early Alert — "Who's struggling?"

**Who uses it:** Faculty, Advisors, Deans

**The scenario:**
```
It's Week 4 of the semester. Dr. Martinez teaches BIO301 with 35 students.
Three students haven't submitted the last 2 assignments. One student's grade 
dropped from B to D. Dr. Martinez doesn't have time to cross-reference 
spreadsheets for 35 students across 4 assignments.

Dr. Martinez opens Teams:
  "Show me at-risk students in BIO301"

UniGuard:
  "3 students in BIO301 need attention:

   🔴 Sofia Garcia — Engagement: 34%
      • 0 of last 3 assignments submitted
      • Current grade: D (was B- in Week 2)
      • Last LMS login: 8 days ago
      → Hasn't engaged with the course in over a week

   🟠 Marcus Lee — Engagement: 52%
      • 2 of 3 assignments submitted (both late)
      • Current grade: C-
      • LMS logins: sporadic
      → Submitting but falling behind

   🟡 Priya Patel — Engagement: 68%
      • All assignments submitted (1 late)
      • Current grade: C+, was B+
      • LMS activity: regular
      → Grade decline worth monitoring

   Would you like me to draft outreach for any of them?"
```

**Data needed:** Student Enrollments (assignments, grades), LMS activity
**Flow:** GetStudentContext → Generative Answer
**POC:** Pre-loaded enrollment data with realistic patterns

---

### Use Case 2: 📊 Student Pulse — "Tell me about this student"

**Who uses it:** Advisors (cross-class view)

**The scenario:**
```
Academic advisor Dr. Chen has 200 advisees. Sofia Garcia's BIO301 professor
just flagged her. Dr. Chen needs the full picture — not just one class.

Dr. Chen: "How is Sofia Garcia doing?"

UniGuard:
  "🎓 Sofia Garcia (STU003) — Biology, Pre-Med Track

   Overall Engagement: 41% 🔴 Critical
   GPA: 1.8 (down from 2.4 last semester)

   📚 Current Courses:
   ┌──────────────────────────────────────────────┐
   │ Course    │ Grade │ Assign. │ Engage │ Status │
   │ BIO301    │  D    │  3/10   │  34%   │  🔴   │
   │ CHEM201   │  C-   │  5/8    │  55%   │  🟠   │
   │ MATH201   │  F    │  2/10   │  22%   │  🔴   │
   │ ENG102    │  B    │  7/8    │  82%   │  🟢   │
   └──────────────────────────────────────────────┘

   🎯 Career Goal: Medical school

   📝 Past Interventions:
   • Mar 10: Email about BIO301 (no response)
   • Mar 15: Meeting with advisor (attended)
   • Mar 18: Referred to tutoring (hasn't gone)

   💡 Recommendation: Sofia is succeeding in ENG102
   but struggling in all STEM courses. Pattern suggests
   she may need to reassess course load or get intensive
   STEM tutoring. Meeting with pre-med advisor recommended
   to discuss adjusted timeline."
```

**Data needed:** All lists — profiles, enrollments, career goals, interventions
**Flow:** GetStudentContext (comprehensive fetch)
**POC:** All data pre-loaded

---

### Use Case 3: 📧 Outreach — "Draft an email to this student"

**Who uses it:** Faculty, Advisors

**The scenario:**
```
Dr. Martinez wants to reach out to Sofia but doesn't have time to write
a thoughtful, personalized email. Generic "please come to class" emails 
get ignored.

Dr. Martinez: "Draft an email to Sofia about her missing BIO301 assignments"

UniGuard:
  "Here's a draft based on Sofia's current data:

   Subject: Checking in — BIO301 Assignments

   Hi Sofia,

   I noticed you haven't submitted the last 3 assignments in BIO301 
   (Lab Report 3, Problem Set 4, and the Genetics Quiz). Your current
   grade is a D, and I know that doesn't reflect your capability — 
   you scored a B+ on the midterm.

   I also see you're interested in medical school, and a strong 
   biology foundation will be important for that path.

   I'd love to help you get back on track. Could we meet during 
   my office hours this Thursday (2-4 PM)? I can also connect you 
   with our Biology tutoring center — they have drop-in hours 
   Mon/Wed 6-8 PM.

   You've got this.
   Dr. Martinez

   ─────────────────────────
   [✅ Send]  [✏️ Edit]  [❌ Cancel]"

Dr. Martinez: [Send]

UniGuard:
  "✅ Email sent to sofia.garcia@university.edu
   📝 Logged to intervention history
   🔔 Follow-up reminder set for March 28"
```

**What makes it powerful:** The email references REAL data — specific assignments, actual grade, career goals. Not a generic template.
**Flow:** GetStudentContext → Generative AI drafts → SendOutreach (Outlook + log)
**POC:** Real email actually sends via Outlook

---

### Use Case 4: 🗺️ Degree Progress — "What does she need to graduate?"

**Who uses it:** Advisors, Students

**The scenario:**
```
Sofia is on academic probation. Her advisor needs to understand:
Can she still graduate on time? What's the most strategic path forward?

Dr. Chen: "Show Sofia's degree progress"

UniGuard:
  "🗺️ Sofia Garcia — Biology BS (Pre-Med Track)

   Credits: 68 completed / 120 required (57%)
   Projected graduation: Spring 2027 (1 semester behind)

   ✅ Completed (68 credits):
   • BIO101 Intro Biology (A)
   • BIO201 Cell Biology (B+)
   • CHEM101 General Chemistry (B)
   • MATH101 Calculus I (C+)
   • ENG101 English I (A-)
   • PSY101 Intro Psych (B)
   • [+ 12 more gen eds]

   📚 In Progress (16 credits):
   • BIO301 Molecular Biology — D ⚠️
   • CHEM201 Organic Chemistry — C-
   • MATH201 Calculus II — F ⚠️
   • ENG102 English II — B

   ❌ Still Needed (36 credits):
   • Physics I & II (8 cr) — prereq: MATH201 ✅ needed
   • Biochemistry (4 cr) — prereq: CHEM201 ⏳ in progress
   • Genetics (3 cr)
   • 2 Biology electives (6 cr)
   • Senior Thesis (3 cr)
   • Sociology (3 cr) — med school requirement
   • Free electives (9 cr)

   ⚠️ Risk: If Sofia fails MATH201, she can't take Physics
   next semester — pushing graduation to Fall 2027.

   💡 Recommendation: Consider summer course for MATH201
   retake to stay on track for Physics in Fall."
```

**Flow:** GetDegreeProgress (reads Degree Plans + Enrollments + Course Catalog)
**POC:** Pre-loaded degree plan for Biology major

---

### Use Case 5: 📅 Course Recommendation — "What should I take next?"

**Who uses it:** Students, Advisors

**The scenario:**
```
A student is planning next semester and doesn't know what to take.
Currently they browse a 200-page course catalog. UniGuard knows their
degree requirements, completed courses, prerequisites, AND career goals.

Sofia: "What should I take next semester?"

UniGuard:
  "Based on your Biology (Pre-Med) degree, here's my recommendation
   for Fall 2026:

   RECOMMENDED (lighter load given current GPA):

   1. PHY101 Physics I (4 cr) ✅ prereqs met
      • Required for pre-med AND degree
      • Offered: MWF 10-11, TTh 2-3:30

   2. BIO310 Genetics (3 cr) ✅ prereqs met
      • Bio elective + valuable for MCAT
      • Offered: TTh 11-12:30

   3. SOC101 Intro Sociology (3 cr) — no prereq
      • Med school requirement you haven't started
      • Lighter course to balance STEM load

   Total: 10 credits (reduced from typical 15)

   ⚠️ Also recommended:
   • Retake MATH201 in Summer 2026 (needed for Physics II)
   • This keeps you on track for Spring 2027 graduation

   ❌ Not yet eligible for:
   • Biochemistry (needs CHEM201 — finish this semester first)
   • Physics II (needs MATH201 — retake first)

   Would you like me to check available sections and times?"
```

**Flow:** GetDegreeProgress + Course Catalog lookup
**POC:** Pre-loaded catalog with prerequisites

---

### Use Case 6: 📝 Progress Report — "Generate a class report"

**Who uses it:** Faculty, Department Chairs, Deans

**The scenario:**
```
It's midterm. The Biology department chair wants to know how students 
are performing across all biology courses this semester.

Department Chair: "Generate a report for the Biology department"

UniGuard:
  "📊 Biology Department — Midterm Progress Report
   Generated: March 25, 2026

   OVERVIEW
   ────────
   Total students enrolled: 127
   Average engagement score: 71% 🟡
   Students at risk: 18 (14%)
   Students critical: 7 (6%)

   BY COURSE
   ─────────
   BIO101 (45 students) — Avg engagement: 78% 🟢
     At risk: 3, Critical: 1
   BIO201 (38 students) — Avg engagement: 72% 🟡
     At risk: 5, Critical: 2
   BIO301 (28 students) — Avg engagement: 63% 🟠
     At risk: 8, Critical: 3
   BIO310 (16 students) — Avg engagement: 81% 🟢
     At risk: 2, Critical: 1

   TRENDS
   ──────
   • BIO301 has the highest at-risk rate (39%)
   • 4 students are at-risk in 2+ biology courses
   • Overall engagement declined 5% from Week 4 to Week 6

   TOP CONCERNS
   ─────────────
   🔴 Sofia Garcia — engagement 34% across 2 bio courses
   🔴 Tyler Brooks — 0 submissions in BIO301 for 3 weeks
   🟠 Maria Santos — grade dropped B+ to C- in BIO201

   📄 Full report saved to OneDrive
   📧 Emailed to biology-dept@university.edu"
```

**Flow:** GenerateReport (aggregates all enrollment data, computes stats)
**POC:** Pre-loaded data generates realistic report

---

## POC Data Strategy

### What We Pre-Load

| List | Records | Purpose |
|---|---|---|
| Student Profiles | 5 students (2 struggling, 1 borderline, 2 healthy) | Realistic demo variety |
| Course Catalog | 6 courses across departments | Show cross-department view |
| Degree Plans | 2 plans (Biology Pre-Med, Computer Science) | Demo degree tracking |
| Student Enrollments | 15 enrollments with realistic grade/assignment data | The core signal data |
| Alert Rules | 8 rules (engagement-based) | Configurable thresholds |
| Intervention History | 3 past interventions for Sofia | Show ongoing support story |
| Career Goals | 2 students with goals (Sofia: med school, Emma: software engineering) | Personalized advising |
| Agent Config | 7 settings | Customizable per university |

### Sample Engagement Scores (pre-calculated)

| Student | BIO301 | CHEM201 | MATH201 | ENG102 | Overall |
|---|---|---|---|---|---|
| Sofia Garcia | 34% 🔴 | 55% 🟠 | 22% 🔴 | 82% 🟢 | 41% 🔴 |
| James Wilson | 52% 🟠 | — | — | 78% 🟢 | 61% 🟡 |
| Olivia Brown | — | — | — | 85% 🟢 | 68% 🟡 |
| Emma Johnson | 91% 🟢 | — | 88% 🟢 | 95% 🟢 | 92% 🟢 |
| Liam Chen | — | 94% 🟢 | 96% 🟢 | — | 95% 🟢 |

---

## Build Order (Revised)

```
Phase 1: Foundation — "How is Sofia doing?" works
  ├─ Provision SharePoint (8 lists + sample data)
  ├─ GetStudentContext flow (reads all student data)
  ├─ Copilot agent + Student Pulse topic
  └─ TEST: "How is Sofia doing?" → full profile card

Phase 2: Alerts & Outreach — "Who's struggling?" + "Email them"
  ├─ Early Alerts topic (reads enrollment data, shows at-risk)
  ├─ SendOutreach flow (sends real email via Outlook)
  ├─ Outreach topic (draft + send + log)
  └─ TEST: "Show at-risk students" → "Draft email to Sofia"

Phase 3: Academic Advising — "What does she need?"
  ├─ GetDegreeProgress flow
  ├─ Degree Progress topic
  ├─ Course Recommendation topic
  └─ TEST: "What does Sofia need to graduate?"

Phase 4: Reports & Automation — "Generate a report"
  ├─ Progress Report topic + flow
  ├─ NudgeEngine flow (future: daily student reminders)
  └─ TEST: "Generate Biology department report"
```
