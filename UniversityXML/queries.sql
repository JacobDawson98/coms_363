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
/* SELECT */
/*     CourseCode, */
/*     COUNT(CourseCode) */
/* FROM */
/* 	Enrollment */
/* GROUP BY */
/* 	CourseCode */
/* HAVING */
/* 	COUNT(CourseCode) = (SELECT MIN(COUNT(CourseCode))); */

