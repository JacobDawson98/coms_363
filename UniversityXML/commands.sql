USE db363project;

CREATE TABLE IF NOT EXISTS Person (
    Name CHAR(20),
    ID CHAR(9) NOT NULL,
    Address CHAR(30),
    DOB DATE,
    PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS Instructor (
    Title CHAR(12),
    Salary INT,
    InstructorID CHAR(9) NOT NULL REFERENCES Person,
    PRIMARY KEY (InstructorID)
);

CREATE TABLE IF NOT EXISTS Student (
    Classification CHAR(10),
    GPA DOUBLE,
    CreditHours INT,
    MentorID CHAR(9) NOT NULL REFERENCES Instructor,
    StudentID CHAR(9) NOT NULL REFERENCES Person,
    PRIMARY KEY (StudentID)
);

CREATE TABLE IF NOT EXISTS Course (
    CourseCode CHAR(6) NOT NULL,
    CourseName CHAR(50),
    PreReq CHAR(6),
    PRIMARY KEY (CourseCode)
);

CREATE TABLE IF NOT EXISTS Offering (
    CourseCode CHAR(6) NOT NULL,
    SectionNo INT NOT NULL,
    InstructorID CHAR(9) NOT NULL REFERENCES Instructor,
    PRIMARY KEY (CourseCode , SectionNo)
);

CREATE TABLE IF NOT EXISTS Enrollment (
    CourseCode CHAR(6) NOT NULL REFERENCES Offering,
    SectionNo INT NOT NULL REFERENCES Offering,
    StudentID CHAR(9) NOT NULL REFERENCES Student,
    Grade CHAR(4) NOT NULL,
    PRIMARY KEY (CourseCode , StudentID),
    FOREIGN KEY (CourseCode , SectionNo)
        REFERENCES Offering (CourseCode , SectionNo)
);


LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Person.xml'  INTO TABLE Person ROWS IDENTIFIED BY '<Person>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Instructor.xml' INTO TABLE Instructor ROWS IDENTIFIED BY '<Instructor>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Student.xml' INTO TABLE Student ROWS IDENTIFIED BY '<Student>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Course.xml' INTO TABLE Course ROWS IDENTIFIED BY '<Course>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Offering.xml' INTO TABLE Offering ROWS IDENTIFIED BY '<Offering>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/coms_363/UniversityXML/Enrollment.xml' INTO TABLE Enrollment ROWS IDENTIFIED BY '<Enrollment>';
