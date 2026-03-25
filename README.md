<div align="center">

# 🎓 UniGuard

### **Student Success & Academic Advisory Agent**

*An intelligent Microsoft 365 agent that transforms how universities identify, support, and retain at-risk students — before it's too late.*

[![Built with Copilot Studio](https://img.shields.io/badge/Built%20with-Copilot%20Studio-6264A7?style=for-the-badge&logo=microsoft&logoColor=white)](https://www.microsoft.com/en-us/microsoft-copilot/microsoft-copilot-studio)
[![Power Automate](https://img.shields.io/badge/Power%20Automate-0066FF?style=for-the-badge&logo=power-automate&logoColor=white)](https://powerautomate.microsoft.com/)
[![SharePoint](https://img.shields.io/badge/SharePoint-0078D4?style=for-the-badge&logo=microsoft-sharepoint&logoColor=white)](https://www.microsoft.com/en-us/microsoft-365/sharepoint)
[![Microsoft Teams](https://img.shields.io/badge/Teams-6264A7?style=for-the-badge&logo=microsoft-teams&logoColor=white)](https://www.microsoft.com/en-us/microsoft-teams)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

<br />

<img src="assets/uniguard-banner.png" alt="UniGuard Banner" width="800" />

**1 Agent · 7 Skills · Every Student Covered**

[Getting Started](#-getting-started) · [Architecture](#-architecture) · [Skills](#-skills--capabilities) · [SharePoint Lists](#-sharepoint-brain) · [Flows](#-power-automate-flows) · [Topics](#-copilot-studio-topics)

</div>

---

## 🚨 The Problem

> **1 in 3** college students drop out before completing their degree. Most universities identify at-risk students *after* it's already too late.

Academic advisors juggle hundreds of students across spreadsheets, siloed systems, and gut instincts. Early warning signs — a dip in attendance, missed assignments, declining grades — slip through the cracks until they become crisis-level interventions.

## ✅ The Solution

**UniGuard** is a Copilot Studio agent deployed inside Microsoft Teams that gives faculty, advisors, deans, and students a single conversational interface to:

- 🔍 **Detect** at-risk students before they fall through the cracks
- 📬 **Reach out** with personalized, timely communications
- 📊 **Track** degree progress and recommend next steps
- 🧠 **Advise** on course selection based on prerequisites and history
- 📈 **Report** on student and class-level outcomes
- ⏰ **Nudge** students with proactive reminders and alerts

All powered by data already living in your Microsoft 365 tenant — **no new systems, no new logins, no new training.**

---

## 📊 Manual vs. UniGuard

| Scenario | 🐢 Manual Process | ⚡ With UniGuard |
|---|---|---|
| **Identifying at-risk students** | Advisors review spreadsheets weekly, compare grades/attendance manually | Agent scans enrollment data on schedule, auto-flags students by configurable rules |
| **Sending outreach emails** | Copy-paste templates, manually personalize for each student | *"Draft an email to Sarah about her attendance"* → done in seconds |
| **Checking degree progress** | Cross-reference transcript against degree plan in separate system | *"What courses does Alex need to graduate?"* → instant answer |
| **Course recommendations** | Students visit advisor office, flip through catalog | *"What should I take next semester?"* → AI-powered suggestion with prereq checks |
| **Generating reports** | Export data, build pivot tables, format in Word | *"Generate a report for my CHEM 101 class"* → formatted report, instantly |
| **Following up on interventions** | Sticky notes, calendar reminders, memory | Full intervention history with outcomes, accessible via chat |
| **Proactive student nudges** | Doesn't happen at scale | Automated Teams messages for deadlines, missed classes, low engagement |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        MICROSOFT TEAMS                              │
│                     (Chat Interface / UI)                            │
│                                                                     │
│   👤 Advisor: "How is Sarah doing?"                                 │
│   🤖 UniGuard: "Sarah has 3 active alerts..."                      │
└─────────────────────┬───────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      COPILOT STUDIO                                 │
│               (Conversational AI / Agent Hub)                       │
│                                                                     │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐              │
│  │ Student  │ │  Early   │ │  Degree   │ │  Course  │              │
│  │  Pulse   │ │  Alerts  │ │ Progress  │ │  Advisor │              │
│  └────┬─────┘ └────┬─────┘ └─────┬─────┘ └────┬─────┘              │
│  ┌────┴─────┐ ┌────┴─────┐ ┌─────┴─────┐                           │
│  │ Outreach │ │ Progress │ │   Nudge   │                           │
│  │          │ │  Report  │ │  Engine   │                           │
│  └────┬─────┘ └────┬─────┘ └─────┬─────┘                           │
│       │            │              │                                  │
└───────┼────────────┼──────────────┼─────────────────────────────────┘
        │            │              │
        ▼            ▼              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      POWER AUTOMATE                                 │
│                  (Orchestration Layer)                               │
│                                                                     │
│  ⏰ EarlyAlertScan    ⏰ NudgeEngine                                │
│  ⚡ GetStudentContext  ⚡ GenerateReport                             │
│                                                                     │
└───────┬────────────┬──────────────┬─────────────────────────────────┘
        │            │              │
        ▼            ▼              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    SHAREPOINT ONLINE                                 │
│                  (Structured Data Store)                             │
│                                                                     │
│  📋 Student Profiles    📋 Course Catalog    📋 Degree Plans        │
│  📋 Student Enrollments 📋 Alert Rules       📋 Intervention Hist.  │
│  📋 Agent Config        📋 Audit Log                                │
│                                                                     │
└───────┬─────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   MICROSOFT GRAPH API                               │
│            (Users · Mail · Calendar · Teams)                        │
│                                                                     │
│  📧 Send emails via Outlook    💬 Post adaptive cards in Teams      │
│  👥 Resolve user profiles      📅 Check advisor calendar            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🧠 Skills & Capabilities

UniGuard is **one agent** with **seven specialized skills**, each designed around a core advisory workflow:

| # | Skill | Description | Trigger Example |
|---|---|---|---|
| 1 | 🚨 **Early Alert** | Scans student data against configurable rules to flag at-risk students | *"Show me at-risk students"* |
| 2 | 📬 **Outreach** | Drafts and sends personalized emails/messages to students | *"Draft an email to Sarah about attendance"* |
| 3 | 💬 **Student Pulse** | Gives a holistic snapshot of any student's current standing | *"How is Student X doing?"* |
| 4 | 🗺️ **Degree Planner** | Maps remaining requirements against completed courses | *"What courses does Alex need to graduate?"* |
| 5 | 📚 **Course Advisor** | Recommends next-semester courses based on prereqs, history & plan | *"What should I take next semester?"* |
| 6 | 📈 **Progress Report** | Generates class-level or student-level academic reports | *"Generate a report for my CHEM 101 class"* |
| 7 | ⏰ **Nudge Engine** | Proactively sends reminders about deadlines, missed classes, low scores | *(Runs on schedule — no trigger needed)* |

---

## 📋 SharePoint Brain

All data lives in **SharePoint Lists** — the single source of truth for UniGuard. No external databases required.

### 1. 👤 Student Profiles

| Column | Type | Description |
|---|---|---|
| `StudentName` | Single line of text | Full name of the student |
| `StudentID` | Single line of text | University-issued student ID |
| `Major` | Choice | Declared major (e.g., Computer Science, Biology) |
| `GPA` | Number | Current cumulative GPA |
| `Advisor` | Person | Assigned academic advisor |
| `EnrollmentStatus` | Choice | `Active` · `Probation` · `Leave` · `Graduated` · `Withdrawn` |
| `RiskLevel` | Choice | `Low` · `Medium` · `High` · `Critical` |

### 2. 📘 Course Catalog

| Column | Type | Description |
|---|---|---|
| `CourseID` | Single line of text | Unique course identifier (e.g., `CS-201`) |
| `CourseName` | Single line of text | Full course title |
| `Department` | Choice | Offering department |
| `Prerequisites` | Multiple lines of text | Comma-separated prerequisite course IDs |
| `Credits` | Number | Credit hours |
| `Semester` | Choice | `Fall` · `Spring` · `Summer` · `All` |

### 3. 🗺️ Degree Plans

| Column | Type | Description |
|---|---|---|
| `PlanName` | Single line of text | Name of the degree plan |
| `Major` | Choice | Associated major |
| `RequiredCourses` | Multiple lines of text | Comma-separated list of required course IDs |
| `ElectiveRequirements` | Multiple lines of text | Elective category requirements and credit counts |
| `TotalCredits` | Number | Total credits needed for degree completion |

### 4. 📝 Student Enrollments

| Column | Type | Description |
|---|---|---|
| `Student` | Lookup | Link to Student Profiles list |
| `Course` | Lookup | Link to Course Catalog list |
| `Semester` | Single line of text | Semester identifier (e.g., `Fall 2025`) |
| `Grade` | Choice | `A` · `B` · `C` · `D` · `F` · `W` · `IP` (In Progress) |
| `AttendanceRate` | Number (%) | Percentage of classes attended |
| `AssignmentCompletionRate` | Number (%) | Percentage of assignments submitted |

### 5. 🚨 Alert Rules

| Column | Type | Description |
|---|---|---|
| `Metric` | Choice | `AttendanceRate` · `GPA` · `AssignmentCompletionRate` · `Grade` |
| `Threshold` | Number | Trigger value (e.g., `70` for 70%) |
| `Operator` | Choice | `<` · `<=` · `>` · `>=` · `=` |
| `Severity` | Choice | `Low` · `Medium` · `High` · `Critical` |
| `Action` | Multiple lines of text | What happens when triggered (e.g., "Notify advisor, flag student") |

> **Example Rule:** *If `AttendanceRate` < `70%` → Severity: `High` → Action: "Flag student, notify advisor via Teams"*

### 6. 📒 Intervention History

| Column | Type | Description |
|---|---|---|
| `Student` | Lookup | Link to Student Profiles list |
| `Date` | Date | Date of the intervention |
| `Type` | Choice | `Email` · `Meeting` · `Phone Call` · `Teams Message` · `Referral` |
| `Notes` | Multiple lines of text | Details about the intervention |
| `Outcome` | Choice | `Positive` · `Neutral` · `No Response` · `Escalated` |

### 7. ⚙️ Agent Config

| Column | Type | Description |
|---|---|---|
| `SettingName` | Single line of text | Configuration key (e.g., `ScanFrequency`) |
| `SettingValue` | Single line of text | Configuration value (e.g., `Daily`) |
| `Description` | Multiple lines of text | What this setting controls |

### 8. 📜 Audit Log

| Column | Type | Description |
|---|---|---|
| `Timestamp` | Date and Time | When the action occurred |
| `Actor` | Person | Who or what performed the action |
| `Action` | Single line of text | What happened (e.g., `AlertTriggered`, `EmailSent`) |
| `Target` | Single line of text | Affected entity (student ID, course ID, etc.) |
| `Details` | Multiple lines of text | Additional context |

---

## ⚡ Power Automate Flows

Four flows orchestrate data movement and automation behind the scenes:

### 1. ⏰ EarlyAlertScan

| Property | Value |
|---|---|
| **Trigger** | Scheduled (configurable — default: daily at 6:00 AM) |
| **What it does** | Reads all items from **Student Enrollments**, evaluates each against **Alert Rules**, and flags matching students by updating their `RiskLevel` in **Student Profiles** |
| **Outputs** | Updated risk levels, new entries in **Audit Log**, Teams notifications to advisors |

```
Trigger (Schedule)
  → Get items: Student Enrollments
  → Get items: Alert Rules
  → For each enrollment:
      → Evaluate against each rule
      → If threshold breached:
          → Update Student Profile (RiskLevel)
          → Create Audit Log entry
          → Send Teams notification to advisor
```

### 2. ⏰ NudgeEngine

| Property | Value |
|---|---|
| **Trigger** | Scheduled (configurable — default: weekdays at 8:00 AM) |
| **What it does** | Sends proactive Teams messages to students about upcoming deadlines, missed classes, and low assignment completion rates |
| **Outputs** | Teams messages to students, entries in **Audit Log** |

```
Trigger (Schedule)
  → Get items: Student Enrollments (current semester, In Progress)
  → Filter: AttendanceRate < threshold OR AssignmentCompletionRate < threshold
  → For each flagged student:
      → Compose personalized nudge message
      → Send Teams chat message to student
      → Create Audit Log entry
```

### 3. ⚡ GetStudentContext

| Property | Value |
|---|---|
| **Trigger** | Instant (called by Copilot Studio) |
| **Input** | `StudentID` (text) |
| **What it does** | Fetches a student's complete profile, current enrollments, degree plan, active alerts, and intervention history — returns it as a single JSON payload to the agent |
| **Outputs** | JSON object with all student context |

```
Trigger (HTTP / Copilot Studio)
  → Input: StudentID
  → Get item: Student Profiles (filter by StudentID)
  → Get items: Student Enrollments (filter by Student)
  → Get items: Degree Plans (filter by Major)
  → Get items: Intervention History (filter by Student)
  → Compose: Merge all data into unified JSON
  → Respond to Copilot Studio
```

### 4. ⚡ GenerateReport

| Property | Value |
|---|---|
| **Trigger** | Instant (called by Copilot Studio) |
| **Input** | `ReportType` (Student / Class), `Identifier` (StudentID or CourseID), `Semester` |
| **What it does** | Aggregates enrollment data, computes statistics (avg GPA, attendance, completion rates), and formats a structured progress report |
| **Outputs** | Formatted report (Adaptive Card or text) returned to agent |

```
Trigger (HTTP / Copilot Studio)
  → Input: ReportType, Identifier, Semester
  → Branch: Student Report vs. Class Report
  → Get items: Student Enrollments (filtered)
  → Compute: Averages, trends, flags
  → Compose: Formatted report payload
  → Respond to Copilot Studio
```

---

## 💬 Copilot Studio Topics

Each topic maps a natural language intent to a skill powered by the flows and SharePoint data:

### 1. 💬 Student Pulse

> **"How is Sarah doing?"** · **"Give me an update on Student 12345"**

Calls `GetStudentContext` → Summarizes GPA, attendance, alerts, recent interventions, and risk level in a conversational response.

### 2. 🚨 Early Alerts

> **"Show me at-risk students"** · **"Who needs attention in my advising group?"**

Queries **Student Profiles** filtered by `RiskLevel = High OR Critical` and the current advisor → Returns a list with alert details.

### 3. 🗺️ Degree Progress

> **"What courses does Alex need to graduate?"** · **"Show me Alex's degree progress"**

Calls `GetStudentContext` → Compares completed/in-progress courses against the student's **Degree Plan** → Lists remaining requirements.

### 4. 📚 Course Recommendation

> **"What should I take next semester?"** · **"Recommend courses for a CS junior"**

Evaluates completed courses against **Degree Plan** requirements and **Course Catalog** prerequisites → Suggests eligible courses prioritized by graduation progress.

### 5. 📬 Outreach

> **"Draft an email to Sarah about her attendance"** · **"Send a check-in message to Student 12345"**

Fetches student context → Uses AI to draft a personalized, empathetic message → Advisor reviews and confirms → Sends via Microsoft Graph (Outlook/Teams) → Logs to **Intervention History**.

### 6. 📈 Progress Report

> **"Generate a report for my CHEM 101 class"** · **"Give me a progress report for Sarah"**

Calls `GenerateReport` → Returns a formatted summary with key metrics, trends, and flagged concerns.

---

## 📂 Project Structure

```
UniGuard/
├── 📄 README.md                          # You are here
├── 📄 LICENSE                            # MIT License
│
├── 📁 copilot-studio/
│   ├── 📁 topics/
│   │   ├── StudentPulse.yaml             # "How is Student X doing?"
│   │   ├── EarlyAlerts.yaml              # "Show me at-risk students"
│   │   ├── DegreeProgress.yaml           # "What courses does Student X need?"
│   │   ├── CourseRecommendation.yaml     # "What should I take next semester?"
│   │   ├── Outreach.yaml                 # "Draft an email to Student X..."
│   │   └── ProgressReport.yaml           # "Generate a report for my class"
│   ├── 📁 entities/
│   │   ├── StudentEntity.json            # Student name/ID entity
│   │   ├── CourseEntity.json             # Course name/ID entity
│   │   └── SemesterEntity.json           # Semester entity
│   └── 📁 adaptive-cards/
│       ├── StudentPulseCard.json         # Student overview card
│       ├── AlertListCard.json            # At-risk students card
│       ├── DegreeProgressCard.json       # Degree progress visualization
│       └── ProgressReportCard.json       # Report output card
│
├── 📁 power-automate/
│   ├── EarlyAlertScan.zip               # Scheduled alert scanning flow
│   ├── NudgeEngine.zip                   # Scheduled nudge/reminder flow
│   ├── GetStudentContext.zip             # Instant student data aggregation
│   └── GenerateReport.zip               # Instant report generation
│
├── 📁 sharepoint/
│   ├── 📁 list-templates/
│   │   ├── StudentProfiles.json          # List schema + sample data
│   │   ├── CourseCatalog.json            # List schema + sample data
│   │   ├── DegreePlans.json              # List schema + sample data
│   │   ├── StudentEnrollments.json       # List schema + sample data
│   │   ├── AlertRules.json               # List schema + default rules
│   │   ├── InterventionHistory.json      # List schema
│   │   ├── AgentConfig.json              # List schema + default settings
│   │   └── AuditLog.json                 # List schema
│   └── 📁 site-scripts/
│       └── provision-site.json           # Site script to create all lists
│
├── 📁 docs/
│   ├── setup-guide.md                    # Detailed setup walkthrough
│   ├── admin-guide.md                    # Configuration & alert rules
│   ├── user-guide.md                     # How to use UniGuard in Teams
│   └── architecture.md                   # Deep-dive technical architecture
│
└── 📁 assets/
    ├── uniguard-banner.png               # README banner image
    ├── uniguard-icon.png                 # Agent icon
    └── screenshots/
        ├── student-pulse-demo.png        # Student Pulse in action
        ├── early-alert-demo.png          # Early Alert list
        ├── degree-progress-demo.png      # Degree Progress card
        └── nudge-demo.png               # Nudge Engine message
```

---

## 🚀 Getting Started

### Prerequisites

| Requirement | Details |
|---|---|
| **Microsoft 365 Tenant** | Business or Education license with Teams |
| **Copilot Studio** | License to create and publish agents |
| **Power Automate** | Premium connectors (SharePoint, HTTP, Teams) |
| **SharePoint Online** | Site with permissions to create lists |
| **Microsoft Graph API** | App registration with `Mail.Send`, `Chat.ReadWrite`, `User.Read.All` |

### Setup Overview

```
Step 1 ──► Provision SharePoint Site & Lists
            Deploy list templates from /sharepoint/list-templates/
            Populate Course Catalog and Degree Plans with your data

Step 2 ──► Configure Alert Rules
            Add your institution's thresholds to the Alert Rules list
            (e.g., Attendance < 70% = High, GPA < 2.0 = Critical)

Step 3 ──► Import Power Automate Flows
            Import .zip packages from /power-automate/
            Update SharePoint site URL and connection references

Step 4 ──► Create Copilot Studio Agent
            Import topic definitions from /copilot-studio/topics/
            Connect to Power Automate flows as actions
            Upload adaptive card templates

Step 5 ──► Register Graph API App
            Create app registration in Azure AD
            Grant permissions: Mail.Send, Chat.ReadWrite, User.Read.All
            Add client secret to Agent Config list

Step 6 ──► Publish to Teams
            Publish agent in Copilot Studio
            Deploy to Teams app catalog
            Assign to target user groups (advisors, faculty, students)

Step 7 ──► Test & Validate
            Run EarlyAlertScan manually to verify alert detection
            Test each topic in Teams chat
            Verify Audit Log entries
```

> 📖 For the full step-by-step walkthrough, see **[docs/setup-guide.md](docs/setup-guide.md)**

---

## 🔒 Security & Privacy

UniGuard is designed with student data privacy in mind:

| Concern | How UniGuard Addresses It |
|---|---|
| **Data Residency** | All data stays in your M365 tenant — no external APIs or third-party storage |
| **Access Control** | SharePoint permissions + Teams channel policies restrict who sees what |
| **FERPA Compliance** | Advisors only see their assigned students; role-based topic access |
| **Audit Trail** | Every agent action is logged to the Audit Log list with actor, timestamp, and details |
| **No PII in Prompts** | Student data is fetched server-side via flows — never sent as raw prompts to AI |

---

## 🎯 Who Is This For?

| Role | How They Use UniGuard |
|---|---|
| 🧑‍🏫 **Academic Advisors** | Check on students, view alerts, draft outreach, track interventions |
| 👨‍💼 **Department Deans** | Generate class-level reports, monitor at-risk trends, review intervention outcomes |
| 👩‍🎓 **Students** | Ask about degree progress, get course recommendations, receive proactive nudges |
| 🏫 **Faculty** | View attendance/completion trends for their sections, flag concerns |

---

## 🗺️ Roadmap

- [x] Core SharePoint data model (8 lists)
- [x] Power Automate flows (4 flows)
- [x] Copilot Studio topics (6 topics)
- [x] Adaptive Card templates
- [ ] 🔜 Power BI dashboard for institutional analytics
- [ ] 🔜 Bulk import tool for SIS (Student Information System) data
- [ ] 🔜 Multi-language support for student-facing nudges
- [ ] 🔜 Integration with LMS (Canvas, Blackboard) via API connectors
- [ ] 🔜 Predictive risk scoring with AI Builder

---

## 🤝 Contributing

Contributions are welcome! Whether it's a bug fix, new feature, documentation improvement, or a cool adaptive card template — we'd love your help.

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting.

---

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

You are free to use, modify, and distribute this project for your university or institution.

---

## 💡 Acknowledgments

- Built on the [Microsoft 365 Platform](https://developer.microsoft.com/en-us/microsoft-365)
- Powered by [Microsoft Copilot Studio](https://www.microsoft.com/en-us/microsoft-copilot/microsoft-copilot-studio)
- Inspired by the mission to make every student's success visible and actionable

---

<div align="center">

**Built with ❤️ for higher education**

*Because no student should fall through the cracks.*

<br />

⭐ Star this repo if you believe in student success ⭐

</div>
