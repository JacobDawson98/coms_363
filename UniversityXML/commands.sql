USE db363project;

CREATE TABLE IF NOT EXISTS Person (
    Name char (20),
    ID char (9) not null,
    Address char (30),
    DOB date,
    Primary key (ID)
);

CREATE TABLE IF NOT EXISTS Instructor (
    Rank char (12),
    Salary int,
    InstructorID char (9) NOT NULL references Person,
    Primary key (InstructorID)
);

CREATE TABLE IF NOT EXISTS Student (
    Classification char (10),
    GPA double,
    CreditHours int,
    MentorID char (9) NOT NULL references Instructor,
    StudentID char (9) NOT NULL references Person,
    Primary key (StudentID)
);

CREATE TABLE IF NOT EXISTS Course (
    CourseCode char (6) NOT NULL,
    CourseName char(50),
    PreReq char(6)
);

CREATE TABLE IF NOT EXISTS Offering (
    CourseCode char (6) NOT NULL,
    SectionNo int NOT NULL,
    InstructorID char (9) NOT NULL references Instructor,
    Primary key(CourseCode, SectionNo)
);

CREATE TABLE IF NOT EXISTS Enrollment (
    CourseCode char(6) NOT NULL references Offering,
    SectionNo int NOT NULL references Offering,
    StudentID char(9) NOT NULL references Student,
    Grade char(4) NOT NULL,
    primary key (CourseCode, StudentID),
    foreign key (CourseCode, SectionNo) references Offering(CourseCode, SectionNo)
);

LOAD XML LOCAL INFILE '/Users/jacobd/Projects/UniversityXML/Person.xml'  INTO TABLE Person ROWS IDENTIFIED BY '<Person>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/UniversityXML/Instructor.xml' INTO TABLE Instructor ROWS IDENTIFIED BY '<Instructor>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/UniversityXML/Student.xml' INTO TABLE Student ROWS IDENTIFIED BY '<Student>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/UniversityXML/Course.xml' INTO TABLE Course ROWS IDENTIFIED BY '<Course>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/UniversityXML/Offering.xml' INTO TABLE Offering ROWS IDENTIFIED BY '<Offering>';
LOAD XML LOCAL INFILE '/Users/jacobd/Projects/UniversityXML/Enrollment.xml' INTO TABLE Enrollment ROWS IDENTIFIED BY '<Enrollment>';

/* DROP TABLE Enrollment; */
/* DROP TABLE Offering; */
/* DROP TABLE Course; */
/* DROP TABLE Student; */
/* DROP TABLE Instructor; */
/* DROP TABLE Person; */
