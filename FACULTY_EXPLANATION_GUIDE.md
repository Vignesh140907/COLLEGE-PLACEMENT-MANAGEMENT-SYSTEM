# Comprehensive Project Explanation Guide for Faculty Evaluation
## College Placement Management System (OOP & DBMS Project)

---

## 1. Executive Summary & Architecture Overview

The **College Placement Management System** is an end-to-end, 3-tier full-stack application designed to streamline campus recruitment for university placement cells, recruiting companies, and students.

### 3-Tier System Architecture:
```
+---------------------------------------------------------------------------------+
|                               PRESENTATION TIER                                 |
|                 HTML5  •  CSS3 (Custom Variables)  •  Vanilla JavaScript        |
|  [index.html: Auth & Stats]  [student.html: Dashboard]  [admin.html: Management]|
+----------------------------------------+----------------------------------------+
                                         | JSON via Fetch API (REST over HTTP)
                                         v
+---------------------------------------------------------------------------------+
|                                BUSINESS LOGIC TIER                              |
|                       Java 17 (Pure Object-Oriented Design)                     |
|                                                                                 |
|  * Embedded Server : com.sun.net.httpserver.HttpServer (Port 8080, Multi-threaded)|
|  * Controllers     : AuthHandler, StudentHandler, AdminHandler, StaticFileHandler|
|  * Rule Engine     : EligibilityService (Strategy/Specification Design Pattern) |
|  * Data Layer      : DAO Pattern (UserDAO, StudentDAO, JobDriveDAO, AppDAO)     |
|  * Domain Models   : User (Abstract), Student, Admin, Company, JobDrive, App    |
+----------------------------------------+----------------------------------------+
                                         | JDBC PreparedStatement (Connection Pool)
                                         v
+---------------------------------------------------------------------------------+
|                                   DATA TIER                                     |
|                            MySQL 8.0 Relational DBMS                            |
|                                                                                 |
|  * 3NF Normalized Tables: users, students, companies, job_drives, applications  |
|  * Integrity Controls  : Primary Keys, Foreign Keys (ON DELETE CASCADE), Checks |
|  * Optimizations       : B-Tree Indexes on CGPA, Department, Status, Deadline   |
|  * Virtual Relations   : SQL Views (vw_department_statistics, vw_placement_recs)|
|  * Transaction Safety  : ACID Compliance via manual commit & rollback           |
+---------------------------------------------------------------------------------+
```

---

## 2. Frontend Engineering (HTML5, CSS3 & Vanilla JavaScript)

### Why Vanilla JavaScript over Frameworks?
- **Academic Rigor**: Demonstrates a fundamental understanding of Document Object Model (DOM) manipulation, asynchronous JavaScript (`async/await`), and the browser `Fetch API` without relying on framework abstractions like React or Angular.
- **Zero Build Step**: No `node_modules`, bundlers, or compilation latency. Assets are served directly by the Java embedded HTTP server.

### Component Breakdown:

#### A. Central Utilities (`js/api.js`)
1. **Unified REST Client (`API` object)**:
   - Wraps standard `fetch()` into reusable methods: `API.get()`, `API.post()`, `API.put()`, `API.delete()`.
   - Automatically handles JSON serializing, response header inspection, and uniform error extraction.
2. **Session Storage Manager (`Session` object)**:
   - Saves authenticated user object into browser `localStorage`.
   - Protects role-based routes: `Session.requireRole("STUDENT")` and `Session.requireRole("ADMIN")`. If an unauthenticated user attempts to view `admin.html`, they are automatically redirected to `index.html`.
3. **Dynamic Toast Notifications (`showToast()`)**:
   - Programmatically creates transient alert cards (green for success, red for errors) that slide in, wait 4 seconds, and auto-dismiss using CSS transitions.
4. **Modal Window Controllers (`openModal()`, `closeModal()`)**:
   - Manages accessible pop-up overlays for login, editing profiles, posting drives, and reviewing applications.

#### B. Landing & Authentication (`index.html` + `js/auth.js`)
- **Live Stats Ticker**: When the landing page loads, it asynchronously queries `GET /api/admin/stats` to render dynamic metrics (Total Students, Placed Count, Active Drives, Highest CTC).
- **Tabbed Modal Navigation**:
  - Tab 1: **Student Login** (Submits to `POST /api/auth/login`).
  - Tab 2: **Student Registration** (Collects register number, department, CGPA, arrears count, contact, skills; submits to `POST /api/auth/register`).
  - Tab 3: **Admin Login** (Submits to `POST /api/auth/login`).
  - Includes **1-Click Demo Fill buttons** for effortless viva demonstrations.

#### C. Student Dashboard (`student.html` + `js/student.js`)
- **Profile Overview & In-Place Editor**:
  - Displays academic credentials. Clicking **"Edit Academic Profile"** opens a modal to adjust CGPA or Arrears.
  - When saved, `PUT /api/student/profile` updates the database, and **the page recalculates eligibility for all drives in real time without a page refresh**.
- **Drive Cards & Automated Eligibility UI**:
  - Renders all active company drives.
  - If eligible: Displays a **`badge-eligible`** (green) and an active **"Apply Now"** button.
  - If ineligible: Displays a **`badge-ineligible`** (red) with a descriptive reason box explaining why (e.g. *"Has 1 arrear; maximum allowed is 0"* or *"CGPA 7.15 is below required 8.50"*), disabling the button.
  - If already applied: Disables button and marks it *"Already Applied"*.
- **Application Status Pipeline Table**:
  - Queries `GET /api/student/applications?studentId=...`.
  - Color-codes application progress: `APPLIED` (Blue), `SHORTLISTED` (Purple), `INTERVIEW_SCHEDULED` (Amber), `SELECTED` (Green), `REJECTED` (Red).

#### D. Admin Dashboard (`admin.html` + `js/admin.js`)
- **Placement Analytics Tab**: Renders summary KPI cards and the **Department Placement Performance Table** populated directly by the MySQL View `vw_department_statistics`.
- **Applications Review Tab**: Allows the placement officer to filter applications by specific Drive or Status, click **"Review"**, select a new status (e.g., `SELECTED`), add custom interview feedback, and update the record.
- **Job Drives Tab**: Post new placement drives with custom criteria (Min CGPA, Max Arrears, Branches, Package, Deadlines) and delete completed drives.
- **Student Directory Tab**: Filter university students using multi-criteria search (Department dropdown, Minimum CGPA filter, Maximum Arrears filter, and Name/Register No text search).
- **Partner Companies Tab**: Register new recruiting organizations.

#### E. Styling & Design System (`css/style.css`)
- Custom CSS variables (`--primary`, `--success`, `--danger`, `--bg-main`, etc.).
- Responsive Grid layouts (`grid-2`, `grid-3`, `grid-4`) adapting to mobile, tablet, and desktop viewports.
- Pure CSS modal backdrop blur, smooth card hover elevations, and status badges.

---

## 3. Backend & Java Object-Oriented Programming (OOP) Deep-Dive

### Why Java Standard Library HTTP Server?
- We utilize `com.sun.net.httpserver.HttpServer` which is bundled directly inside JDK 17.
- **Benefits for Academic Project**:
  - Avoids heavyweight 50MB Tomcat/Spring dependency chains.
  - Multi-threaded: Powered by `Executors.newFixedThreadPool(15)`, allowing multiple concurrent student and admin requests.
  - Zero XML/Tomcat deployment descriptor configuration. Starts cleanly in milliseconds with a simple command.

### Demonstration of Core OOP Concepts:

#### 1. Abstraction & Inheritance
- **Base Class `User`** (`com.placement.models.User`):
  An abstract class defining shared identity and credential properties:
  ```java
  public abstract class User {
      private int id;
      private String username;
      private String password;
      private String role; // 'ADMIN' or 'STUDENT'
      private Timestamp createdAt;

      // Abstract method demonstrating polymorphism
      public abstract String getDisplayName();
      // Getters & Setters
  }
  ```
- **Derived Classes `Student` and `Admin`**:
  - `Student extends User`: Adds academic attributes (`registerNo`, `department`, `cgpa`, `arrearCount`, `skills`, `resumeUrl`). Overrides `getDisplayName()` to return `"FullName (RegisterNo - Department)"`.
  - `Admin extends User`: Overrides `getDisplayName()` to return `"Placement Administrator (Username)"`.

#### 2. Polymorphism
- **Dynamic Role-Based Instantiation**:
  In `UserDAO.authenticate(username, password)`, depending on the database `role` column, the method polymorphically instantiates and returns either a `Student` or an `Admin` reference:
  ```java
  if ("ADMIN".equalsIgnoreCase(role)) {
      return new Admin(userId, uname, pass);
  } else if ("STUDENT".equalsIgnoreCase(role)) {
      Student student = studentDAO.getByUserId(userId);
      return student; // Polymorphic return as User
  }
  ```

#### 3. Encapsulation
- All domain classes (`JobDrive`, `Company`, `Application`, `EligibilityResult`, `DashboardStats`) have `private` fields.
- Access is controlled through public getter and setter methods.
- Defensive validation is enforced before setting values (e.g., verifying CGPA is within 0.0 to 10.0 and arrears are non-negative).

#### 4. Separation of Concerns & Abstraction (DAO Pattern)
The application strictly enforces layered abstraction:
- **Controllers / Handlers** (`AuthHandler`, `StudentHandler`, `AdminHandler`): Handle HTTP request routing, parameter parsing, and JSON response generation.
- **Services** (`EligibilityService`): Encapsulates pure business logic without knowing anything about HTTP or SQL.
- **Data Access Objects (DAO)** (`UserDAO`, `StudentDAO`, `JobDriveDAO`, `ApplicationDAO`, `StatsDAO`): Encapsulates raw SQL execution, connection handling, and result set mapping. The rest of the application never writes SQL.

#### 5. Design Pattern: Strategy / Specification Pattern for Eligibility Engine
Instead of writing nested, hardcoded `if-else` blocks, the automatic eligibility check uses the **Strategy Pattern**:
- Interface: `EligibilityCriterion`
  ```java
  public interface EligibilityCriterion {
      boolean isSatisfiedBy(Student student, JobDrive drive, StringBuilder failureReason);
  }
  ```
- Three concrete rule strategies:
  1. `CgpaCriterion`:
     ```java
     if (student.getCgpa() < drive.getMinCgpa()) {
         failureReason.append(String.format("CGPA %.2f is below minimum required %.2f", 
             student.getCgpa(), drive.getMinCgpa()));
         return false;
     }
     ```
  2. `ArrearCriterion`:
     ```java
     if (student.getArrearCount() > drive.getMaxArrears()) {
         failureReason.append(String.format("Has %d arrear(s); maximum allowed is %d", 
             student.getArrearCount(), drive.getMaxArrears()));
         return false;
     }
     ```
  3. `DepartmentCriterion`:
     Splits comma-separated allowed departments (e.g., `"CSE,IT,ECE"`) and validates if `student.getDepartment()` is present.
- **Extensibility (Open/Closed Principle)**: If tomorrow the college wants to add an `AttendanceCriterion` or a `BacklogHistoryCriterion`, we simply write a new class implementing `EligibilityCriterion` without modifying existing rules!

---

## 4. Database & MySQL DBMS Concepts Deep-Dive

### Relational Schema (3NF Normalization)

The database schema (`placement_db`) is fully normalized to **Third Normal Form (3NF)**:
- **1NF**: Every column contains atomic (indivisible) values. Primary keys are defined for every table.
- **2NF**: No partial dependency; all non-key attributes are fully functionally dependent on the entire primary key.
- **3NF**: No transitive dependencies; non-key attributes depend only on the primary key (e.g., separating `users` and `students` so user authentication data is not redundantly stored with academic data).

```
   +---------------+          1 : 1          +---------------+
   |     users     | ----------------------> |   students    |
   +---------------+                         +---------------+
   | PK id         |                         | PK id         |
   |    username   |                         | FK user_id    |
   |    password   |                         |    register_no|
   |    role       |                         |    cgpa       |
   +---------------+                         |    arrear_cnt |
                                             +-------+-------+
                                                     | 1
                                                     |
                                                     | N
   +---------------+          1 : N          +-------v-------+
   |   companies   | ----------------------> | applications  |
   +---------------+                         +---------------+
   | PK id         |                         | PK id         |
   |    name       |                         | FK student_id |
   |    industry   |                         | FK drive_id   |
   +-------+-------+                         |    status     |
           | 1                               +-------^-------+
           |                                         | N
           | N                                       |
   +-------v-------+                                 | 1
   |  job_drives   | --------------------------------+
   +---------------+
   | PK id         |
   | FK company_id |
   |    package_lpa|
   |    min_cgpa   |
   |    max_arrears|
   +---------------+
```

### Key DBMS Concepts Implemented in SQL:

#### 1. Referential Integrity & Cascading Constraints
```sql
CONSTRAINT fk_students_users FOREIGN KEY (user_id) 
    REFERENCES users(id) ON DELETE CASCADE,
CONSTRAINT fk_drives_companies FOREIGN KEY (company_id) 
    REFERENCES companies(id) ON DELETE CASCADE,
CONSTRAINT fk_app_student FOREIGN KEY (student_id) 
    REFERENCES students(id) ON DELETE CASCADE,
CONSTRAINT fk_app_drive FOREIGN KEY (drive_id) 
    REFERENCES job_drives(id) ON DELETE CASCADE
```
- If an admin deletes a company, all corresponding job drives and candidate applications are safely cleaned up automatically, preventing orphaned records.

#### 2. Domain & Entity Integrity (Check and Unique Constraints)
```sql
-- Prevents a student from applying to the same placement drive multiple times:
CONSTRAINT uq_student_drive UNIQUE (student_id, drive_id),

-- Enforces valid grading scale:
CONSTRAINT chk_cgpa CHECK (cgpa >= 0.00 AND cgpa <= 10.00),

-- Enforces non-negative arrears:
CONSTRAINT chk_arrears CHECK (arrear_count >= 0),

-- Enforces positive compensation:
CONSTRAINT chk_drive_package CHECK (package_lpa > 0)
```

#### 3. B-Tree Query Optimization (Indexes)
Frequently filtered and sorted columns are indexed to convert full-table scans into $O(\log N)$ B-Tree index lookups:
```sql
CREATE INDEX idx_student_dept ON students(department);
CREATE INDEX idx_student_cgpa ON students(cgpa);
CREATE INDEX idx_student_arrears ON students(arrear_count);
CREATE INDEX idx_drive_status ON job_drives(status);
CREATE INDEX idx_drive_deadline ON job_drives(deadline);
CREATE INDEX idx_app_status ON applications(status);
```

#### 4. Virtual Relations (SQL Views)
We created dedicated SQL views to encapsulate complex queries and provide real-time reporting without data duplication:

- **Department Analytics View (`vw_department_statistics`)**:
  ```sql
  CREATE OR REPLACE VIEW vw_department_statistics AS
  SELECT 
      s.department,
      COUNT(DISTINCT s.id) AS total_students,
      COUNT(DISTINCT CASE WHEN a.status = 'SELECTED' THEN s.id END) AS placed_students,
      ROUND(
          IFNULL((COUNT(DISTINCT CASE WHEN a.status = 'SELECTED' THEN s.id END) * 100.0) / 
          NULLIF(COUNT(DISTINCT s.id), 0), 0), 
          2
      ) AS placement_percentage,
      IFNULL(MAX(CASE WHEN a.status = 'SELECTED' THEN jd.package_lpa END), 0) AS highest_package_lpa,
      IFNULL(ROUND(AVG(CASE WHEN a.status = 'SELECTED' THEN jd.package_lpa END), 2), 0) AS avg_package_lpa
  FROM students s
  LEFT JOIN applications a ON s.id = a.student_id
  LEFT JOIN job_drives jd ON a.drive_id = jd.id
  GROUP BY s.department;
  ```
  *Why this is impressive in viva*: It uses aggregate functions (`COUNT`, `AVG`, `MAX`), conditional aggregation (`CASE WHEN`), `LEFT JOIN` to include unplaced students, and `NULLIF` to prevent division-by-zero errors.

- **Placement Records Join View (`vw_placement_records`)**:
  Performs an inner join across 4 relational tables (`applications`, `students`, `job_drives`, `companies`) to give a flat reporting view of all recruitment activities.

#### 5. ACID Transactions (Atomicity & Consistency)
In `UserDAO.java`, student onboarding requires creating a record in `users` and another in `students`. If one fails, the database must not be left in an inconsistent state:
```java
try (Connection conn = DatabaseConfig.getConnection()) {
    conn.setAutoCommit(false); // Begin ACID Transaction
    try {
        // Step 1: Insert into users table
        // Step 2: Retrieve generated user_id
        // Step 3: Insert into students table using user_id
        conn.commit(); // Commit transaction atomically
    } catch (SQLException ex) {
        conn.rollback(); // Rollback on error - Atomicity guaranteed!
        throw ex;
    } finally {
        conn.setAutoCommit(true);
    }
}
```

#### 6. SQL Injection Prevention (Security)
Every single query in the application uses JDBC `PreparedStatement` with parameterized placeholders (`?`), completely eliminating SQL Injection vulnerabilities:
```java
String sql = "SELECT * FROM students WHERE department = ? AND cgpa >= ?";
PreparedStatement stmt = conn.prepareStatement(sql);
stmt.setString(1, dept);
stmt.setDouble(2, minCgpa);
```

---

## 5. End-to-End Request Flow (How Everything Connects)

Here is the exact lifecycle of an **"Apply for Drive"** user action:

1. **User Action**: The student clicks **"Apply Now"** for a job drive on `student.html`.
2. **Client-side (`student.js`)**:
   - Gathers `studentId` from current session and `driveId`.
   - Sends a `POST` request to `/api/student/apply` via `fetch()`.
3. **HTTP Server & Routing (`Main.java` & `StudentHandler.java`)**:
   - The embedded server receives the request on port 8080 and routes to `StudentHandler.handleApply()`.
   - Parses the JSON request body using `Gson`.
4. **Business Logic & Rule Engine (`EligibilityService.java`)**:
   - Server re-queries student academic records and drive criteria from the database.
   - Runs `eligibilityService.checkEligibility(student, drive)`:
     - Verifies CGPA.
     - Verifies standing arrears.
     - Verifies branch.
   - *Security Check*: Even if a student manually modifies client JavaScript, the backend rejects disqualified applicants with `HTTP 400 Bad Request`.
5. **Database Execution (`ApplicationDAO.java`)**:
   - Checks `hasApplied(studentId, driveId)`.
   - Executes `INSERT INTO applications (student_id, drive_id, status, remarks) VALUES (?, ?, 'APPLIED', ?)`.
   - MySQL evaluates the `uq_student_drive` constraint and commits the row.
6. **Response**:
   - Server responds with `HTTP 200 OK` and a JSON success message.
   - Frontend `showToast()` displays a green notification and updates the button to *"Already Applied"*.

---

## 6. Faculty Viva Q&A Cheat Sheet

| Question | Recommended Answer |
| :--- | :--- |
| **Q1: Which design pattern did you use in the backend?** | *"We used the **DAO (Data Access Object) Pattern** to abstract database operations away from controllers, and the **Strategy/Specification Pattern** in `EligibilityService` to evaluate polymorphic criteria (CGPA, arrears, department) independently."* |
| **Q2: Why didn't you use Spring Boot or Tomcat?** | *"We wanted to demonstrate foundational mastery of Java networking and OOP without framework bloat. We utilized Java 17's built-in `com.sun.net.httpserver.HttpServer` with a multi-threaded fixed thread pool executor, making the application 100% self-contained and runnable on any computer."* |
| **Q3: How is your database normalized?** | *"The schema is in **Third Normal Form (3NF)**. There are no repeating groups (1NF), all non-key attributes depend fully on primary keys (2NF), and transitive dependencies are eliminated by separating authentication (`users`) from student details (`students`) and company info (`companies`) from placement drives (`job_drives`)."* |
| **Q4: How did you ensure data integrity?** | *"We implemented Foreign Keys with `ON DELETE CASCADE`, domain constraints using `CHECK (cgpa BETWEEN 0 AND 10)` and `CHECK (arrear_count >= 0)`, and a unique composite key `UNIQUE (student_id, drive_id)` to prevent duplicate job applications."* |
| **Q5: How does your system prevent SQL Injection?** | *"All database communications strictly use JDBC `PreparedStatement` with parameterized placeholders (`?`). No string concatenation is used in SQL queries."* |
| **Q6: How are ACID properties maintained during registration?** | *"Student registration requires inserts into both `users` and `students`. We disable autocommit (`conn.setAutoCommit(false)`), perform both inserts, and invoke `conn.commit()`. If either query fails, `conn.rollback()` restores the previous state, ensuring Atomicity."* |
| **Q7: What is the benefit of your SQL views?** | *"The view `vw_department_statistics` allows the placement office to retrieve branch-wise placement percentages, total offers, and highest/average packages on demand using SQL aggregate functions without having to duplicate or cache data."* |

---

## 7. Recommended 3-Minute Live Demonstration Script

1. **Open the Project**:
   - Double-click `Open in Chrome.bat` (or visit `http://localhost:8080`).
2. **Showcase Landing Page**:
   - Point out the hero banner and live campus metrics ticker populated from MySQL.
3. **Show Student Experience & Dynamic Eligibility**:
   - Click **"Student Login"**, auto-fill `karthik.ece` / `student123` (Student with 1 standing arrear).
   - Point to Google and Zoho: Show that they are **🔴 NOT ELIGIBLE** because they require 0 arrears.
   - Point to TCS: Show that it is **🟢 ELIGIBLE** because TCS allows up to 1 arrear.
   - Click **"Edit Academic Profile"**, change arrears from `1` to `0`, and save.
   - Show the faculty that Zoho **instantly switches to 🟢 ELIGIBLE** right in front of their eyes!
4. **Submit Application**:
   - Click **"Apply Now"** for Zoho.
   - Switch to **"My Application Status"** tab to show the status badge is `APPLIED`.
5. **Showcase Admin Portal**:
   - Sign out and log in as `admin` / `admin123`.
   - Show the **Department Placement Performance Table** generated from the MySQL View.
   - Go to **Applications Review**, locate the candidate's application, click **"Review"**, change status to `SELECTED`, and add a remark.
   - Return to the **Placement Analytics** tab to show the placement rate has recalculated automatically!
