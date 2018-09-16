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
/* Double check: May be correct */
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

    /* i.InstructorID = p.ID */
    /*     AND NOT i.InstructorID = o.InstructorID */
    /*     AND NOT i.InstructorID = s.MentorID; */

/* Item 19. Find the IDs, names and DOB of the youngest student(s). */
/* Double CHECK WITH TA */
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
SELECT
    CourseCode, MIN(enrollCount) AS 'enrollCount'
FROM
    (SELECT
        CourseCode, COUNT(*) AS 'enrollCount'
    FROM
        Enrollment
    GROUP BY CourseCode
    ORDER BY enrollCount) a;

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
