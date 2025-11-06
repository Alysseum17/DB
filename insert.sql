INSERT INTO contact_data (email, phone)
VALUES
('oleh.p@example.com', '+380501112233'),
('anna.k@example.com', '+380672223344'),
('student1@example.com', '+380991112233'),
('maria.ui@example.com', '+380994445566'),
('john.eng@example.com', '+380631234567'),
('alysseum17@example.com', '+380682580514'),
('misha2006@example.com', '+380679243126'),
('sasha2008@example.com', '+380682130164'),
('iryna.b@example.com', '+380509876543');

INSERT INTO teacher (username, name, surname, biography, specialization, contact_data_id)
VALUES
('oleh_dev', 'Олег', 'Петренко', 'Досвідчений Full-Stack розробник з 10-річним стажем.', 'Web Development', 1),
('anna_java', 'Анна', 'Коваленко', 'Senior Java Developer, сертифікований Oracle спеціаліст.', 'Java Development', 2),
('maria_design', 'Марія', 'Гончаренко', 'Провідний UI/UX дизайнер з 8-річним досвідом.', 'UI/UX Design', 4),
('john_english', 'John', 'Doe', 'Носій мови з США, TESOL сертифікат.', 'English Teacher', 5);

INSERT INTO student (username, name, contact_data_id, registered_at)
VALUES
('student1_user', 'Студент', 3, '2025-2-10 11:02:00+02'),
('alysseum17', 'Даня', 5, '2025-01-10 10:00:00+02'),
('misha2006', 'Михайло', 6, '2025-02-15 11:30:00+02'),
('sasha200812', 'Олександр', 7, '2025-03-20 14:00:00+02'),
('iryna_b', 'Ірина', 8, '2025-04-01 09:00:00+03');

INSERT INTO course (name, description, price, category, teacher_id)
VALUES
('Fullstack developer from zero to master', 'HTML, CSS, JavaScript, React, Node.js', 20.99, 'Programming', 1),
('Java for Backend', 'Java basics and Spring framework', 15.99, 'Programming', 2),
('Основи UI/UX Дизайну', 'Створіть свій перший мобільний додаток у Figma.', 30.00, 'Design', 3),
('Business English', 'Ділова англійська для IT спеціалістів.', 25.50, 'Language', 4),
('React Advanced', 'Глибоке занурення в React Hooks та State Management.', 22.00, 'Programming', 1),
('Spring Boot Advanced', 'Advanced topics: Spring Security, Microservices', 35.00, 'Programming', 2);

INSERT INTO lesson (name, description, order_in_course, course_id)
VALUES
('Intro to HTML', '...', 1, 1),
('CSS Basics', '...', 2, 1),
('JavaScript Intro', '...', 3, 1),
('Java Syntax', '...', 1, 2),
('OOP Concepts', '...', 2, 2),
('Spring Boot Hello World', '...', 3, 2),
('What is UI/UX?', '...', 1, 3),
('Figma Basics', '...', 2, 3),
('Prototyping', '...', 3, 3),
('Greetings & Meetings', '...', 1, 4),
('Writing Emails', '...', 2, 4),
('useEffect Deep Dive', '...', 1, 5),
('useContext vs Redux', '...', 2, 5),
('Custom Hooks', '...', 3, 5),
('Spring Security Basics', '...', 1, 6),
('Intro to Microservices', '...', 2, 6);

INSERT INTO registration (is_finished, registered_at, student_id, course_id)
VALUES
(true, '2025-01-11 10:00:00+02', 1, 1),
(false, '2025-03-01 12:00:00+02', 1, 3),
(false, '2025-02-16 11:30:00+02', 2, 1),
(false, '2025-02-20 15:00:00+02', 2, 2),
(true, '2025-03-21 14:05:00+02', 3, 3),
(false, '2025-04-02 09:10:00+03', 4, 1),
(true, '2025-04-03 10:00:00+03', 4, 4),
(false, '2025-04-05 11:00:00+03', 4, 5);

INSERT INTO lesson_progress (is_completed, completed_at, student_id, lesson_id)
VALUES
(true, '2025-01-12 10:00:00+02', 1, 1),
(true, '2025-01-13 11:00:00+02', 1, 2),
(true, '2025-01-14 12:00:00+02', 1, 3),
(true, '2025-03-02 13:00:00+02', 1, 7),
(true, '2025-02-17 12:00:00+02', 2, 1),
(true, '2025-03-22 10:00:00+02', 3, 7),
(true, '2025-03-23 11:00:00+02', 3, 8),
(true, '2025-03-24 12:00:00+02', 3, 9),
(true, '2025-04-03 09:30:00+03', 4, 1),
(true, '2025-04-04 10:00:00+03', 4, 2),
(true, '2025-04-03 11:00:00+03', 4, 10),
(true, '2025-04-04 11:30:00+03', 4, 11),
(true, '2025-04-06 14:00:00+03', 4, 12);
