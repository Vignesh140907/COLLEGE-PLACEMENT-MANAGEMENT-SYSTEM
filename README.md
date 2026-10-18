# College Placement Management System (OOP & DBMS)

A full-stack, enterprise-grade **College Placement Management System** built with **HTML5, CSS3, vanilla JavaScript**, **Java (OOP Architecture)**, and **MySQL 8.0 (DBMS Concepts)**.

---

## 🌟 Key Features

1. **Role-Based Authentication**:
   - Secure login and registration for **Students** and **Placement Administrators**.
   - Transactional student onboarding (`users` + `students` tables linked via ACID transactions).
2. **Student Academic Profiles**:
   - Manages Register Number, Department, CGPA, Standing Arrear count, Skills, and Contact details.
   - Live profile editor to observe how job eligibility updates dynamically.
3. **Company & Placement Drive Management**:
   - Admins can register recruiting partner companies (Google, Zoho, TCS, TI, etc.).
   - Create campus recruitment drives with specific criteria: Min CGPA, Max Arrears, Eligible Branches, Salary Package (CTC in LPA), and Deadlines.
4. **Automated Eligibility Engine (OOP Strategy Pattern)**:
   - Evaluates whether a student satisfies a drive's requirements based on:
     - 🎓 **CGPA Criterion**: `student.cgpa >= drive.minCgpa`
     - ⚠️ **Arrear Criterion**: `student.arrearCount <= drive.maxArrears`
     - 🏛️ **Department Criterion**: `drive.eligibleDepartments` includes student's branch (or `ALL`)
   - Highlights exact disqualification reasons if ineligible and restricts invalid submissions.
5. **Real-Time Application Pipeline Tracking**:
   - Track application stages: `APPLIED` ➔ `SHORTLISTED` ➔ `INTERVIEW SCHEDULED` ➔ `SELECTED` / `REJECTED`.
   - Admin reviewer modal to update applicant statuses with custom feedback notes.
6. **Placement Analytics & DBMS Views**:
   - Live summary metrics: Total Students, Placed Count, Overall Placement %, Active Drives, Highest Package, Average CTC.
   - Department-wise placement performance table dynamically generated via SQL View `vw_department_statistics`.

---

## 🏗️ Technical Architecture & OOP/DBMS Concepts

### Object-Oriented Programming (OOP) Concepts in Java
- **Inheritance & Polymorphism**:
  - `User` abstract base class extended by `Student` and `Admin`.
  - Polymorphic role handling in `UserDAO.authenticate()`.
- **Encapsulation**:
  - Private fields with validated getters and setters across models (`JobDrive`, `Student`, `Company`, `Application`).
- **Abstraction & DAO Pattern**:
  - `UserDAO`, `StudentDAO`, `JobDriveDAO`, `ApplicationDAO`, and `StatsDAO` decouple business logic from raw SQL execution.
- **Design Pattern (Rule Engine)**:
  - `EligibilityCriterion` interface with polymorphic implementations: `CgpaCriterion`, `ArrearCriterion`, and `DepartmentCriterion`.

### Database Management System (DBMS) Concepts in MySQL
- **Relational Normalization (3NF)**:
  - Separate normalized entities: `users`, `students`, `companies`, `job_drives`, `applications`.
- **Referential Integrity**:
  - Foreign Keys with `ON DELETE CASCADE` ensuring consistency across linked entities.
- **Constraints & Domain Integrity**:
  - Primary Keys (`INT AUTO_INCREMENT`).
  - Unique Keys: `users.username`, `students.email`, `students.register_no`, and `uq_student_drive(student_id, drive_id)` (prevents duplicate applications).
  - Check Constraints: `CHECK (cgpa >= 0.00 AND cgpa <= 10.00)`, `CHECK (arrear_count >= 0)`.
- **SQL Views**:
  - `vw_department_statistics`: Aggregates placement rate, student count, and average CTC per department.
  - `vw_placement_records`: Multi-table relational join for reporting.
- **ACID Transactions**:
  - Used in `UserDAO.registerStudent()` with `conn.setAutoCommit(false)` and `rollback()` handling.

---

## 📁 Project Directory Structure

```text
COLLEGE PLACEMENT MANAGEMENT SYSTEM/
│
├── database/
│   └── schema.sql                 # Complete MySQL DDL: Tables, Constraints, Views, Seeds
│
├── lib/
│   ├── mysql-connector-j-8.3.0.jar # MySQL JDBC Driver
│   └── gson-2.10.1.jar            # JSON Serialization Library
│
├── src/main/
│   ├── java/com/placement/
│   │   ├── Main.java              # Server Entry Point & Embedded HTTP Server (Port 8080)
│   │   ├── config/
│   │   │   └── DatabaseConfig.java # JDBC Connection Manager
│   │   ├── models/                # OOP Models (User, Student, Admin, JobDrive, etc.)
│   │   ├── dao/                   # Data Access Objects (UserDAO, StudentDAO, etc.)
│   │   ├── service/               # Eligibility Rule Engine (Polymorphic criteria)
│   │   └── controller/            # REST API Handlers & Static File Server
│   └── resources/
│       ├── db.properties          # MySQL Connection Credentials
│       └── web/                   # Responsive Frontend
│           ├── index.html         # Landing Page & Auth Modal
│           ├── student.html       # Student Dashboard & Applications Tracker
│           ├── admin.html         # Placement Officer Dashboard & Analytics
│           ├── css/style.css      # CSS Design System
│           └── js/                # Frontend Scripts (api.js, auth.js, student.js, admin.js)
│
├── run.bat                        # Windows CMD 1-Click Launcher
├── run.ps1                        # PowerShell 1-Click Launcher
└── pom.xml                        # Maven Configuration (For IDEs)
```

---

## 🚀 How to Run the Application

### 1. Database Setup
The MySQL schema has already been executed into your local MySQL server (`placement_db`).
If you ever need to re-import it, run:
```powershell
Get-Content database\schema.sql | mysql -u root -proot
```

### 2. Start the Application
Simply double-click **`run.bat`** or run in PowerShell:
```powershell
.\run.ps1
```

The application will start on **`http://localhost:8080`**.

---

## 🔑 Default Accounts for Testing & Viva Demo

| Portal | Username | Password | Role / Details |
| :--- | :--- | :--- | :--- |
| **Admin Portal** | `admin` | `admin123` | Placement Administrator |
| **Student 1 (Eligible for all)** | `rahul.cse` | `student123` | CSE &bull; 8.95 CGPA &bull; 0 Arrears |
| **Student 2 (Average CGPA)** | `ananya.it` | `student123` | IT &bull; 7.80 CGPA &bull; 0 Arrears |
| **Student 3 (Arrear Test)** | `karthik.ece` | `student123` | ECE &bull; 7.15 CGPA &bull; 1 Standing Arrear |
| **Student 4 (Branch Test)** | `sneha.mech` | `student123` | MECH &bull; 6.85 CGPA &bull; 0 Arrears |

---

## 💡 Live Viva Demonstration Steps

1. **Login as Student 3 (`karthik.ece` / `student123`)**:
   - Notice that Google and Zoho show **🔴 NOT ELIGIBLE** because he has 1 standing arrear and criteria requires 0 arrears.
   - Notice that TCS shows **🟢 ELIGIBLE** because TCS allows up to 1 standing arrear!
2. **Open Profile Editor**:
   - Change Karthik's arrears from `1` to `0` and save.
   - Watch the live eligibility engine recalculate dynamically: Zoho instantly becomes **🟢 ELIGIBLE**!
3. **Submit Application**:
   - Click **"Apply Now"** for an eligible drive.
   - Switch to the "My Application Status" tab to see the live status badge.
4. **Login as Admin (`admin` / `admin123`)**:
   - Open **`http://localhost:8080/admin.html`**.
   - Check the **Placement Analytics** table displaying branch-wise stats calculated from the MySQL View.
   - Go to **Applications Review**, locate the candidate's application, click **"Review"**, and update status to `SELECTED` with custom remarks.
   - Notice the Department placement rate and total placed metrics update immediately.
