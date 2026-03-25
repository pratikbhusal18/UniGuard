# 🎓 UniGuard — Power Automate Flow Walkthrough

Step-by-step guide for creating flows in the Power Automate portal.
These flows connect the Copilot Studio agent to SharePoint data and Outlook actions.

---

## Flow 1: GetStudentContext (Main Data Flow)

This is the primary flow. The agent calls it on every conversation turn to load role-filtered data from SharePoint.

### Create the Flow

1. Go to [Power Automate](https://make.powerautomate.com)
2. In the left nav, click **Solutions** → open **UniGuard**
   - If the solution doesn't exist yet, create one: **New solution** → Display name: `UniGuard`, Publisher: your default publisher
3. Inside the solution, click **New** → **Automation** → **Cloud flow** → **Instant**
4. Flow name: `GetStudentContext`
5. Trigger: select **Run a flow from Copilot**
6. Click **Create**

### Add the Input

1. In the trigger card, click **+ Add an input**
2. Choose **Text**
3. Input name: `query`
4. Description: `The user's natural language question`

### Add the 6 "Get Items" Actions

For each action below, click **+ New step** → search for **SharePoint** → select **Get items**.

All actions use the same site:

> **Site Address:** `https://m365cpi30732412.sharepoint.com/sites/UniGuard`

| # | List Name | Rename Action To | Top Count |
|---|-----------|-----------------|-----------|
| 1 | User Roles | Get Items — User Roles | 500 |
| 2 | Student Profiles | Get Items — Student Profiles | 500 |
| 3 | Student Enrollments | Get Items — Student Enrollments | 2000 |
| 4 | Intervention History | Get Items — Intervention History | 1000 |
| 5 | Degree Plans | Get Items — Degree Plans | 100 |
| 6 | Alert Rules | Get Items — Alert Rules | 100 |

**To rename an action:**
- Click the `...` (three dots) on the action card → **Rename** → paste the name from the table above.

**To set Top Count:**
- Expand **Show advanced options** on each Get Items action → set **Top Count** to the value above.

### Return the Data to Copilot

1. Click **+ New step** → search for **Respond to Copilot** (or "Return value(s) to Power Virtual Agents")
2. Add **6 text outputs**, one for each list:

| Output Name | Value (Expression) |
|---|---|
| `userRolesJSON` | `json(body('Get_Items_—_User_Roles')?['value'])` |
| `studentProfilesJSON` | `json(body('Get_Items_—_Student_Profiles')?['value'])` |
| `studentEnrollmentsJSON` | `json(body('Get_Items_—_Student_Enrollments')?['value'])` |
| `interventionHistoryJSON` | `json(body('Get_Items_—_Intervention_History')?['value'])` |
| `degreePlansJSON` | `json(body('Get_Items_—_Degree_Plans')?['value'])` |
| `alertRulesJSON` | `json(body('Get_Items_—_Alert_Rules')?['value'])` |

> **Tip:** To enter an expression, click in the Value field → switch to the **Expression** tab → paste the expression → click **OK**.

> **Alternative (simpler):** If expressions cause issues, use the **Dynamic content** picker. Click in the Value field → Dynamic content → select **body** from each Get Items action. The output will be the raw JSON array. Rename the outputs to match the names above.

### Save and Test

1. Click **Save** in the top-right corner
2. Click **Test** → **Manually** → enter a test query like `"Show me at-risk students"`
3. Verify all 6 Get Items actions return data (green checkmarks)
4. Verify the Respond to Copilot action shows 6 JSON strings

### Connect to Copilot Studio

1. Open [Copilot Studio](https://copilotstudio.microsoft.com)
2. Open the **UniGuard** agent
3. In any topic, add an action node → **Call an action** → select **GetStudentContext**
4. Map the input: `query` ← `Activity.Text` (the user's message)
5. Save the 6 output variables — the agent's system prompt and generative AI nodes use them for context

---

## Flow 2: SendOutreach (Email + Log)

This flow lets the agent draft and send outreach emails on behalf of faculty/advisors, then logs the intervention.

### Create the Flow

1. In the **UniGuard** solution, click **New** → **Automation** → **Cloud flow** → **Instant**
2. Flow name: `SendOutreach`
3. Trigger: **Run a flow from Copilot**
4. Click **Create**

### Add the Inputs

Click **+ Add an input** three times:

| Input | Type | Description |
|---|---|---|
| `studentEmail` | Text | The student's email address |
| `subject` | Text | Email subject line |
| `body` | Text | Email body content |

### Action 1: Send the Email

1. Click **+ New step** → search for **Office 365 Outlook** → select **Send an email (V2)**
2. Fill in the fields:

| Field | Value |
|---|---|
| **To** | `studentEmail` (dynamic content from trigger) |
| **Subject** | `subject` (dynamic content from trigger) |
| **Body** | `body` (dynamic content from trigger) |

3. Rename this action: `Send Outreach Email`

### Action 2: Log to Intervention History

1. Click **+ New step** → search for **SharePoint** → select **Create item**
2. Fill in:

| Field | Value |
|---|---|
| **Site Address** | `https://m365cpi30732412.sharepoint.com/sites/UniGuard` |
| **List Name** | `Intervention History` |
| **Title** | `Outreach: @{triggerBody()?['text_1']}` (or use: `Outreach email sent`) |
| **InterventionType** | `Email` |
| **Notes** | `Subject: @{triggerBody()?['text_1']}` — use the `subject` dynamic content |
| **Outcome** | `Pending` |

3. Rename this action: `Log to Intervention History`

### Action 3: Log to Audit Log

1. Click **+ New step** → search for **SharePoint** → select **Create item**
2. Fill in:

| Field | Value |
|---|---|
| **Site Address** | `https://m365cpi30732412.sharepoint.com/sites/UniGuard` |
| **List Name** | `Audit Log` |
| **Title** | `Outreach email sent` |
| **ActionType** | `Outreach` |
| **Details** | `Sent to: @{triggerBody()?['text']} | Subject: @{triggerBody()?['text_1']}` |
| **Timestamp** | `utcNow()` (expression) |

3. Rename this action: `Log to Audit Log`

### Return Confirmation

1. Click **+ New step** → **Respond to Copilot**
2. Add one text output:

| Output Name | Value |
|---|---|
| `confirmationMessage` | `Outreach email sent to @{triggerBody()?['text']} with subject: @{triggerBody()?['text_1']}. Logged to Intervention History and Audit Log.` |

### Save and Test

1. Click **Save**
2. Test with sample values:
   - studentEmail: `student@contoso.com`
   - subject: `Checking in — BIO301`
   - body: `Hi Sofia, I noticed you've missed a few classes. Let me know if there's anything I can help with.`
3. Verify: email sent, Intervention History item created, Audit Log item created

### Connect to Copilot Studio

1. In any topic where the agent offers to send outreach (e.g., the "Student Outreach" topic):
2. Add a **Call an action** node → select **SendOutreach**
3. Map inputs from the conversation variables the agent has composed

---

## Flow 3: EarlyAlertScan (Scheduled) — Phase 2

> ⚠️ **Phase 2 — add when ready.** This flow runs on a schedule and proactively flags students who meet alert rule criteria. It does not require a user to be chatting with the agent.

### Design Overview

| Setting | Value |
|---|---|
| **Type** | Scheduled cloud flow |
| **Frequency** | Every 6 hours |
| **Solution** | UniGuard |
| **Name** | EarlyAlertScan |

### Planned Actions

```
┌──────────────────────────────────────────────────────────────┐
│  Trigger: Recurrence (every 6 hours)                         │
│                                                              │
│  1. Get Items — Alert Rules                                  │
│     Site: https://m365cpi30732412.sharepoint.com/sites/…     │
│     List: Alert Rules                                        │
│     Filter: IsActive eq 1                                    │
│                                                              │
│  2. Get Items — Student Enrollments                          │
│     Top Count: 5000                                          │
│                                                              │
│  3. Get Items — Student Profiles                             │
│     Top Count: 2000                                          │
│                                                              │
│  4. Apply to each: Alert Rule                                │
│     ├─ Apply to each: Enrollment                             │
│     │  ├─ Condition: evaluate metric vs threshold            │
│     │  │  e.g., EngagementScore < 40                         │
│     │  │                                                     │
│     │  │  IF YES:                                            │
│     │  │  ├─ Update Student Profile: RiskLevel = rule's      │
│     │  │  │  severity                                        │
│     │  │  ├─ Create item in Intervention History:            │
│     │  │  │  Type=EarlyAlert, auto-generated note            │
│     │  │  └─ Create item in Audit Log                        │
│     │  │                                                     │
│     │  │  IF NO: skip                                        │
│     │  └──────────────────────────────────────               │
│     └────────────────────────────────────────                │
│                                                              │
│  5. Get Items — User Roles (where Role = Advisor)            │
│     For each advisor, send a Teams adaptive card             │
│     summarizing newly flagged advisees                       │
│                                                              │
│  6. Log to Audit Log: "EarlyAlertScan completed.             │
│     X students flagged."                                     │
└──────────────────────────────────────────────────────────────┘
```

### Why Phase 2?

- Requires careful testing of threshold logic to avoid false positives
- Needs real engagement data flowing in first
- The GetStudentContext flow + agent topics handle on-demand alerts for now
- The scheduled scan adds proactive monitoring once the system is stable

---

## Summary

| Flow | Type | Status | Purpose |
|---|---|---|---|
| **GetStudentContext** | Instant (Copilot trigger) | ✅ Build now | Main data retrieval — 6 lists → agent context |
| **SendOutreach** | Instant (Copilot trigger) | ✅ Build now | Send email + log intervention + audit trail |
| **EarlyAlertScan** | Scheduled (every 6 hrs) | 🔜 Phase 2 | Proactive risk detection + advisor notifications |

---

## Troubleshooting

| Issue | Fix |
|---|---|
| Get Items returns empty | Verify the SharePoint site URL and list name are exact matches |
| Expression errors in Respond to Copilot | Switch to Dynamic Content picker instead of Expression tab |
| Flow not showing in Copilot Studio | Make sure the flow is in the same **Solution** as the agent |
| SendOutreach fails on "Send email" | Check that the Office 365 Outlook connection is authorized |
| Top Count not enough | Increase Top Count or add OData filter queries to narrow results |
| Timeout on large lists | Add **Filter Query** (OData) to Get Items to reduce rows returned |
