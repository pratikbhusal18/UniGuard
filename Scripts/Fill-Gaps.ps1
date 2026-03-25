$siteId = "m365cpi30732412.sharepoint.com,b04a5893-9fdc-49c4-ab1a-f97fa0271ddc,aff2f30c-417c-4214-8026-99f3e1d78794"
$lists = (Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists" -Method GET).value

# --- 1. Add missing columns to Student Profiles ---
$spId = ($lists | Where-Object { $_.displayName -eq "Student Profiles" }).id
foreach ($col in @(
    @{ displayName="CareerGoal"; name="CareerGoal"; text=@{ allowMultipleLines=$true; textType="plain" } }
    @{ displayName="EngagementScore"; name="EngagementScore"; number=@{} }
    @{ displayName="Track"; name="Track"; text=@{} }
    @{ displayName="PriorGPA"; name="PriorGPA"; number=@{} }
    @{ displayName="YearLevel"; name="YearLevel"; choice=@{ choices=@("Freshman","Sophomore","Junior","Senior","Graduate") } }
)) {
    try {
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$spId/columns" -Body ($col | ConvertTo-Json -Depth 5) -ContentType "application/json" | Out-Null
        Write-Host ("  Column added - " + $col.displayName)
    } catch { Write-Host ("  Column exists - " + $col.displayName) }
}

# --- 2. Update Student Profiles ---
$spItems = (Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$spId/items?`$expand=fields" -Method GET).value
$updates = @{
    "STU001" = @{ CareerGoal="Software engineering at a major tech company"; EngagementScore=92; Track="Software Development"; PriorGPA=3.4; YearLevel="Junior" }
    "STU002" = @{ CareerGoal="Start my own business after graduation"; EngagementScore=61; Track="Entrepreneurship"; PriorGPA=2.5; YearLevel="Sophomore" }
    "STU003" = @{ CareerGoal="Medical school - want to become a surgeon"; EngagementScore=34; Track="Pre-Med"; PriorGPA=2.4; YearLevel="Junior" }
    "STU004" = @{ CareerGoal="Work in aerospace engineering, possibly SpaceX or NASA"; EngagementScore=95; Track="Aerospace"; PriorGPA=3.7; YearLevel="Senior" }
    "STU005" = @{ CareerGoal="Clinical psychology - want to help people with anxiety disorders"; EngagementScore=68; Track="Clinical"; PriorGPA=3.0; YearLevel="Sophomore" }
}
foreach ($item in $spItems) {
    $sid = $item.fields.StudentID
    if ($updates.ContainsKey($sid)) {
        Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$spId/items/$($item.id)/fields" -Body ($updates[$sid] | ConvertTo-Json -Compress) -ContentType "application/json" | Out-Null
        Write-Host ("  Updated " + $sid)
    }
}

# --- 3. Populate Degree Plans ---
Write-Host "Adding Degree Plans..."
$dpId = ($lists | Where-Object { $_.displayName -eq "Degree Plans" }).id
$plans = @(
    @{ Title="Biology BS - Pre-Med Track"; Major="Biology"; Track="Pre-Med"; RequiredCourses="BIO101,BIO201,BIO301,BIO310,CHEM101,CHEM201,CHEM301,PHY101,PHY102,MATH101,MATH201,ENG101,ENG102,SOC101,BIO490"; ElectiveCredits=12; TotalCredits=120; Notes="MCAT prep recommended. Senior thesis required." }
    @{ Title="Computer Science BS"; Major="Computer Science"; Track="Software Development"; RequiredCourses="CS101,CS201,CS301,CS401,MATH101,MATH201,MATH301,ENG101,ENG102,PHY101,CS310,CS320,CS490"; ElectiveCredits=15; TotalCredits=120; Notes="Internship strongly recommended." }
    @{ Title="Business Administration BS"; Major="Business Admin"; Track="Entrepreneurship"; RequiredCourses="BUS101,BUS201,BUS301,BUS401,ECON101,ECON201,MATH101,ENG101,ENG102,ACC101,ACC201,BUS490"; ElectiveCredits=18; TotalCredits=120; Notes="Business plan capstone." }
    @{ Title="Psychology BS - Clinical Track"; Major="Psychology"; Track="Clinical"; RequiredCourses="PSY101,PSY201,PSY301,PSY310,PSY320,PSY401,MATH101,ENG101,ENG102,BIO101,SOC101,PSY490"; ElectiveCredits=15; TotalCredits=120; Notes="Research methods required. GRE prep for graduate school." }
    @{ Title="Engineering BS - Aerospace"; Major="Engineering"; Track="Aerospace"; RequiredCourses="ENG101,ENG102,MATH101,MATH201,MATH301,PHY101,PHY102,CS101,ENGR101,ENGR201,ENGR301,ENGR401,ENGR490"; ElectiveCredits=12; TotalCredits=128; Notes="Senior design project. FE exam preparation recommended." }
)
foreach ($plan in $plans) {
    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$dpId/items" -Body (@{ fields=$plan } | ConvertTo-Json -Depth 5 -Compress) -ContentType "application/json" | Out-Null
    Write-Host ("  Plan - " + $plan.Title)
}

# --- 4. Populate Intervention History ---
Write-Host "Adding Intervention History..."
$ihId = ($lists | Where-Object { $_.displayName -eq "Intervention History" }).id
$interventions = @(
    @{ Title="Email about BIO301 attendance"; StudentRef="STU003"; InterventionType="Email"; Notes="Sent personalized email about missing 3 BIO301 classes. No response received."; Outcome="NoChange" }
    @{ Title="Advisor meeting - academic plan"; StudentRef="STU003"; InterventionType="Meeting"; Notes="Met with Amber to discuss declining grades. She mentioned personal issues at home. Agreed to weekly check-ins."; Outcome="Pending" }
    @{ Title="Referred to tutoring center"; StudentRef="STU003"; InterventionType="Referral"; Notes="Referred Amber to STEM tutoring center for MATH201 and BIO301. She has not visited yet."; Outcome="NoChange" }
    @{ Title="Email about late BUS201 submissions"; StudentRef="STU002"; InterventionType="Email"; Notes="Contacted Dakota about 2 late BUS201 assignments. He responded saying he would catch up."; Outcome="Improved" }
)
foreach ($iv in $interventions) {
    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$ihId/items" -Body (@{ fields=$iv } | ConvertTo-Json -Depth 5 -Compress) -ContentType "application/json" | Out-Null
    Write-Host ("  Intervention - " + $iv.Title)
}

Write-Host "ALL GAPS FILLED!" -ForegroundColor Green
