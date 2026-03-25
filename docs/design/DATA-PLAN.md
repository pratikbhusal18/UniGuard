# 🎓 UniGuard — Detailed Data & Scenario Plan

## How University Data Actually Works

### The Reality of University Data Systems

Universities don't have one system — they have **dozens**, and data is scattered:

```
┌─────────────────────────────────────────────────────────────────┐
│                    University Data Landscape                     │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │     SIS       │  │     LMS      │  │   Microsoft 365      │  │
│  │ (Student Info │  │ (Learning    │  │   Education          │  │
│  │  System)      │  │  Management) │  │                      │  │
│  │              │  │              │  │  • Teams (classes)    │  │
│  │ • Banner     │  │ • Canvas     │  │  • Assignments       │  │
│  │ • PeopleSoft │  │ • Blackboard │  │  • Grades            │  │
│  │ • Workday    │  │ • Moodle     │  │  • Attendance        │  │
│  │ • Ellucian   │  │ • Brightspace│  │  • OneDrive          │  │
│  │              │  │              │  │  • SharePoint         │  │
│  │ Has:         │  │ Has:         │  │  • Outlook           │  │
│  │ • Enrollment │  │ • Grades     │  │  • Reflect (wellbeing)│  │
│  │ • Transcripts│  │ • Submissions│  │                      │  │
│  │ • Financial  │  │ • Engagement │  │  Synced via:         │  │
│  │ • Demographics│ │ • Content    │  │  School Data Sync    │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                  │                      │              │
│         ▼                  ▼                      ▼              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │           Microsoft School Data Sync (SDS)               │    │
│  │  Syncs SIS roster data → M365 (users, classes, roles)   │    │
│  │  Runs 2x daily automatically                             │    │
│  └──────────────────────────┬──────────────────────────────┘    │
│                              │                                    │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Microsoft Graph Education API               │    │
│  │  • /education/schools                                    │    │
│  │  • /education/classes                                    │    │
│  │  • /education/classes/{id}/members (roster)              │    │
│  │  • /education/classes/{id}/assignments                   │    │
│  │  • /education/classes/{id}/assignments/{id}/submissions  │    │
│  │  • /users/{id}/reflectCheckInResponses (wellbeing)       │    │
│  └──────────────────────────┬──────────────────────────────┘    │
│                              │                                    │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    🎓 UniGuard                            │    │
│  │          Reads, analyzes, and acts on all of this        │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Sources — What UniGuard Reads

### Source 1: Microsoft Graph Education API (Primary)
This is the **backbone**. When a university uses M365 Education + School Data Sync, all this data is available via API:

| Data | API Endpoint | What It Tells Us |
|------|-------------|-----------------|
| **Schools** | `/education/schools` | List of schools/departments |
| **Classes** | `/education/classes` | All courses with term, teacher, description |
| **Roster** | `/education/classes/{id}/members` | Students enrolled in each class |
| **Assignments** | `/education/classes/{id}/assignments` | What's assigned, due dates, points |
| **Submissions** | `/education/classes/{id}/assignments/{id}/submissions` | Who submitted, when, grade, late? |
| **Grades** | Submission outcomes | Individual assignment grades |
| **Attendance** | Teams meeting attendance reports | Who showed up to class |
| **Wellbeing** | `/reports/reflectCheckInResponses` | Student emotional check-ins (if using Reflect) |

### Source 2: Microsoft Teams Signals
| Signal | How to Capture | What It Means |
|--------|---------------|--------------|
| Class attendance | Teams meeting attendance API | Student showed up / didn't |
| Chat participation | Teams message activity | Student is engaged / silent |
| File access | OneDrive/SharePoint audit logs | Student is accessing materials |
| Assignment views | Education API | Student looked at the assignment |

### Source 3: SharePoint (UniGuard's Own Brain)
| List | Managed By | Purpose |
|------|-----------|---------|
| Student Profiles | Synced from SIS via SDS | Demographics, major, GPA, advisor |
| Degree Plans | Academic affairs | Requirements per major |
| Course Catalog | Registrar | Course details, prerequisites |
| Alert Rules | Admin configurable | Thresholds for early alerts |
| Intervention History | Advisors | What actions were taken |
| Career Goals | Students themselves | Self-reported goals and interests |

---

## How It's Customized Per University

### Configuration Layers

```
┌─────────────────────────────────────┐
│  Layer 1: University-Wide Config     │
│  • Alert thresholds                  │
│  • Degree plans per major            │
│  • Grading scale (A-F vs 4.0)       │
│  • Semester dates                    │
│  • Department structure              │
│  • Compliance requirements (FERPA)   │
│  Set by: IT Admin / Provost          │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│  Layer 2: Department/College Config  │
│  • Specific alert rules              │
│  • Custom intervention workflows     │
│  • Required courses per program      │
│  • Lab/clinical requirements         │
│  Set by: Department Chair / Dean     │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│  Layer 3: Student-Level Config       │
│  • Career goals (self-reported)      │
│  • Accommodation needs (IEP/504)     │
│  • Preferred communication channel   │
│  • Advisor assignment                │
│  • Personal risk factors             │
│  Set by: Student + Advisor           │
└─────────────────────────────────────┘
```

### Per-University Customization Examples

| University Type | Custom Config | Why |
|----------------|--------------|-----|
| **Large State University (50K students)** | Higher alert volume → only surface Critical. Batch nudges weekly. Department-level dashboards. | Scale requires filtering |
| **Small Liberal Arts (2K students)** | Lower thresholds. Individual attention. Advisor sees every alert. Daily nudges. | Personal touch matters |
| **Community College** | Track part-time vs full-time differently. Financial aid alerts. Transfer readiness tracking. | Different student needs |
| **Online University** | No attendance signal → use login frequency + assignment engagement instead. Async engagement metrics. | No physical classroom |
| **Research University** | Add research output tracking for grad students. Publication milestones. Advisor meeting frequency. | Graduate student focus |

---

## Per-Student Customization

### Student Profile Card (what UniGuard knows about each student)

```
┌─────────────────────────────────────────────────────┐
│  🎓 Sofia Garcia (STU-2024-0847)                     │
│                                                       │
│  Major: Biology (Pre-Med Track)       GPA: 1.8        │
│  Year: Junior                         Status: Probation│
│  Advisor: Dr. Martinez                Risk: 🔴 HIGH   │
│                                                       │
│  📊 Current Semester                                  │
│  ┌─────────────────────────────────────────────────┐ │
│  │ BIO301 Molecular Biology    Grade: D  Attend: 62%│ │
│  │ CHEM201 Organic Chemistry   Grade: C- Attend: 71%│ │
│  │ MATH201 Calculus II         Grade: F  Attend: 45%│ │
│  │ ENG102 English Composition  Grade: B  Attend: 89%│ │
│  └─────────────────────────────────────────────────┘ │
│                                                       │
│  🚨 Active Alerts                                     │
│  • MATH201 attendance below 50% (Critical)           │
│  • BIO301 3 consecutive absences (Critical)          │
│  • GPA below 2.0 (Probation threshold)               │
│  • 4 missing assignments across courses               │
│                                                       │
│  🎯 Career Goals (self-reported)                      │
│  • Medical school admission                           │
│  • MCAT prep (planning for Summer 2025)              │
│  • Research experience in molecular biology           │
│                                                       │
│  📝 Intervention History                              │
│  • Mar 10: Email sent about MATH201 attendance       │
│  • Mar 15: Meeting with advisor Dr. Martinez         │
│  • Mar 18: Referred to tutoring center               │
│  • Mar 22: No improvement — escalate to Dean?        │
│                                                       │
│  💡 AI Recommendation                                 │
│  "Sofia's STEM courses are struggling but English is  │
│   strong. Consider: 1) Mandatory tutoring for MATH,   │
│   2) Reduced course load next semester, 3) Connect    │
│   with pre-med advisor about adjusted timeline."      │
└─────────────────────────────────────────────────────┘
```

### Career Goals Integration

Students self-report career goals via a **Teams form** or **chat with UniGuard**:

```
Student: "I want to go to medical school"

UniGuard: Based on your pre-med track, here's your status:
  ✅ Completed: BIO101, CHEM101, BIO201
  ⚠️  In Progress: BIO301 (currently D — needs B+ for med school)
  ❌ Not Started: Physics I & II, Biochemistry, Sociology
  
  📊 Your science GPA: 2.1 (med school avg acceptance: 3.5)
  
  💡 Recommendation: Focus on improving BIO301 and MATH201 this 
  semester. Consider summer courses to lighten future semesters. 
  Would you like me to find tutoring resources?
```

---

## Real University Scenarios

### Scenario 1: Arizona State University (80K+ students)
**Problem:** 80,000 students. Advisors have 500+ students each. Impossible to manually track who's struggling.

**UniGuard approach:**
- SDS syncs roster from PeopleSoft → M365
- UniGuard scans all 80K students daily via Education API
- Alert Rules: Only surface Critical + High (to manage volume)
- Dashboard for each college: "Engineering has 47 at-risk students this week"
- Auto-sends nudge to students: "You haven't submitted your MATH201 homework due tomorrow"
- Advisors see only their flagged students, sorted by urgency
- **Impact:** Advisor spends 10 min reviewing UniGuard alerts instead of 2 hours checking spreadsheets

### Scenario 2: Community College (5K students, high drop-out risk)
**Problem:** 40% of students don't return after first semester. Most are first-generation college students who don't ask for help.

**UniGuard approach:**
- Lower alert thresholds: flag at 80% attendance (not 70%)
- Track "silent disengagement": no Teams logins in 5 days = alert
- Financial aid integration: flag students whose FAFSA is incomplete
- Proactive nudges every 3 days (not weekly): "Hey, we noticed you missed BIO101. Need help?"
- Connect struggling students to peer mentors automatically
- Career goals: "What job do you want?" → map to certificate/degree → track progress
- **Impact:** 15% improvement in first-year retention (industry benchmark for early alert systems)

### Scenario 3: Online University (Global, 100% async)
**Problem:** No classroom attendance. Hard to tell who's engaged vs. who's disappeared.

**UniGuard approach:**
- Replace attendance metrics with: last login, assignment views, discussion posts, video completion
- Alert Rule: "No login in 7 days" = High alert
- Alert Rule: "Viewed assignment but didn't submit within 48 hours" = Medium alert
- Nudge via email (not Teams) — online students may not check Teams
- "Office hours" tracking: did the student attend virtual office hours?
- **Impact:** Catch "ghost students" (enrolled but not engaging) within the first 2 weeks

### Scenario 4: Research University (Graduate Students)
**Problem:** PhD students fall through the cracks — no structured classes, just research. Advisors are busy with their own research.

**UniGuard approach:**
- Track different signals: advisor meeting frequency, publication submissions, milestone completions
- Alert: "No advisor meeting logged in 30 days" = High
- Alert: "Dissertation milestone overdue by 60 days" = Critical
- Career goals: academic track vs. industry → different milestone tracking
- Wellbeing: Reflect check-ins for mental health monitoring
- **Impact:** Reduce "time to degree" and catch struggling grad students early

### Scenario 5: Multi-Campus University System (like SUNY or UC)
**Problem:** 23 campuses, 500K+ students. Each campus has different SIS, different thresholds, different culture.

**UniGuard approach:**
- University-wide alert rules as baseline
- Campus-level overrides (campus admin configures their thresholds)
- System-wide dashboard for the Chancellor: "Which campuses have the highest at-risk rates?"
- Cross-campus transfer tracking: student transfers from Campus A to Campus B, history follows
- **Impact:** Standardized early alert across all campuses with local flexibility

---

## Data Flow — How It All Connects

### Step-by-Step Data Pipeline

```
1. UNIVERSITY SETUP (one-time)
   ├── IT Admin enables School Data Sync
   ├── SDS connects to SIS (Banner/PeopleSoft/Workday)
   ├── SDS syncs students, classes, enrollments → M365
   ├── IT Admin runs UniGuard provisioning script
   └── Admin configures alert rules + degree plans in SharePoint

2. DAILY AUTOMATIC CYCLE (UniGuard HeartbeatFlow)
   ├── 6:00 AM: Pull class rosters via Education API
   ├── 6:05 AM: Pull assignment submissions + grades
   ├── 6:10 AM: Pull Teams attendance reports
   ├── 6:15 AM: Compare against alert rules
   │   ├── Student A: attendance 65% → 🔴 CRITICAL (below 70%)
   │   ├── Student B: 3 late assignments → 🟠 HIGH
   │   └── Student C: GPA dropped from 3.2 to 2.5 → 🟡 MEDIUM
   ├── 6:20 AM: Write findings to Scan Results list
   ├── 6:25 AM: Calculate risk scores per student
   ├── 6:30 AM: Send alerts to advisors via Teams
   ├── 6:35 AM: Send nudges to at-risk students
   └── 6:40 AM: Log everything to Audit Log

3. INTERACTIVE (advisor or student chats with UniGuard)
   ├── "How is Sofia doing?" → pulls Student Profile Card
   ├── "Show me at-risk students in my advising group"
   ├── "Draft an email to Sofia about her attendance"
   ├── "What courses does Sofia need to graduate?"
   └── "Generate a progress report for BIO301"

4. STUDENT SELF-SERVICE
   ├── "What are my grades?" → pulls from Education API
   ├── "What should I take next semester?" → checks degree plan + prereqs
   ├── "I want to go to medical school" → saves career goal, adjusts tracking
   └── "I'm struggling with math" → connects to tutoring resources
```

---

## Privacy & Compliance (FERPA)

| Concern | How UniGuard Handles It |
|---------|----------------------|
| **FERPA compliance** | All data stays within M365 tenant. No external APIs. |
| **Who sees what** | Role-based: advisors see their students only. Students see only their own data. |
| **Data retention** | Configurable per university policy. Auto-purge old alerts. |
| **Audit trail** | Every query, alert, and action logged with timestamp and user. |
| **Student consent** | Career goals are opt-in. Wellbeing data requires Reflect opt-in. |
| **Parent access** | Configurable: FERPA allows for dependents. University controls this. |

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
- SharePoint brain provisioned
- SDS connected (or sample data loaded)
- Basic alert rules configured
- GetStudentContext flow working
- Copilot agent answers "How is Student X doing?"

### Phase 2: Early Alerts (Week 3-4)
- EarlyAlertScan flow reads Education API data
- Alerts written to SharePoint
- Advisor notifications via Teams
- Student nudges via email/Teams

### Phase 3: Academic Advising (Week 5-6)
- Degree plan data loaded
- Course recommendation logic
- Career goals tracking
- "What should I take?" topic working

### Phase 4: Reporting & Scale (Week 7-8)
- Progress reports auto-generated
- Department-level dashboards
- Multi-department rollout
- Performance tuning for scale

---

## What Makes UniGuard Different from Existing Solutions

| Existing Solution | Limitation | UniGuard Advantage |
|------------------|-----------|-------------------|
| **EAB Navigate** | Expensive ($$$), separate platform | Free on existing M365 license |
| **Civitas Illume** | Requires data warehouse setup | Reads directly from M365 Education API |
| **Starfish (Hobsons)** | Faculty must manually flag students | Auto-detects from M365 signals |
| **Salesforce Education Cloud** | Not integrated with classroom tools | Native to Teams where classes happen |
| **Custom dashboards** | View-only, no action | UniGuard takes action (nudges, emails, referrals) |

---

## Key Metrics (ROI for University Leadership)

| Metric | Before UniGuard | Target After |
|--------|----------------|-------------|
| First-year retention rate | ~75% | ~85% (+10%) |
| Average time to detect at-risk student | 4-6 weeks | 1 week |
| Advisor caseload review time | 2 hrs/week per 500 students | 20 min/week |
| Student nudge response rate | N/A (no nudges) | 40-60% |
| Students connected to support services | ~15% of at-risk | ~70% of at-risk |
