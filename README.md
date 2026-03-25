<div align="center">

# 🎓 UniGuard

### Student Success & Academic Advisory Agent

*An intelligent Microsoft 365 agent that transforms how universities identify, support, and retain at-risk students — before it's too late.*

[![Copilot Studio](https://img.shields.io/badge/Copilot%20Studio-6264A7?style=for-the-badge&logo=microsoft&logoColor=white)](https://www.microsoft.com/en-us/microsoft-copilot/microsoft-copilot-studio)
[![Power Automate](https://img.shields.io/badge/Power%20Automate-0066FF?style=for-the-badge&logo=power-automate&logoColor=white)](https://powerautomate.microsoft.com/)
[![SharePoint](https://img.shields.io/badge/SharePoint-0078D4?style=for-the-badge&logo=microsoft-sharepoint&logoColor=white)](https://www.microsoft.com/en-us/microsoft-365/sharepoint)
[![Teams](https://img.shields.io/badge/Teams-6264A7?style=for-the-badge&logo=microsoft-teams&logoColor=white)](https://www.microsoft.com/en-us/microsoft-teams)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**1 Agent · 6 Skills · Every Student Covered**

[Quick Deploy](docs/guides/QUICK-DEPLOY.md) · [Full Deployment](docs/guides/STEP-BY-STEP-GUIDE.md) · [Use Cases](docs/design/USE-CASES-v2.md) · [Privacy](docs/design/PRIVACY-DESIGN.md)

</div>

---

## 🚨 The Problem

> **1 in 3** college students drop out before completing their degree. Most universities identify at-risk students *after* it's already too late.

Academic advisors juggle hundreds of students across spreadsheets, siloed systems, and gut instincts. Warning signs — missed assignments, declining grades, LMS inactivity — slip through the cracks until they become crisis-level interventions.

```
The timeline today:

Week 1-3    Student stops submitting assignments. Nobody notices.
Week 4-6    Grades drop. Engagement fades. Still no alert.
Week 7-8    Midterm grades post — advisor finally sees the problem.
Week 9+     Too late. Student fails or drops out.

With UniGuard:

Week 1-3    Auto-detected. Advisor notified. Action taken.
```

---

## ✅ What UniGuard Does

UniGuard is a Copilot Studio agent deployed in Microsoft Teams that gives faculty, advisors, and students a single conversational interface to act on student data.

| You say... | UniGuard does... |
|---|---|
| *"Show me at-risk students"* | Lists students with low engagement scores, sorted by severity 🔴🟠🟡🟢 |
| *"How is Amber Rodriguez doing?"* | Full profile: grades per course, engagement score, career goals, past interventions |
| *"Draft an email to Amber about her missing labs"* | Writes a personalized email using real data — specific assignments, grades, dates. You approve and send. |
| *"What does Amber need to graduate?"* | Degree progress map — completed, in progress, remaining courses, projected graduation date |
| *"What should I take next semester?"* | Prereq-aware course recommendations aligned to career goals |
| *"Generate a report for BIO301"* | Class performance summary with trends, at-risk counts, and flagged students |

---

## 📊 Manual vs. UniGuard

| Scenario | 🐢 Manual Process | ⚡ With UniGuard |
|---|---|---|
| Identifying at-risk students | Advisors review spreadsheets weekly | Agent flags students by engagement score automatically |
| Sending outreach emails | Copy-paste templates, manually personalize | *"Draft email to Amber"* → done in seconds with real data |
| Checking degree progress | Cross-reference transcript against catalog | *"What does she need?"* → instant answer |
| Course recommendations | Students visit advisor, flip through catalog | *"What should I take?"* → AI-powered, prereq-aware |
| Generating reports | Export data, pivot tables, format in Word | *"Generate a report for BIO301"* → instant |
| Following up on interventions | Sticky notes, calendar reminders | Full history with outcomes, accessible via chat |

---

## 👥 Who Uses It

UniGuard serves **5 personas** — each sees different data, asks different questions.

### 👩‍🏫 Faculty (Professors & Instructors)

> *"I teach 3 sections with 120 students. I can't track who's falling behind across all of them."*

| What they ask UniGuard | What they see |
|---|---|
| *"Who's struggling in my BIO301?"* | Students in their linked courses only |
| *"Draft an email to Amber about her missing labs"* | Assignment data, grades for their classes |
| *"Generate a midterm report for BIO301"* | Class performance summary |

### 🧑‍💼 Academic Advisors

> *"I have 200 advisees. I don't know who's in trouble until they're on academic probation."*

| What they ask UniGuard | What they see |
|---|---|
| *"Show me my at-risk advisees"* | Their caseload — cross-class view with engagement scores |
| *"How is Amber doing across all her courses?"* | Full profile: grades, career goals, intervention history |
| *"What does Amber need to graduate?"* | Degree progress map for their advisees |
| *"Log that I met with Amber today"* | Saves to intervention history |

### 🎓 Students

> *"I don't know if I'm on track to graduate. I'm afraid to check."*

| What they ask UniGuard | What they see |
|---|---|
| *"What are my grades?"* | Only their own grades and engagement |
| *"What should I take next semester?"* | Personalized course recommendations |
| *"I want to go to medical school — am I on track?"* | Degree progress mapped to career goals |

### 🏛️ Department Chairs & Deans

| What they ask UniGuard | What they see |
|---|---|
| *"Generate a department report for Biology"* | Aggregated stats — at-risk counts, engagement trends |
| *"Which courses have the lowest engagement?"* | Course-level performance data |

### 🔧 IT Administrators

| What they do | What they manage |
|---|---|
| Deploy and maintain the agent | SharePoint lists, Entra groups, Power Platform |
| Configure alert thresholds | Agent Config + Alert Rules lists |
| Monitor compliance | Audit Log list |

### Access Matrix

| Data | 🎓 Student | 👩‍🏫 Faculty | 🧑‍💼 Advisor | 🏛️ Dean | 🔧 Admin |
|---|---|---|---|---|---|
| Own grades | ✅ | — | — | — | ✅ |
| Students in their class | — | ✅ | — | — | ✅ |
| Advisee caseload (full) | — | — | ✅ | — | ✅ |
| Career goals | ✅ own | ❌ | ✅ advisees | ❌ | ✅ |
| Intervention history | ❌ | ❌ | ✅ advisees | ❌ | ✅ |
| Department aggregates | ❌ | ❌ | ❌ | ✅ | ✅ |

> 🔒 Privacy enforced at the **Power Automate flow level** — the AI never receives data the user shouldn't see. See [Privacy Design](docs/design/PRIVACY-DESIGN.md).

---

## 📊 Engagement Score (not attendance)

Most in-person classes don't track attendance digitally. UniGuard uses signals that **every university already has**:

```
Engagement Score = 40% Assignment completion & timeliness
                 + 30% Grade performance vs passing threshold
                 + 20% LMS activity (logins, resource access)
                 + 10% Attendance (if available — optional)

🟢 75-100  On Track
🟡 60-74   Needs Monitoring
🟠 40-59   At Risk
🔴 0-39    Critical — Immediate Intervention
```

Works for **every university** — in-person, online, hybrid, large lecture, small seminar.

---

## 💬 Demo Conversation

```
Advisor opens Teams → chats with UniGuard:

Advisor: "Show me at-risk students"

UniGuard: You have 3 students needing attention:

  🔴 Amber Rodriguez — Engagement: 34%
     0 of last 3 assignments submitted, GPA: 1.8 (was 2.4)
     Career goal: Medical school
     3 past interventions — no improvement yet

  🟠 Dakota Sanchez — Engagement: 61%
     2 late submissions, grade trending down in BUS201

  🟡 Omar Bennett — Engagement: 68%
     GPA dropped from 3.0 to 2.5, attendance slipping

  Want me to draft outreach for any of them?

Advisor: "Tell me more about Amber"

UniGuard: 🎓 Amber Rodriguez (STU003) — Biology, Pre-Med Track
  GPA: 1.8 (down from 2.4) · Engagement: 34% 🔴

  BIO301: D  — 3/10 assignments submitted
  ENG102: B  — 7/8 assignments submitted
  PSY101: C- — 5/8 assignments submitted

  Career goal: Medical school — want to become a surgeon
  Interventions: Email (no response), Meeting (attended), Tutoring referral (hasn't gone)

  💡 Recommend: Mandatory tutoring + reduced course load next semester

Advisor: "Draft an email to Amber about her BIO301 labs"

UniGuard: Here's a draft:

  Subject: Checking in — BIO301 Lab Reports

  Hi Amber, I noticed you haven't submitted the last 3 lab reports
  in BIO301. Your current grade is a D, and I know that doesn't
  reflect your capability — you scored a B+ on the midterm...

  [Send] [Edit] [Cancel]
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                       UniGuard                           │
│                                                          │
│  Microsoft Teams (chat interface)                       │
│       ↕                                                  │
│  Copilot Studio (agent + topics + generative AI)        │
│       ↕                                                  │
│  Power Automate (GetStudentContext — role-filtered)      │
│       ↕                                                  │
│  SharePoint "Brain" (9 lists)                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Student Profiles · Course Catalog · Degree Plans   │ │
│  │ Student Enrollments · Alert Rules · User Roles     │ │
│  │ Intervention History · Agent Config · Audit Log    │ │
│  └────────────────────────────────────────────────────┘ │
│       ↕                                                  │
│  Microsoft Graph Education API                          │
│  (production: SIS → School Data Sync → M365)            │
└─────────────────────────────────────────────────────────┘
```

---

## 📈 Impact & ROI

| Metric | Before UniGuard | With UniGuard |
|---|---|---|
| At-risk detection speed | 4-6 weeks | 1 week |
| Advisor review time | 2 hrs/week per 500 students | 20 min/week |
| First-year retention | ~75% | ~85% (+10%) |
| Cost vs alternatives | $100K+ (EAB Navigate, Starfish) | $0 incremental on existing M365 |

---

## 🚀 Quick Deploy (~30 min)

```bash
# Step 1: Provision SharePoint brain (5 min)
cd Scripts
.\Provision-UniGuard.ps1 -OwnerEmail "admin@yourtenant.onmicrosoft.com"

# Step 2: Create Entra security groups (2 min)

# Step 3: Import solution/UniGuard_Solution.zip (2 min)

# Step 4: Create Copilot Studio agent + connect flow (15 min)

# Step 5: Publish to Teams + test (5 min)
```

📖 **[Full Step-by-Step Deployment Guide →](docs/guides/STEP-BY-STEP-GUIDE.md)**

---

## 📂 Project Structure

```
UniGuard/
├── README.md                          # You are here
├── solution/
│   └── UniGuard_Solution.zip          # ⚡ Importable Power Platform solution
├── Scripts/
│   ├── Provision-UniGuard.ps1         # 🔧 Creates SharePoint + 9 lists + sample data
│   └── Fill-Gaps.ps1                  # 🔧 Adds degree plans, career goals, interventions
├── docs/
│   ├── guides/
│   │   ├── STEP-BY-STEP-GUIDE.md      # ⭐ Complete deployment walkthrough
│   │   ├── QUICK-DEPLOY.md            # 10-min summary
│   │   ├── FLOW-WALKTHROUGH.md        # Power Automate flow details
│   │   └── SETUP.md                   # SharePoint list schemas
│   └── design/
│       ├── AGENT-DESIGN.md            # Topic flows, conversation diagrams
│       ├── USE-CASES-v2.md            # 6 detailed use cases with examples
│       ├── PRIVACY-DESIGN.md          # FERPA compliance + access controls
│       ├── SHAREPOINT-DESIGN-v2.md    # 9-list design with role filtering
│       └── DATA-PLAN.md              # University data landscape + 5 real scenarios
└── LICENSE
```

---

## 📚 Documentation

| Doc | Description |
|---|---|
| [**Step-by-Step Guide**](docs/guides/STEP-BY-STEP-GUIDE.md) | Complete deployment walkthrough |
| [**Use Cases**](docs/design/USE-CASES-v2.md) | 6 scenarios with full conversation examples |
| [**Privacy Design**](docs/design/PRIVACY-DESIGN.md) | FERPA compliance, access matrix, role-based filtering |
| [**Agent Design**](docs/design/AGENT-DESIGN.md) | Topic flows, Power Automate architecture |
| [**Data Plan**](docs/design/DATA-PLAN.md) | How university data flows, 5 real-world scenarios |
| [**SharePoint Design**](docs/design/SHAREPOINT-DESIGN-v2.md) | 9-list schema with engagement score model |

---

## License

MIT — See [LICENSE](LICENSE)

---

> 🎓 **UniGuard** — Because every student deserves to be seen before they fall behind.
