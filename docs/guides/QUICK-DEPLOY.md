# 🎓 UniGuard — Quick Deploy Guide

**Total time: ~10 minutes**

---

## Prerequisites

- Microsoft 365 Education E3/E5
- Copilot Studio license
- Power Automate Premium
- PowerShell 7 + Microsoft.Graph module (`Install-Module Microsoft.Graph -Scope CurrentUser`)

---

## Step 1: Provision SharePoint Brain (~5 min)

```powershell
cd UniGuard\Scripts
.\Provision-UniGuard.ps1 -OwnerEmail "admin@yourtenant.onmicrosoft.com"
```

✅ Creates: SharePoint site, 9 lists, sample students, courses, degree plans, alert rules

---

## Step 2: Create Entra Groups (~2 min)

```powershell
Connect-MgGraph -Scopes "Group.ReadWrite.All","GroupMember.ReadWrite.All"

# Create groups
foreach ($g in @("UniGuard-Faculty","UniGuard-Advisors","UniGuard-Students")) {
    New-MgGroup -DisplayName $g -MailEnabled:$false -MailNickname $g.Replace("-","") -SecurityEnabled
}

# Add users to groups (replace with your users)
# Get group IDs with: Get-MgGroup -Filter "displayName eq 'UniGuard-Faculty'" | Select Id
# Add members with: New-MgGroupMember -GroupId <groupId> -DirectoryObjectId <userId>
```

---

## Step 3: Import Solution (~2 min)

1. Go to **[make.powerapps.com](https://make.powerapps.com)** → Solutions → **Import solution**
2. Upload `UniGuard_Solution.zip` from this repo
3. Map connections when prompted (SharePoint, Office 365 Users)
4. Click **Import**

---

## Step 4: Configure & Publish (~3 min)

1. Open the imported solution → find **UniGuard - GetStudentContext** flow
2. Edit → update the SharePoint site URL in each action to your site
3. Save and turn on the flow

4. Go to **[copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)**
5. Open the **UniGuard** agent
6. Update Knowledge source → your SharePoint site URL
7. Click **Publish** → enable **Teams** channel

---

## Step 5: Test

In Teams, chat with UniGuard:
- `Show me at-risk students`
- `How is Amber Rodriguez doing?`
- `What does she need to graduate?`

---

## Done! 🎉

For full documentation see:
- [DEPLOYMENT.md](DEPLOYMENT.md) — detailed guide with troubleshooting
- [SETUP.md](SETUP.md) — SharePoint list schemas
- [PRIVACY-DESIGN.md](PRIVACY-DESIGN.md) — role-based access controls
- [USE-CASES-v2.md](USE-CASES-v2.md) — conversation examples
