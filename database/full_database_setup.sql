-- =========================================
-- FILE: database/schema.sql
-- =========================================
-- School leadership/profile seed data
CREATE TABLE IF NOT EXISTS school_profile(
 id SERIAL PRIMARY KEY,
 president_bn VARCHAR(150),
 head_teacher_bn VARCHAR(150),
 assistant_head_teacher_bn VARCHAR(150),
 ict_teacher_bn VARCHAR(150),
 building_image VARCHAR(255),
 updated_at TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO school_profile(president_bn,head_teacher_bn,assistant_head_teacher_bn,ict_teacher_bn,building_image)
SELECT 'নেয়ামুল হক খান','মুহাম্মদ শফিকুল ইসলাম','তাপসী সরকার','মুহাম্মদ আবুবকর সিদ্দিক','/school-building.jpg'
WHERE NOT EXISTS (SELECT 1 FROM school_profile);
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE TABLE IF NOT EXISTS roles(id SERIAL PRIMARY KEY,name VARCHAR(60) UNIQUE NOT NULL,label_bn VARCHAR(100) NOT NULL);
INSERT INTO roles(name,label_bn) VALUES
('super_admin','সুপার অ্যাডমিন'),('admin','অ্যাডমিন'),('head_teacher','প্রধান শিক্ষক'),('assistant_head_teacher','সহকারী প্রধান শিক্ষক'),('teacher','শিক্ষক'),('accountant','হিসাবরক্ষক'),('librarian','গ্রন্থাগারিক'),('student','শিক্ষার্থী'),('guardian','অভিভাবক'),('staff','কর্মচারী') ON CONFLICT(name) DO NOTHING;
CREATE TABLE IF NOT EXISTS permissions(id SERIAL PRIMARY KEY,code VARCHAR(100) UNIQUE NOT NULL,label_bn VARCHAR(150) NOT NULL);
CREATE TABLE IF NOT EXISTS role_permissions(role_id INT REFERENCES roles(id) ON DELETE CASCADE,permission_id INT REFERENCES permissions(id) ON DELETE CASCADE,PRIMARY KEY(role_id,permission_id));
CREATE TABLE IF NOT EXISTS users(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),login_id VARCHAR(100) UNIQUE NOT NULL,full_name VARCHAR(180) NOT NULL,email VARCHAR(180),phone VARCHAR(40),password_hash TEXT NOT NULL,role_id INT NOT NULL REFERENCES roles(id),is_active BOOLEAN NOT NULL DEFAULT TRUE,must_change_password BOOLEAN NOT NULL DEFAULT FALSE,last_login_at TIMESTAMPTZ,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE IF NOT EXISTS students(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),student_id VARCHAR(60) UNIQUE NOT NULL,roll_no INT,name_bn VARCHAR(180) NOT NULL,name_en VARCHAR(180),class_name VARCHAR(30) NOT NULL,section VARCHAR(30),gender VARCHAR(30),date_of_birth DATE,blood_group VARCHAR(10),religion VARCHAR(50),father_name VARCHAR(180),mother_name VARCHAR(180),guardian_name VARCHAR(180),guardian_relation VARCHAR(80),guardian_phone VARCHAR(40),guardian_email VARCHAR(180),address TEXT,admission_date DATE,admission_class VARCHAR(30),previous_school VARCHAR(250),birth_registration_no VARCHAR(80),emergency_phone VARCHAR(40),photo_url TEXT,status VARCHAR(30) NOT NULL DEFAULT 'active',created_at TIMESTAMPTZ DEFAULT NOW(),updated_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS teachers(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),employee_id VARCHAR(60) UNIQUE NOT NULL,name_bn VARCHAR(180) NOT NULL,name_en VARCHAR(180),designation VARCHAR(120),designation_en VARCHAR(120),subject VARCHAR(120),phone VARCHAR(40),email VARCHAR(180),joining_date DATE,gender VARCHAR(30),address TEXT,user_id UUID REFERENCES users(id) ON DELETE SET NULL,photo_url TEXT,status VARCHAR(30) DEFAULT 'active');
CREATE TABLE IF NOT EXISTS staff(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),employee_id VARCHAR(60) UNIQUE NOT NULL,name_bn VARCHAR(180) NOT NULL,name_en VARCHAR(180),designation VARCHAR(120) NOT NULL,phone VARCHAR(40),email VARCHAR(180),joining_date DATE,gender VARCHAR(30),address TEXT,status VARCHAR(30) NOT NULL DEFAULT 'active',user_id UUID REFERENCES users(id) ON DELETE SET NULL,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE IF NOT EXISTS academic_years(id SERIAL PRIMARY KEY,year INT UNIQUE NOT NULL,is_current BOOLEAN DEFAULT FALSE);
CREATE TABLE IF NOT EXISTS subjects(id SERIAL PRIMARY KEY,code VARCHAR(30) UNIQUE NOT NULL,name_bn VARCHAR(120) NOT NULL,name_en VARCHAR(120),class_name VARCHAR(30),full_marks NUMERIC(8,2) DEFAULT 100,pass_marks NUMERIC(8,2) DEFAULT 33,active BOOLEAN DEFAULT TRUE);
CREATE TABLE IF NOT EXISTS exams(id SERIAL PRIMARY KEY,name_bn VARCHAR(150) NOT NULL,exam_type VARCHAR(60),academic_year_id INT REFERENCES academic_years(id),start_date DATE,end_date DATE,status VARCHAR(30) DEFAULT 'draft');
CREATE TABLE IF NOT EXISTS marks(id BIGSERIAL PRIMARY KEY,exam_id INT REFERENCES exams(id) ON DELETE CASCADE,student_id UUID REFERENCES students(id) ON DELETE CASCADE,subject_id INT REFERENCES subjects(id),written NUMERIC(8,2),mcq NUMERIC(8,2),practical NUMERIC(8,2),total NUMERIC(8,2),grade VARCHAR(10),gpa NUMERIC(4,2),remarks TEXT,UNIQUE(exam_id,student_id,subject_id));
CREATE TABLE IF NOT EXISTS attendance(id BIGSERIAL PRIMARY KEY,student_id UUID REFERENCES students(id) ON DELETE CASCADE,attendance_date DATE NOT NULL,status VARCHAR(20) NOT NULL,remarks TEXT,UNIQUE(student_id,attendance_date));
CREATE TABLE IF NOT EXISTS notices(id SERIAL PRIMARY KEY,title_bn VARCHAR(250) NOT NULL,title_en VARCHAR(250),body TEXT,notice_date DATE DEFAULT CURRENT_DATE,published BOOLEAN DEFAULT FALSE,urgent BOOLEAN DEFAULT FALSE,attachment_url TEXT,created_by UUID REFERENCES users(id));
CREATE TABLE IF NOT EXISTS fees(id BIGSERIAL PRIMARY KEY,student_id UUID REFERENCES students(id),fee_type VARCHAR(80) NOT NULL,amount NUMERIC(12,2) NOT NULL,due_date DATE,status VARCHAR(30) DEFAULT 'due',paid_at TIMESTAMPTZ,receipt_no VARCHAR(80) UNIQUE);
CREATE TABLE IF NOT EXISTS books(id SERIAL PRIMARY KEY,isbn VARCHAR(60),title VARCHAR(250) NOT NULL,author VARCHAR(180),category VARCHAR(100),quantity INT DEFAULT 1,available_quantity INT DEFAULT 1);
CREATE TABLE IF NOT EXISTS library_loans(id BIGSERIAL PRIMARY KEY,book_id INT REFERENCES books(id),student_id UUID REFERENCES students(id),issued_at DATE DEFAULT CURRENT_DATE,due_at DATE,returned_at DATE,fine NUMERIC(10,2) DEFAULT 0);
CREATE TABLE IF NOT EXISTS routines(id SERIAL PRIMARY KEY,class_name VARCHAR(30),section VARCHAR(30),day_of_week INT,start_time TIME,end_time TIME,subject_id INT REFERENCES subjects(id),teacher_id UUID REFERENCES teachers(id),room VARCHAR(60));
CREATE TABLE IF NOT EXISTS audit_logs(id BIGSERIAL PRIMARY KEY,user_id UUID REFERENCES users(id),action VARCHAR(100) NOT NULL,entity VARCHAR(100),entity_id VARCHAR(100),details JSONB,created_at TIMESTAMPTZ DEFAULT NOW());
CREATE INDEX IF NOT EXISTS idx_students_class ON students(class_name,section,roll_no);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(attendance_date);
CREATE INDEX IF NOT EXISTS idx_marks_exam_student ON marks(exam_id,student_id);
CREATE INDEX IF NOT EXISTS idx_notices_published_date ON notices(published,notice_date DESC);
-- Development-only account. Change password immediately in a real deployment.
-- Password: ChangeMe123!
INSERT INTO users(login_id,full_name,password_hash,role_id,must_change_password)
SELECT '114290','System Administrator',crypt('ChangeMe123!',gen_salt('bf')),r.id,TRUE FROM roles r WHERE r.name='super_admin'
ON CONFLICT(login_id) DO NOTHING;

-- V5 security/RBAC permission seed
INSERT INTO permissions(code,label_bn) VALUES
('user.view','ব্যবহারকারী দেখা'),('user.create','ব্যবহারকারী তৈরি'),('user.update','ব্যবহারকারী সম্পাদনা'),('user.role','Role পরিবর্তন'),('user.password_reset','Password reset'),('student.view','শিক্ষার্থী দেখা'),('student.manage','শিক্ষার্থী ব্যবস্থাপনা'),('attendance.manage','উপস্থিতি ব্যবস্থাপনা'),('result.manage','ফলাফল ব্যবস্থাপনা'),('notice.manage','নোটিশ ব্যবস্থাপনা')
ON CONFLICT(code) DO NOTHING;
INSERT INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permissions p
WHERE r.name IN ('super_admin','admin') ON CONFLICT DO NOTHING;
INSERT INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r JOIN permissions p ON p.code IN ('student.view','attendance.manage','result.manage','notice.manage')
WHERE r.name='head_teacher' ON CONFLICT DO NOTHING;
INSERT INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r JOIN permissions p ON p.code IN ('student.view','attendance.manage','result.manage')
WHERE r.name IN ('assistant_head_teacher','teacher') ON CONFLICT DO NOTHING;
CREATE TABLE IF NOT EXISTS admission_applications(
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 application_no VARCHAR(50) UNIQUE NOT NULL,
 academic_year INT NOT NULL,
 applied_class VARCHAR(30) NOT NULL,
 applicant_name_bn VARCHAR(180) NOT NULL,
 applicant_name_en VARCHAR(180),
 date_of_birth DATE,
 gender VARCHAR(30),
 birth_registration_no VARCHAR(80),
 father_name VARCHAR(180),
 mother_name VARCHAR(180),
 guardian_name VARCHAR(180),
 guardian_phone VARCHAR(40) NOT NULL,
 guardian_email VARCHAR(180),
 address TEXT,
 previous_school VARCHAR(250),
 quota VARCHAR(80),
 application_date DATE NOT NULL DEFAULT CURRENT_DATE,
 status VARCHAR(30) NOT NULL DEFAULT 'submitted',
 admission_test_mark NUMERIC(8,2),
 payment_amount NUMERIC(12,2) DEFAULT 0,
 payment_status VARCHAR(30) NOT NULL DEFAULT 'unpaid',
 notes TEXT,
 converted_student_id UUID REFERENCES students(id) ON DELETE SET NULL,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_admission_year_class ON admission_applications(academic_year, applied_class);
CREATE INDEX IF NOT EXISTS idx_admission_status ON admission_applications(status);
CREATE INDEX IF NOT EXISTS idx_admission_phone ON admission_applications(guardian_phone);

-- V9 Examination & Result Engine
CREATE TABLE IF NOT EXISTS grading_schemes(id SERIAL PRIMARY KEY,name_bn VARCHAR(150) NOT NULL,name_en VARCHAR(150),board VARCHAR(120),academic_year INT,pass_percent NUMERIC(5,2) DEFAULT 33,active BOOLEAN DEFAULT TRUE,created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS grade_rules(id SERIAL PRIMARY KEY,scheme_id INT NOT NULL REFERENCES grading_schemes(id) ON DELETE CASCADE,min_percent NUMERIC(5,2) NOT NULL,max_percent NUMERIC(5,2) NOT NULL,letter_grade VARCHAR(10) NOT NULL,gpa NUMERIC(4,2) NOT NULL,UNIQUE(scheme_id,min_percent,max_percent));
CREATE TABLE IF NOT EXISTS exam_subjects(id SERIAL PRIMARY KEY,exam_id INT NOT NULL REFERENCES exams(id) ON DELETE CASCADE,subject_id INT NOT NULL REFERENCES subjects(id),full_marks NUMERIC(8,2) DEFAULT 100,pass_marks NUMERIC(8,2) DEFAULT 33,written_max NUMERIC(8,2) DEFAULT 100,mcq_max NUMERIC(8,2) DEFAULT 0,practical_max NUMERIC(8,2) DEFAULT 0,UNIQUE(exam_id,subject_id));
CREATE INDEX IF NOT EXISTS idx_exam_subjects_exam ON exam_subjects(exam_id);
CREATE INDEX IF NOT EXISTS idx_grade_rules_scheme ON grade_rules(scheme_id,min_percent DESC);
ALTER TABLE exams ADD COLUMN IF NOT EXISTS grading_scheme_id INT REFERENCES grading_schemes(id);
ALTER TABLE marks ADD COLUMN IF NOT EXISTS absent BOOLEAN DEFAULT FALSE;
ALTER TABLE marks ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;

-- V10 Finance & Library enhancements
CREATE TABLE IF NOT EXISTS fee_payments(id BIGSERIAL PRIMARY KEY,fee_id BIGINT NOT NULL REFERENCES fees(id) ON DELETE CASCADE,amount NUMERIC(12,2) NOT NULL CHECK(amount>0),payment_method VARCHAR(30) DEFAULT 'cash',reference VARCHAR(120),paid_at TIMESTAMPTZ DEFAULT NOW(),received_by UUID REFERENCES users(id));
CREATE TABLE IF NOT EXISTS expenses(id BIGSERIAL PRIMARY KEY,title VARCHAR(200) NOT NULL,category VARCHAR(100),amount NUMERIC(12,2) NOT NULL CHECK(amount>0),expense_date DATE DEFAULT CURRENT_DATE,notes TEXT,created_by UUID REFERENCES users(id),created_at TIMESTAMPTZ DEFAULT NOW());

-- V11 portal/learning additions
ALTER TABLE students ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
CREATE TABLE IF NOT EXISTS guardian_student_links(id BIGSERIAL PRIMARY KEY,guardian_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,relation VARCHAR(50),UNIQUE(guardian_user_id,student_id));
CREATE TABLE IF NOT EXISTS learning_contents(id BIGSERIAL PRIMARY KEY,class_name VARCHAR(30) NOT NULL,subject_id INT REFERENCES subjects(id) ON DELETE SET NULL,title_bn VARCHAR(250) NOT NULL,title_en VARCHAR(250),content_type VARCHAR(30) NOT NULL DEFAULT 'note',content_url TEXT,body TEXT,published BOOLEAN NOT NULL DEFAULT FALSE,created_by UUID REFERENCES users(id) ON DELETE SET NULL,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());

-- V13 assessment/learning tables (see migration 012_assessment_learning.sql)

-- V14 migration
-- V14: AI Education, study plans and learning analytics foundation
CREATE TABLE IF NOT EXISTS ai_conversations(
 id BIGSERIAL PRIMARY KEY,
 user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 title VARCHAR(200),
 language VARCHAR(10) NOT NULL DEFAULT 'bn',
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS ai_messages(
 id BIGSERIAL PRIMARY KEY,
 conversation_id BIGINT NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
 role VARCHAR(20) NOT NULL CHECK(role IN ('user','assistant','system')),
 message TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_messages_conversation ON ai_messages(conversation_id,created_at);
CREATE TABLE IF NOT EXISTS study_plans(
 id BIGSERIAL PRIMARY KEY,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 title_bn VARCHAR(250) NOT NULL,
 goal TEXT,
 start_date DATE NOT NULL,
 end_date DATE NOT NULL,
 plan_json JSONB NOT NULL DEFAULT '[]'::jsonb,
 status VARCHAR(20) NOT NULL DEFAULT 'active',
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_study_plans_student ON study_plans(student_id,status);
CREATE TABLE IF NOT EXISTS ai_feedback(
 id BIGSERIAL PRIMARY KEY,
 student_id UUID REFERENCES students(id) ON DELETE CASCADE,
 topic VARCHAR(200),
 feedback_type VARCHAR(50),
 feedback TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_feedback_student ON ai_feedback(student_id,created_at DESC);

-- V15 Advanced Reports & Analytics indexes
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, attendance_date DESC);
CREATE INDEX IF NOT EXISTS idx_marks_student_exam ON marks(student_id, exam_id);
CREATE INDEX IF NOT EXISTS idx_fee_payments_paid_at ON fee_payments(paid_at DESC);
CREATE INDEX IF NOT EXISTS idx_library_loans_student_returned ON library_loans(student_id, returned_at);
CREATE INDEX IF NOT EXISTS idx_admission_application_date ON admission_applications(application_date DESC);
-- V16 Official Documents & Print System
CREATE TABLE IF NOT EXISTS document_templates(
 id BIGSERIAL PRIMARY KEY,
 document_type VARCHAR(40) NOT NULL UNIQUE,
 name_bn VARCHAR(150) NOT NULL,
 name_en VARCHAR(150),
 active BOOLEAN NOT NULL DEFAULT TRUE,
 settings JSONB NOT NULL DEFAULT '{}'::jsonb,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS issued_documents(
 id BIGSERIAL PRIMARY KEY,
 document_type VARCHAR(40) NOT NULL,
 student_id UUID REFERENCES students(id) ON DELETE SET NULL,
 exam_id INT REFERENCES exams(id) ON DELETE SET NULL,
 document_no VARCHAR(80) NOT NULL UNIQUE,
 issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
 data_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
 issued_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_issued_documents_student ON issued_documents(student_id,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_issued_documents_type ON issued_documents(document_type,issue_date DESC);
INSERT INTO document_templates(document_type,name_bn,name_en) VALUES
 ('id_card','শিক্ষার্থী পরিচয়পত্র','Student ID Card'),
 ('marksheet','মার্কশিট','Marksheet'),
 ('progress_report','প্রগ্রেস রিপোর্ট','Progress Report'),
 ('certificate','সনদপত্র','Certificate'),
 ('admit_card','প্রবেশপত্র','Admit Card'),
 ('tabulation','ট্যাবুলেশন শিট','Tabulation Sheet'),
 ('merit_list','মেধা তালিকা','Merit List')
ON CONFLICT(document_type) DO NOTHING;

-- V17 Notifications & Communication
CREATE TABLE IF NOT EXISTS notifications(
 id BIGSERIAL PRIMARY KEY,
 recipient_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 title_bn VARCHAR(250) NOT NULL,
 title_en VARCHAR(250),
 body TEXT,
 type VARCHAR(40) NOT NULL DEFAULT 'general',
 priority VARCHAR(20) NOT NULL DEFAULT 'normal' CHECK(priority IN ('low','normal','high','urgent')),
 entity_type VARCHAR(60),
 entity_id VARCHAR(100),
 action_url TEXT,
 is_read BOOLEAN NOT NULL DEFAULT FALSE,
 read_at TIMESTAMPTZ,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_user_id,is_read,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type,created_at DESC);
CREATE TABLE IF NOT EXISTS notification_preferences(
 id BIGSERIAL PRIMARY KEY,
 user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 channel VARCHAR(20) NOT NULL DEFAULT 'in_app' CHECK(channel IN ('in_app','email','sms','push')),
 notification_type VARCHAR(40) NOT NULL DEFAULT 'general',
 enabled BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE(user_id,channel,notification_type)
);
CREATE TABLE IF NOT EXISTS communication_messages(
 id BIGSERIAL PRIMARY KEY,
 sender_user_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
 recipient_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
 recipient_group VARCHAR(30),
 subject_bn VARCHAR(250),
 body TEXT NOT NULL,
 channel VARCHAR(20) NOT NULL DEFAULT 'in_app',
 status VARCHAR(20) NOT NULL DEFAULT 'queued',
 sent_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 CHECK(recipient_user_id IS NOT NULL OR recipient_group IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_communication_messages_recipient ON communication_messages(recipient_user_id,created_at DESC);

-- V22 session invalidation: increment when password/role/status changes to invalidate old JWTs
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_token_version INTEGER NOT NULL DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_users_auth_token_version ON users(id, auth_token_version);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\006_student_staff_management.sql
-- =========================================
-- V6: Student & Staff management enhancement
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS photo_url TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS gender VARCHAR(30);
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS designation_en VARCHAR(120);
ALTER TABLE students ADD COLUMN IF NOT EXISTS photo_url TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS blood_group VARCHAR(10);
ALTER TABLE students ADD COLUMN IF NOT EXISTS religion VARCHAR(50);
ALTER TABLE students ADD COLUMN IF NOT EXISTS father_name VARCHAR(180);
ALTER TABLE students ADD COLUMN IF NOT EXISTS mother_name VARCHAR(180);
ALTER TABLE students ADD COLUMN IF NOT EXISTS guardian_relation VARCHAR(80);
ALTER TABLE students ADD COLUMN IF NOT EXISTS guardian_email VARCHAR(180);
ALTER TABLE students ADD COLUMN IF NOT EXISTS previous_school VARCHAR(250);
ALTER TABLE students ADD COLUMN IF NOT EXISTS admission_class VARCHAR(30);
ALTER TABLE students ADD COLUMN IF NOT EXISTS birth_registration_no VARCHAR(80);
ALTER TABLE students ADD COLUMN IF NOT EXISTS emergency_phone VARCHAR(40);
CREATE TABLE IF NOT EXISTS staff(
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), employee_id VARCHAR(60) UNIQUE NOT NULL,
 name_bn VARCHAR(180) NOT NULL, name_en VARCHAR(180), designation VARCHAR(120) NOT NULL,
 phone VARCHAR(40), email VARCHAR(180), joining_date DATE, gender VARCHAR(30), address TEXT,
 status VARCHAR(30) NOT NULL DEFAULT 'active', user_id UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_staff_status ON staff(status);
CREATE INDEX IF NOT EXISTS idx_teachers_status ON teachers(status);
CREATE INDEX IF NOT EXISTS idx_students_status ON students(status);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\007_attendance_smart.sql
-- =========================================
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, attendance_date DESC);
CREATE INDEX IF NOT EXISTS idx_students_active_class ON students(status, class_name, section, roll_no);
DO $$ BEGIN ALTER TABLE attendance ADD CONSTRAINT attendance_status_check CHECK (status IN ('present','absent','late','leave')) NOT VALID; EXCEPTION WHEN duplicate_object THEN NULL; END $$;


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\008_admission.sql
-- =========================================
CREATE TABLE IF NOT EXISTS admission_applications(
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 application_no VARCHAR(50) UNIQUE NOT NULL,
 academic_year INT NOT NULL,
 applied_class VARCHAR(30) NOT NULL,
 applicant_name_bn VARCHAR(180) NOT NULL,
 applicant_name_en VARCHAR(180),
 date_of_birth DATE,
 gender VARCHAR(30),
 birth_registration_no VARCHAR(80),
 father_name VARCHAR(180),
 mother_name VARCHAR(180),
 guardian_name VARCHAR(180),
 guardian_phone VARCHAR(40) NOT NULL,
 guardian_email VARCHAR(180),
 address TEXT,
 previous_school VARCHAR(250),
 quota VARCHAR(80),
 application_date DATE NOT NULL DEFAULT CURRENT_DATE,
 status VARCHAR(30) NOT NULL DEFAULT 'submitted',
 admission_test_mark NUMERIC(8,2),
 payment_amount NUMERIC(12,2) DEFAULT 0,
 payment_status VARCHAR(30) NOT NULL DEFAULT 'unpaid',
 notes TEXT,
 converted_student_id UUID REFERENCES students(id) ON DELETE SET NULL,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_admission_year_class ON admission_applications(academic_year, applied_class);
CREATE INDEX IF NOT EXISTS idx_admission_status ON admission_applications(status);
CREATE INDEX IF NOT EXISTS idx_admission_phone ON admission_applications(guardian_phone);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\009_examination_result.sql
-- =========================================
-- V9 Examination & Result Engine
CREATE TABLE IF NOT EXISTS grading_schemes(
 id SERIAL PRIMARY KEY, name_bn VARCHAR(150) NOT NULL, name_en VARCHAR(150), board VARCHAR(120), academic_year INT,
 pass_percent NUMERIC(5,2) DEFAULT 33, active BOOLEAN DEFAULT TRUE, created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS grade_rules(
 id SERIAL PRIMARY KEY, scheme_id INT NOT NULL REFERENCES grading_schemes(id) ON DELETE CASCADE,
 min_percent NUMERIC(5,2) NOT NULL, max_percent NUMERIC(5,2) NOT NULL, letter_grade VARCHAR(10) NOT NULL, gpa NUMERIC(4,2) NOT NULL,
 UNIQUE(scheme_id,min_percent,max_percent)
);
CREATE TABLE IF NOT EXISTS exam_subjects(
 id SERIAL PRIMARY KEY, exam_id INT NOT NULL REFERENCES exams(id) ON DELETE CASCADE, subject_id INT NOT NULL REFERENCES subjects(id),
 full_marks NUMERIC(8,2) DEFAULT 100, pass_marks NUMERIC(8,2) DEFAULT 33,
 written_max NUMERIC(8,2) DEFAULT 100, mcq_max NUMERIC(8,2) DEFAULT 0, practical_max NUMERIC(8,2) DEFAULT 0,
 UNIQUE(exam_id,subject_id)
);
CREATE INDEX IF NOT EXISTS idx_exam_subjects_exam ON exam_subjects(exam_id);
CREATE INDEX IF NOT EXISTS idx_grade_rules_scheme ON grade_rules(scheme_id,min_percent DESC);
ALTER TABLE exams ADD COLUMN IF NOT EXISTS grading_scheme_id INT REFERENCES grading_schemes(id);
ALTER TABLE marks ADD COLUMN IF NOT EXISTS absent BOOLEAN DEFAULT FALSE;
ALTER TABLE marks ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;

INSERT INTO grading_schemes(name_bn,name_en,board,academic_year,pass_percent,active)
SELECT 'বাংলাদেশ মাধ্যমিক সাধারণ গ্রেডিং','Bangladesh Secondary General Grading','মাধ্যমিক শিক্ষা',EXTRACT(YEAR FROM CURRENT_DATE)::int,33,true
WHERE NOT EXISTS (SELECT 1 FROM grading_schemes);
INSERT INTO grade_rules(scheme_id,min_percent,max_percent,letter_grade,gpa)
SELECT g.id,v.min_percent,v.max_percent,v.letter_grade,v.gpa FROM grading_schemes g CROSS JOIN (VALUES
(80::numeric,100::numeric,'A+',5::numeric),(70,79.99,'A',4),(60,69.99,'A-',3.5),(50,59.99,'B',3),(40,49.99,'C',2),(33,39.99,'D',1),(0,32.99,'F',0)
) v(min_percent,max_percent,letter_grade,gpa)
WHERE NOT EXISTS (SELECT 1 FROM grade_rules r WHERE r.scheme_id=g.id);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\010_finance_library.sql
-- =========================================
-- V10 Finance & Library enhancements
CREATE TABLE IF NOT EXISTS fee_payments(
 id BIGSERIAL PRIMARY KEY, fee_id BIGINT NOT NULL REFERENCES fees(id) ON DELETE CASCADE,
 amount NUMERIC(12,2) NOT NULL CHECK(amount>0), payment_method VARCHAR(30) DEFAULT 'cash',
 reference VARCHAR(120), paid_at TIMESTAMPTZ DEFAULT NOW(), received_by UUID REFERENCES users(id)
);
CREATE TABLE IF NOT EXISTS expenses(
 id BIGSERIAL PRIMARY KEY, title VARCHAR(200) NOT NULL, category VARCHAR(100), amount NUMERIC(12,2) NOT NULL CHECK(amount>0),
 expense_date DATE DEFAULT CURRENT_DATE, notes TEXT, created_by UUID REFERENCES users(id), created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_fee_payments_fee ON fee_payments(fee_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\011_portals_learning.sql
-- =========================================
-- V11: portal identity links and digital learning foundation
ALTER TABLE students ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_students_user_id ON students(user_id);
CREATE TABLE IF NOT EXISTS guardian_student_links(
 id BIGSERIAL PRIMARY KEY,
 guardian_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 relation VARCHAR(50),
 UNIQUE(guardian_user_id,student_id)
);
CREATE INDEX IF NOT EXISTS idx_guardian_links_user ON guardian_student_links(guardian_user_id);
CREATE TABLE IF NOT EXISTS learning_contents(
 id BIGSERIAL PRIMARY KEY,
 class_name VARCHAR(30) NOT NULL,
 subject_id INT REFERENCES subjects(id) ON DELETE SET NULL,
 title_bn VARCHAR(250) NOT NULL,
 title_en VARCHAR(250),
 content_type VARCHAR(30) NOT NULL DEFAULT 'note',
 content_url TEXT,
 body TEXT,
 published BOOLEAN NOT NULL DEFAULT FALSE,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_learning_class_subject ON learning_contents(class_name,subject_id,published);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\012_assessment_learning.sql
-- =========================================
-- V13: Question Bank, Assignments and Online Exam foundation
CREATE TABLE IF NOT EXISTS question_bank(
 id BIGSERIAL PRIMARY KEY,
 class_name VARCHAR(30) NOT NULL,
 subject_id INT REFERENCES subjects(id) ON DELETE SET NULL,
 chapter VARCHAR(180),
 question_type VARCHAR(30) NOT NULL DEFAULT 'mcq',
 question_bn TEXT NOT NULL,
 question_en TEXT,
 options JSONB,
 correct_answer TEXT,
 marks NUMERIC(6,2) NOT NULL DEFAULT 1 CHECK(marks>0),
 difficulty VARCHAR(20) DEFAULT 'medium',
 explanation TEXT,
 published BOOLEAN NOT NULL DEFAULT FALSE,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_question_bank_filter ON question_bank(class_name,subject_id,question_type,published);

CREATE TABLE IF NOT EXISTS assignments(
 id BIGSERIAL PRIMARY KEY,
 title_bn VARCHAR(250) NOT NULL,
 subject_id INT REFERENCES subjects(id) ON DELETE SET NULL,
 class_name VARCHAR(30) NOT NULL,
 description TEXT,
 instructions TEXT,
 due_at TIMESTAMPTZ,
 max_marks NUMERIC(8,2) DEFAULT 100,
 status VARCHAR(30) NOT NULL DEFAULT 'draft',
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS assignment_submissions(
 id BIGSERIAL PRIMARY KEY,
 assignment_id BIGINT NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 answer_text TEXT,
 attachment_url TEXT,
 submitted_at TIMESTAMPTZ DEFAULT NOW(),
 marks NUMERIC(8,2),
 feedback TEXT,
 status VARCHAR(30) DEFAULT 'submitted',
 UNIQUE(assignment_id,student_id)
);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_student ON assignment_submissions(student_id,assignment_id);

CREATE TABLE IF NOT EXISTS online_exams(
 id BIGSERIAL PRIMARY KEY,
 title_bn VARCHAR(250) NOT NULL,
 subject_id INT REFERENCES subjects(id) ON DELETE SET NULL,
 class_name VARCHAR(30) NOT NULL,
 duration_minutes INT NOT NULL DEFAULT 30 CHECK(duration_minutes>0),
 total_marks NUMERIC(8,2) DEFAULT 0,
 pass_marks NUMERIC(8,2) DEFAULT 0,
 starts_at TIMESTAMPTZ,
 ends_at TIMESTAMPTZ,
 status VARCHAR(30) NOT NULL DEFAULT 'draft',
 shuffle_questions BOOLEAN DEFAULT TRUE,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS online_exam_questions(
 id BIGSERIAL PRIMARY KEY,
 online_exam_id BIGINT NOT NULL REFERENCES online_exams(id) ON DELETE CASCADE,
 question_id BIGINT NOT NULL REFERENCES question_bank(id) ON DELETE CASCADE,
 display_order INT NOT NULL DEFAULT 1,
 UNIQUE(online_exam_id,question_id)
);
CREATE TABLE IF NOT EXISTS online_exam_attempts(
 id BIGSERIAL PRIMARY KEY,
 online_exam_id BIGINT NOT NULL REFERENCES online_exams(id) ON DELETE CASCADE,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 started_at TIMESTAMPTZ DEFAULT NOW(),
 submitted_at TIMESTAMPTZ,
 score NUMERIC(8,2) DEFAULT 0,
 status VARCHAR(30) DEFAULT 'in_progress',
 UNIQUE(online_exam_id,student_id)
);
CREATE TABLE IF NOT EXISTS online_exam_answers(
 id BIGSERIAL PRIMARY KEY,
 attempt_id BIGINT NOT NULL REFERENCES online_exam_attempts(id) ON DELETE CASCADE,
 question_id BIGINT NOT NULL REFERENCES question_bank(id) ON DELETE CASCADE,
 answer TEXT,
 is_correct BOOLEAN,
 marks_awarded NUMERIC(8,2) DEFAULT 0,
 UNIQUE(attempt_id,question_id)
);
CREATE INDEX IF NOT EXISTS idx_online_exam_class_status ON online_exams(class_name,status);
CREATE INDEX IF NOT EXISTS idx_online_attempt_student ON online_exam_attempts(student_id,online_exam_id);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\013_ai_education.sql
-- =========================================
-- V14: AI Education, study plans and learning analytics foundation
CREATE TABLE IF NOT EXISTS ai_conversations(
 id BIGSERIAL PRIMARY KEY,
 user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 title VARCHAR(200),
 language VARCHAR(10) NOT NULL DEFAULT 'bn',
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS ai_messages(
 id BIGSERIAL PRIMARY KEY,
 conversation_id BIGINT NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
 role VARCHAR(20) NOT NULL CHECK(role IN ('user','assistant','system')),
 message TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_messages_conversation ON ai_messages(conversation_id,created_at);
CREATE TABLE IF NOT EXISTS study_plans(
 id BIGSERIAL PRIMARY KEY,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 title_bn VARCHAR(250) NOT NULL,
 goal TEXT,
 start_date DATE NOT NULL,
 end_date DATE NOT NULL,
 plan_json JSONB NOT NULL DEFAULT '[]'::jsonb,
 status VARCHAR(20) NOT NULL DEFAULT 'active',
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_study_plans_student ON study_plans(student_id,status);
CREATE TABLE IF NOT EXISTS ai_feedback(
 id BIGSERIAL PRIMARY KEY,
 student_id UUID REFERENCES students(id) ON DELETE CASCADE,
 topic VARCHAR(200),
 feedback_type VARCHAR(50),
 feedback TEXT NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_feedback_student ON ai_feedback(student_id,created_at DESC);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\014_reports_analytics.sql
-- =========================================
-- V15: Advanced Reports & Analytics
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, attendance_date DESC);
CREATE INDEX IF NOT EXISTS idx_marks_student_exam ON marks(student_id, exam_id);
CREATE INDEX IF NOT EXISTS idx_fee_payments_paid_at ON fee_payments(paid_at DESC);
CREATE INDEX IF NOT EXISTS idx_library_loans_student_returned ON library_loans(student_id, returned_at);
CREATE INDEX IF NOT EXISTS idx_admission_application_date ON admission_applications(application_date DESC);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\015_documents_print.sql
-- =========================================
-- V16 Official Documents & Print System
CREATE TABLE IF NOT EXISTS document_templates(
 id BIGSERIAL PRIMARY KEY,
 document_type VARCHAR(40) NOT NULL UNIQUE,
 name_bn VARCHAR(150) NOT NULL,
 name_en VARCHAR(150),
 active BOOLEAN NOT NULL DEFAULT TRUE,
 settings JSONB NOT NULL DEFAULT '{}'::jsonb,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS issued_documents(
 id BIGSERIAL PRIMARY KEY,
 document_type VARCHAR(40) NOT NULL,
 student_id UUID REFERENCES students(id) ON DELETE SET NULL,
 exam_id INT REFERENCES exams(id) ON DELETE SET NULL,
 document_no VARCHAR(80) NOT NULL UNIQUE,
 issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
 data_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
 issued_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_issued_documents_student ON issued_documents(student_id,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_issued_documents_type ON issued_documents(document_type,issue_date DESC);
INSERT INTO document_templates(document_type,name_bn,name_en) VALUES
 ('id_card','শিক্ষার্থী পরিচয়পত্র','Student ID Card'),
 ('marksheet','মার্কশিট','Marksheet'),
 ('progress_report','প্রগ্রেস রিপোর্ট','Progress Report'),
 ('certificate','সনদপত্র','Certificate'),
 ('admit_card','প্রবেশপত্র','Admit Card'),
 ('tabulation','ট্যাবুলেশন শিট','Tabulation Sheet'),
 ('merit_list','মেধা তালিকা','Merit List')
ON CONFLICT(document_type) DO NOTHING;


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\016_notifications_communication.sql
-- =========================================
-- V17: Notifications & Communication
CREATE TABLE IF NOT EXISTS notifications(
 id BIGSERIAL PRIMARY KEY,
 recipient_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 title_bn VARCHAR(250) NOT NULL,
 title_en VARCHAR(250),
 body TEXT,
 type VARCHAR(40) NOT NULL DEFAULT 'general',
 priority VARCHAR(20) NOT NULL DEFAULT 'normal' CHECK(priority IN ('low','normal','high','urgent')),
 entity_type VARCHAR(60),
 entity_id VARCHAR(100),
 action_url TEXT,
 is_read BOOLEAN NOT NULL DEFAULT FALSE,
 read_at TIMESTAMPTZ,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_user_id,is_read,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type,created_at DESC);

CREATE TABLE IF NOT EXISTS notification_preferences(
 id BIGSERIAL PRIMARY KEY,
 user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 channel VARCHAR(20) NOT NULL DEFAULT 'in_app' CHECK(channel IN ('in_app','email','sms','push')),
 notification_type VARCHAR(40) NOT NULL DEFAULT 'general',
 enabled BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE(user_id,channel,notification_type)
);

CREATE TABLE IF NOT EXISTS communication_messages(
 id BIGSERIAL PRIMARY KEY,
 sender_user_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
 recipient_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
 recipient_group VARCHAR(30),
 subject_bn VARCHAR(250),
 body TEXT NOT NULL,
 channel VARCHAR(20) NOT NULL DEFAULT 'in_app' CHECK(channel IN ('in_app','email','sms','push')),
 status VARCHAR(20) NOT NULL DEFAULT 'queued' CHECK(status IN ('queued','sent','failed')),
 sent_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 CHECK(recipient_user_id IS NOT NULL OR recipient_group IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_communication_messages_sender ON communication_messages(sender_user_id,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_communication_messages_recipient ON communication_messages(recipient_user_id,created_at DESC);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\017_session_invalidation.sql
-- =========================================
-- V22: Session invalidation / token versioning
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_token_version INTEGER NOT NULL DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_users_auth_token_version ON users(id, auth_token_version);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\018_routine_integrity.sql
-- =========================================
-- V23 routine integrity and lookup indexes
CREATE INDEX IF NOT EXISTS idx_routines_class_day_time ON routines(class_name,section,day_of_week,start_time);
CREATE INDEX IF NOT EXISTS idx_routines_teacher_day_time ON routines(teacher_id,day_of_week,start_time);
-- Prevent exact duplicate slots for the same class/section.
CREATE UNIQUE INDEX IF NOT EXISTS uq_routine_exact_slot ON routines(class_name,(COALESCE(section,'')),day_of_week,start_time,end_time);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\019_co_curricular_content.sql
-- =========================================
CREATE TABLE IF NOT EXISTS school_content_items (
 id BIGSERIAL PRIMARY KEY,
 content_type VARCHAR(30) NOT NULL CHECK (content_type IN ('event','achievement','scholarship','facility')),
 title_bn VARCHAR(220) NOT NULL,
 title_en VARCHAR(220),
 description TEXT,
 event_date DATE,
 location VARCHAR(180),
 status VARCHAR(30) NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published','archived')),
 sort_order INT NOT NULL DEFAULT 0,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_school_content_type_status ON school_content_items(content_type,status,sort_order,event_date DESC);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\020_school_content_expansion.sql
-- =========================================
-- V36: expand public school-life content and gallery metadata
ALTER TABLE school_content_items DROP CONSTRAINT IF EXISTS school_content_items_content_type_check;
ALTER TABLE school_content_items ADD CONSTRAINT school_content_items_content_type_check
CHECK (content_type IN ('event','achievement','scholarship','facility','institution','sport','gallery','transport','hostel','club','library_info'));
ALTER TABLE school_content_items ADD COLUMN IF NOT EXISTS image_url TEXT;
CREATE INDEX IF NOT EXISTS idx_school_content_gallery ON school_content_items(content_type,status,event_date DESC);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\021_transport_hostel.sql
-- =========================================
-- V48: operational transport and hostel management
CREATE TABLE IF NOT EXISTS transport_vehicles (
 id BIGSERIAL PRIMARY KEY, vehicle_no VARCHAR(60) UNIQUE NOT NULL, vehicle_type VARCHAR(40) NOT NULL DEFAULT 'bus', capacity INT NOT NULL DEFAULT 0 CHECK(capacity>=0), driver_name VARCHAR(180), driver_phone VARCHAR(40), route_name VARCHAR(180), active BOOLEAN NOT NULL DEFAULT TRUE, notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS transport_assignments (
 id BIGSERIAL PRIMARY KEY, vehicle_id BIGINT NOT NULL REFERENCES transport_vehicles(id) ON DELETE CASCADE, student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE, pickup_point VARCHAR(180), monthly_fee NUMERIC(10,2) DEFAULT 0 CHECK(monthly_fee>=0), status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK(status IN ('active','inactive')), assigned_at DATE NOT NULL DEFAULT CURRENT_DATE, UNIQUE(vehicle_id,student_id)
);
CREATE INDEX IF NOT EXISTS idx_transport_assignment_student ON transport_assignments(student_id,status);
CREATE TABLE IF NOT EXISTS hostel_rooms (
 id BIGSERIAL PRIMARY KEY, room_no VARCHAR(40) UNIQUE NOT NULL, building VARCHAR(100), floor_no VARCHAR(30), capacity INT NOT NULL DEFAULT 0 CHECK(capacity>=0), gender VARCHAR(30), supervisor_name VARCHAR(180), active BOOLEAN NOT NULL DEFAULT TRUE, notes TEXT
);
CREATE TABLE IF NOT EXISTS hostel_assignments (
 id BIGSERIAL PRIMARY KEY, room_id BIGINT NOT NULL REFERENCES hostel_rooms(id) ON DELETE CASCADE, student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE, bed_no VARCHAR(30), monthly_fee NUMERIC(10,2) DEFAULT 0 CHECK(monthly_fee>=0), status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK(status IN ('active','inactive')), assigned_at DATE NOT NULL DEFAULT CURRENT_DATE, UNIQUE(room_id,student_id)
);
CREATE INDEX IF NOT EXISTS idx_hostel_assignment_student ON hostel_assignments(student_id,status);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\022_scholarship_events_achievements.sql
-- =========================================
-- V49: operational scholarship and co-curricular records
CREATE TABLE IF NOT EXISTS scholarship_awards (
 id BIGSERIAL PRIMARY KEY,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 scholarship_name VARCHAR(180) NOT NULL,
 academic_year INT NOT NULL,
 provider VARCHAR(180),
 amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK(amount>=0),
 award_date DATE,
 status VARCHAR(30) NOT NULL DEFAULT 'awarded' CHECK(status IN ('awarded','pending','cancelled')),
 notes TEXT,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_scholarship_student_year ON scholarship_awards(student_id,academic_year);
CREATE INDEX IF NOT EXISTS idx_scholarship_year_status ON scholarship_awards(academic_year,status);

CREATE TABLE IF NOT EXISTS event_participants (
 id BIGSERIAL PRIMARY KEY,
 content_id BIGINT NOT NULL REFERENCES school_content_items(id) ON DELETE CASCADE,
 student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
 role VARCHAR(100),
 position VARCHAR(100),
 notes TEXT,
 created_by UUID REFERENCES users(id) ON DELETE SET NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 UNIQUE(content_id,student_id)
);
CREATE INDEX IF NOT EXISTS idx_event_participants_content ON event_participants(content_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_student ON event_participants(student_id);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\023_assignment_feedback.sql
-- =========================================
-- V51: teacher feedback for assignment submissions
ALTER TABLE assignment_submissions
  ADD COLUMN IF NOT EXISTS teacher_feedback TEXT;
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_status ON assignment_submissions(status);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\024_operational_integrity.sql
-- =========================================
-- V65 — operational integrity constraints for active facility assignments
-- Deactivate duplicate active assignments before adding partial unique indexes.
WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY student_id ORDER BY assigned_at DESC, id DESC) rn
  FROM transport_assignments WHERE status='active'
)
UPDATE transport_assignments t SET status='inactive' FROM ranked r WHERE t.id=r.id AND r.rn>1;

WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY student_id ORDER BY assigned_at DESC, id DESC) rn
  FROM hostel_assignments WHERE status='active'
)
UPDATE hostel_assignments t SET status='inactive' FROM ranked r WHERE t.id=r.id AND r.rn>1;

CREATE UNIQUE INDEX IF NOT EXISTS uq_transport_active_student
  ON transport_assignments(student_id) WHERE status='active';
CREATE UNIQUE INDEX IF NOT EXISTS uq_hostel_active_student
  ON hostel_assignments(student_id) WHERE status='active';
CREATE UNIQUE INDEX IF NOT EXISTS uq_hostel_active_bed
  ON hostel_assignments(room_id,bed_no) WHERE status='active' AND bed_no IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_school_content_public
  ON school_content_items(status,content_type,sort_order,event_date DESC);


-- =========================================
-- FILE: C:\Users\Walton\OneDrive\Desktop\magra_school_management_v85\magra_work_v81\database\migrations\025_document_integrity.sql
-- =========================================
-- V72 — official document integrity
-- Keep the issued-document registry aligned with the supported generator types.
ALTER TABLE issued_documents DROP CONSTRAINT IF EXISTS issued_documents_document_type_check;
ALTER TABLE issued_documents
  ADD CONSTRAINT issued_documents_document_type_check
  CHECK (document_type IN ('id_card','marksheet','progress_report','certificate','admit_card','tabulation','merit_list'));

CREATE INDEX IF NOT EXISTS idx_issued_documents_exam
  ON issued_documents(exam_id,issue_date DESC);


-- =========================================
-- FILE: database/pilot/pilot_seed.sql
-- =========================================
-- V84 PILOT ONLY — synthetic data for functional testing.
-- DO NOT use this file for production. All names/IDs are fictional.
-- Default pilot passwords: Pilot@12345 (users are flagged to change password).
BEGIN;

-- Pilot accounts. Requires database/schema.sql + all migrations to have been applied first.
INSERT INTO users(login_id,full_name,password_hash,role_id,must_change_password)
SELECT v.login_id,v.full_name,crypt('Pilot@12345',gen_salt('bf')),r.id,TRUE
FROM (VALUES
  ('pilot-admin','Pilot Admin'),
  ('pilot-teacher-01','Pilot Teacher 01'),
  ('pilot-teacher-02','Pilot Teacher 02'),
  ('pilot-teacher-03','Pilot Teacher 03'),
  ('pilot-guardian-01','Pilot Guardian 01'),
  ('pilot-guardian-02','Pilot Guardian 02'),
  ('pilot-student-06-01','Pilot Student 06-01'),
  ('pilot-student-06-02','Pilot Student 06-02'),
  ('pilot-student-07-01','Pilot Student 07-01'),
  ('pilot-student-07-02','Pilot Student 07-02'),
  ('pilot-student-08-01','Pilot Student 08-01'),
  ('pilot-student-08-02','Pilot Student 08-02'),
  ('pilot-student-09-01','Pilot Student 09-01'),
  ('pilot-student-09-02','Pilot Student 09-02'),
  ('pilot-student-10-01','Pilot Student 10-01'),
  ('pilot-student-10-02','Pilot Student 10-02')
) AS v(login_id,full_name)
JOIN roles r ON r.name = CASE
  WHEN v.login_id='pilot-admin' THEN 'admin'
  WHEN v.login_id LIKE 'pilot-teacher-%' THEN 'teacher'
  WHEN v.login_id LIKE 'pilot-guardian-%' THEN 'guardian'
  ELSE 'student' END
ON CONFLICT(login_id) DO UPDATE SET must_change_password=TRUE;

-- Three synthetic teachers.
INSERT INTO teachers(employee_id,name_bn,name_en,designation,designation_en,subject,joining_date,gender,status,user_id)
SELECT v.employee_id,v.name_bn,v.name_en,'সহকারী শিক্ষক','Assistant Teacher',v.subject,'2026-01-01',v.gender,'active',u.id
FROM (VALUES
 ('PILOT-T01','পরীক্ষামূলক শিক্ষক ১','Pilot Teacher 01','বাংলা','পুরুষ','pilot-teacher-01'),
 ('PILOT-T02','পরীক্ষামূলক শিক্ষক ২','Pilot Teacher 02','ইংরেজি','পুরুষ','pilot-teacher-02'),
 ('PILOT-T03','পরীক্ষামূলক শিক্ষক ৩','Pilot Teacher 03','গণিত','নারী',NULL)
) v(employee_id,name_bn,name_en,subject,gender,login_id)
LEFT JOIN users u ON u.login_id=v.login_id
ON CONFLICT(employee_id) DO NOTHING;

-- Two synthetic students per class (6–10).
INSERT INTO students(student_id,roll_no,name_bn,name_en,class_name,section,gender,date_of_birth,guardian_name,guardian_relation,guardian_phone,admission_date,admission_class,status)
SELECT v.student_id,v.roll_no,v.name_bn,v.name_en,v.class_name,'A',v.gender,v.dob::date,'Pilot Guardian '||v.class_name||'-'||v.roll_no,
       CASE WHEN v.roll_no=1 THEN 'পিতা' ELSE 'মাতা' END,'01700000000','2026-01-01'::date,v.class_name,'active'
FROM (VALUES
 ('PILOT-06-01',1,'পরীক্ষামূলক শিক্ষার্থী ৬-১','Pilot Student 6-1','6','পুরুষ','2014-01-01'),
 ('PILOT-06-02',2,'পরীক্ষামূলক শিক্ষার্থী ৬-২','Pilot Student 6-2','6','নারী','2014-02-01'),
 ('PILOT-07-01',1,'পরীক্ষামূলক শিক্ষার্থী ৭-১','Pilot Student 7-1','7','পুরুষ','2013-01-01'),
 ('PILOT-07-02',2,'পরীক্ষামূলক শিক্ষার্থী ৭-২','Pilot Student 7-2','7','নারী','2013-02-01'),
 ('PILOT-08-01',1,'পরীক্ষামূলক শিক্ষার্থী ৮-১','Pilot Student 8-1','8','পুরুষ','2012-01-01'),
 ('PILOT-08-02',2,'পরীক্ষামূলক শিক্ষার্থী ৮-২','Pilot Student 8-2','8','নারী','2012-02-01'),
 ('PILOT-09-01',1,'পরীক্ষামূলক শিক্ষার্থী ৯-১','Pilot Student 9-1','9','পুরুষ','2011-01-01'),
 ('PILOT-09-02',2,'পরীক্ষামূলক শিক্ষার্থী ৯-২','Pilot Student 9-2','9','নারী','2011-02-01'),
 ('PILOT-10-01',1,'পরীক্ষামূলক শিক্ষার্থী ১০-১','Pilot Student 10-1','10','পুরুষ','2010-01-01'),
 ('PILOT-10-02',2,'পরীক্ষামূলক শিক্ষার্থী ১০-২','Pilot Student 10-2','10','নারী','2010-02-01')
) v(student_id,roll_no,name_bn,name_en,class_name,gender,dob)
ON CONFLICT(student_id) DO NOTHING;

-- Link guardians to pilot students and link every student account to its student record.
INSERT INTO guardian_student_links(guardian_user_id,student_id,relation)
SELECT u.id,s.id,CASE WHEN s.roll_no=1 THEN 'পিতা' ELSE 'মাতা' END
FROM users u JOIN students s ON s.student_id IN ('PILOT-06-01','PILOT-06-02')
WHERE u.login_id='pilot-guardian-01'
ON CONFLICT DO NOTHING;
INSERT INTO guardian_student_links(guardian_user_id,student_id,relation)
SELECT u.id,s.id,CASE WHEN s.roll_no=1 THEN 'পিতা' ELSE 'মাতা' END
FROM users u JOIN students s ON s.student_id IN ('PILOT-07-01','PILOT-07-02')
WHERE u.login_id='pilot-guardian-02'
ON CONFLICT DO NOTHING;
UPDATE students s
SET guardian_email=(SELECT email FROM users WHERE login_id='pilot-guardian-01')
WHERE s.student_id IN ('PILOT-06-01','PILOT-06-02');
UPDATE students s
SET guardian_email=(SELECT email FROM users WHERE login_id='pilot-guardian-02')
WHERE s.student_id IN ('PILOT-07-01','PILOT-07-02');
UPDATE students s
SET user_id=u.id
FROM users u
WHERE u.login_id='pilot-student-' || replace(s.student_id,'PILOT-','')
  AND s.student_id LIKE 'PILOT-%';

-- Minimal academic data for result/attendance workflows.
INSERT INTO academic_years(year,is_current) VALUES (2026,TRUE) ON CONFLICT(year) DO UPDATE SET is_current=TRUE;
INSERT INTO subjects(code,name_bn,name_en,class_name,full_marks,pass_marks) VALUES
 ('PILOT-BAN','বাংলা','Bangla','6',100,33),
 ('PILOT-ENG','ইংরেজি','English','6',100,33),
 ('PILOT-MAT','গণিত','Mathematics','6',100,33)
ON CONFLICT(code) DO NOTHING;

INSERT INTO exams(name_bn,exam_type,academic_year_id,start_date,end_date,status)
SELECT 'Pilot Test Exam','internal',id,'2026-09-20','2026-09-25','published'
FROM academic_years WHERE year=2026
AND NOT EXISTS (SELECT 1 FROM exams WHERE name_bn='Pilot Test Exam');

-- Sample attendance for two students.
INSERT INTO attendance(student_id,attendance_date,status,remarks)
SELECT s.id,d::date,CASE WHEN s.roll_no=1 THEN 'present' ELSE 'absent' END,'Pilot test record'
FROM students s CROSS JOIN generate_series('2026-09-15'::date,'2026-09-16'::date,'1 day') d
WHERE s.student_id IN ('PILOT-06-01','PILOT-06-02')
ON CONFLICT(student_id,attendance_date) DO NOTHING;

-- Sample marks.
INSERT INTO marks(exam_id,student_id,subject_id,written,mcq,practical,total,grade,gpa,remarks)
SELECT e.id,s.id,sub.id,70,20,0,90,'A+',5.00,'Pilot result'
FROM exams e JOIN students s ON s.student_id='PILOT-06-01'
JOIN subjects sub ON sub.code='PILOT-BAN'
WHERE e.name_bn='Pilot Test Exam'
ON CONFLICT(exam_id,student_id,subject_id) DO NOTHING;

-- Assignment + submission.
INSERT INTO assignments(title_bn,subject_id,class_name,description,instructions,due_at,max_marks,status,created_by)
SELECT 'Pilot Assignment',sub.id,'6','Synthetic pilot assignment','Submit a short answer.', '2026-09-30 23:59:00+06',20,'published',u.id
FROM subjects sub CROSS JOIN users u
WHERE sub.code='PILOT-BAN' AND u.login_id='pilot-teacher-01'
AND NOT EXISTS (SELECT 1 FROM assignments WHERE title_bn='Pilot Assignment');
INSERT INTO assignment_submissions(assignment_id,student_id,answer_text,marks,feedback,status)
SELECT a.id,s.id,'Pilot answer',18,'Good pilot submission','graded'
FROM assignments a JOIN students s ON s.student_id='PILOT-06-01'
WHERE a.title_bn='Pilot Assignment'
ON CONFLICT(assignment_id,student_id) DO NOTHING;

-- Finance + library smoke-test records.
INSERT INTO fees(student_id,fee_type,amount,due_date,status)
SELECT s.id,'Pilot Fee',500,'2026-09-30'::date,'due' FROM students s WHERE s.student_id='PILOT-06-01'
AND NOT EXISTS (SELECT 1 FROM fees f WHERE f.student_id=s.id AND f.fee_type='Pilot Fee');
INSERT INTO books(isbn,title,author,category,quantity,available_quantity)
SELECT 'PILOT-ISBN-001','Pilot Mathematics Book','Pilot Author','Pilot',3,3
WHERE NOT EXISTS (SELECT 1 FROM books WHERE isbn='PILOT-ISBN-001');
INSERT INTO library_loans(book_id,student_id,issued_at,due_at)
SELECT b.id,s.id,'2026-09-19'::date,'2026-09-26'::date
FROM books b CROSS JOIN students s
WHERE b.isbn='PILOT-ISBN-001' AND s.student_id='PILOT-06-01'
AND NOT EXISTS (SELECT 1 FROM library_loans l WHERE l.book_id=b.id AND l.student_id=s.id AND l.returned_at IS NULL);

-- Pilot notice.
INSERT INTO notices(title_bn,title_en,body,notice_date,published,urgent,created_by)
SELECT 'পাইলট পরীক্ষা সংক্রান্ত নোটিশ','Pilot Test Notice','This is synthetic pilot content.','2026-09-19'::date,TRUE,FALSE,u.id
FROM users u WHERE u.login_id='pilot-admin'
AND NOT EXISTS (SELECT 1 FROM notices WHERE title_bn='পাইলট পরীক্ষা সংক্রান্ত নোটিশ');

COMMIT;


