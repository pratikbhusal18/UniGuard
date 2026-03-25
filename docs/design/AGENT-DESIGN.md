# 🎓 UniGuard — Agent Design & Flow Concept

---

## Agent Identity

```
Name:        UniGuard
Tagline:     "Your University's AI Student Success Partner"
Surface:     Microsoft Teams (faculty, advisors, students — role-based)
Personality: Supportive, data-driven, action-oriented.
             Never judgmental about students. Always suggests next steps.
             Uses 🔴🟠🟡🟢 for risk levels.
```

---

## Three User Personas

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  👩‍🏫 FACULTY                🧑‍💼 ADVISOR              🎓 STUDENT    │
│                                                                │
│  "Which students         "Show me my              "What do I   │
│   are struggling          at-risk                  need to      │
│   in my class?"           caseload"                graduate?"   │
│                                                                │
│  Sees:                   Sees:                    Sees:         │
│  • Their classes only    • Their advisees only    • Own data    │
│  • Assignment stats      • Cross-class view       • Own grades  │
│  • Attendance data       • Intervention history   • Degree map  │
│  • Grade distribution    • Career goal tracking   • Career path │
│                                                                │
│  Can do:                 Can do:                  Can do:       │
│  • Flag a student        • Send outreach          • Set goals   │
│  • Send class nudge      • Create action plan     • Ask advice  │
│  • Generate report       • Refer to services      • Get nudges  │
│  • View alerts           • Escalate to dean       • Find help   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Conversation Flows (6 Topics)

### Topic 1: 🚨 Early Alerts

```
TRIGGER: "Show me at-risk students"
         "Who's struggling in my class?"
         "Any alerts?"

FLOW:
  ┌──────────────────────────────┐
  │  Detect User Role            │
  │  (Faculty or Advisor?)       │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Call Flow: GetAlerts         │
  │                               │
  │  Faculty → filter by their    │
  │            classes only       │
  │  Advisor → filter by their    │
  │            advisee list       │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Generative Answer           │
  │                               │
  │  "You have 5 at-risk students │
  │   this week:                  │
  │                               │
  │   🔴 Sofia Garcia (BIO301)   │
  │      Attendance: 45%          │
  │      3 missing assignments    │
  │      GPA: 1.8                 │
  │                               │
  │   🟠 James Wilson (BUS201)   │
  │      2 late submissions       │
  │      Grade trending down      │
  │                               │
  │   Want me to draft outreach   │
  │   emails for any of them?"    │
  └──────────────────────────────┘
```

---

### Topic 2: 📊 Student Pulse

```
TRIGGER: "How is Sofia Garcia doing?"
         "Show me Student ID STU003"
         "Tell me about James Wilson"

FLOW:
  ┌──────────────────────────────┐
  │  Extract student name/ID      │
  │  from user message            │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Call Flow: GetStudentContext  │
  │                               │
  │  Fetches from SharePoint:     │
  │  • Student Profile            │
  │  • Current Enrollments        │
  │  • Active Alerts              │
  │  • Intervention History       │
  │  • Career Goals               │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Generative Answer            │
  │  (Student Profile Card)       │
  │                               │
  │  Renders the full card:       │
  │  • Demographics + GPA         │
  │  • Per-class breakdown        │
  │  • Alert flags                │
  │  • Career goals               │
  │  • Past interventions         │
  │  • AI recommendation          │
  └──────────────────────────────┘
```

---

### Topic 3: 📧 Outreach

```
TRIGGER: "Draft an email to Sofia about her attendance"
         "Send a nudge to James about his late assignments"
         "Contact Sofia's parents"

FLOW:
  ┌──────────────────────────────┐
  │  Extract: student + concern   │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Call Flow: GetStudentContext  │
  │  (get real data about the     │
  │   student's situation)        │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Generative Answer            │
  │  Drafts a personalized email: │
  │                               │
  │  "Subject: Checking in —      │
  │   BIO301 Attendance           │
  │                               │
  │   Dear Sofia,                 │
  │                               │
  │   I noticed you've missed     │
  │   the last 3 BIO301 classes.  │
  │   Your current attendance is  │
  │   62%, and there are 2        │
  │   assignments due this week.  │
  │                               │
  │   I'd like to help. Can we    │
  │   meet during office hours    │
  │   this Thursday?              │
  │                               │
  │   — Dr. Martinez"             │
  │                               │
  │  [Send] [Edit] [Cancel]       │
  └──────────┬───────────────────┘
             │ (if approved)
  ┌──────────▼───────────────────┐
  │  Call Flow: SendOutreach      │
  │  • Sends email via Outlook    │
  │  • Logs to Intervention       │
  │    History list                │
  │  • Updates Audit Log          │
  └──────────────────────────────┘
```

---

### Topic 4: 🗺️ Degree Progress

```
TRIGGER: "What courses does Sofia need to graduate?"
         "Show degree progress for STU003"
         "What do I need to graduate?" (student asking)

FLOW:
  ┌──────────────────────────────┐
  │  Identify student             │
  │  (named student or self)      │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Call Flow: GetDegreeProgress │
  │                               │
  │  Fetches:                     │
  │  • Degree Plan for major      │
  │  • Completed courses          │
  │  • In-progress courses        │
  │  • Remaining requirements     │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Generative Answer            │
  │                               │
  │  "Sofia Garcia — Biology BS   │
  │   (Pre-Med Track)             │
  │                               │
  │   ✅ Completed (68/120 cr)    │
  │   • BIO101, BIO201, CHEM101   │
  │   • ENG101, MATH101, PSY101   │
  │                               │
  │   📚 In Progress (16 cr)      │
  │   • BIO301 (D), CHEM201 (C-) │
  │   • MATH201 (F), ENG102 (B)  │
  │                               │
  │   ❌ Still Needed (36 cr)     │
  │   • Physics I & II            │
  │   • Biochemistry              │
  │   • 2 Bio electives           │
  │   • Senior thesis             │
  │                               │
  │   ⚠️  At current pace,       │
  │   graduation: Spring 2027     │
  │   (1 semester behind plan)"   │
  └──────────────────────────────┘
```

---

### Topic 5: 📅 Course Recommendation

```
TRIGGER: "What should I take next semester?"
         "Recommend courses for Sofia for Fall 2026"
         "I want to go to medical school — what do I need?"

FLOW:
  ┌──────────────────────────────┐
  │  Identify student + context   │
  │  (career goals if available)  │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Call Flow: GetDegreeProgress │
  │  + GetCourseCatalog           │
  │                               │
  │  Checks:                      │
  │  • What's left to complete    │
  │  • Prerequisites met          │
  │  • Course availability        │
  │  • Career goal alignment      │
  │  • Workload balance           │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Generative Answer            │
  │                               │
  │  "Recommended for Fall 2026:  │
  │                               │
  │   1. PHY101 Physics I (4 cr)  │
  │      Required for pre-med     │
  │      Prereq: MATH101 ✅       │
  │                               │
  │   2. BIO310 Genetics (3 cr)   │
  │      Bio elective + med school│
  │      Prereq: BIO201 ✅        │
  │                               │
  │   3. SOC101 Sociology (3 cr)  │
  │      Med school requirement   │
  │      No prereq                │
  │                               │
  │   Total: 10 credits           │
  │   (lighter load recommended   │
  │    given current GPA)         │
  │                               │
  │   ⚠️ Retake MATH201 in       │
  │   summer to stay on track"    │
  └──────────────────────────────┘
```

---

### Topic 6: 📝 Progress Report

```
TRIGGER: "Generate a report for my BIO301 class"
         "Create a progress report for my advisees"
         "Department report for Biology"

FLOW:
  ┌──────────────────────────────┐
  │  Determine report scope       │
  │  (class / advisees / dept)    │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Ask: Report type?            │
  │                               │
  │  • Class Performance Summary  │
  │  • Individual Student Report  │
  │  • At-Risk Cohort Report      │
  │  • Department Overview        │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Call Flow: GenerateReport    │
  │                               │
  │  Aggregates data:             │
  │  • Enrollment + grades        │
  │  • Attendance averages        │
  │  • Alert counts by severity   │
  │  • Intervention outcomes      │
  │  • Trend vs. last month       │
  └──────────┬───────────────────┘
             │
  ┌──────────▼───────────────────┐
  │  Save report to OneDrive      │
  │  Email link to requester      │
  │  Display summary in chat      │
  └──────────────────────────────┘
```

---

## Power Automate Flows (5)

```
┌─────────────────────────────────────────────────────────────┐
│                    SCHEDULED FLOWS                           │
│                                                              │
│  ┌─────────────────────┐    ┌─────────────────────┐         │
│  │  EarlyAlertScan      │    │  NudgeEngine         │        │
│  │  Every 6 hours       │    │  Daily at 8 AM       │        │
│  │                      │    │                      │        │
│  │  • Read enrollments  │    │  • Find upcoming     │        │
│  │  • Check alert rules │    │    assignment due     │        │
│  │  • Flag at-risk      │    │    dates              │        │
│  │  • Notify advisors   │    │  • Find students     │        │
│  │  • Log to audit      │    │    with overdue tasks │        │
│  └─────────────────────┘    │  • Send Teams/email   │        │
│                              │    nudge to student   │        │
│                              └─────────────────────┘         │
│                                                              │
│                    INSTANT FLOWS (called by agent)            │
│                                                              │
│  ┌─────────────────────┐    ┌─────────────────────┐         │
│  │  GetStudentContext   │    │  GetDegreeProgress   │        │
│  │                      │    │                      │        │
│  │  Input: student name │    │  Input: student ID   │        │
│  │                      │    │                      │        │
│  │  Returns:            │    │  Returns:            │        │
│  │  • Profile           │    │  • Degree plan       │        │
│  │  • Enrollments       │    │  • Completed courses │        │
│  │  • Alerts            │    │  • Remaining reqs    │        │
│  │  • Interventions     │    │  • Career goals      │        │
│  │  • Career goals      │    │  • Projected grad    │        │
│  └─────────────────────┘    └─────────────────────┘         │
│                                                              │
│  ┌─────────────────────┐                                     │
│  │  SendOutreach        │                                    │
│  │                      │                                    │
│  │  Input: student,     │                                    │
│  │    email content     │                                    │
│  │                      │                                    │
│  │  Actions:            │                                    │
│  │  • Send via Outlook  │                                    │
│  │  • Log intervention  │                                    │
│  │  • Update audit log  │                                    │
│  └─────────────────────┘                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## SharePoint Brain — 8 Lists

```
┌─────────────────────────────────────────────────────────────┐
│                    SharePoint Site: UniGuard                  │
│                                                              │
│  📋 Student Profiles        📋 Course Catalog               │
│  ├─ Name, ID, Major         ├─ CourseID, Name, Dept         │
│  ├─ GPA, Advisor            ├─ Credits, Prerequisites       │
│  ├─ Risk Level              ├─ Semester, Instructor         │
│  └─ Career Goals            └─ Max Enrollment               │
│                                                              │
│  📋 Degree Plans            📋 Student Enrollments          │
│  ├─ Major, Track            ├─ Student → Course link        │
│  ├─ Required Courses        ├─ Grade, Attendance %          │
│  ├─ Elective Credits        ├─ Assignment Completion %      │
│  └─ Total Credits           └─ Status (Enrolled/Done/Fail)  │
│                                                              │
│  📋 Alert Rules             📋 Intervention History         │
│  ├─ Metric (Attend/GPA/..) ├─ Student, Date, Type          │
│  ├─ Threshold, Operator     ├─ Notes, Outcome              │
│  ├─ Severity                ├─ Follow-up Date              │
│  └─ Action Template         └─ Escalated? (Y/N)            │
│                                                              │
│  📋 Agent Config            📋 Audit Log                    │
│  ├─ Setting Key/Value       ├─ Action Type                  │
│  └─ Description             ├─ Details, Timestamp           │
│                              └─ Triggered By                │
└─────────────────────────────────────────────────────────────┘
```

---

## End-to-End Flow: "Sofia is struggling"

```
Day 1 (Monday 6 AM) — EarlyAlertScan runs
  │
  ├─ Reads Sofia's enrollments: MATH201 attendance = 45%
  ├─ Checks Alert Rules: "Attendance < 70% = High"
  ├─ Creates alert in Scan Results: 🔴 CRITICAL
  ├─ Sends Teams notification to Dr. Martinez (advisor):
  │   "🔴 Sofia Garcia: MATH201 attendance critically low (45%)"
  └─ Logs to Audit

Day 1 (Monday 8 AM) — NudgeEngine runs
  │
  ├─ Finds Sofia has 2 assignments due Wednesday
  ├─ Sends Teams message to Sofia:
  │   "Hey Sofia, you have 2 assignments due in 2 days:
  │    • MATH201 Problem Set 5
  │    • BIO301 Lab Report
  │    Need help? Reply 'help' to connect with tutoring."
  └─ Logs to Audit

Day 1 (Monday 9 AM) — Advisor opens Teams
  │
  ├─ Dr. Martinez sees the alert
  ├─ Chats with UniGuard: "Tell me about Sofia Garcia"
  ├─ UniGuard returns full Student Profile Card
  ├─ Dr. Martinez: "Draft an email to Sofia about her math attendance"
  ├─ UniGuard drafts personalized email with real data
  ├─ Dr. Martinez: [Send]
  ├─ Email sent, logged to Intervention History
  └─ UniGuard: "Would you like me to also refer Sofia to
     the Math Tutoring Center?"

Day 3 (Wednesday) — Follow-up
  │
  ├─ NudgeEngine checks: did Sofia submit those assignments?
  ├─ MATH201: ❌ Not submitted (now overdue)
  ├─ BIO301: ✅ Submitted
  ├─ Sends follow-up nudge to Sofia about MATH201
  └─ Updates advisor: "Sofia submitted BIO301 but missed MATH201"

Day 7 (Next Monday) — EarlyAlertScan runs again
  │
  ├─ Sofia's MATH201 attendance now 40% (worse)
  ├─ Assignment completion: 30% (worse)
  ├─ UniGuard escalation: Suggests meeting with Dean
  ├─ Sends alert to advisor + department chair
  └─ "Interventions to date haven't improved outcomes.
      Consider: academic plan modification, course withdrawal
      deadline is March 28."
```

---

## Build Order

```
Phase 1: Foundation (what we build first)
  ├─ SharePoint brain (8 lists + sample data)
  ├─ GetStudentContext flow
  ├─ Student Pulse topic
  └─ Test: "How is Sofia doing?" → works

Phase 2: Alerts & Outreach
  ├─ EarlyAlertScan flow (reads enrollment data, checks rules)
  ├─ Early Alerts topic
  ├─ SendOutreach flow
  ├─ Outreach topic
  └─ Test: "Show at-risk students" + "Draft email to Sofia"

Phase 3: Academic Advising
  ├─ GetDegreeProgress flow
  ├─ Degree Progress topic
  ├─ Course Recommendation topic
  └─ Test: "What does Sofia need to graduate?"

Phase 4: Automation
  ├─ NudgeEngine flow (daily student nudges)
  ├─ Progress Report topic + GenerateReport flow
  ├─ Deploy to Teams for pilot group
  └─ Test end-to-end scenario
```
