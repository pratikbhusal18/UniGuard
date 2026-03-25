from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)

# Colors
DARK_BG = RGBColor(0x1B, 0x1B, 0x2F)
ACCENT = RGBColor(0x6C, 0x63, 0xFF)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
LIGHT_GRAY = RGBColor(0xB0, 0xB0, 0xC0)
GREEN = RGBColor(0x4E, 0xC9, 0xB0)
ORANGE = RGBColor(0xFF, 0xA0, 0x50)
RED = RGBColor(0xFF, 0x55, 0x55)
YELLOW = RGBColor(0xFF, 0xD7, 0x00)
BLUE = RGBColor(0x55, 0x9F, 0xFF)

def add_bg(slide, color=DARK_BG):
    bg = slide.background
    fill = bg.fill
    fill.solid()
    fill.fore_color.rgb = color

def add_text(slide, left, top, width, height, text, size=18, color=WHITE, bold=False, alignment=PP_ALIGN.LEFT):
    txBox = slide.shapes.add_textbox(Inches(left), Inches(top), Inches(width), Inches(height))
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = text
    p.font.size = Pt(size)
    p.font.color.rgb = color
    p.font.bold = bold
    p.alignment = alignment
    return tf

def add_para(tf, text, size=18, color=WHITE, bold=False):
    p = tf.add_paragraph()
    p.text = text
    p.font.size = Pt(size)
    p.font.color.rgb = color
    p.font.bold = bold
    return p

# ============================================================
# SLIDE 1: Title
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])  # blank
add_bg(slide)
add_text(slide, 1, 0.8, 11, 1, "🎓", size=60, alignment=PP_ALIGN.CENTER)
add_text(slide, 1, 2.0, 11, 1.5, "UniGuard", size=54, color=WHITE, bold=True, alignment=PP_ALIGN.CENTER)
add_text(slide, 1, 3.3, 11, 1, "Student Success & Academic Advisory Agent", size=28, color=ACCENT, alignment=PP_ALIGN.CENTER)
add_text(slide, 1, 4.5, 11, 0.8, "Built entirely on Microsoft 365", size=20, color=LIGHT_GRAY, alignment=PP_ALIGN.CENTER)
add_text(slide, 1, 5.8, 11, 0.5, "Copilot Studio  ·  Power Automate  ·  SharePoint  ·  Teams", size=16, color=LIGHT_GRAY, alignment=PP_ALIGN.CENTER)

# ============================================================
# SLIDE 2: The Problem
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "The Problem", size=36, color=ACCENT, bold=True)

tf = add_text(slide, 0.8, 1.5, 5.5, 5, "", size=22, color=WHITE)
tf.paragraphs[0].text = "1 in 3 students drop out"
tf.paragraphs[0].font.size = Pt(28)
tf.paragraphs[0].font.bold = True
tf.paragraphs[0].font.color.rgb = RED

add_para(tf, "", size=12)
add_para(tf, "📊  Advisors juggle 200+ students with spreadsheets", size=18, color=LIGHT_GRAY)
add_para(tf, "", size=8)
add_para(tf, "⏰  Warning signs are caught weeks too late", size=18, color=LIGHT_GRAY)
add_para(tf, "", size=8)
add_para(tf, "🔇  No attendance tracking in most in-person classes", size=18, color=LIGHT_GRAY)
add_para(tf, "", size=8)
add_para(tf, "📧  Outreach is manual, generic, and slow", size=18, color=LIGHT_GRAY)
add_para(tf, "", size=8)
add_para(tf, "🏫  Every university has the data — nobody connects it", size=18, color=LIGHT_GRAY)

tf2 = add_text(slide, 7, 1.8, 5.5, 4.5, "", size=18, color=WHITE)
tf2.paragraphs[0].text = "The timeline today:"
tf2.paragraphs[0].font.bold = True
tf2.paragraphs[0].font.size = Pt(20)
add_para(tf2, "", size=10)
add_para(tf2, "Week 1-3    Student starts missing assignments", size=16, color=LIGHT_GRAY)
add_para(tf2, "Week 4-6    Grades drop, disengagement grows", size=16, color=LIGHT_GRAY)
add_para(tf2, "Week 7-8    Midterm grades post — advisor finally sees it", size=16, color=YELLOW)
add_para(tf2, "Week 9+     Too late — student fails or drops out", size=16, color=RED)
add_para(tf2, "", size=14)
add_para(tf2, "With UniGuard:", size=20, bold=True, color=GREEN)
add_para(tf2, "Week 1-3    Auto-detected. Advisor notified. Action taken.", size=16, color=GREEN)

# ============================================================
# SLIDE 3: What UniGuard Does
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "What UniGuard Does", size=36, color=ACCENT, bold=True)

items = [
    ("🚨", "Early Alerts", "Detects at-risk students by engagement score", RED),
    ("📊", "Student Pulse", "Full student profile — grades, goals, interventions", BLUE),
    ("📧", "Smart Outreach", "Drafts personalized emails using real academic data", GREEN),
    ("🗺️", "Degree Progress", "Maps completed vs remaining courses to graduation", YELLOW),
    ("📅", "Course Advisor", "Prereq-aware recommendations aligned to career goals", ACCENT),
    ("📝", "Reports", "Class, department, and cohort performance summaries", ORANGE),
]

for i, (icon, title, desc, color) in enumerate(items):
    row = i // 3
    col = i % 3
    x = 0.8 + col * 4.0
    y = 1.8 + row * 2.5
    
    add_text(slide, x, y, 0.6, 0.6, icon, size=28)
    add_text(slide, x + 0.6, y, 3, 0.5, title, size=22, color=color, bold=True)
    add_text(slide, x + 0.6, y + 0.5, 3, 0.6, desc, size=14, color=LIGHT_GRAY)

# ============================================================
# SLIDE 4: Engagement Score
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "Engagement Score — Not Attendance", size=36, color=ACCENT, bold=True)

add_text(slide, 0.8, 1.5, 11, 0.6, "Most in-person classes don't track attendance. UniGuard uses signals every university already has.", size=18, color=LIGHT_GRAY)

tf = add_text(slide, 0.8, 2.5, 5, 4, "", size=20, color=WHITE)
tf.paragraphs[0].text = "The Formula"
tf.paragraphs[0].font.bold = True
tf.paragraphs[0].font.size = Pt(24)
add_para(tf, "", size=10)
add_para(tf, "40%   Assignment completion & timeliness", size=18, color=GREEN)
add_para(tf, "30%   Grade performance vs passing", size=18, color=BLUE)
add_para(tf, "20%   LMS activity (logins, resource access)", size=18, color=YELLOW)
add_para(tf, "10%   Attendance (if available — optional)", size=18, color=LIGHT_GRAY)

tf2 = add_text(slide, 7, 2.5, 5, 4, "", size=20, color=WHITE)
tf2.paragraphs[0].text = "Risk Levels"
tf2.paragraphs[0].font.bold = True
tf2.paragraphs[0].font.size = Pt(24)
add_para(tf2, "", size=10)
add_para(tf2, "🟢  75-100    On Track", size=20, color=GREEN)
add_para(tf2, "🟡  60-74      Needs Monitoring", size=20, color=YELLOW)
add_para(tf2, "🟠  40-59     At Risk", size=20, color=ORANGE)
add_para(tf2, "🔴  0-39       Critical — Immediate Action", size=20, color=RED)

# ============================================================
# SLIDE 5: Who Uses It (Personas)
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "5 Personas, 1 Agent", size=36, color=ACCENT, bold=True)

personas = [
    ("👩‍🏫", "Faculty", "\"Who's struggling in my BIO301?\"", "Sees their classes only"),
    ("🧑‍💼", "Advisors", "\"Show my at-risk advisees\"", "Full cross-class view of caseload"),
    ("🎓", "Students", "\"Am I on track to graduate?\"", "Own data only (FERPA)"),
    ("🏛️", "Deans", "\"Biology department report\"", "Aggregated department stats"),
    ("🔧", "IT Admins", "Manages config + compliance", "Full access, no student chat"),
]

for i, (icon, title, query, scope) in enumerate(personas):
    x = 0.4 + i * 2.5
    add_text(slide, x, 1.8, 0.5, 0.5, icon, size=32, alignment=PP_ALIGN.CENTER)
    add_text(slide, x - 0.2, 2.5, 2.8, 0.4, title, size=18, color=WHITE, bold=True, alignment=PP_ALIGN.CENTER)
    add_text(slide, x - 0.2, 3.0, 2.8, 0.8, query, size=12, color=ACCENT, alignment=PP_ALIGN.CENTER)
    add_text(slide, x - 0.2, 3.8, 2.8, 0.6, scope, size=11, color=LIGHT_GRAY, alignment=PP_ALIGN.CENTER)

add_text(slide, 0.8, 5.0, 11, 0.6, "Privacy enforced at the flow level — the AI never receives unauthorized data.", size=16, color=GREEN, alignment=PP_ALIGN.CENTER)

# ============================================================
# SLIDE 6: Demo Conversation
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "Demo: Advisor Experience", size=36, color=ACCENT, bold=True)

msgs = [
    (True, "Show me at-risk students"),
    (False, "You have 3 students needing attention:\n\n🔴 Amber Rodriguez — Engagement: 34%\n     0 of last 3 assignments submitted, GPA: 1.8\n\n🟠 Dakota Sanchez — Engagement: 61%\n     2 late submissions, grade trending down\n\n🟡 Omar Bennett — Engagement: 68%\n     GPA dropped from 3.0 to 2.5"),
    (True, "Tell me more about Amber"),
    (False, "🎓 Amber Rodriguez (STU003) — Biology, Pre-Med\n     GPA: 1.8 (was 2.4) · Engagement: 34% 🔴\n     Career goal: Medical school\n     3 interventions attempted — no improvement yet\n\n     💡 Recommend: Mandatory tutoring + reduced course load"),
]

y = 1.5
for is_user, text in msgs:
    if is_user:
        add_text(slide, 7, y, 5.5, 0.5, text, size=16, color=ACCENT, bold=True, alignment=PP_ALIGN.RIGHT)
        y += 0.5
    else:
        add_text(slide, 0.8, y, 8, 2.0, text, size=12, color=LIGHT_GRAY)
        y += len(text.split('\n')) * 0.22 + 0.3

# ============================================================
# SLIDE 7: Architecture
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "Architecture", size=36, color=ACCENT, bold=True)

layers = [
    ("Microsoft Teams", "Chat interface for all personas", BLUE, 1.6),
    ("Copilot Studio", "Agent + Topics + Generative AI", ACCENT, 2.6),
    ("Power Automate", "GetStudentContext flow (role-filtered)", GREEN, 3.6),
    ("SharePoint", "9 lists — the brain (profiles, enrollments, plans, alerts)", YELLOW, 4.6),
    ("Graph Education API", "Production: SIS → School Data Sync → M365", ORANGE, 5.6),
]

for name, desc, color, y in layers:
    add_text(slide, 2, y, 4, 0.5, name, size=22, color=color, bold=True)
    add_text(slide, 2, y + 0.35, 4, 0.4, desc, size=13, color=LIGHT_GRAY)
    # Arrow
    if y < 5.6:
        add_text(slide, 3.5, y + 0.7, 1, 0.3, "↕", size=18, color=LIGHT_GRAY, alignment=PP_ALIGN.CENTER)

# Right side - SharePoint lists
tf = add_text(slide, 7.5, 1.6, 5, 5, "", size=16, color=WHITE)
tf.paragraphs[0].text = "SharePoint Brain (9 Lists)"
tf.paragraphs[0].font.bold = True
tf.paragraphs[0].font.size = Pt(20)
tf.paragraphs[0].font.color.rgb = YELLOW
add_para(tf, "", size=8)
for lst in ["📋 Student Profiles", "📋 Course Catalog", "📋 Degree Plans", 
            "📋 Student Enrollments", "📋 Alert Rules", "📋 Intervention History",
            "📋 User Roles (privacy)", "📋 Agent Config", "📋 Audit Log"]:
    add_para(tf, lst, size=14, color=LIGHT_GRAY)

# ============================================================
# SLIDE 8: Privacy & FERPA
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "Privacy & FERPA Compliance", size=36, color=ACCENT, bold=True)

tf = add_text(slide, 0.8, 1.5, 11, 0.6, "Privacy is enforced at the Power Automate flow level — the AI never receives data the user shouldn't see.", size=18, color=GREEN)

# Access matrix
headers = ["Data", "🎓 Student", "👩‍🏫 Faculty", "🧑‍💼 Advisor", "🔧 Admin"]
rows = [
    ["Own grades", "✅", "—", "—", "✅"],
    ["Class students", "—", "✅", "—", "✅"],
    ["Advisees (full)", "—", "—", "✅", "✅"],
    ["Career goals", "✅ own", "❌", "✅", "✅"],
    ["Interventions", "❌", "❌", "✅", "✅"],
    ["Dept aggregates", "❌", "❌", "❌", "✅"],
]

y_start = 2.5
for i, row in enumerate([-1] + list(range(len(rows)))):
    y = y_start + i * 0.55
    if row == -1:
        cells = headers
        color = WHITE
        bold = True
    else:
        cells = rows[row]
        color = LIGHT_GRAY
        bold = False
    for j, cell in enumerate(cells):
        x = 0.8 + j * 2.3
        c = GREEN if cell == "✅" else (RED if cell == "❌" else color)
        add_text(slide, x, y, 2.2, 0.4, cell, size=14, color=c, bold=bold)

# ============================================================
# SLIDE 9: ROI
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "Impact & ROI", size=36, color=ACCENT, bold=True)

metrics = [
    ("At-risk detection", "4-6 weeks", "1 week", "⚡ 80% faster"),
    ("Advisor review time", "2 hrs/week", "20 min/week", "⚡ 83% reduction"),
    ("First-year retention", "~75%", "~85%", "⚡ +10% improvement"),
    ("Cost vs alternatives", "$100K+ (EAB, Starfish)", "$0 incremental", "⚡ Free on existing M365"),
]

tf = add_text(slide, 0.8, 1.5, 11, 0.5, "", size=14, color=LIGHT_GRAY)
header_y = 1.5
for j, h in enumerate(["Metric", "Before", "After", "Impact"]):
    add_text(slide, 0.8 + j * 3, header_y, 2.8, 0.4, h, size=16, color=WHITE, bold=True)

for i, (metric, before, after, impact) in enumerate(metrics):
    y = 2.2 + i * 0.9
    add_text(slide, 0.8, y, 2.8, 0.5, metric, size=15, color=LIGHT_GRAY)
    add_text(slide, 3.8, y, 2.8, 0.5, before, size=15, color=RED)
    add_text(slide, 6.8, y, 2.8, 0.5, after, size=15, color=GREEN)
    add_text(slide, 9.8, y, 3, 0.5, impact, size=15, color=YELLOW, bold=True)

# ============================================================
# SLIDE 10: Deploy
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 0.8, 0.5, 11, 0.8, "Deploy in ~30 Minutes", size=36, color=ACCENT, bold=True)

steps = [
    ("1", "Run provisioning script", "Creates SharePoint site + 9 lists + sample data", "5 min"),
    ("2", "Create Entra security groups", "UniGuard-Faculty, Advisors, Students", "2 min"),
    ("3", "Import solution .zip", "Upload at make.powerapps.com → Solutions", "2 min"),
    ("4", "Create Copilot Studio agent", "Instructions + Knowledge + Flow + Topic", "15 min"),
    ("5", "Publish to Teams", "Publish → Channels → Teams → Turn on", "1 min"),
    ("6", "Test", "\"Show me at-risk students\" → it works!", "5 min"),
]

for i, (num, title, desc, time) in enumerate(steps):
    y = 1.6 + i * 0.9
    add_text(slide, 1.0, y, 0.6, 0.5, num, size=28, color=ACCENT, bold=True)
    add_text(slide, 1.8, y, 5, 0.4, title, size=20, color=WHITE, bold=True)
    add_text(slide, 1.8, y + 0.35, 5, 0.4, desc, size=13, color=LIGHT_GRAY)
    add_text(slide, 10, y + 0.1, 2, 0.4, time, size=16, color=GREEN, alignment=PP_ALIGN.RIGHT)

add_text(slide, 0.8, 7.0, 11, 0.4, "github.com/pratikbhusal18/UniGuard", size=18, color=ACCENT, alignment=PP_ALIGN.CENTER)

# ============================================================
# SLIDE 11: Call to Action
# ============================================================
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_bg(slide)
add_text(slide, 1, 1.5, 11, 1, "🎓 UniGuard", size=48, color=WHITE, bold=True, alignment=PP_ALIGN.CENTER)
add_text(slide, 1, 2.8, 11, 0.8, "Every student deserves to be seen before they fall behind.", size=24, color=ACCENT, alignment=PP_ALIGN.CENTER)

tf = add_text(slide, 2, 4.2, 9, 2.5, "", size=18, color=LIGHT_GRAY, alignment=PP_ALIGN.CENTER)
tf.paragraphs[0].text = "🔗  github.com/pratikbhusal18/UniGuard"
tf.paragraphs[0].font.size = Pt(20)
tf.paragraphs[0].font.color.rgb = ACCENT
add_para(tf, "", size=12)
p = add_para(tf, "Open source · MIT licensed · Ready to deploy", size=16, color=LIGHT_GRAY)
p.alignment = PP_ALIGN.CENTER
add_para(tf, "", size=12)
p = add_para(tf, "Feedback, PRs, and ideas welcome!", size=18, color=GREEN)
p.alignment = PP_ALIGN.CENTER

# Save
output_path = r"C:\Users\prbhusal\UniGuard\UniGuard-Presentation.pptx"
prs.save(output_path)
print(f"Saved to {output_path}")
