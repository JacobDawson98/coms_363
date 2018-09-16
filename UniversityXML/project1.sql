/* Jacob Dawson, netid: dawson */
/* Christian Eggers, netid: linko */

USE db363project;

/* Item 1: The Person table. The Person table consists of the attributes Name, ID, Address, and DOB (date of birth). */
/* The types of these attributes are char(20), char(9), char(30), and date, respectively. ID will be the primary key of the table, */
/* and it cannot have a null value. These requirements could be expressed in terms of the following create statement: */
CREATE TABLE IF NOT EXISTS Person (
    Name CHAR(20),
    ID CHAR(9) NOT NULL,
    Address CHAR(30),
    DOB DATE,
    PRIMARY KEY (ID)
);

/* Item 2: The Instructor table. The Instructor table consists of InstructorID, a 9 character non-null attribute that serves as the primary */
/* key and also references ID in the Person table. Other attributes are Rank and Salary. Rank can have up to 12 characters and Salary is */
/* an integer. */
CREATE TABLE IF NOT EXISTS Instructor (
    Title CHAR(12),
    Salary INT,
    InstructorID CHAR(9) NOT NULL REFERENCES Person,
    PRIMARY KEY (InstructorID)
);

/* Item 3: The Student table. The Student table has StudentID that has same requirements as InstructorID. The Student table has four */
/* additional attributes: Classification that is a string of up to 10 characters, GPA that is a double, MentorID, consisting of 9 characters, */
/* references InstructorID in Instructor table, and CreditHours that is an integer. */
CREATE TABLE IF NOT EXISTS Student (
    Classification CHAR(10),
    GPA DOUBLE,
    CreditHours INT,
    MentorID CHAR(9) NOT NULL REFERENCES Instructor,
    StudentID CHAR(9) NOT NULL REFERENCES Person,
    PRIMARY KEY (StudentID)
);

/* Item 4: The Course table. The Course table has a 6 character non-null attribute called CourseCode, a 50 character CourseName, */
/* and 6 character PreReq, representing prerequisite of a course. Note that a course can have several prerequisites. */
/* This is why CourseCode alone cannot be a key. If a course has no prerequisites, the string �None� is entered. For a given course a tuple, */
/* will exist for every prerequisite for the course. */
CREATE TABLE IF NOT EXISTS Course (
    CourseCode CHAR(6) NOT NULL,
    CourseName CHAR(50),
    PreReq CHAR(6)
);

/* Item 5: The Offering table. The Offering table contains three non-null attributes CourseCode, SectionNo, and InstructorID that are of */
/* type char(6), int, and char(9). A CourseCode in the Offering table should appear in the Course table. This could be enforced by an */
/* integrity constraint of the form "check (CourseCode in (select ...))". But it seems that Microsoft Access or the ODBC driver that we are */
/* using will not support it. Therefore, we will ignore this requirement. The InstructorID references InstructorID in Instructor table. */
/* The primary key for this table will be formed using CourseCode and SectionNo attributes. */
CREATE TABLE IF NOT EXISTS Offering (
    CourseCode CHAR(6) NOT NULL,
    SectionNo INT NOT NULL,
    InstructorID CHAR(9) NOT NULL REFERENCES Instructor,
    PRIMARY KEY (CourseCode , SectionNo)
);

/* Item 6: The Enrollment table. The Enrollment table consists of four non-null attributes CourseCode, SectionNo, StudentID, and Grade, */
/* with types char(6), int, char(9), and char(4), respectively. CourseCode and SectionNo reference the Offering table. */
/* StudentID references the Student table. The primary key for this table will consist of CourseCode and StudentID attributes. */
/* SectionNo is not included in the primary key. (Why?) Note that we would expect that a CourseCode, SectionNo pair in the Offering table */
/* must occur in the Course table. This requirement will not be captured by our design. For your reference, the create statement for */
/* Enrollment table is given below. */
CREATE TABLE IF NOT EXISTS Enrollment (
    CourseCode CHAR(6) NOT NULL REFERENCES Offering,
    SectionNo INT NOT NULL REFERENCES Offering,
    StudentID CHAR(9) NOT NULL REFERENCES Student,
    Grade CHAR(4) NOT NULL,
    PRIMARY KEY (CourseCode , StudentID),
    FOREIGN KEY (CourseCode , SectionNo)
        REFERENCES Offering (CourseCode , SectionNo)
);

/* Items 7-12. Load Person, Instructor, Student, Course, Offering, and Enrollment tables. */
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Person.xml'  INTO TABLE Person ROWS IDENTIFIED BY '<Person>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Instructor.xml' INTO TABLE Instructor ROWS IDENTIFIED BY '<Instructor>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Student.xml' INTO TABLE Student ROWS IDENTIFIED BY '<Student>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Course.xml' INTO TABLE Course ROWS IDENTIFIED BY '<Course>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Offering.xml' INTO TABLE Offering ROWS IDENTIFIED BY '<Offering>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Enrollment.xml' INTO TABLE Enrollment ROWS IDENTIFIED BY '<Enrollment>';

/* Item 13. List the IDs of students and the IDs of their Mentors for
students who are junior or senior having a GPA above 3.8. */
SELECT
    MentorID, StudentID
FROM
    Student s
WHERE
    s.GPA > 3.8
        AND (s.Classification = 'Junior'
        OR s.Classification = 'Senior');

/* Item 14. List the distinct course codes and sections for courses that
are being taken by sophomore. */
SELECT DISTINCT
    CourseCode, SectionNo
FROM
    Enrollment e,
    Student s
WHERE
    e.StudentID = s.StudentID
        AND s.Classification = 'Sophomore';

/* Item 15. List the name and salary for mentors of all freshmen. */
SELECT DISTINCT
    Name, Salary
FROM
    Student s,
    Instructor i,
    Person p
WHERE
    s.Classification = 'Freshman'
        AND s.MentorID = i.InstructorID
        AND i.InstructorID = p.ID;

/* Item 16. Find the total salary of all instructors who are not offering
any course. */
SELECT
    SUM(DISTINCT Salary) AS 'Total Salary'
FROM
    Instructor i,
    Offering o
WHERE
    i.InstructorID NOT IN (o.InstructorID);

/* Item 17. List all the names and DOBs of students who were born in 1976.
The expression "Year(x.DOB) = 1976", checks if x is born in the year 1976. */
SELECT DISTINCT
    Name, DOB
FROM
    Student s,
    Person p
WHERE
    s.StudentID = p.ID
        AND YEAR(p.DOB) = 1976;

/* Item 18. List the names and rank of instructors who neither offer a course
nor mentor a student. */
SELECT DISTINCT
    p.Name, i.Title
FROM
    Instructor i,
    Person p
WHERE
    i.InstructorID NOT IN
        (SELECT MentorID FROM Student) AND
    i.InstructorID NOT IN
        (SELECT InstructorID FROM Offering);

/* Item 19. Find the IDs, names and DOB of the youngest student(s). */
SELECT
    ID, Name, DOB
FROM
    Person p,
    Student s
WHERE
    p.ID = s.StudentID
        AND (DOB = (SELECT
            MIN(p.DOB)
        FROM
            Person))
ORDER BY DOB DESC;

/* Item 20. List the IDs, DOB, and Names of Persons who are neither a student
nor a instructor. */
SELECT
    ID, DOB, Name
FROM
    Person p
WHERE
    p.ID NOT IN (SELECT
            StudentID
        FROM
            Student)
        AND p.ID NOT IN (SELECT
            InstructorID
        FROM
            Instructor);

/* Item 21. For each instructor list his / her name and the number of
students he / she mentors. */
SELECT
    Name, COUNT(*)
FROM
    Instructor i
        INNER JOIN
    Person AS InstructorInfo ON InstructorInfo.ID = i.InstructorID
        INNER JOIN
    Student AS Mentees ON Mentees.MentorID = i.InstructorID
GROUP BY Name;

/* Item 22. List the number of students and average GPA for each
classification. Your query should not use constants such as "Freshman". */
SELECT
    Classification,
    COUNT(*),
    AVG(GPA)
FROM
    Student
GROUP BY
    Classification;

/* Item 23. Report the course(s) with lowest enrollments. You should output
the course code and the number of enrollments. */
/* Throws error ON my machine (Mac) but works ON partner's machine (Windows) */
/* SELECT */
/*     CourseCode, MIN(enrollCount) AS 'enrollCount' */
/* FROM */
/*     (SELECT */
/*         CourseCode, COUNT(*) AS 'enrollCount' */
/*     FROM */
/*         Enrollment */
/*     GROUP BY CourseCode */
/*     ORDER BY enrollCount) a; */

/* Item 24. List the IDs and Mentor IDs of students who are taking some course,
offered by their mentor. */
SELECT DISTINCT
    MentorID, s.StudentID
FROM
    Student s, Enrollment e, Offering o
WHERE
    s.StudentID = e.StudentID AND o.InstructorID = s.MentorID;

/* Item 25. List the student id, name, and completed credit hours of all
freshman born in or after 1976. */
SELECT DISTINCT
    StudentID, Name, CreditHours
FROM
    Student s, Person p
WHERE
    s.Classification = 'Freshman' AND YEAR(p.DOB) >= 1976 AND s.StudentID = p.ID;

/* Item 26. Insert following information in the database: Student name: Briggs Jason; ID: 480293439; */
/* address: 215 North Hyland Avenue; date of birth: 15th January 1975. He is a junior with a GPA of 3.48 and with 75 credit hours. */
/* His mentor is the instructor with InstructorID 201586985. Jason Briggs is taking two courses CS311 Section 2 and CS330 Section 1. */
/* He has an 'A' on CS311 and 'A-' on CS330. */
INSERT INTO Person (Name, ID, Address, DOB)
   VALUES ('Briggs Jason', '480293439', '215 North Hyland Avenue', '1975/1/15');
INSERT INTO Student (GPA, CreditHours, Classification, MentorID, StudentID)
    VALUES(3.48, 75, 'Junior', '201586985', '480293439');
INSERT INTO Enrollment (CourseCode, SectionNo, Grade, StudentID)
    VALUES('CS311', 2, 'A', '480293439');
INSERT INTO Enrollment (CourseCode, SectionNo, Grade, StudentID)
    VALUES('CS330', 1, 'A-', '480293439');

SELECT
    *
FROM
    Person P
WHERE
    P.Name = 'Briggs Jason';

SELECT
    *
FROM
    Student S
WHERE
    S.StudentID = '480293439';

SELECT
    *
FROM
    Enrollment E
WHERE
    E.StudentID = '480293439';

/* Item 27. Next, delete the records of students from the database who have a GPA less than 0.5. Note that it is not sufficient */
/* to delete these records from Student table; you have to delete them from the Enrollment table first. (Why?) On the  other hand, */
/* do not delete these students from the Person table. */
DELETE FROM Enrollment
WHERE
    StudentID IN (SELECT
        StudentID
    FROM
        Student s
    WHERE
        s.GPA < 0.5);

DELETE FROM Student
WHERE
   GPA < 0.5;

Select *
From Student S
Where S.GPA < 0.5;

/* Item 28. Update the instructor Ricky Ponting's salary to reflect a 10% raise provided there are at least 5 different students */
/* enrolled in his courses with a grade of A. Note that he may be teaching more than one course, and a student having A grade */
/* in more than one course should be counted only once. To do this, the distinct option with the count function may be helpful. */
SELECT Salary
FROM Instructor i, Person p
WHERE i.InstructorID = p.ID AND p.Name = 'Ricky Ponting';

UPDATE Instructor
SET
    Salary = Salary * 1.1
WHERE 5 <=
    (SELECT DISTINCT
            COUNT(*)
        FROM
            Student s
                INNER JOIN
            Person p ON p.ID = s.MentorID
                AND p.Name IN ('Ricky Ponting')
                INNER JOIN
			(SELECT DISTINCT StudentID FROM Enrollment) AliasID
			ON AliasID.StudentID = s.StudentID
				INNER JOIN
            (SELECT DISTINCT
                Grade
            FROM
                Enrollment) AliasGrade ON AliasGrade.Grade = 'A') ;

SELECT Salary
FROM Instructor i, Person p
WHERE i.InstructorID = p.ID AND p.Name = 'Ricky Ponting';


/* Item 29. Insert the following information into the Person table. Name: Trevor Horns; ID: 000957303; Address: 23 Canberra Street; */
/* date of birth: 23rd November 1964. Then execute a query to verify that the record has been inserted. */
INSERT INTO Person (Name, ID, Address, DOB)
    VALUES ('Horns Trevor', '000957303', '23 Canberra Street', '1964/11/23');
SELECT *
FROM Person p
WHERE p.ID = '000957303';

/* Item 30. Delete the record for the student Jan Austin from Enrollment and Student tables. Her record from the Person table
should not be deleted. */
SELECT p.Name
FROM Student s, Person p
WHERE s.StudentID = p.ID AND p.Name = 'Jan Austin';

SELECT s.StudentID
FROM Student s, Person p
WHERE p.Name = 'Jan Austin' AND s.StudentID = p.ID;

DELETE FROM Enrollment
WHERE
    StudentID IN (SELECT ID
    FROM
        Person p
    WHERE p.Name = 'Jan Austin');

DELETE FROM Student
WHERE
    StudentID IN (SELECT ID
    FROM
        Person p
    WHERE p.Name = 'Jan Austin');

SELECT p.Name
FROM  Person p
WHERE p.Name = 'Jan Austin';

SELECT s.StudentID
FROM Student s, Person p
WHERE p.Name = 'Jan Austin' AND s.StudentID = p.ID;
