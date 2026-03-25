# 🔒 UniGuard — Privacy & Access Control Design

## The Problem

Without access controls, any user chatting with UniGuard could query any student's data.
That violates FERPA and university privacy policies.

```
❌ BAD: Student Amber asks "How is Kai Carter doing?" → sees Kai's grades
❌ BAD: Faculty Lisa asks about students not in her class
❌ BAD: Advisor Monica sees students assigned to Advisor Robin
```

## The Solution: Role-Based Filtering in the Flow

The **GetStudentContext** flow must detect WHO is asking and filter data BEFORE
returning it to the agent. The agent never sees data the user shouldn't access.

```
┌──────────────────────────────────────────────────────────────┐
│                    ACCESS CONTROL FLOW                        │
│                                                               │
│  User chats with UniGuard                                    │
│       │                                                       │
│       ▼                                                       │
│  ┌─────────────────────────────┐                             │
│  │ Step 1: WHO IS ASKING?       │                             │
│  │                               │                             │
│  │ Flow calls: Get User Roles    │                             │
│  │ Filter: UserEmail eq          │                             │
│  │   '{logged-in-user-email}'    │                             │
│  │                               │                             │
│  │ Result: Role + Scope          │                             │
│  └──────────┬────────────────────┘                             │
│             │                                                  │
│  ┌──────────▼────────────────────┐                             │
│  │ Step 2: WHAT CAN THEY SEE?    │                             │
│  │                                │                             │
│  │ Student (LinkedStudentID=X)    │                             │
│  │   → Filter ALL lists WHERE     │                             │
│  │     StudentRef = X OR          │                             │
│  │     StudentID = X              │                             │
│  │   → Returns: ONLY their data   │                             │
│  │                                │                             │
│  │ Faculty (LinkedCourses=A,B)    │                             │
│  │   → Filter enrollments WHERE   │                             │
│  │     CourseRef IN (A,B)         │                             │
│  │   → Get student profiles for   │                             │
│  │     students in those courses  │                             │
│  │   → Returns: their classes     │                             │
│  │     only                       │                             │
│  │                                │                             │
│  │ Advisor (LinkedAdvisees=X,Y,Z) │                             │
│  │   → Filter profiles WHERE      │                             │
│  │     StudentID IN (X,Y,Z)      │                             │
│  │   → Get all data for those     │                             │
│  │     students only              │                             │
│  │   → Returns: advisee data      │                             │
│  │                                │                             │
│  │ Admin                          │                             │
│  │   → No filter, sees everything │                             │
│  └──────────┬────────────────────┘                             │
│             │                                                  │
│  ┌──────────▼────────────────────┐                             │
│  │ Step 3: RETURN FILTERED DATA   │                             │
│  │                                │                             │
│  │ Agent ONLY receives data the   │                             │
│  │ user is authorized to see.     │                             │
│  │ It CANNOT access anything else.│                             │
│  └────────────────────────────────┘                             │
└──────────────────────────────────────────────────────────────┘
```

---

## Implementation: Revised GetStudentContext Flow

### Current Flow (no privacy):
```
Trigger → Get ALL User Roles → Get ALL Students → Get ALL Enrollments → Return ALL
```

### New Flow (with privacy):
```
Trigger
  → Step 1: Get logged-in user's email (from trigger context)
  → Step 2: Look up User Roles WHERE UserEmail = logged-in email
  → Step 3: Branch by Role
      → IF Student: Get ONLY their profile + enrollments + degree plan
      → IF Faculty: Get enrollments WHERE course IN their LinkedCourses
                    Get profiles for students in those enrollments
      → IF Advisor: Get profiles WHERE StudentID IN their LinkedAdvisees
                    Get enrollments for those students
      → IF Admin: Get everything (no filter)
  → Step 4: Return filtered data + user's role
```

---

## Power Automate Implementation (Step-by-Step)

### Step 1: Get the Logged-In User's Email

After the trigger, add:
- **Action:** Compose
- **Input:** `@{triggerOutputs()?['headers']?['x-ms-user-email-encoded']}`
- **Rename:** `Get Caller Email`

Alternative (more reliable):
- **Action:** Office 365 Users → **Get my profile (V2)**
- This returns the logged-in user's email
- **Rename:** `Get My Profile`

### Step 2: Look Up Their Role

- **Action:** SharePoint → Get items
- Site: `https://m365cpi30732412.sharepoint.com/sites/UniGuard`
- List: `User Roles`
- Filter Query: `UserEmail eq '@{outputs('Get_My_Profile')?['body/mail']}'`
- **Rename:** `Lookup Role`

### Step 3: Extract Role and Scope

- **Action:** Compose
- Input: `@{first(body('Lookup_Role')?['value'])?['Role']}`
- **Rename:** `User Role`

- **Action:** Compose
- Input: `@{first(body('Lookup_Role')?['value'])?['LinkedStudentID']}`
- **Rename:** `Linked Student ID`

- **Action:** Compose
- Input: `@{first(body('Lookup_Role')?['value'])?['LinkedCourses']}`
- **Rename:** `Linked Courses`

- **Action:** Compose
- Input: `@{first(body('Lookup_Role')?['value'])?['LinkedAdvisees']}`
- **Rename:** `Linked Advisees`

### Step 4: Switch on Role

- **Action:** Switch
- On: `@{outputs('User_Role')}`

**Case: "Student"**
  - Get items → Student Profiles → Filter: `StudentID eq '@{outputs('Linked_Student_ID')}'`
  - Get items → Student Enrollments → Filter: `StudentRef eq '@{outputs('Linked_Student_ID')}'`
  - Get items → Degree Plans → Filter: matches student's major
  - (NO access to other students, interventions, or alert rules)

**Case: "Faculty"**
  - Get items → Student Enrollments → Filter: `CourseRef eq 'BIO301' or CourseRef eq 'PSY101'`
    (dynamically built from LinkedCourses)
  - Get items → Student Profiles → for students found in above enrollments
  - Get items → Alert Rules → (faculty can see rules for their courses)
  - (NO access to other courses, advisee data, or career goals)

**Case: "Advisor"**
  - Get items → Student Profiles → Filter: `StudentID eq 'STU001' or StudentID eq 'STU002' or StudentID eq 'STU003'`
    (dynamically built from LinkedAdvisees)
  - Get items → Student Enrollments → for those students
  - Get items → Intervention History → for those students
  - Get items → Degree Plans → for those students' majors
  - (Full view of their advisees, including career goals and interventions)

**Case: "Admin"**
  - Get ALL items from all lists (no filter)

### Step 5: Return Filtered Data + Role

- Return value(s) to Copilot:
  - `userRole` → the detected role (Student/Faculty/Advisor/Admin)
  - `students` → filtered student profiles
  - `enrollments` → filtered enrollments
  - `interventions` → filtered (empty for Student/Faculty)
  - `degreePlans` → filtered degree plans
  - `alertRules` → filtered alert rules

---

## What Each Role Sees (Access Matrix)

| Data | 🎓 Student | 👩‍🏫 Faculty | 🧑‍💼 Advisor | 🔑 Admin |
|------|-----------|---------|---------|-------|
| **Own profile** | ✅ | ❌ | ❌ | ✅ |
| **Own grades** | ✅ | ❌ | ❌ | ✅ |
| **Own degree progress** | ✅ | ❌ | ❌ | ✅ |
| **Other student profiles** | ❌ | ✅ (their classes) | ✅ (their advisees) | ✅ |
| **Other student grades** | ❌ | ✅ (their classes) | ✅ (their advisees) | ✅ |
| **Career goals** | ✅ (own) | ❌ | ✅ (their advisees) | ✅ |
| **Intervention history** | ❌ | ❌ | ✅ (their advisees) | ✅ |
| **Degree plans** | ✅ (own major) | ❌ | ✅ (advisee majors) | ✅ |
| **Alert rules** | ❌ | ✅ | ✅ | ✅ |
| **Audit log** | ❌ | ❌ | ❌ | ✅ |
| **Agent config** | ❌ | ❌ | ❌ | ✅ |

---

## Agent Instructions Update

Add this to the Copilot Studio system prompt:

```
PRIVACY RULES (CRITICAL — never violate these):
- You receive pre-filtered data based on the user's role.
- NEVER claim to have access to data not in the provided context.
- If a user asks about a student not in the data, respond:
  "I don't have access to that student's information. You can only
   view data for students in your classes/caseload."
- NEVER reveal one student's data to another student.
- NEVER reveal career goals or intervention history to faculty.
- If the userRole is "Student", ONLY discuss their own data.
  Never mention other students by name or comparison.
```

---

## Testing the Privacy Controls

### Test 1: Student Can Only See Own Data
- Log in as Amber Rodriguez (AmberR@...)
- Ask: "How is Kai Carter doing?"
- Expected: "I don't have access to that student's information."
- Ask: "What are my grades?"
- Expected: Shows only Amber's grades (STU003)

### Test 2: Faculty Sees Only Their Classes
- Log in as Lisa Taylor (LisaT@...) — teaches BIO301, PSY101
- Ask: "Show me at-risk students"
- Expected: Shows only students in BIO301 and PSY101
- Ask: "How is Corey Gray doing?" (Corey is in CS101, not Lisa's class)
- Expected: "I don't have access to that student's information."

### Test 3: Advisor Sees Only Their Advisees
- Log in as Monica Thompson (MonicaT@...) — advises STU001, STU002, STU003
- Ask: "Show my students"
- Expected: Shows Kai, Dakota, Amber only
- Ask: "How is Omar Bennett doing?" (Omar is Robin's advisee)
- Expected: "I don't have access to that student's information."

### Test 4: Admin Sees Everything
- Log in as MOD Admin or Pratik Bhusal
- Ask: "Show all at-risk students"
- Expected: Shows all 5 students

---

## For the POC

The privacy flow requires a **Switch** action in Power Automate which adds complexity.
Two approaches:

### Option A: Build the full privacy flow (recommended for demo impact)
- Takes ~20 extra minutes to build
- Shows enterprise-readiness
- Impresses security-conscious customers

### Option B: Simulate with the agent instructions
- Keep the current simple flow (returns all data)
- Add the privacy rules to the agent instructions
- The AI will ATTEMPT to filter, but it's not enforced
- Good enough for a quick demo, not production-ready

I recommend **Option A** for FastTrack demos — the privacy story is a key differentiator.
