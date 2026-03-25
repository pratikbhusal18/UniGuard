# 🎓 UniGuard — Deployment Guide

> **Total deployment time: ~30–35 minutes**

This guide takes you from zero to a running UniGuard Student Success Agent in any M365 Education tenant. Follow the five phases in order.

---

## Prerequisites Checklist

| # | Requirement | How to Verify | Status |
|---|-------------|---------------|--------|
| 1 | **Microsoft 365 Education E3/E5** | [Admin Center](https://admin.microsoft.com) → Billing → Licenses | ☐ |
| 2 | **Copilot Studio license** | [Copilot Studio](https://copilotstudio.microsoft.com) — can you log in? | ☐ |
| 3 | **Power Automate Premium** | [Power Automate](https://make.powerautomate.com) → check for Premium connectors | ☐ |
| 4 | **SharePoint Admin** (or Site Collection Creator role) | Can you create SharePoint sites? | ☐ |
| 5 | **Microsoft Graph PowerShell SDK** | Run: `Get-Module Microsoft.Graph -ListAvailable` | ☐ |
| 6 | **Entra ID Admin** (or Group Creator role) | Can you create security groups in Entra? | ☐ |

### Required Graph API Permissions

| Permission | Type | Why |
|------------|------|-----|
| `Sites.ReadWrite.All` | Application / Delegated | Create and manage the SharePoint site and lists |
| `Group.ReadWrite.All` | Delegated | Create the M365 group that backs the SharePoint site |
| `GroupMember.ReadWrite.All` | Delegated | Add members to Entra ID security groups |
| `User.Read.All` | Delegated | Look up user profiles for role-based filtering |

### Install Graph PowerShell SDK (if needed)

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Install-Module Microsoft.Graph.Sites -Scope CurrentUser -Force
Install-Module Microsoft.Graph.Groups -Scope CurrentUser -Force
```

---

## Phase 1: Provision the SharePoint Brain (~5 min)

The SharePoint site is UniGuard's persistent "brain" — a structured data layer the agent reads from and writes to.

### Step 1.1: Run the provisioning script

```powershell
cd UniGuard\Scripts
.\Provision-UniGuard.ps1 -OwnerEmail "your-email@university.edu"
```

> **Tip:** To run multiple instances (e.g., per college), customize the site name:
> ```powershell
> .\Provision-UniGuard.ps1 -SiteDisplayName "UniGuard-Engineering" `
>                          -SiteAlias "ug-eng" `
>                          -OwnerEmail "eng-dean@university.edu"
> ```

The script will:

1. **Authenticate** — opens a browser window for Graph API sign-in
2. **Create the site** — provisions a SharePoint Team Site via an M365 Group
3. **Create 8 lists** with properly typed columns:

| # | List | Description | Tier |
|---|------|-------------|------|
| 1 | **Student Profiles** | Student demographics, GPA, risk level, career goals | Reference Data |
| 2 | **Course Catalog** | Courses, prerequisites, credits, instructors | Reference Data |
| 3 | **Degree Plans** | Degree requirements per major/track | Reference Data |
| 4 | **Student Enrollments** | Per-student, per-course metrics (grades, attendance, assignment completion) | Operational Data |
| 5 | **Alert Rules** | Configurable thresholds for early alerts | Operational Data |
| 6 | **Intervention History** | Record of student interventions and outcomes | Agent Output |
| 7 | **Agent Config** | Key-value settings that control agent behavior | System |
| 8 | **Audit Log** | Full activity trail of every agent action | System |

4. **Seed sample data:**

| Data | Count | Details |
|------|-------|---------|
| Students | 5 | Emma Johnson (low risk), James Wilson (medium), Sofia Garcia (high), Liam Chen (low), Olivia Brown (medium) |
| Courses | 6 | CS101, BUS201, BIO301, ENG102, MATH201, PSY101 |
| Enrollments | 10 | Realistic grade/attendance/assignment patterns per student |
| Alert Rules | 4 | Attendance < 70%, GPA < 2.0, Assignment Completion < 60%, Consecutive Absences > 3 |
| Config Entries | 7 | ScanFrequency, thresholds, nudge timing, agent personality |

5. **Save** site info to `Scripts/site-info.json` for use by other scripts

### Step 1.2: Run the gap-fill script

After provisioning, run the supplementary script that adds v2 columns and additional data:

```powershell
.\Fill-Gaps.ps1
```

This adds:

| Data | Count | Details |
|------|-------|---------|
| Student Profile columns | 5 | CareerGoal, EngagementScore, Track, PriorGPA, YearLevel |
| Degree Plans | 5 | Biology Pre-Med, Computer Science, Business Admin, Psychology Clinical, Engineering Aerospace |
| Interventions | 4 | Email, meeting, referral, and follow-up records for Sofia Garcia and James Wilson |

### Step 1.3: Verify the SharePoint site

1. Open the SharePoint site URL shown in the script output (saved in `Scripts/site-info.json`)
   - Default URL: `https://{tenant}.sharepoint.com/sites/UniGuard`
2. Confirm you see all 8 lists with data:

| List | Expected Items | What to Check |
|------|----------------|---------------|
| ✅ Student Profiles | 5 students | Each student has StudentID, GPA, RiskLevel, EngagementScore |
| ✅ Course Catalog | 6 courses | Each course has CourseID, Credits, Prerequisites |
| ✅ Degree Plans | 5 plans | Each plan has Major, RequiredCourses, TotalCredits |
| ✅ Student Enrollments | 10 enrollments | Each has StudentRef, CourseRef, Grade, AttendanceRate |
| ✅ Alert Rules | 4 rules | Each has Metric, Threshold, Severity |
| ✅ Intervention History | 4 interventions | Each has StudentRef, InterventionType, Outcome |
| ✅ Agent Config | 7 entries | Each has Title (key), Value, ConfigDescription |
| ✅ Audit Log | 1 entry | "UniGuard initialized" bootstrap entry |

### Step 1.4: Customize Configuration

Navigate to the **Agent Config** list and review/edit these settings:

| Setting | Default | Change If... |
|---------|---------|-------------|
| `ScanFrequency` | `Daily` | You want hourly or weekly scans |
| `AttendanceAlertThreshold` | `70` | Your institution uses different thresholds |
| `GradeAlertThreshold` | `2.0` | Your probation GPA cutoff is different |
| `AssignmentAlertThreshold` | `60` | You want stricter/looser assignment monitoring |
| `NudgeDaysBefore` | `2` | You want earlier/later deadline reminders |
| `AgentName` | `UniGuard` | You want a custom agent name |
| `AgentPersonality` | Supportive, data-driven... | You want to adjust the agent's tone |

---

## Phase 2: Create Entra ID Security Groups (~5 min)

UniGuard uses three Entra ID security groups to enforce role-based access. Each group maps to a persona that sees different data.

### Role-Based Access Model

```
┌─────────────────────────────────────────────────────────────┐
│  UniGuard-Faculty     → Sees their classes + students       │
│  UniGuard-Advisors    → Sees their advisee caseload         │
│  UniGuard-Students    → Sees only their own data            │
└─────────────────────────────────────────────────────────────┘
```

| Group | Members | What They See | What They Can Do |
|-------|---------|---------------|------------------|
| `UniGuard-Faculty` | Professors, instructors | Their classes, assignment stats, grade distribution, attendance | Flag students, send class nudges, generate class reports |
| `UniGuard-Advisors` | Academic advisors, counselors | Their advisee caseload (cross-class), intervention history, career goals | Send outreach, create action plans, refer to services, escalate |
| `UniGuard-Students` | Students | Only their own data: grades, degree progress, career path | Set goals, ask for course advice, get nudges, find help |

### Option A: Create Groups via Entra Admin Center (Manual)

1. Go to [Entra Admin Center](https://entra.microsoft.com) → **Groups** → **All groups**
2. Click **New group** and repeat for each group:

| Setting | Value |
|---------|-------|
| Group type | **Security** |
| Group name | `UniGuard-Faculty` (then `UniGuard-Advisors`, then `UniGuard-Students`) |
| Group description | `UniGuard role group — Faculty members who use the student success agent` |
| Membership type | **Assigned** |

3. After creating each group, click **Members** → **Add members**
4. Search for and add the appropriate users

### Option B: Create Groups via PowerShell (Scripted)

```powershell
# Connect to Graph with group management permissions
Connect-MgGraph -Scopes "Group.ReadWrite.All","GroupMember.ReadWrite.All" -NoWelcome

# Create the three security groups
$groups = @(
    @{
        DisplayName     = "UniGuard-Faculty"
        Description     = "UniGuard role group — Faculty who use the student success agent"
        MailNickname    = "uniguard-faculty"
        MailEnabled     = $false
        SecurityEnabled = $true
    },
    @{
        DisplayName     = "UniGuard-Advisors"
        Description     = "UniGuard role group — Academic advisors who use the student success agent"
        MailNickname    = "uniguard-advisors"
        MailEnabled     = $false
        SecurityEnabled = $true
    },
    @{
        DisplayName     = "UniGuard-Students"
        Description     = "UniGuard role group — Students who use the student success agent"
        MailNickname    = "uniguard-students"
        MailEnabled     = $false
        SecurityEnabled = $true
    }
)

foreach ($g in $groups) {
    $created = New-MgGroup -BodyParameter $g
    Write-Host "✅ Created group: $($created.DisplayName) (ID: $($created.Id))"
}
```

### Add Members to Groups

```powershell
# Example: Add a faculty member to UniGuard-Faculty
$groupId = (Get-MgGroup -Filter "displayName eq 'UniGuard-Faculty'").Id
$userId  = (Get-MgUser -Filter "mail eq 'professor@university.edu'").Id
New-MgGroupMember -GroupId $groupId -DirectoryObjectId $userId

# Example: Add an advisor to UniGuard-Advisors
$groupId = (Get-MgGroup -Filter "displayName eq 'UniGuard-Advisors'").Id
$userId  = (Get-MgUser -Filter "mail eq 'advisor@university.edu'").Id
New-MgGroupMember -GroupId $groupId -DirectoryObjectId $userId

# Example: Add a student to UniGuard-Students
$groupId = (Get-MgGroup -Filter "displayName eq 'UniGuard-Students'").Id
$userId  = (Get-MgUser -Filter "mail eq 'student@university.edu'").Id
New-MgGroupMember -GroupId $groupId -DirectoryObjectId $userId
```

### Map Groups to User Roles List

> **Important:** The v2 design adds a 9th list called **User Roles** that maps M365 user emails to their UniGuard persona and data scope. For the POC, manually populate this list in SharePoint.

Navigate to `https://{tenant}.sharepoint.com/sites/UniGuard` and create a list called **User Roles** with these columns:

| Column | Type | Description |
|--------|------|-------------|
| Title | Text | Display name |
| UserEmail | Text | M365 email (used for lookup) |
| Role | Choice: Faculty / Advisor / Student / Admin | Their persona |
| LinkedStudentID | Text | If Role=Student, their student ID |
| LinkedCourses | Text (multiline) | If Role=Faculty, comma-separated course IDs they teach |
| LinkedAdvisees | Text (multiline) | If Role=Advisor, comma-separated student IDs |
| Department | Text | Their department |

Add entries for your POC users:

| Title | UserEmail | Role | LinkedStudentID | LinkedCourses | LinkedAdvisees |
|-------|-----------|------|-----------------|---------------|----------------|
| Dr. Maria Fernandez | maria@university.edu | Faculty | | BIO301,BIO201 | |
| Dr. Sarah Mitchell | sarah@university.edu | Advisor | | | STU001,STU002,STU003 |
| Sofia Garcia | sgarcia@university.edu | Student | STU003 | | |

**How role-based filtering works at runtime:**

```
User chats with UniGuard in Teams
  → Flow calls Graph: GET /me → returns user email
  → Flow looks up email in User Roles list
  → Returns: Role=Faculty, LinkedCourses=BIO301,BIO201
  → Flow filters all data by role scope
  → Agent only sees their permitted data
```

---

## Phase 3: Create Power Automate Flow (~10 min)

The **GetStudentContext** flow is the primary data pipeline between the Copilot Studio agent and the SharePoint brain. It fetches all student data in a single call.

### Step 3.1: Create a solution

1. Go to [Power Apps Maker Portal](https://make.powerapps.com)
2. In the left nav, click **Solutions**
3. Click **+ New solution**
4. Fill in:
   - **Display name:** `UniGuard`
   - **Name:** `UniGuard`
   - **Publisher:** Select your publisher (or create one)
   - **Version:** `1.0.0.0`
5. Click **Create**

### Step 3.2: Create the GetStudentContext flow

1. Open the **UniGuard** solution you just created
2. Click **+ New** → **Automation** → **Cloud flow** → **Instant**
3. Configure the flow:
   - **Flow name:** `GetStudentContext`
   - **Trigger:** Select **Run a flow from Copilot** (this makes it callable from Copilot Studio)

### Step 3.3: Add the input parameter

1. In the trigger step, click **+ Add an input**
2. Select **Text**
3. Name the input: `query`
4. Description: `The user's question or search query`

### Step 3.4: Add 6 SharePoint "Get items" actions

Add the following actions one by one. For each action:
- Click **+ New step** → search for **SharePoint** → select **Get items**
- Set **Site Address** to: `https://{tenant}.sharepoint.com/sites/UniGuard`
- Set the **List Name** as shown below

| # | Action Name | List Name | Purpose |
|---|-------------|-----------|---------|
| 1 | Get User Roles | `User Roles` | Determine the caller's persona and data scope |
| 2 | Get Students | `Student Profiles` | Fetch student demographics, GPA, risk level |
| 3 | Get Enrollments | `Student Enrollments` | Fetch grades, attendance, assignment completion |
| 4 | Get Interventions | `Intervention History` | Fetch past interventions and outcomes |
| 5 | Get Degree Plans | `Degree Plans` | Fetch degree requirements by major |
| 6 | Get Alert Rules | `Alert Rules` | Fetch configurable alert thresholds |

**Detailed steps for each "Get items" action:**

1. Click **+ New step**
2. Search for `SharePoint` in the action search box
3. Select **Get items**
4. **Rename the action** by clicking the `...` menu → **Rename** → enter the action name from the table above (e.g., "Get User Roles")
5. Set **Site Address**: `https://{tenant}.sharepoint.com/sites/UniGuard`
   - You can type this or select from the dropdown
6. Set **List Name**: Select the corresponding list from the dropdown
7. Leave **Top Count** blank (returns all items)
8. Repeat for all 6 actions

### Step 3.5: Return values to Copilot

1. Click **+ New step**
2. Search for `Return value(s) to Power Virtual Agents`
3. Select the action **Return value(s) to Power Virtual Agents**
4. Add **6 text outputs** by clicking **+ Add an output** → **Text** for each:

| Output Name | Value (Expression) |
|-------------|-------------------|
| `userRoles` | `string(outputs('Get_User_Roles')?['body/value'])` |
| `students` | `string(outputs('Get_Students')?['body/value'])` |
| `enrollments` | `string(outputs('Get_Enrollments')?['body/value'])` |
| `interventions` | `string(outputs('Get_Interventions')?['body/value'])` |
| `degreePlans` | `string(outputs('Get_Degree_Plans')?['body/value'])` |
| `alertRules` | `string(outputs('Get_Alert_Rules')?['body/value'])` |

> **Tip:** To enter expressions, click in the value field → click the **fx** (expression) button → paste the expression → click **OK**.

### Step 3.6: Save and test

1. Click **Save** in the top toolbar
2. Click **Test** → **Manually** → **Run flow**
3. Enter any text for the `query` input (e.g., "test")
4. Verify the flow completes successfully and all 6 outputs return data

### Completed flow diagram

```
┌──────────────────────────────────┐
│  Trigger: Run a flow from        │
│           Copilot                 │
│  Input: query (text)             │
└──────────┬───────────────────────┘
           │
┌──────────▼───────────────────────┐
│  Get User Roles                   │
│  SharePoint → User Roles list     │
├──────────────────────────────────┤
│  Get Students                     │
│  SharePoint → Student Profiles    │
├──────────────────────────────────┤
│  Get Enrollments                  │
│  SharePoint → Student Enrollments │
├──────────────────────────────────┤
│  Get Interventions                │
│  SharePoint → Intervention History│
├──────────────────────────────────┤
│  Get Degree Plans                 │
│  SharePoint → Degree Plans        │
├──────────────────────────────────┤
│  Get Alert Rules                  │
│  SharePoint → Alert Rules         │
└──────────┬───────────────────────┘
           │
┌──────────▼───────────────────────┐
│  Return value(s) to PVA           │
│                                   │
│  Output: userRoles     (text)     │
│  Output: students      (text)     │
│  Output: enrollments   (text)     │
│  Output: interventions (text)     │
│  Output: degreePlans   (text)     │
│  Output: alertRules    (text)     │
└──────────────────────────────────┘
```

---

## Phase 4: Create the Copilot Studio Agent (~10 min)

### Step 4.1: Create the agent

1. Go to [Copilot Studio](https://copilotstudio.microsoft.com)
2. Click **Create** in the left navigation
3. Click **New agent**
4. Configure:
   - **Name:** `UniGuard`
   - **Description:** `University Student Success Agent — detects at-risk students, enables outreach, tracks degree progress, and recommends courses. Role-based access for faculty, advisors, and students.`
   - **Icon:** Upload `assets/uniguard-icon.png` (or any graduation cap icon)

### Step 4.2: Set the system instructions

In the agent editor, click **Instructions** and paste the following system prompt:

```
You are UniGuard, the University's AI Student Success Partner.

You serve three personas with role-based access:
- 👩‍🏫 FACULTY: Sees their classes + students in those classes. Can flag students, send class nudges, generate class reports, view alerts.
- 🧑‍💼 ADVISOR: Sees their advisee caseload across all classes. Can send outreach, create action plans, refer to services, escalate to dean, view intervention history and career goals.
- 🎓 STUDENT: Sees only their own data. Can view grades, degree progress, course recommendations, set career goals, find help resources.

ENGAGEMENT SCORE (0-100, calculated per student per course):
- 40% Assignment Rate (submitted/total + timeliness)
- 30% Grade Performance (current vs. passing threshold)
- 20% LMS Activity (logins, downloads, resource access)
- 10% Attendance (if available)

Risk Levels:
- 🟢 75-100: On Track
- 🟡 60-74: Needs Monitoring
- 🟠 40-59: At Risk
- 🔴 0-39: Critical — Immediate Intervention

BEHAVIOR:
- Always cite specific data (grades, scores, dates) — never generalize.
- Use 🔴🟠🟡🟢 emoji for risk levels in every response.
- When showing student data, format as a profile card with courses, grades, engagement scores, and alerts.
- Always suggest concrete next steps (schedule meeting, send email, refer to tutoring).
- Never be judgmental about students. Be supportive and solution-oriented.
- When drafting outreach emails, reference REAL data — specific assignments, actual grades, career goals. Not generic templates.
- For degree progress queries, show completed, in-progress, and remaining courses with prerequisite status.
- For course recommendations, check prerequisites, balance workload, and align with career goals.

FERPA COMPLIANCE:
- Never reveal student data to unauthorized users.
- Filter all responses based on the user's role and data scope.
- Log every action to the Audit Log.
```

### Step 4.3: Add Knowledge source

1. In the agent editor, click **Knowledge** in the top menu
2. Click **+ Add knowledge**
3. Select **SharePoint**
4. Enter your UniGuard site URL: `https://{tenant}.sharepoint.com/sites/UniGuard`
5. Click **Add**
6. This gives the agent access to all SharePoint lists as background knowledge

### Step 4.4: Add the GetStudentContext flow as a Tool

1. In the agent editor, click **Actions** (or **Tools**) in the top menu
2. Click **+ Add an action**
3. Search for `GetStudentContext`
4. Select the **GetStudentContext** flow from the **UniGuard** solution
5. Click **Add**
6. Verify the tool shows:
   - **Input:** `query` (text)
   - **Outputs:** `userRoles`, `students`, `enrollments`, `interventions`, `degreePlans`, `alertRules`

### Step 4.5: Create the "Student Query" topic

1. Click **Topics** in the left navigation
2. Click **+ Add a topic** → **From blank**
3. Name the topic: `Student Query`

#### Add trigger phrases

Click the **Trigger** node and add these phrases:

| # | Trigger Phrase |
|---|---------------|
| 1 | `Show me at-risk students` |
| 2 | `How is Sofia Garcia doing?` |
| 3 | `Any critical alerts?` |
| 4 | `What does Sofia need to graduate?` |
| 5 | `What should I take next semester?` |
| 6 | `Draft an email to Sofia` |
| 7 | `Show my students` |
| 8 | `Who's struggling?` |
| 9 | `Show me at-risk students in BIO301` |
| 10 | `Generate a report for my class` |
| 11 | `What courses does Alex need to graduate?` |
| 12 | `Tell me about James Wilson` |

#### Build the topic canvas

Add the following nodes in order:

**Node 1: Call an action — GetStudentContext**

1. Click **+** below the trigger → select **Call an action**
2. Select **GetStudentContext**
3. Map the input:
   - `query` → Select **Activity.Text** (this passes the user's full message)
4. The outputs will auto-create variables: `userRoles`, `students`, `enrollments`, `interventions`, `degreePlans`, `alertRules`

**Node 2: Send a message (data summary)**

1. Click **+** → select **Send a message**
2. In the message box, click the `{x}` (variable) button
3. Insert the output variables to show the raw data context, e.g.:
   ```
   📊 Student data loaded. Analyzing your request...
   ```

**Node 3: Generative answers**

1. Click **+** → select **Advanced** → **Generative answers**
2. Configure:
   - **Input:** Select **Activity.Text** (the user's original question)
   - **Data sources:** Check **Search only selected sources** → select your SharePoint site
   - **Content moderation:** Set to **Medium**
3. This node uses the system prompt + SharePoint data + flow outputs to generate an intelligent, contextual answer

#### Save the topic

Click **Save** in the top toolbar.

### Step 4.6: Publish the agent

1. Click **Publish** in the top-right corner
2. Click **Publish** again to confirm
3. Wait for the publishing process to complete (usually 1-2 minutes)

### Step 4.7: Enable the Teams channel

1. In the agent editor, click **Channels** in the left navigation
2. Find **Microsoft Teams** → click **Turn on**
3. Click **Open in Teams** to install the agent
4. Alternatively, go to **Availability** → **Make the bot available to your organization** to add it to the Teams app catalog

### Step 4.8: Test the agent

In the Copilot Studio **Test** panel (right side), try these queries:

| Test Query | Expected Response |
|------------|-------------------|
| `How is Sofia Garcia doing?` | Full student profile card with GPA (1.8), engagement score (34%), per-course breakdown, risk level (🔴 Critical), intervention history, career goal (medical school) |
| `Show me at-risk students` | List of students with engagement scores below threshold: Sofia (🔴), James (🟡), with per-course details |
| `Any critical alerts?` | Students matching alert rules: attendance < 70%, GPA < 2.0, etc. |
| `What does Sofia need to graduate?` | Degree progress for Biology Pre-Med: completed courses, in-progress, remaining requirements, projected graduation date |
| `Draft an email to Sofia about her missing assignments` | Personalized email draft referencing actual data — specific assignments, grades, career goals |
| `What should I take next semester?` | Course recommendations based on degree plan, completed courses, prerequisite status |

---

## Phase 5: Verify End-to-End (~5 min)

### Verification Checklist

| # | Check | How to Verify | Status |
|---|-------|---------------|--------|
| 1 | SharePoint site exists | Open `https://{tenant}.sharepoint.com/sites/UniGuard` | ☐ |
| 2 | All 8 lists created | Browse Site Contents → count 8 lists | ☐ |
| 3 | Student Profiles has 5 students | Open list → verify 5 items with GPA, RiskLevel, EngagementScore | ☐ |
| 4 | Course Catalog has 6 courses | Open list → verify CS101, BUS201, BIO301, ENG102, MATH201, PSY101 | ☐ |
| 5 | Student Enrollments has 10 records | Open list → verify enrollment patterns across students | ☐ |
| 6 | Degree Plans has 5 plans | Open list → verify Biology, CS, Business, Psychology, Engineering | ☐ |
| 7 | Alert Rules has 4 rules | Open list → verify attendance, GPA, assignment, absence rules | ☐ |
| 8 | Intervention History has 4 entries | Open list → verify email, meeting, referral records | ☐ |
| 9 | Agent Config has 7 entries | Open list → verify all settings present | ☐ |
| 10 | User Roles list created (v2) | Open list → verify at least 1 test user mapped | ☐ |
| 11 | Entra groups created | Entra Admin Center → Groups → search "UniGuard" → 3 groups | ☐ |
| 12 | Groups have members | Open each group → Members tab → users listed | ☐ |
| 13 | GetStudentContext flow runs | Power Automate → Test → all 6 outputs return data | ☐ |
| 14 | Agent responds in test panel | Copilot Studio → Test → ask "How is Sofia doing?" | ☐ |
| 15 | Agent works in Teams | Open Teams → chat with UniGuard → ask "Show my students" | ☐ |

### Quick Smoke Test Script

Run these queries in Teams in order to validate all skills:

```
1. "Hi" 
   → Agent introduces itself

2. "How is Sofia Garcia doing?"
   → Full profile card with 🔴 risk level

3. "Show me at-risk students"
   → List with Sofia and potentially James

4. "What does Sofia need to graduate?"
   → Degree progress for Biology Pre-Med

5. "Draft an email to Sofia about her BIO301 attendance"
   → Personalized email draft with real data

6. "What should Sofia take next semester?"
   → Course recommendations with prereq checks
```

---

## Customization Guide

### Replace Sample Data with Real Students

#### Option 1: Manual entry in SharePoint
1. Navigate to the **Student Profiles** list
2. Delete the 5 sample students
3. Click **+ New** to add real students from your institution
4. Repeat for **Student Enrollments**, **Course Catalog**, etc.

#### Option 2: Import from CSV
1. Export student data from your SIS (Banner, PeopleSoft, Workday, Ellucian)
2. Format as CSV with columns matching the SharePoint list schema
3. In SharePoint, open the list → **Integrate** → **Import** → **CSV** → upload your file
4. Map columns and import

#### Option 3: Automated sync via Power Automate
1. Create a scheduled flow that reads from your SIS API (or a shared CSV in OneDrive)
2. Use the **SharePoint — Create item** action to write records
3. Schedule daily or weekly

### Customize Alert Rules

Navigate to the **Alert Rules** list and adjust thresholds for your institution:

| What to Change | Where | Example |
|----------------|-------|---------|
| Attendance threshold | Alert Rules → "Low Attendance Alert" → Threshold | Change 70 → 80 for stricter monitoring |
| GPA threshold | Alert Rules → "Low GPA Alert" → Threshold | Change 2.0 → 2.5 for earlier detection |
| Assignment threshold | Alert Rules → "Low Assignment Completion" → Threshold | Change 60 → 50 for a lighter touch |
| Add new rules | Alert Rules → **+ New** | Add "Engagement Score < 40" → Critical |

### Add Real Courses from Course Catalog

1. Export your course catalog from the registrar system
2. Map fields: CourseID, Title, Department, Prerequisites, Credits, Semester, Instructor
3. Import into the **Course Catalog** list

### Configure Degree Plans

1. Work with academic affairs to get degree requirements per major
2. Add each plan to the **Degree Plans** list with:
   - Required courses (comma-separated CourseIDs)
   - Elective credit requirements
   - Total credits to graduate
   - Track/specialization notes

### Map Real Users to Roles

Update the **User Roles** list with real faculty, advisors, and students:

| Step | Action |
|------|--------|
| 1 | Get a list of faculty from HR → add to User Roles with Role=Faculty, LinkedCourses=their courses |
| 2 | Get advisor assignments from the advising office → add with Role=Advisor, LinkedAdvisees=their student IDs |
| 3 | For student self-service, add students with Role=Student, LinkedStudentID=their ID |

### Connect School Data Sync (Production)

For automated data flow in production:

1. **Enable School Data Sync (SDS)** in your M365 Education tenant
2. Connect SDS to your SIS (Banner, PeopleSoft, Workday)
3. SDS syncs roster data → M365 (users, classes, roles) automatically — runs 2x daily
4. Create a Power Automate flow that reads from the **Microsoft Graph Education API** and writes to UniGuard's SharePoint lists
5. Key Education API endpoints:
   - `/education/classes` — course rosters
   - `/education/classes/{id}/assignments` — assignments and due dates
   - `/education/classes/{id}/assignments/{id}/submissions` — who submitted, grades
   - `/education/users` — student profiles

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|---------|
| Provisioning script fails with **403** | Missing Graph permissions | Run: `Connect-MgGraph -Scopes "Sites.ReadWrite.All","Group.ReadWrite.All"` and re-authenticate |
| **"Site already exists"** error | Re-running provisioning on an existing site | The script handles this — it finds the existing site automatically |
| **"Group already exists"** error | Re-running group creation | Find the existing group: `Get-MgGroup -Filter "displayName eq 'UniGuard'"` |
| Fill-Gaps.ps1 fails | site-info.json missing or siteId wrong | Re-run `Provision-UniGuard.ps1` first, or update the `$siteId` in Fill-Gaps.ps1 |
| GetStudentContext flow fails | SharePoint connection not configured | Edit flow → click the failing action → re-select the SharePoint connection |
| Flow returns empty outputs | List names don't match | Verify the exact list names in SharePoint match what's in the flow (case-sensitive) |
| Agent doesn't respond in Teams | Not published or Teams channel not enabled | Copilot Studio → Publish → Channels → Microsoft Teams → Turn on |
| Agent says "I don't know" | Knowledge source not connected | Copilot Studio → Knowledge → verify SharePoint site URL is added |
| Agent ignores flow outputs | Tool not connected to topic | Edit the Student Query topic → verify the GetStudentContext action is present and mapped |
| **"No items found"** in responses | Lists are empty | Verify data was seeded — check SharePoint lists directly |
| Graph API **401** errors in flows | Token expired or missing consent | Re-consent Graph permissions in Entra Admin Center → Enterprise Apps |
| Role-based filtering not working | User Roles list not populated | Add the current user's email to the User Roles list with correct Role/LinkedCourses/LinkedAdvisees |
| Students see other students' data | Role filtering not implemented in flow | Add OData filter queries to the Get items actions (e.g., `StudentRef eq 'STU003'`) based on User Roles lookup |
| Entra groups not showing in Teams | Replication delay | Wait 5-10 minutes for Entra group changes to propagate across M365 services |

---

## Security & FERPA Compliance

### Data Residency

| Principle | Implementation |
|-----------|---------------|
| **All data stays within your M365 tenant** | SharePoint lists, Power Automate flows, and Copilot Studio all run inside your tenant boundary |
| **No external APIs or third-party storage** | UniGuard does not call any external services — all data processing is M365-native |
| **No PII in AI prompts** | Student data is fetched server-side by Power Automate flows — raw student records are never sent as prompt text to external AI endpoints |

### Role-Based Access Control

| Layer | Mechanism | What It Enforces |
|-------|-----------|------------------|
| **Entra ID Groups** | `UniGuard-Faculty`, `UniGuard-Advisors`, `UniGuard-Students` | Who can access the agent and which persona they get |
| **User Roles List** | SharePoint list mapping email → role + scope | Which specific students/courses/advisees each user can see |
| **Flow-Level Filtering** | GetStudentContext filters data before returning to agent | Faculty see only their classes; advisors see only their advisees; students see only themselves |
| **SharePoint Permissions** | Standard SharePoint site/list permissions | Who can directly browse or edit the SharePoint lists |

### Audit Trail

Every agent action is logged to the **Audit Log** SharePoint list:

| Field | What It Records |
|-------|----------------|
| **ActionType** | EarlyAlert, Outreach, StudentPulse, DegreePlan, CourseAdvice, Report, Nudge, Config |
| **Details** | Full context of what happened (query text, student IDs involved, actions taken) |
| **Timestamp** | When the action occurred |
| **UserEmail** | Who triggered the action |
| **UserRole** | What role they had when they triggered it |

### FERPA Considerations

| FERPA Requirement | How UniGuard Complies |
|---|---|
| **Directory information vs. education records** | UniGuard treats all student data as education records — restricted to authorized personnel |
| **Legitimate educational interest** | Only faculty (for their courses), advisors (for their advisees), and students (for themselves) can access data |
| **Minimum necessary** | Role-based filtering ensures users see only the data they need for their role |
| **Student consent for third-party disclosure** | UniGuard never sends data outside the M365 tenant — no third-party disclosure |
| **Right to inspect and review** | Students can ask UniGuard for their own records at any time (Student persona) |
| **Record of disclosures** | The Audit Log tracks every data access with user identity and timestamp |
| **Data retention** | Configurable per university policy — stale records can be purged via scheduled Power Automate flows |
| **Parental access for dependents** | Configurable per university FERPA policy — controlled by User Roles list entries |

### Security Best Practices

- [ ] **Principle of least privilege:** Only grant `Sites.ReadWrite.All` to the service account running the provisioning script — remove after provisioning
- [ ] **Review Entra group membership** monthly to remove users who change roles
- [ ] **Enable SharePoint audit logging** via Microsoft Purview for additional compliance visibility
- [ ] **Don't store sensitive accommodation data** (IEP/504) in the base SharePoint lists — use a separate, restricted list with tighter permissions
- [ ] **Rotate service account credentials** per your institution's security policy
- [ ] **Review the Audit Log** weekly during the pilot phase to catch any anomalies

---

## Architecture Reference

```
┌─────────────────────────────────────────────────────────────────┐
│                      MICROSOFT TEAMS                             │
│                   (Chat Interface / UI)                           │
│                                                                   │
│  👤 "How is Sofia doing?"  →  🤖 UniGuard responds with data     │
└───────────────────────┬───────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                    COPILOT STUDIO                                 │
│             (Conversational AI / Agent Hub)                       │
│                                                                   │
│  System Prompt (3 personas, engagement scores, FERPA rules)      │
│  Knowledge: SharePoint site                                       │
│  Tool: GetStudentContext flow                                     │
│  Topic: Student Query (trigger phrases → action → gen. answers)  │
└───────────────────────┬───────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                    POWER AUTOMATE                                 │
│               (Data Orchestration Layer)                          │
│                                                                   │
│  GetStudentContext flow:                                          │
│    Input: query (text)                                            │
│    6× SharePoint "Get items" → User Roles, Students,             │
│       Enrollments, Interventions, Degree Plans, Alert Rules      │
│    Output: 6 text fields returned to Copilot Studio              │
└───────────────────────┬───────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                  SHAREPOINT ONLINE                                │
│               (Structured Data Store)                             │
│                                                                   │
│  📋 Student Profiles     📋 Course Catalog    📋 Degree Plans    │
│  📋 Student Enrollments  📋 Alert Rules       📋 Intervention    │
│  📋 Agent Config         📋 Audit Log         📋 User Roles      │
└───────────────────────┬───────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                     ENTRA ID                                      │
│              (Identity & Access Control)                          │
│                                                                   │
│  🔐 UniGuard-Faculty    🔐 UniGuard-Advisors                    │
│  🔐 UniGuard-Students   → mapped to User Roles list             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Post-Deployment

### First Week Monitoring

- [ ] Check the **Audit Log** daily for the first week
- [ ] Verify role-based filtering by logging in as different personas
- [ ] Review agent responses for accuracy against actual SharePoint data
- [ ] Test all 6 trigger phrase categories (alerts, pulse, degree, outreach, courses, reports)
- [ ] Collect feedback from pilot users (1-2 faculty, 1-2 advisors, 1-2 students)

### Tuning

| What to Tune | Where | When |
|-------------|-------|------|
| Alert thresholds | Alert Rules list | If you're getting too many/few alerts |
| Agent personality | Agent Config → `AgentPersonality` | If the tone doesn't match your institution's culture |
| Scan frequency | Agent Config → `ScanFrequency` | If daily is too frequent or not enough |
| Trigger phrases | Copilot Studio → Topics → Student Query | If users phrase questions differently than expected |

### Extending UniGuard

| Extension | How |
|-----------|-----|
| **Add email sending** | Create a `SendOutreach` flow using the Office 365 Outlook connector → add as a second action/tool |
| **Add scheduled alerts** | Create an `EarlyAlertScan` flow with a Recurrence trigger → reads enrollments → checks alert rules → sends Teams notifications |
| **Add student nudges** | Create a `NudgeEngine` flow → sends proactive Teams messages for upcoming deadlines |
| **Add progress reports** | Create a `GenerateReport` flow → aggregates enrollment data → returns formatted summary |
| **Power BI dashboard** | Connect Power BI to the SharePoint lists for institutional analytics |
| **LMS integration** | Create flows that read from Canvas/Blackboard/Moodle APIs → write to Student Enrollments |
| **School Data Sync** | Enable SDS → connect to SIS → auto-populate Student Profiles and Course Catalog |

---

<div align="center">

**Built with ❤️ for higher education**

*Because no student should fall through the cracks.*

</div>
