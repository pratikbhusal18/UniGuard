# 🎓 UniGuard — Step-by-Step Deployment Guide

**Total time: ~30 minutes** (10 min scripted, 20 min portal)

---

## Prerequisites

| # | Requirement | How to Verify |
|---|---|---|
| 1 | Microsoft 365 Education E3/E5 | [admin.microsoft.com](https://admin.microsoft.com) → Licenses |
| 2 | Copilot Studio license | Can you log into [copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)? |
| 3 | Power Automate Premium | [flow.microsoft.com](https://flow.microsoft.com) → check license |
| 4 | PowerShell 7 | Run: `pwsh --version` |
| 5 | Microsoft.Graph module | Run: `Install-Module Microsoft.Graph -Scope CurrentUser` |
| 6 | SharePoint admin or site creator role | Can you create SharePoint sites? |

---

## Step 1: Provision SharePoint Brain (5 min)

### 1.1 Open PowerShell and navigate to the project

```powershell
cd UniGuard\Scripts
```

### 1.2 Run the provisioning script

```powershell
.\Provision-UniGuard.ps1 -OwnerEmail "admin@yourtenant.onmicrosoft.com"
```

A browser window opens — sign in with your admin account.

### 1.3 Wait for completion

The script will:
- ✅ Create a SharePoint site called "UniGuard"
- ✅ Create 9 lists with typed columns
- ✅ Load 5 sample students
- ✅ Load 6 courses
- ✅ Load 10 enrollments with realistic grades/engagement data
- ✅ Load 4 alert rules
- ✅ Load 7 config settings

### 1.4 Run the gap-fill script

```powershell
.\Fill-Gaps.ps1
```

This adds:
- ✅ 5 degree plans (Biology, CS, Business, Psychology, Engineering)
- ✅ Career goals for each student
- ✅ Engagement scores
- ✅ 4 intervention history records

### 1.5 Verify

Open your SharePoint site and confirm:

| List | Expected Items |
|---|---|
| Student Profiles | 5 students |
| Course Catalog | 6 courses |
| Degree Plans | 5 plans |
| Student Enrollments | 10 enrollments |
| Alert Rules | 4 rules |
| Intervention History | 4 records |
| User Roles | (empty — filled in Step 2) |
| Agent Config | 7 settings |
| Audit Log | 1 entry |

---

## Step 2: Create Entra ID Security Groups (5 min)

### 2.1 Run these PowerShell commands

```powershell
Connect-MgGraph -Scopes "Group.ReadWrite.All","GroupMember.ReadWrite.All"

# Create 3 groups
New-MgGroup -DisplayName "UniGuard-Faculty" -MailEnabled:$false -MailNickname "UniGuardFaculty" -SecurityEnabled
New-MgGroup -DisplayName "UniGuard-Advisors" -MailEnabled:$false -MailNickname "UniGuardAdvisors" -SecurityEnabled
New-MgGroup -DisplayName "UniGuard-Students" -MailEnabled:$false -MailNickname "UniGuardStudents" -SecurityEnabled
```

### 2.2 Add users to groups

```powershell
# Get group IDs
$faculty = Get-MgGroup -Filter "displayName eq 'UniGuard-Faculty'"
$advisors = Get-MgGroup -Filter "displayName eq 'UniGuard-Advisors'"
$students = Get-MgGroup -Filter "displayName eq 'UniGuard-Students'"

# Get user IDs (replace with your users)
$user = Get-MgUser -Filter "userPrincipalName eq 'LisaT@yourtenant.onmicrosoft.com'"

# Add to group
New-MgGroupMember -GroupId $faculty.Id -DirectoryObjectId $user.Id
```

Repeat for all faculty, advisors, and students.

### 2.3 Populate the User Roles list in SharePoint

Go to your UniGuard SharePoint site → **User Roles** list → add entries:

| Title | UserEmail | Role | LinkedCourses | LinkedAdvisees | LinkedStudentID |
|---|---|---|---|---|---|
| Lisa Taylor | LisaT@... | Faculty | BIO301,PSY101 | | |
| Mario Rogers | MarioR@... | Faculty | CS101,MATH201 | | |
| Monica Thompson | MonicaT@... | Advisor | | STU001,STU002,STU003 | |
| Robin Kline | RobinK@... | Advisor | | STU004,STU005 | |
| Kai Carter | KaiC@... | Student | | | STU001 |
| Dakota Sanchez | DakotaS@... | Student | | | STU002 |
| Amber Rodriguez | AmberR@... | Student | | | STU003 |
| Corey Gray | CoreyG@... | Student | | | STU004 |
| Omar Bennett | OmarB@... | Student | | | STU005 |

---

## Step 3: Create Power Platform Solution (2 min)

### 3.1 Import the solution

1. Go to **[make.powerapps.com](https://make.powerapps.com)**
2. Left nav → **Solutions** → **Import solution**
3. Click **Browse** → select `solution/UniGuard_Solution.zip`
4. Click **Next** → map connections when prompted
5. Click **Import**
6. Wait for "Solution imported successfully"

### 3.2 Verify

Open the **UniGuard** solution — you should see the imported flows.

---

## Step 4: Create GetStudentContext Flow (10 min)

If the flow wasn't in the solution, create it manually:

### 4.1 Create the flow

1. Inside **UniGuard** solution → **+ New** → **Automation** → **Cloud flow** → **Instant**
2. Name: `UniGuard - GetStudentContext`
3. Trigger: **Run a flow from Copilot**
4. Click **Create**

### 4.2 Add input

5. Click trigger → **+ Add an input** → **Text** → name: `query`

### 4.3 Add 6 SharePoint "Get items" actions

All use site: `https://yourtenant.sharepoint.com/sites/UniGuard`

6. **+ New step** → SharePoint → Get items → List: `User Roles` → *(rename: Get User Roles)*
7. **+ New step** → SharePoint → Get items → List: `Student Profiles` → *(rename: Get Students)*
8. **+ New step** → SharePoint → Get items → List: `Student Enrollments` → *(rename: Get Enrollments)*
9. **+ New step** → SharePoint → Get items → List: `Intervention History` → *(rename: Get Interventions)*
10. **+ New step** → SharePoint → Get items → List: `Degree Plans` → *(rename: Get Degree Plans)*
11. **+ New step** → SharePoint → Get items → List: `Alert Rules` → *(rename: Get Alert Rules)*

### 4.4 Return data to Copilot

12. **+ New step** → **Return value(s) to Power Virtual Agents**
    - Add output → Text → `students` → Dynamic content → **body** from Get Students
    - Add output → Text → `enrollments` → **body** from Get Enrollments
    - Add output → Text → `interventions` → **body** from Get Interventions
    - Add output → Text → `degreePlans` → **body** from Get Degree Plans
    - Add output → Text → `userRoles` → **body** from Get User Roles
    - Add output → Text → `alertRules` → **body** from Get Alert Rules

### 4.5 Save

13. Click **Save**

---

## Step 5: Create Copilot Studio Agent (10 min)

### 5.1 Create the agent

1. Go to **[copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)**
2. Click **+ Create** → **New agent**
3. Name: `UniGuard`
4. Description: `University Student Success & Academic Advisory Agent`
5. Click **Create**

### 5.2 Set instructions

6. Paste into the **Instructions** box:

```
You are UniGuard, a university Student Success Agent.

You serve 3 personas:
- Faculty: see their classes and students in those classes
- Advisors: see their advisee caseload across all classes
- Students: see only their own data

When analyzing students, use the Engagement Score (0-100):
  🟢 75-100 On Track
  🟡 60-74 Needs Monitoring
  🟠 40-59 At Risk
  🔴 0-39 Critical

For at-risk students, always include:
- Current grades and assignment completion per course
- Career goal (if available)
- Past interventions and outcomes
- A specific, actionable recommendation

Rules:
- Never fabricate data — only report what's in the data
- For outreach emails, reference specific assignments and grades
- Always suggest concrete next steps
- Be supportive, never judgmental about students
- If asked about a student not in the data, say "I don't have access to that student's information"
```

### 5.3 Add knowledge source

7. Click **Knowledge** → **+ Add knowledge** → **SharePoint**
8. Enter your site URL: `https://yourtenant.sharepoint.com/sites/UniGuard`
9. Click **Add**

### 5.4 Add the flow as a tool

10. Find **Tools** section → **+ Add tool**
11. Search for `GetStudentContext` → select it → **Add**

### 5.5 Create topic

12. Click **Topics** → **+ Add a topic** → **From blank**
13. Name: `Student Query`
14. Add trigger phrases:
    - `Show me at-risk students`
    - `How is Amber Rodriguez doing?`
    - `Any critical alerts?`
    - `What does Amber need to graduate?`
    - `What should I take next semester?`
    - `Draft an email to Amber`
    - `Show my students`
    - `Who's struggling?`
    - `Generate a class report`
    - `What are my grades?`

15. Build the canvas:
    - Click **+** → **Call an action** → **UniGuard - GetStudentContext**
    - Set `query` → click `{x}` → **Activity.Text**
    - Click **+** → **Create generative answers**
    - In Input, insert one of the output variables (e.g., `students`)
    - Under **Data sources** → Edit → add your SharePoint site

16. Click **Save**

### 5.6 Publish

17. Click **Publish** → confirm

### 5.7 Enable Teams

18. Click **Channels** → **Microsoft Teams** → **Turn on**
19. Click **Open in Teams** → **Add**

---

## Step 6: Test (5 min)

Open UniGuard in Teams and try these:

| Test | Expected |
|---|---|
| `Hi` | Welcome message |
| `Show me at-risk students` | Lists Amber (🔴), Dakota (🟠), Omar (🟡) |
| `How is Amber Rodriguez doing?` | Full profile with grades, engagement 34%, career goal, interventions |
| `What does Amber need to graduate?` | Biology Pre-Med degree map — completed vs remaining |
| `What should Amber take next semester?` | Prereq-aware recommendations |
| `Draft an email to Amber about her missing BIO301 labs` | Personalized email draft |

---

## Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| Script fails with 403 | Missing Graph permissions | Run: `Connect-MgGraph -Scopes "Sites.ReadWrite.All","Group.ReadWrite.All"` |
| "Site already exists" | Re-running script | Script will find and use existing site |
| Flow fails | SharePoint connection not configured | Edit flow → re-authenticate SharePoint connection |
| Agent returns raw JSON | No generative answers node | Add "Create generative answers" after the action |
| Agent says "I don't know" | Knowledge source not connected | Check Knowledge → SharePoint site URL is correct |
| Can't find GetStudentContext in Tools | Flow not in same environment | Make sure flow and agent are in the same Dataverse environment |
| Teams channel not working | Not published | Copilot Studio → Publish → Channels → Teams → Turn on |

---

## Next Steps

After the basic agent is working:

1. **Add privacy filtering** — See [Privacy Design](../design/PRIVACY-DESIGN.md) for role-based flow
2. **Add SendOutreach flow** — See [Flow Walkthrough](FLOW-WALKTHROUGH.md) for email + logging
3. **Replace sample data** — Import real student data from your SIS
4. **Configure alert rules** — Adjust thresholds in the Alert Rules list
5. **Add more topics** — See [Agent Design](../design/AGENT-DESIGN.md) for 6 topic blueprints
