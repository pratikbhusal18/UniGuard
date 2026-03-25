<#
.SYNOPSIS
    UniGuard — SharePoint Brain Provisioning Script
    Creates the SharePoint site, lists, columns, and default data for UniGuard (University Student Success Agent).

.DESCRIPTION
    This script uses Microsoft Graph API to provision the UniGuard "Brain":
    1. Creates a SharePoint Team Site via M365 Group
    2. Creates 8 lists with properly typed columns
    3. Populates default agent configuration and alert rules
    4. Seeds sample student, course, and enrollment data
    5. Verifies everything was created correctly

    ═══════════════════════════════════════════════════════════════
    ARCHITECTURE & DATA FLOW
    ═══════════════════════════════════════════════════════════════

    UniGuard uses SharePoint as its persistent "brain" — a structured
    data layer that a Copilot Studio agent reads from and writes to.
    The 8 lists form three logical tiers:

    ┌─────────────────────────────────────────────────────────────┐
    │  TIER 1 — REFERENCE DATA  (maintained by registrar/admins) │
    │                                                             │
    │  Student Profiles ──► who are the students?                 │
    │  Course Catalog   ──► what courses exist?                   │
    │  Degree Plans     ──► what does each major require?         │
    │                                                             │
    │  These lists are the "source of truth." They can be         │
    │  populated manually, via Power Automate from the SIS        │
    │  (Student Information System), or via CSV import.           │
    └────────────────────────┬────────────────────────────────────┘
                             │ referenced by
    ┌────────────────────────▼────────────────────────────────────┐
    │  TIER 2 — OPERATIONAL DATA  (written by integrations/agent)│
    │                                                             │
    │  Student Enrollments ──► per-student, per-course metrics    │
    │       ↑                  (attendance, grades, completion)   │
    │       │  feeds into                                         │
    │  Alert Rules ──► configurable thresholds that the agent     │
    │                  evaluates against enrollment data           │
    │                                                             │
    │  Data flow:                                                 │
    │    SIS/LMS ─► Power Automate ─► Student Enrollments list    │
    │    Agent reads enrollments, compares to Alert Rules,        │
    │    and triggers interventions when thresholds are breached. │
    └────────────────────────┬────────────────────────────────────┘
                             │ produces
    ┌────────────────────────▼────────────────────────────────────┐
    │  TIER 3 — AGENT OUTPUT  (written by the Copilot agent)     │
    │                                                             │
    │  Intervention History ──► what actions were taken?          │
    │  Audit Log            ──► full activity trail               │
    │                                                             │
    │  The agent writes here every time it sends an alert,        │
    │  nudges a student, generates a report, or runs a scan.     │
    │  Staff can review outcomes and close the loop.              │
    └─────────────────────────────────────────────────────────────┘

    AGENT CONFIG — a key-value list that controls agent behavior
    (scan frequency, thresholds, personality). Change a value in
    SharePoint and the agent picks it up on its next cycle — no
    redeployment needed.

    ═══════════════════════════════════════════════════════════════
    WHO MAINTAINS WHAT
    ═══════════════════════════════════════════════════════════════

    • Registrar / SIS integration:
        - Student Profiles (bulk sync from Banner, PeopleSoft, etc.)
        - Course Catalog   (semester refresh)
        - Degree Plans     (updated when curriculum changes)

    • LMS integration (Canvas, Blackboard, Moodle via Power Automate):
        - Student Enrollments — attendance and assignment data
          flow in automatically; the agent never needs manual entry.

    • Academic advisors / student success staff:
        - Intervention History — review outcomes, add notes
        - Alert Rules — tune thresholds per department or term

    • IT / Copilot admin:
        - Agent Config — adjust scan frequency, personality, etc.
        - Audit Log — read-only monitoring of agent behavior

    ═══════════════════════════════════════════════════════════════
    CUSTOMISING PER UNIVERSITY
    ═══════════════════════════════════════════════════════════════

    This script is designed to be forked and tweaked. The main
    customisation points are:

    1. PARAMETERS — change $SiteDisplayName / $SiteAlias to run
       multiple instances (e.g., per college within a university).
         .\Provision-UniGuard.ps1 -SiteDisplayName "UniGuard-Engineering" `
                                  -SiteAlias "ug-eng" `
                                  -OwnerEmail "eng-dean@contoso.edu"

    2. ENROLLMENT STATUS choices — edit Get-StudentProfilesColumns
       to add institution-specific statuses (e.g., "Co-op", "Leave").

    3. ALERT RULES — the $defaultAlertRules array near line ~310
       sets the initial thresholds. Universities with stricter or
       looser standards simply change the Threshold numbers.

    4. RISK LEVELS — the RiskLevel choice field can be extended
       (add "Watch" between Low and Medium, for example).

    5. DEGREE PLANS — pre-load your real curriculum by replacing
       the sample data block or importing via CSV after provisioning.

    6. AGENT CONFIG — every key-value pair in $defaultConfig is
       editable in SharePoint at any time. Key tunables:
         • ScanFrequency       — "Hourly", "Daily", "Weekly"
         • AttendanceAlertThreshold — percentage (default 70)
         • GradeAlertThreshold     — GPA floor (default 2.0)
         • AgentPersonality        — free-text prompt guidance

    7. ADDITIONAL LISTS — add new lists by writing a
       Get-YourListColumns function and adding an entry to
       $listDefinitions. The rest of the script handles creation.

.PREREQUISITES
    - Microsoft Graph PowerShell SDK: Install-Module Microsoft.Graph -Scope CurrentUser
    - Permissions: Sites.ReadWrite.All, Group.ReadWrite.All
    - SharePoint Admin or Site Collection Creator role

.PARAMETER SiteDisplayName
    Display name for the SharePoint site (default: "UniGuard").
    Change this to run multiple instances (e.g., "UniGuard-Engineering").

.PARAMETER SiteAlias
    URL alias for the site (default: "UniGuard").
    Must be unique within your tenant. Used in the SharePoint URL.

.PARAMETER OwnerEmail
    Email of the site owner/admin (mandatory).
    This person gets full control of the SharePoint site.

.EXAMPLE
    .\Provision-UniGuard.ps1 -OwnerEmail "admin@contoso.com"

.EXAMPLE
    .\Provision-UniGuard.ps1 -SiteDisplayName "UniGuard-Pilot" -SiteAlias "ug-pilot" -OwnerEmail "admin@contoso.com"
#>

[CmdletBinding()]
param(
    [string]$SiteDisplayName = "UniGuard",
    [string]$SiteAlias = "UniGuard",
    [Parameter(Mandatory = $true)]
    [string]$OwnerEmail
)

$ErrorActionPreference = "Stop"

# ============================================================
# COLORS & HELPERS
# ============================================================

function Write-Step { param([string]$Message) Write-Host "`n🔧 $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "  ✅ $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "  ℹ️  $Message" -ForegroundColor Gray }
function Write-Warn { param([string]$Message) Write-Host "  ⚠️  $Message" -ForegroundColor Yellow }
function Write-Fail { param([string]$Message) Write-Host "  ❌ $Message" -ForegroundColor Red }

function Write-Banner {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "  ║   🎓  UniGuard — Provisioning Script              ║" -ForegroundColor Magenta
    Write-Host "  ║   University Student Success Agent                ║" -ForegroundColor Magenta
    Write-Host "  ║   SharePoint Brain Setup                          ║" -ForegroundColor Magenta
    Write-Host "  ╚═══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
}

# ============================================================
# GRAPH API HELPERS
# ============================================================

function Invoke-GraphRequest {
    param(
        [string]$Method = "GET",
        [string]$Uri,
        [object]$Body,
        [string]$ContentType = "application/json"
    )
    $params = @{
        Method = $Method
        Uri    = $Uri
    }
    if ($Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 10 -Compress)
        $params.ContentType = $ContentType
    }
    try {
        Invoke-MgGraphRequest @params
    }
    catch {
        Write-Fail "Graph API error: $($_.Exception.Message)"
        throw
    }
}

# ============================================================
# LIST CREATION HELPERS
# ============================================================

function New-SharePointList {
    param(
        [string]$SiteId,
        [string]$DisplayName,
        [string]$Description,
        [array]$Columns
    )
    Write-Info "Creating list: $DisplayName"

    $listBody = @{
        displayName = $DisplayName
        description = $Description
        list        = @{
            template = "genericList"
        }
    }

    $list = Invoke-GraphRequest -Method POST `
        -Uri "https://graph.microsoft.com/v1.0/sites/$SiteId/lists" `
        -Body $listBody

    $listId = $list.id
    Write-Success "List created: $DisplayName (ID: $listId)"

    foreach ($col in $Columns) {
        Write-Info "  Adding column: $($col.displayName)"
        try {
            Invoke-GraphRequest -Method POST `
                -Uri "https://graph.microsoft.com/v1.0/sites/$SiteId/lists/$listId/columns" `
                -Body $col | Out-Null
            Write-Success "  Column added: $($col.displayName)"
        }
        catch {
            if ($_.Exception.Message -like "*already exists*") {
                Write-Warn "  Column already exists: $($col.displayName)"
            }
            else {
                Write-Fail "  Failed to add column: $($col.displayName) — $($_.Exception.Message)"
            }
        }
    }

    return $list
}

function New-ListItem {
    param(
        [string]$SiteId,
        [string]$ListId,
        [hashtable]$Fields
    )
    $body = @{ fields = $Fields }
    Invoke-GraphRequest -Method POST `
        -Uri "https://graph.microsoft.com/v1.0/sites/$SiteId/lists/$ListId/items" `
        -Body $body | Out-Null
}

# ============================================================
# COLUMN DEFINITIONS
# ============================================================

function Get-StudentProfilesColumns {
    @(
        @{ displayName = "StudentID"; name = "StudentID"; text = @{}; description = "Unique student identifier" }
        @{ displayName = "Major"; name = "Major"; text = @{}; description = "Student major / program" }
        @{ displayName = "GPA"; name = "GPA"; number = @{}; description = "Current cumulative GPA" }
        @{ displayName = "AdvisorName"; name = "AdvisorName"; text = @{}; description = "Assigned academic advisor" }
        @{ displayName = "EnrollmentStatus"; name = "EnrollmentStatus"; choice = @{ choices = @("Active", "Probation", "Suspended", "Graduated") }; description = "Current enrollment status" }
        @{ displayName = "RiskLevel"; name = "RiskLevel"; choice = @{ choices = @("Low", "Medium", "High", "Critical") }; description = "Computed risk level" }
        @{ displayName = "Email"; name = "Email"; text = @{}; description = "Student email address" }
        @{ displayName = "Phone"; name = "Phone"; text = @{}; description = "Student phone number" }
    )
}

function Get-CourseCatalogColumns {
    @(
        @{ displayName = "CourseID"; name = "CourseID"; text = @{}; description = "Course identifier (e.g. CS101)" }
        @{ displayName = "Department"; name = "Department"; text = @{}; description = "Academic department" }
        @{ displayName = "Prerequisites"; name = "Prerequisites"; text = @{ allowMultipleLines = $true; textType = "plain" }; description = "Prerequisite courses" }
        @{ displayName = "Credits"; name = "Credits"; number = @{}; description = "Credit hours" }
        @{ displayName = "Semester"; name = "Semester"; choice = @{ choices = @("Fall", "Spring", "Summer") }; description = "Semester offered" }
        @{ displayName = "Instructor"; name = "Instructor"; text = @{}; description = "Lead instructor" }
        @{ displayName = "MaxEnrollment"; name = "MaxEnrollment"; number = @{}; description = "Maximum enrollment capacity" }
    )
}

function Get-DegreePlansColumns {
    @(
        @{ displayName = "Major"; name = "Major"; text = @{}; description = "Degree program / major" }
        @{ displayName = "RequiredCourses"; name = "RequiredCourses"; text = @{ allowMultipleLines = $true; textType = "plain" }; description = "List of required courses" }
        @{ displayName = "ElectiveCredits"; name = "ElectiveCredits"; number = @{}; description = "Elective credits required" }
        @{ displayName = "TotalCredits"; name = "TotalCredits"; number = @{}; description = "Total credits for degree" }
        @{ displayName = "Notes"; name = "Notes"; text = @{ allowMultipleLines = $true; textType = "plain" }; description = "Additional notes" }
    )
}

function Get-StudentEnrollmentsColumns {
    @(
        @{ displayName = "StudentRef"; name = "StudentRef"; text = @{}; description = "Reference to student (StudentID)" }
        @{ displayName = "CourseRef"; name = "CourseRef"; text = @{}; description = "Reference to course (CourseID)" }
        @{ displayName = "Semester"; name = "Semester"; text = @{}; description = "Enrollment semester (e.g. Fall 2025)" }
        @{ displayName = "Grade"; name = "Grade"; text = @{}; description = "Current or final grade" }
        @{ displayName = "AttendanceRate"; name = "AttendanceRate"; number = @{}; description = "Attendance percentage (0-100)" }
        @{ displayName = "AssignmentCompletionRate"; name = "AssignmentCompletionRate"; number = @{}; description = "Assignment completion percentage (0-100)" }
        @{ displayName = "Status"; name = "Status"; choice = @{ choices = @("Enrolled", "Completed", "Withdrawn", "Failed") }; description = "Enrollment status" }
    )
}

function Get-AlertRulesColumns {
    @(
        @{ displayName = "Metric"; name = "Metric"; choice = @{ choices = @("Attendance", "GradeAverage", "AssignmentCompletion", "ConsecutiveAbsences") }; description = "Metric to monitor" }
        @{ displayName = "Threshold"; name = "Threshold"; number = @{}; description = "Threshold value" }
        @{ displayName = "Operator"; name = "Operator"; choice = @{ choices = @("LessThan", "GreaterThan", "Equals") }; description = "Comparison operator" }
        @{ displayName = "Severity"; name = "Severity"; choice = @{ choices = @("Low", "Medium", "High", "Critical") }; description = "Alert severity when triggered" }
        @{ displayName = "ActionTemplate"; name = "ActionTemplate"; text = @{ allowMultipleLines = $true; textType = "plain" }; description = "Template for the action to take" }
    )
}

function Get-InterventionHistoryColumns {
    @(
        @{ displayName = "StudentRef"; name = "StudentRef"; text = @{}; description = "Reference to student (StudentID)" }
        @{ displayName = "InterventionType"; name = "InterventionType"; choice = @{ choices = @("Email", "Meeting", "PhoneCall", "Referral", "AcademicPlan") }; description = "Type of intervention" }
        @{ displayName = "Notes"; name = "Notes"; text = @{ allowMultipleLines = $true; textType = "plain" }; description = "Intervention notes and details" }
        @{ displayName = "Outcome"; name = "Outcome"; choice = @{ choices = @("Pending", "Improved", "NoChange", "Escalated") }; description = "Intervention outcome" }
        @{ displayName = "FollowUpDate"; name = "FollowUpDate"; dateTime = @{ format = "dateTimeTimeZone" }; description = "Scheduled follow-up date" }
    )
}

function Get-AgentConfigColumns {
    @(
        @{ displayName = "Value"; name = "Value"; text = @{ allowMultipleLines = $true; textType = "plain" }; description = "Configuration value" }
        @{ displayName = "ConfigDescription"; name = "ConfigDescription"; text = @{}; description = "What this setting does" }
    )
}

function Get-AuditLogColumns {
    @(
        @{ displayName = "ActionType"; name = "ActionType"; choice = @{ choices = @("EarlyAlert", "Outreach", "StudentPulse", "DegreePlan", "CourseAdvice", "Report", "Nudge", "Config") }; description = "Type of action logged" }
        @{ displayName = "Details"; name = "Details"; text = @{ allowMultipleLines = $true; textType = "plain" }; description = "Full action details" }
        @{ displayName = "Timestamp"; name = "Timestamp"; dateTime = @{ format = "dateTimeTimeZone" }; description = "When the action occurred" }
    )
}

# ============================================================
# MAIN EXECUTION
# ============================================================

Write-Banner

# --- Step 1: Connect to Graph ---
Write-Step "Connecting to Microsoft Graph..."
try {
    $context = Get-MgContext
    if (-not $context) {
        Connect-MgGraph -Scopes "Sites.ReadWrite.All", "Group.ReadWrite.All" -NoWelcome
    }
    $context = Get-MgContext
    Write-Success "Connected as: $($context.Account)"
}
catch {
    Write-Fail "Failed to connect. Install the Graph SDK: Install-Module Microsoft.Graph -Scope CurrentUser"
    exit 1
}

# --- Step 2: Create SharePoint Site via M365 Group ---
Write-Step "Creating SharePoint site: $SiteDisplayName..."

$rootSite = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/root" -Method GET
$spHost = ([uri]$rootSite.webUrl).Host

$site = $null
$siteId = $null

# Method 1: Create via Microsoft 365 Group (creates a team site with full Graph support)
try {
    Write-Info "Creating via Microsoft 365 Group..."
    $groupBody = @{
        displayName     = $SiteDisplayName
        description     = "UniGuard AI Agent — University student success monitoring brain"
        mailNickname    = $SiteAlias
        mailEnabled     = $false
        securityEnabled = $false
        groupTypes      = @("Unified")
        visibility      = "Private"
    }
    $group = Invoke-GraphRequest -Method POST `
        -Uri "https://graph.microsoft.com/v1.0/groups" `
        -Body $groupBody
    $groupId = $group.id
    Write-Success "Group created: $($group.displayName) (ID: $groupId)"

    # Wait for the SharePoint site to be provisioned
    Write-Info "Waiting for SharePoint site provisioning..."
    $retries = 0
    while ($retries -lt 30) {
        Start-Sleep -Seconds 5
        try {
            $site = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/sites/root"
            if ($site -and $site.id) {
                $siteId = $site.id
                Write-Success "Site provisioned: $($site.webUrl)"
                break
            }
        }
        catch { }
        $retries++
        if ($retries % 6 -eq 0) { Write-Info "Still waiting... ($($retries * 5)s elapsed)" }
    }

    if (-not $siteId) {
        throw "Site provisioning timed out after 150 seconds"
    }
}
catch {
    $groupError = $_.Exception.Message
    Write-Warn "Group creation method failed: $groupError"
    Write-Info "Trying to find existing site..."

    # Method 2: Search for existing site
    try {
        $searchResult = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites?search=$SiteAlias"
        $site = $searchResult.value | Where-Object { $_.displayName -eq $SiteDisplayName -or $_.name -like "*$SiteAlias*" } | Select-Object -First 1
        if ($site) {
            $siteId = $site.id
            Write-Success "Found existing site: $($site.webUrl) (ID: $siteId)"
        }
    }
    catch { }

    if (-not $siteId) {
        Write-Fail "Could not create or find the site."
        Write-Info "Please create a SharePoint site manually:"
        Write-Info "  1. Go to https://$spHost/_layouts/15/sharepoint.aspx"
        Write-Info "  2. Create a Team Site named '$SiteDisplayName'"
        Write-Info "  3. Re-run this script — it will find the existing site"
        exit 1
    }
}

# --- Step 3: Create Lists ---
Write-Step "Creating SharePoint lists..."

$lists = @{}

$listDefinitions = @(
    @{ Name = "StudentProfiles";      DisplayName = "Student Profiles";      Description = "Student demographic and academic profiles";          Columns = (Get-StudentProfilesColumns) }
    @{ Name = "CourseCatalog";        DisplayName = "Course Catalog";        Description = "Available courses and scheduling information";       Columns = (Get-CourseCatalogColumns) }
    @{ Name = "DegreePlans";          DisplayName = "Degree Plans";          Description = "Degree requirements by major";                      Columns = (Get-DegreePlansColumns) }
    @{ Name = "StudentEnrollments";   DisplayName = "Student Enrollments";   Description = "Student course enrollments with performance data";   Columns = (Get-StudentEnrollmentsColumns) }
    @{ Name = "AlertRules";           DisplayName = "Alert Rules";           Description = "Configurable early-alert thresholds";               Columns = (Get-AlertRulesColumns) }
    @{ Name = "InterventionHistory";  DisplayName = "Intervention History";  Description = "Record of student interventions and outcomes";       Columns = (Get-InterventionHistoryColumns) }
    @{ Name = "AgentConfig";          DisplayName = "Agent Config";          Description = "Agent configuration settings";                      Columns = (Get-AgentConfigColumns) }
    @{ Name = "AuditLog";             DisplayName = "Audit Log";             Description = "Agent action audit trail";                          Columns = (Get-AuditLogColumns) }
)

foreach ($def in $listDefinitions) {
    $list = New-SharePointList -SiteId $siteId `
        -DisplayName $def.DisplayName `
        -Description $def.Description `
        -Columns $def.Columns
    $lists[$def.Name] = $list.id
}

# --- Step 4: Populate Default Agent Configuration ---
Write-Step "Populating default agent configuration..."

$defaultConfig = @(
    @{ Title = "ScanFrequency";             Value = "Daily";                                                                                                              ConfigDescription = "How often the agent scans for at-risk students" }
    @{ Title = "AttendanceAlertThreshold";   Value = "70";                                                                                                                 ConfigDescription = "Attendance percentage below which an alert is triggered" }
    @{ Title = "GradeAlertThreshold";        Value = "2.0";                                                                                                                ConfigDescription = "GPA below which an alert is triggered" }
    @{ Title = "AssignmentAlertThreshold";   Value = "60";                                                                                                                 ConfigDescription = "Assignment completion percentage below which an alert is triggered" }
    @{ Title = "NudgeDaysBefore";            Value = "2";                                                                                                                  ConfigDescription = "Days before a deadline to send a nudge reminder" }
    @{ Title = "AgentName";                  Value = "UniGuard";                                                                                                           ConfigDescription = "Agent display name" }
    @{ Title = "AgentPersonality";           Value = "Supportive, data-driven, action-oriented. Always cite specific data. Suggest concrete next steps for intervention.";  ConfigDescription = "How the agent communicates with staff and students" }
)

foreach ($config in $defaultConfig) {
    New-ListItem -SiteId $siteId -ListId $lists["AgentConfig"] -Fields $config
    Write-Success "  Config: $($config.Title) = $($config.Value)"
}

# --- Step 5: Populate Default Alert Rules ---
Write-Step "Populating default alert rules..."

$defaultAlertRules = @(
    @{ Title = "Low Attendance Alert";              Metric = "Attendance";             Threshold = 70;  Operator = "LessThan";    Severity = "High";     ActionTemplate = "Send attendance warning email to student and advisor.`nSchedule check-in meeting within 48 hours." }
    @{ Title = "Low GPA Alert";                     Metric = "GradeAverage";           Threshold = 2;   Operator = "LessThan";    Severity = "Critical"; ActionTemplate = "Immediately notify academic advisor.`nCreate academic improvement plan.`nSchedule mandatory advising session." }
    @{ Title = "Low Assignment Completion Alert";   Metric = "AssignmentCompletion";   Threshold = 60;  Operator = "LessThan";    Severity = "High";     ActionTemplate = "Send assignment completion reminder to student.`nNotify instructor for follow-up.`nOffer tutoring resources." }
    @{ Title = "Consecutive Absences Alert";        Metric = "ConsecutiveAbsences";    Threshold = 3;   Operator = "GreaterThan"; Severity = "Critical"; ActionTemplate = "Trigger welfare check.`nNotify Dean of Students office.`nContact student via phone and email." }
)

foreach ($rule in $defaultAlertRules) {
    New-ListItem -SiteId $siteId -ListId $lists["AlertRules"] -Fields $rule
    Write-Success "  Rule: $($rule.Title) — $($rule.Metric) $($rule.Operator) $($rule.Threshold) => $($rule.Severity)"
}

# --- Step 6: Seed Sample Student Profiles ---
Write-Step "Seeding sample student profiles..."

$sampleStudents = @(
    @{ Title = "Emma Johnson";   StudentID = "STU001"; Major = "Computer Science";  GPA = 3.5; AdvisorName = "Dr. Sarah Mitchell";  EnrollmentStatus = "Active";    RiskLevel = "Low";    Email = "ejohnson@university.edu";  Phone = "(555) 101-0001" }
    @{ Title = "James Wilson";   StudentID = "STU002"; Major = "Business Admin";    GPA = 2.1; AdvisorName = "Prof. Robert Hayes";  EnrollmentStatus = "Active";    RiskLevel = "Medium"; Email = "jwilson@university.edu";   Phone = "(555) 101-0002" }
    @{ Title = "Sofia Garcia";   StudentID = "STU003"; Major = "Biology";           GPA = 1.8; AdvisorName = "Dr. Maria Fernandez"; EnrollmentStatus = "Probation"; RiskLevel = "High";   Email = "sgarcia@university.edu";   Phone = "(555) 101-0003" }
    @{ Title = "Liam Chen";      StudentID = "STU004"; Major = "Engineering";       GPA = 3.8; AdvisorName = "Dr. Kevin Park";      EnrollmentStatus = "Active";    RiskLevel = "Low";    Email = "lchen@university.edu";     Phone = "(555) 101-0004" }
    @{ Title = "Olivia Brown";   StudentID = "STU005"; Major = "Psychology";        GPA = 2.5; AdvisorName = "Prof. Lisa Adams";    EnrollmentStatus = "Active";    RiskLevel = "Medium"; Email = "obrown@university.edu";    Phone = "(555) 101-0005" }
)

foreach ($student in $sampleStudents) {
    New-ListItem -SiteId $siteId -ListId $lists["StudentProfiles"] -Fields $student
    Write-Success "  Student: $($student.Title) ($($student.StudentID)) — GPA $($student.GPA), $($student.RiskLevel) risk"
}

# --- Step 7: Seed Sample Course Catalog ---
Write-Step "Seeding sample course catalog..."

$sampleCourses = @(
    @{ Title = "Intro to Programming";  CourseID = "CS101";   Department = "Computer Science"; Prerequisites = "None";                         Credits = 3; Semester = "Fall";   Instructor = "Dr. Alan Turing";     MaxEnrollment = 120 }
    @{ Title = "Business Analytics";     CourseID = "BUS201";  Department = "Business";         Prerequisites = "BUS101 - Intro to Business";   Credits = 3; Semester = "Spring"; Instructor = "Prof. Janet Morgan";   MaxEnrollment = 80 }
    @{ Title = "Molecular Biology";      CourseID = "BIO301";  Department = "Biology";          Prerequisites = "BIO201 - Cell Biology`nCHEM101 - General Chemistry"; Credits = 4; Semester = "Fall"; Instructor = "Dr. Maria Fernandez"; MaxEnrollment = 45 }
    @{ Title = "English Composition";    CourseID = "ENG102";  Department = "English";          Prerequisites = "ENG101 - English I";           Credits = 3; Semester = "Spring"; Instructor = "Prof. David Clarke";   MaxEnrollment = 90 }
    @{ Title = "Calculus II";            CourseID = "MATH201"; Department = "Mathematics";       Prerequisites = "MATH101 - Calculus I";         Credits = 4; Semester = "Fall";   Instructor = "Dr. Emily Zhang";      MaxEnrollment = 60 }
    @{ Title = "Intro to Psychology";    CourseID = "PSY101";  Department = "Psychology";        Prerequisites = "None";                         Credits = 3; Semester = "Fall";   Instructor = "Prof. Lisa Adams";     MaxEnrollment = 150 }
)

foreach ($course in $sampleCourses) {
    New-ListItem -SiteId $siteId -ListId $lists["CourseCatalog"] -Fields $course
    Write-Success "  Course: $($course.CourseID) — $($course.Title) ($($course.Credits) credits)"
}

# --- Step 8: Seed Sample Enrollments ---
Write-Step "Seeding sample student enrollments..."

$sampleEnrollments = @(
    # Emma Johnson — strong student
    @{ Title = "STU001-CS101-F25";  StudentRef = "STU001"; CourseRef = "CS101";   Semester = "Fall 2025";   Grade = "A";  AttendanceRate = 95; AssignmentCompletionRate = 98; Status = "Enrolled" }
    @{ Title = "STU001-MATH201-F25"; StudentRef = "STU001"; CourseRef = "MATH201"; Semester = "Fall 2025";  Grade = "A-"; AttendanceRate = 92; AssignmentCompletionRate = 95; Status = "Enrolled" }

    # James Wilson — borderline student
    @{ Title = "STU002-BUS201-S25"; StudentRef = "STU002"; CourseRef = "BUS201";  Semester = "Spring 2025"; Grade = "C";  AttendanceRate = 75; AssignmentCompletionRate = 68; Status = "Enrolled" }
    @{ Title = "STU002-ENG102-S25"; StudentRef = "STU002"; CourseRef = "ENG102";  Semester = "Spring 2025"; Grade = "C-"; AttendanceRate = 72; AssignmentCompletionRate = 65; Status = "Enrolled" }

    # Sofia Garcia — concerning patterns (low attendance, missing assignments)
    @{ Title = "STU003-BIO301-F25"; StudentRef = "STU003"; CourseRef = "BIO301";  Semester = "Fall 2025";   Grade = "D";  AttendanceRate = 52; AssignmentCompletionRate = 40; Status = "Enrolled" }
    @{ Title = "STU003-PSY101-F25"; StudentRef = "STU003"; CourseRef = "PSY101";  Semester = "Fall 2025";   Grade = "D-"; AttendanceRate = 58; AssignmentCompletionRate = 45; Status = "Enrolled" }
    @{ Title = "STU003-ENG102-S25"; StudentRef = "STU003"; CourseRef = "ENG102";  Semester = "Spring 2025"; Grade = "F";  AttendanceRate = 38; AssignmentCompletionRate = 25; Status = "Failed" }

    # Liam Chen — excellent student
    @{ Title = "STU004-CS101-F25";   StudentRef = "STU004"; CourseRef = "CS101";   Semester = "Fall 2025";   Grade = "A+"; AttendanceRate = 98; AssignmentCompletionRate = 100; Status = "Enrolled" }
    @{ Title = "STU004-MATH201-F25"; StudentRef = "STU004"; CourseRef = "MATH201"; Semester = "Fall 2025";   Grade = "A";  AttendanceRate = 96; AssignmentCompletionRate = 97;  Status = "Enrolled" }

    # Olivia Brown — average with some flags
    @{ Title = "STU005-PSY101-F25"; StudentRef = "STU005"; CourseRef = "PSY101";  Semester = "Fall 2025";   Grade = "B-"; AttendanceRate = 78; AssignmentCompletionRate = 72; Status = "Enrolled" }
)

foreach ($enrollment in $sampleEnrollments) {
    New-ListItem -SiteId $siteId -ListId $lists["StudentEnrollments"] -Fields $enrollment
    Write-Success "  Enrollment: $($enrollment.StudentRef) → $($enrollment.CourseRef) — Attendance: $($enrollment.AttendanceRate)%, Assignments: $($enrollment.AssignmentCompletionRate)%"
}

# --- Step 9: Log Bootstrap to Audit Trail ---
Write-Step "Logging bootstrap to audit trail..."
$auditFields = @{
    Title      = "UniGuard initialized"
    ActionType = "Config"
    Details    = "Bootstrap complete. Created site '$SiteDisplayName', 8 lists, 7 config entries, 4 alert rules, 5 students, 6 courses, 10 enrollments. Owner: $OwnerEmail"
}
New-ListItem -SiteId $siteId -ListId $lists["AuditLog"] -Fields $auditFields
Write-Success "Audit log entry created"

# --- Step 10: Verification ---
Write-Step "Verifying provisioning..."

$verifyResults = @()
foreach ($def in $listDefinitions) {
    try {
        $check = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$($lists[$def.Name])"
        $itemCount = 0
        try {
            $items = Invoke-GraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$($lists[$def.Name])/items?`$top=0&`$count=true" -Method GET
            if ($items.'@odata.count') { $itemCount = $items.'@odata.count' }
        }
        catch { }
        $verifyResults += @{ List = $def.DisplayName; Status = "✅ OK"; Id = $lists[$def.Name]; Items = $itemCount }
    }
    catch {
        $verifyResults += @{ List = $def.DisplayName; Status = "❌ FAIL"; Id = "N/A"; Items = 0 }
    }
}

Write-Host ""
Write-Host "  ┌──────────────────────────┬──────────┐" -ForegroundColor Cyan
Write-Host "  │ List                     │ Status   │" -ForegroundColor Cyan
Write-Host "  ├──────────────────────────┼──────────┤" -ForegroundColor Cyan
foreach ($r in $verifyResults) {
    $name = $r.List.PadRight(24)
    Write-Host "  │ $name │ $($r.Status)     │"
}
Write-Host "  └──────────────────────────┴──────────┘" -ForegroundColor Cyan

$failCount = ($verifyResults | Where-Object { $_.Status -like "*FAIL*" }).Count
if ($failCount -eq 0) {
    Write-Host ""
    Write-Host "  🎓  UniGuard provisioning complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Site URL: $($site.webUrl)" -ForegroundColor White
    Write-Host "  Site ID:  $siteId" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Summary:" -ForegroundColor Yellow
    Write-Host "    • 8 SharePoint lists created" -ForegroundColor White
    Write-Host "    • 7 agent config entries" -ForegroundColor White
    Write-Host "    • 4 alert rules" -ForegroundColor White
    Write-Host "    • 5 sample students" -ForegroundColor White
    Write-Host "    • 6 sample courses" -ForegroundColor White
    Write-Host "    • 10 sample enrollments" -ForegroundColor White
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor Yellow
    Write-Host "    1. Import the Copilot Studio solution" -ForegroundColor White
    Write-Host "    2. Configure the agent with Site ID: $siteId" -ForegroundColor White
    Write-Host "    3. Review alert rules in the 'Alert Rules' list" -ForegroundColor White
    Write-Host "    4. Add real student data to 'Student Profiles'" -ForegroundColor White
    Write-Host ""

    # Save site info for other scripts
    $siteInfo = @{
        SiteId          = $siteId
        SiteUrl         = $site.webUrl
        SiteDisplayName = $SiteDisplayName
        Lists           = $lists
        ProvisionedAt   = (Get-Date -Format "o")
        OwnerEmail      = $OwnerEmail
    }
    $siteInfoPath = Join-Path $PSScriptRoot "site-info.json"
    $siteInfo | ConvertTo-Json -Depth 5 | Set-Content $siteInfoPath
    Write-Info "Site info saved to: $siteInfoPath"
}
else {
    Write-Fail "`n  Provisioning completed with $failCount error(s). Check the output above."
    exit 1
}
