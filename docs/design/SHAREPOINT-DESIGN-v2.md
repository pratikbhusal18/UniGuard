# 🎓 UniGuard — Revised SharePoint Design (v2)

## Why Redesign?

The v1 SharePoint brain was flat — 8 lists with no role awareness.
Now that we're using Entra ID groups for personas, the SharePoint
structure needs to support:
- Role-based data filtering
- Faculty ↔ Course mapping
- Advisor ↔ Student mapping
- Student self-service data

---

## Entra ID Groups (3)

| Group | Members | Purpose |
|---|---|---|
| `UniGuard-Faculty` | Professors, instructors | Sees their classes + students in those classes |
| `UniGuard-Advisors` | Academic advisors, counselors | Sees their advisee caseload across all classes |
| `UniGuard-Students` | Students | Sees only their own data |

---

## Revised SharePoint Lists (9 lists)

### Tier 1: People & Roles

#### 📋 1. User Roles (NEW — replaces role detection logic)
Maps M365 users to their UniGuard role and scope.

| Column | Type | Description |
|---|---|---|
| Title | Text | Display name |
| UserEmail | Text | M365 email (used for lookup) |
| Role | Choice: Faculty / Advisor / Student / Admin | Their persona |
| LinkedStudentID | Text | If Role=Student, their student ID |
| LinkedCourses | Text (multiline) | If Role=Faculty, comma-separated course IDs they teach |
| LinkedAdvisees | Text (multiline) | If Role=Advisor, comma-separated student IDs |
| Department | Text | Their department |

**Why this list matters:**
```
User logs in → Flow calls GET /me → gets email
  → Looks up email in User Roles list
  → Finds: Role=Faculty, LinkedCourses=BIO301,BIO201
  → Agent knows: show only BIO301 and BIO201 data
```

#### 📋 2. Student Profiles (revised)
| Column | Type | Description |
|---|---|---|
| Title | Text | Student full name |
| StudentID | Text | Unique ID (STU001) |
| Major | Text | Declared major |
| Track | Text | Specialization (e.g., "Pre-Med") |
| GPA | Number | Current cumulative GPA |
| PriorGPA | Number | Previous semester GPA (for trend) |
| AdvisorEmail | Text | Advisor's M365 email (links to User Roles) |
| EnrollmentStatus | Choice | Active / Probation / Suspended / Graduated / Withdrawn |
| RiskLevel | Choice | Low / Medium / High / Critical |
| EngagementScore | Number | Calculated 0-100 |
| CareerGoal | Text (multiline) | Self-reported career aspiration |
| Accommodations | Text (multiline) | IEP/504 notes (advisor-only visibility) |
| Email | Text | Student email |
| Phone | Text | Phone number |
| YearLevel | Choice | Freshman / Sophomore / Junior / Senior / Graduate |

---

### Tier 2: Academic Data

#### 📋 3. Course Catalog (unchanged)
| Column | Type | Description |
|---|---|---|
| Title | Text | Course name |
| CourseID | Text | Course code (CS101) |
| Department | Text | Department name |
| Prerequisites | Text (multiline) | Required prior courses |
| Credits | Number | Credit hours |
| Semester | Choice | Fall / Spring / Summer / All |
| Instructor | Text | Faculty name |
| InstructorEmail | Text | Faculty M365 email (links to User Roles) |
| MaxEnrollment | Number | Capacity |

#### 📋 4. Degree Plans (unchanged)
| Column | Type | Description |
|---|---|---|
| Title | Text | Plan name ("Biology BS - Pre-Med") |
| Major | Text | Major name |
| Track | Text | Track/specialization |
| RequiredCourses | Text (multiline) | Comma-separated course IDs |
| ElectiveCredits | Number | Elective credits needed |
| TotalCredits | Number | Total credits to graduate |
| Notes | Text (multiline) | Additional requirements |

#### 📋 5. Student Enrollments (revised — adds EngagementScore)
| Column | Type | Description |
|---|---|---|
| Title | Text | "STU003 → BIO301 (Spring 2026)" |
| StudentRef | Text | Student ID |
| CourseRef | Text | Course ID |
| Semester | Text | "Spring 2026" |
| Grade | Text | Current letter grade |
| GradePoints | Number | Numeric (4.0 scale) |
| AssignmentTotal | Number | Total assignments in course |
| AssignmentsSubmitted | Number | How many submitted |
| AssignmentsLate | Number | How many submitted late |
| AssignmentCompletionRate | Number | % (0-100) |
| AttendanceRate | Number | % (0-100) — optional, null if not tracked |
| LMSActivityScore | Number | % (0-100) — logins, resource access |
| EngagementScore | Number | Calculated 0-100 weighted score |
| Status | Choice | Enrolled / Completed / Withdrawn / Failed |
| LastActivityDate | DateTime | Last assignment/LMS interaction |
| WeeksInactive | Number | Weeks since last activity |

---

### Tier 3: Intervention & Tracking

#### 📋 6. Alert Rules (revised — engagement-based)
| Column | Type | Description |
|---|---|---|
| Title | Text | Rule name |
| Metric | Choice | EngagementScore / GPA / AssignmentCompletion / GradeDrop / WeeksInactive |
| Threshold | Number | Numeric threshold |
| Operator | Choice | LessThan / GreaterThan / Equals |
| Severity | Choice | Low / Medium / High / Critical |
| ActionTemplate | Text (multiline) | Default intervention action |
| IsActive | Boolean | Enable/disable rule |
| AppliesToRole | Choice | All / Faculty / Advisor | Who sees alerts from this rule |

#### 📋 7. Intervention History (revised — links to user who intervened)
| Column | Type | Description |
|---|---|---|
| Title | Text | Brief description |
| StudentRef | Text | Student ID |
| IntervenedByEmail | Text | M365 email of faculty/advisor who acted |
| InterventionType | Choice | Email / Meeting / PhoneCall / Referral / AcademicPlan / CourseWithdrawal |
| Notes | Text (multiline) | Details of the intervention |
| Outcome | Choice | Pending / Improved / NoChange / Escalated / Resolved |
| FollowUpDate | DateTime | When to check back |
| CreatedDate | DateTime | When intervention was logged |

---

### Tier 4: System

#### 📋 8. Agent Config (unchanged)
| Column | Type | Description |
|---|---|---|
| Title | Text | Setting key |
| Value | Text (multiline) | Setting value |
| ConfigDescription | Text | What this setting does |

#### 📋 9. Audit Log (unchanged)
| Column | Type | Description |
|---|---|---|
| Title | Text | Action description |
| ActionType | Choice | EarlyAlert / Outreach / StudentPulse / DegreePlan / CourseAdvice / Report / Nudge / Config |
| Details | Text (multiline) | Full details |
| Timestamp | DateTime | When |
| UserEmail | Text | Who triggered this action |
| UserRole | Text | Their role when they triggered it |

---

## How Role-Based Filtering Works

```
┌─────────────────────────────────────────────────────────┐
│  User chats with UniGuard in Teams                       │
│                                                          │
│  Step 1: GetStudentContext flow fires                    │
│                                                          │
│  Step 2: Flow calls Graph API: GET /me                  │
│          → Returns: admin@M365CPI30732412...            │
│                                                          │
│  Step 3: Flow looks up email in "User Roles" list       │
│          → Returns: Role=Faculty, Courses=BIO301,BIO201 │
│                                                          │
│  Step 4: Flow filters data by role                      │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │ IF Faculty:                                      │    │
│  │   → Get enrollments WHERE CourseRef IN           │    │
│  │     their LinkedCourses                          │    │
│  │   → Show: class stats, at-risk students in       │    │
│  │     their classes only                           │    │
│  │                                                  │    │
│  │ IF Advisor:                                      │    │
│  │   → Get student profiles WHERE StudentID IN      │    │
│  │     their LinkedAdvisees                         │    │
│  │   → Show: full profile cards, cross-class view,  │    │
│  │     intervention history, career goals           │    │
│  │                                                  │    │
│  │ IF Student:                                      │    │
│  │   → Get enrollments WHERE StudentRef =           │    │
│  │     their LinkedStudentID                        │    │
│  │   → Show: own grades, degree progress,           │    │
│  │     course recommendations only                  │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  Step 5: Return filtered data to agent                  │
│          Agent generates response with generative AI    │
└─────────────────────────────────────────────────────────┘
```

---

## Entra ID Groups → User Roles List Sync

In production, this would be automated:
```
Entra ID Group: UniGuard-Faculty
  → Members synced to User Roles list with Role=Faculty
  → LinkedCourses populated from Course Catalog (where InstructorEmail matches)

Entra ID Group: UniGuard-Students
  → Members synced to User Roles list with Role=Student
  → LinkedStudentID populated from Student Profiles (where Email matches)
```

For the POC, we manually populate the User Roles list.

---

## What Changed from v1

| | v1 | v2 |
|---|---|---|
| **Role detection** | None — everyone sees everything | User Roles list + Entra groups |
| **Data filtering** | No filtering | Role-based: faculty→classes, advisor→advisees, student→self |
| **Engagement Score** | Not tracked | Calculated per enrollment, stored in Student Enrollments |
| **Attendance** | Primary signal | Optional signal (10% weight) |
| **LMS Activity** | Not tracked | Tracked as LMSActivityScore |
| **Career Goals** | Separate implied | In Student Profiles directly |
| **Audit Log** | Basic | Tracks who + what role triggered each action |
| **Lists** | 8 | 9 (added User Roles) |
