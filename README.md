<div align="center">

# 🎓 UniGuard

### Student Success & Academic Advisory Agent

*Detect at-risk students early. Help every student succeed. Built entirely on Microsoft 365.*

[![Copilot Studio](https://img.shields.io/badge/Copilot%20Studio-6264A7?style=flat-square&logo=microsoft&logoColor=white)](https://www.microsoft.com/en-us/microsoft-copilot/microsoft-copilot-studio)
[![Power Automate](https://img.shields.io/badge/Power%20Automate-0066FF?style=flat-square&logo=power-automate&logoColor=white)](https://powerautomate.microsoft.com/)
[![SharePoint](https://img.shields.io/badge/SharePoint-0078D4?style=flat-square&logo=microsoft-sharepoint&logoColor=white)](https://www.microsoft.com/en-us/microsoft-365/sharepoint)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## What It Does

UniGuard is a Teams chatbot that monitors student academic signals (assignments, grades, LMS activity) and enables faculty, advisors, and students to act before it's too late.

| You say... | UniGuard does... |
|---|---|
| *"Show me at-risk students"* | Lists students with low engagement scores, sorted by severity |
| *"How is Amber Rodriguez doing?"* | Full profile: grades, engagement, career goals, intervention history |
| *"Draft an email to Amber about her missing labs"* | Writes personalized email with real data, you approve and send |
| *"What does Amber need to graduate?"* | Degree progress map — completed, in progress, remaining courses |
| *"What should I take next semester?"* | Prereq-aware course recommendations aligned to career goals |
| *"Generate a report for BIO301"* | Class performance summary with trends and flagged students |

---

## Who Uses It

| Persona | What They See | Example Query |
|---|---|---|
| 👩‍🏫 **Faculty** | Students in their classes only | *"Who's struggling in my BIO301?"* |
| 🧑‍💼 **Advisors** | Their advisee caseload, cross-class | *"Show my at-risk advisees"* |
| 🎓 **Students** | Only their own data | *"Am I on track to graduate?"* |
| 🏛️ **Deans** | Department aggregates | *"Biology department report"* |
| 🔧 **IT Admins** | Everything — manages config | SharePoint lists + Entra groups |

Privacy enforced via **Entra ID groups + role-based flow filtering**. See [Privacy Design](docs/design/PRIVACY-DESIGN.md).

---

## Engagement Score (not attendance)

Most in-person classes don't track attendance digitally. UniGuard uses signals that **every university already has**:

```
Engagement Score = 40% Assignment completion
                 + 30% Grade performance  
                 + 20% LMS activity
                 + 10% Attendance (if available)

🟢 75-100  On Track
🟡 60-74   Needs Monitoring
🟠 40-59   At Risk
🔴 0-39    Critical
```

---

## Architecture

```
Microsoft Teams (chat)
    ↕
Copilot Studio (agent + topics + generative AI)
    ↕
Power Automate (GetStudentContext flow — role-filtered)
    ↕
SharePoint (9 lists — the "brain")
    ↕
Microsoft Graph Education API (production: SIS → School Data Sync → M365)
```

---

## Quick Deploy (~10 min)

```bash
# Step 1: Provision SharePoint brain
cd Scripts
.\Provision-UniGuard.ps1 -OwnerEmail "admin@yourtenant.onmicrosoft.com"

# Step 2: Create Entra security groups
# (UniGuard-Faculty, UniGuard-Advisors, UniGuard-Students)

# Step 3: Import solution
# Upload solution/UniGuard_Solution.zip at make.powerapps.com

# Step 4: Create agent in Copilot Studio + publish to Teams

# Step 5: Test — "Show me at-risk students"
```

📖 **[Full Step-by-Step Deployment Guide →](docs/guides/STEP-BY-STEP-GUIDE.md)**

---

## Project Structure

```
UniGuard/
├── README.md                          # You are here
├── solution/
│   └── UniGuard_Solution.zip          # Importable Power Platform solution
├── Scripts/
│   ├── Provision-UniGuard.ps1         # Creates SharePoint + sample data
│   └── Fill-Gaps.ps1                  # Adds degree plans + interventions
├── docs/
│   ├── guides/
│   │   ├── STEP-BY-STEP-GUIDE.md      # ⭐ Complete deployment walkthrough
│   │   ├── QUICK-DEPLOY.md            # 10-min summary
│   │   ├── FLOW-WALKTHROUGH.md        # Power Automate flow details
│   │   └── SETUP.md                   # SharePoint list schemas
│   └── design/
│       ├── AGENT-DESIGN.md            # Topics, flows, conversation diagrams
│       ├── USE-CASES-v2.md            # 6 use cases with examples
│       ├── PRIVACY-DESIGN.md          # FERPA + access controls
│       ├── SHAREPOINT-DESIGN-v2.md    # 9-list design
│       └── DATA-PLAN.md              # University data landscape
└── LICENSE
```

---

## Documentation

| Doc | Description |
|---|---|
| [**Step-by-Step Guide**](docs/guides/STEP-BY-STEP-GUIDE.md) | Complete deployment walkthrough with screenshots |
| [**Use Cases**](docs/design/USE-CASES-v2.md) | 6 detailed scenarios with conversation examples |
| [**Privacy Design**](docs/design/PRIVACY-DESIGN.md) | FERPA compliance, access matrix, role-based filtering |
| [**Agent Design**](docs/design/AGENT-DESIGN.md) | Topic flows, Power Automate architecture |
| [**Data Plan**](docs/design/DATA-PLAN.md) | How university data flows, 5 real scenarios |
| [**SharePoint Design**](docs/design/SHAREPOINT-DESIGN-v2.md) | 9-list schema with role filtering |

---

## License

MIT — See [LICENSE](LICENSE)

> 🎓 **UniGuard** — Because every student deserves to be seen before they fall behind.
