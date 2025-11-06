CREATE TYPE course_category AS ENUM (
    'Programming',
    'Design',
    'Marketing',
    'Business',
    'Language'
);

CREATE TYPE teacher_spec AS ENUM (
    'Data Science',
    'Web Development',
    'Project Management',
    'Cybersecurity',
    'UI/UX Design',
    'Python Development',
    'Java Development',
    'C# Development',
    'C++ Development',
    'English Teacher', 
    'Spanish Teacher',
    'German Teacher'
);

CREATE TABLE IF NOT EXISTS contact_data (
    contact_data_id SERIAL PRIMARY KEY,
    email VARCHAR(32) NOT NULL UNIQUE, 
    phone VARCHAR(32) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS teacher (
    teacher_id SERIAL PRIMARY KEY,
    username VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(32) NOT NULL,
    surname VARCHAR(32) NOT NULL,
    biography TEXT,
    specialization teacher_spec NOT NULL,
	is_deleted BOOLEAN NOT NULL DEFAULT false,
	contact_data_id INTEGER NOT NULL REFERENCES contact_data(contact_data_id)
);

CREATE TABLE IF NOT EXISTS student (
    student_id SERIAL PRIMARY KEY,
    username VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(32) NOT NULL,
	is_deleted BOOLEAN NOT NULL DEFAULT false,
	contact_data_id INTEGER NOT NULL REFERENCES contact_data(contact_data_id),
    registered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS course (
    course_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    category course_category NOT NULL,
	is_active BOOLEAN NOT NULL DEFAULT true,
    teacher_id INTEGER NOT NULL REFERENCES teacher(teacher_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lesson (
    lesson_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL, 
    description TEXT,
    order_in_course SMALLINT NOT NULL,
	is_active BOOLEAN NOT NULL DEFAULT true,
    course_id INTEGER NOT NULL REFERENCES course(course_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS registration (
    is_finished BOOLEAN NOT NULL DEFAULT false,
    registered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    student_id INTEGER NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
    course_id INTEGER NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id, course_id)
);

CREATE TABLE IF NOT EXISTS lesson_progress (
    is_completed BOOLEAN NOT NULL DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    student_id INTEGER NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
    lesson_id INTEGER NOT NULL REFERENCES lesson(lesson_id) ON DELETE CASCADE,
    PRIMARY KEY(student_id, lesson_id)
);

INSERT INTO contact_data (email, phone)
VALUES ('oleh.p@example.com', '+380501112233'),   
('anna.k@example.com', '+380672223344');  

INSERT INTO teacher (username, name, surname, biography, specialization, contact_data_id)
VALUES ('oleh_dev', 'Олег', 'Петренко', 'Досвідчений Full-Stack розробник з 10-річним стажем.', 'Web Development', 1),  
('anna_java', 'Анна', 'Коваленко', 'Senior Java Developer, сертифікований Oracle спеціаліст.', 'Java Development', 2);

INSERT INTO course (name, description, price, category, teacher_id)
VALUES ('Fullstack developer from zero to master', 'HTML, CSS, JavaScript, React, Node.js', 20.99, 'Programming', 1), 
('Java for Backend', 'Java basics and Spring framework', 15.99, 'Programming', 2); 

UPDATE lesson SET is_active = false 
WHERE lesson_id = 3;

UPDATE course SET name = 'Fullstack developer from zero to master in 5 month', price = 23.99
WHERE course_id = 1;

DELETE FROM lesson 
WHERE lesson_id = 3;

DELETE FROM registration 
WHERE course_id = 1 AND student_id = 2;

SELECT 
	t.teacher_id,
	t.name || ' ' || t.surname AS teacher_full_name,
	c.course_id,
	c.name AS course_name, 
	c.description,
	c.price
FROM course c 
INNER JOIN teacher t USING(teacher_id)
WHERE t.name = 'Олег' AND c.is_active AND t.is_deleted = false;

SELECT
	c.course_id,
	c.name AS course_name, 
	s.student_id,
	s.name AS student_name,
	s.username
FROM student s 
INNER JOIN registration r USING(student_id)
INNER JOIN course c USING(course_id)
WHERE c.course_id = 1 AND is_active AND s.is_deleted = false;

WITH lesson_count AS (
	SELECT c.course_id,
		c.name AS course_name,
		c.category,
		COUNT(*) AS lesson_count
	FROM course c 
	INNER JOIN lesson l USING(course_id)
	WHERE c.is_active AND l.is_active
	GROUP BY c.course_id, c.name, c.category
),
student_progress AS (
	SELECT 
		s.student_id, 
		s.name AS student_name, 
		s.username, 
		c.course_id, 
		c.name AS course_name, 
		c.category, 
		COUNT(*) AS finished_lessons
	FROM course c 
	INNER JOIN lesson l USING(course_id)
	INNER JOIN lesson_progress lp USING(lesson_id)
	INNER JOIN student s USING(student_id)
	WHERE c.is_active AND l.is_active AND s.is_deleted = false AND lp.is_completed
	GROUP BY s.student_id, s.name, s.username, c.course_id, c.name, c.category
),
student_progress_percentage AS (
	SELECT
        r.student_id,
        r.course_id,
        lc.category,
        (COALESCE(sp.finished_lessons, 0)::REAL / lc.lesson_count::REAL) AS percentage
    FROM registration r
    INNER JOIN student s USING(student_id)
    INNER JOIN lesson_count lc USING(course_id)
    LEFT JOIN student_progress sp 
	ON r.student_id = sp.student_id AND r.course_id = sp.course_id
    WHERE s.is_deleted = false AND lc.lesson_count > 0 
)

SELECT category, AVG(percentage) AS avg_percentage FROM student_progress_percentage
GROUP BY category
ORDER BY avg_percentage DESC


SELECT 
	t.teacher_id,
	t.name || ' ' || t.surname AS teacher_full_name,
	COUNT(DISTINCT s.student_id) AS student_count
FROM teacher t 
INNER JOIN course c USING(teacher_id)
INNER JOIN registration r USING(course_id)
INNER JOIN student s USING(student_id)
WHERE c.is_active AND t.is_deleted = false AND s.is_deleted = false
GROUP BY t.teacher_id, t.name, t.surname
ORDER BY student_count DESC
LIMIT 5;

SELECT 
    c.course_id,
    c.name,
    c.category,
    COUNT(s.student_id) AS student_count,
    DENSE_RANK() OVER (PARTITION BY c.category ORDER BY COUNT(s.student_id) DESC) AS rank_in_category
FROM course c
LEFT JOIN registration r USING(course_id)
LEFT JOIN student s ON r.student_id = s.student_id AND s.is_deleted = false
WHERE c.is_active = true 
GROUP BY c.course_id, c.name, c.category
ORDER BY c.category, rank_in_category;

WITH student_course_count AS (
	SELECT
		s.student_id,
		s.name,
		s.username,
		s.is_deleted,
		COUNT(c.course_id) AS course_count
	FROM student s
	INNER JOIN registration r USING(student_id)
	INNER JOIN course c ON c.course_id = r.course_id AND c.is_active
	WHERE s.is_deleted = false 
	GROUP BY s.student_id, s.name, s.username
)


SELECT 
	scc.student_id, 
	scc.name, 
	scc.username, 
	scc.course_count,
	COUNT(r.course_id) AS unfinished_course
FROM student_course_count scc
INNER JOIN registration r USING(student_id)
INNER JOIN course c ON c.course_id = r.course_id AND c.is_active
WHERE r.is_finished = false
GROUP BY scc.student_id, scc.name, scc.username, scc.course_count
HAVING scc.course_count > 1 AND scc.course_count = COUNT(r.course_id);
