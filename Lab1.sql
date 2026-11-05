DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS faculties CASCADE;

CREATE TABLE faculties (
    faculty_code SERIAL PRIMARY KEY,
    faculty_name TEXT NOT NULL,
    foundation_date DATE,
    activity_type TEXT NOT NULL,
    max_students INT NOT NULL
);

CREATE TABLE groups (
    group_number VARCHAR(10) PRIMARY KEY,
    max_people INT NOT NULL,
    faculty_code INT NOT NULL,
    curator TEXT,
    CONSTRAINT fk_faculty 
        FOREIGN KEY (faculty_code) 
        REFERENCES faculties(faculty_code) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

INSERT INTO faculties (faculty_name, foundation_date, activity_type, max_students) VALUES
('Факультет теоретической физики', '1950-09-01', 'Технические науки', 250),
('Факультет радиоэлектроники', '1965-09-01', 'Технические науки', 220),
('Факультет кибернетики', '1980-09-01', 'Технические науки', 300),
('Гуманитарный факультет', '1990-09-01', 'Гуманитарные науки', 180),
('Экономический факультет', '1985-09-01', 'Экономика', 210),
('Строительный факультет', '1955-09-01', 'Технические науки', 240),
('Химико-технологический факультет', '1960-09-01', 'Технические науки', 190),
('Юридический факультет', '1995-09-01', 'Юриспруденция', 150),
('Механико-математический факультет', '1945-09-01', 'Технические науки', 280),
('Факультет энергетики', '1970-09-01', 'Технические науки', 230);

INSERT INTO groups (group_number, max_people, faculty_code, curator) VALUES
('Ф-11', 25, 1, 'Иванов И.И.'),
('Ф-12', 12, 1, NULL),
('Р-21', 20, 2, 'Петров П.П.'),
('К-31', 22, 3, 'Сидоров С.С.'),
('Г-11', 18, 4, 'Кузнецова А.А.'),
('Э-11', 25, 5, NULL),
('С-11', 14, 6, 'Смирнов В.В.'),
('Х-11', 16, 7, 'Попов Д.Д.'),
('Ю-11', 30, 8, 'Соколова М.Н.'),
('М-11', 24, 9, 'Васильев В.В.');

SELECT * 
FROM faculties 
WHERE max_students > 200 AND activity_type LIKE '%Технические%';

SELECT g.* 
FROM groups g
JOIN faculties f ON g.faculty_code = f.faculty_code
WHERE f.faculty_name = 'Факультет теоретической физики' 
  AND g.max_people > 20;

DROP TABLE IF EXISTS tech_faculties_groups;

SELECT f.faculty_code, f.faculty_name, f.max_students, f.activity_type, g.group_number
INTO tech_faculties_groups
FROM faculties f
JOIN groups g ON f.faculty_code = g.faculty_code
WHERE f.max_students > 200 AND f.activity_type LIKE '%Технические%';

INSERT INTO tech_faculties_groups (faculty_code, faculty_name, max_students, activity_type, group_number)
SELECT f.faculty_code, f.faculty_name, f.max_students, f.activity_type, g.group_number
FROM faculties f
JOIN groups g ON f.faculty_code = g.faculty_code
WHERE g.max_people < 15;

UPDATE tech_faculties_groups
SET group_number = 'Т' || SUBSTRING(group_number FROM 2)
WHERE activity_type LIKE '%Технические%';

DELETE FROM tech_faculties_groups
WHERE group_number IN (
    SELECT g.group_number 
    FROM groups g 
    WHERE g.curator IS NULL
);

SELECT f.faculty_name, 
       COUNT(g.group_number) AS total_groups, 
       SUM(g.max_people) AS total_max_students
FROM faculties f
LEFT JOIN groups g ON f.faculty_code = g.faculty_code
GROUP BY f.faculty_name
ORDER BY f.faculty_name;
