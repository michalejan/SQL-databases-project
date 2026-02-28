USE final_0_submissionsql
GO

CREATE TABLE CountryCode (
    CountryCode CHAR(2) PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL
);

INSERT INTO CountryCode (CountryCode, CountryName) VALUES
 ('AT','Austria'), ('BE','Belgium'), ('BG','Bulgaria'),
 ('HR','Croatia'), ('CY','Cyprus'), ('CZ','Czechia'),
 ('DK','Denmark'), ('EE','Estonia'), ('FI','Finland'),
 ('FR','France'),  ('DE','Germany'), ('GR','Greece'),
 ('HU','Hungary'), ('IE','Ireland'), ('IT','Italy'),
 ('LV','Latvia'),  ('LT','Lithuania'),('LU','Luxembourg'),
 ('MT','Malta'),   ('NL','Netherlands'),('PL','Poland'),
 ('PT','Portugal'),('RO','Romania'),  ('SK','Slovakia'),
 ('SI','Slovenia'),('ES','Spain'),     ('SE','Sweden'),
 ('NO','Norway'), ('IS','Iceland'), ('LI','Liechtenstein');

CREATE TABLE StatusCode (
    StatusCode VARCHAR(12) PRIMARY KEY,
    Description VARCHAR(50) NOT NULL
);

INSERT INTO StatusCode (StatusCode, Description) VALUES
 ('Draft','Saved but not submitted'),
 ('Submitted','Sent by student; awaiting review'),
 ('Nominated','Nominated to host faculty'),
 ('Approved','Approved by host/home'),
 ('Rejected','Rejected by host/home'),
 ('Withdrawn','Withdrawn by student'),
 ('Cancelled','Cancelled by coordinator'),
 ('Completed','Exchange finished and closed');

CREATE TABLE University (
    UniversityID INT PRIMARY KEY IDENTITY(1,1),
    UniversityName VARCHAR(255) NOT NULL UNIQUE,
    EUCountry CHAR(2) NOT NULL,
    FOREIGN KEY (EUCountry) REFERENCES CountryCode(CountryCode)
);

CREATE TABLE Coordinator (
    CoordinatorID   INT IDENTITY(1,1) PRIMARY KEY,
    CoordinatorName VARCHAR(255) NOT NULL,
    CoordinatorEmail VARCHAR(255) NOT NULL,
    Phone           VARCHAR(50)
);

CREATE TABLE Faculty (
    FacultyID     INT IDENTITY(1,1) PRIMARY KEY,
    UniversityID  INT NOT NULL,
    FacultyName   VARCHAR(255) NOT NULL,
    CoordinatorID INT NOT NULL UNIQUE,
    FOREIGN KEY (UniversityID)  REFERENCES University(UniversityID),
    FOREIGN KEY (CoordinatorID) REFERENCES Coordinator(CoordinatorID),
    UNIQUE (UniversityID, FacultyName)          -- ← new rule
);

CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    HomeFacultyID INT NOT NULL,
    GradeAverage DECIMAL(3,2) NOT NULL CHECK (GradeAverage BETWEEN 0 AND 10),
    Gender CHAR(1) CHECK (Gender IN ('M','F','X')),
    BirthDate DATE,
    FOREIGN KEY (HomeFacultyID) REFERENCES Faculty(FacultyID)
);

CREATE TABLE Course (
    CourseID   INT IDENTITY(1,1) PRIMARY KEY,
    FacultyID  INT NOT NULL,
    CourseName VARCHAR(255) NOT NULL,
    ECTS       INT NOT NULL CHECK (ECTS BETWEEN 1 AND 60),
    Term       VARCHAR(50),
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID),
    UNIQUE (FacultyID, CourseName)
);

CREATE TABLE Agreement (
    HomeFacultyID INT NOT NULL,
    HostFacultyID INT NOT NULL,
    ScholarshipAmount DECIMAL(12,2),
    PRIMARY KEY (HomeFacultyID, HostFacultyID),
    FOREIGN KEY (HomeFacultyID) REFERENCES Faculty(FacultyID),
    FOREIGN KEY (HostFacultyID) REFERENCES Faculty(FacultyID)
);

CREATE TABLE Application (
    ApplicationID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    SubmissionDate DATE NOT NULL,
    AppStatus VARCHAR(12) NOT NULL,
    AppTerm VARCHAR(50),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (AppStatus) REFERENCES StatusCode(StatusCode)
);

CREATE TABLE ExchangePeriod (
    ExchangeID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL UNIQUE,
    HostFacultyID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID),
    FOREIGN KEY (HostFacultyID) REFERENCES Faculty(FacultyID)
);

CREATE TABLE ScholarshipPayment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    ApplicationID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    Currency CHAR(3) NOT NULL DEFAULT 'EUR',
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
);

CREATE TABLE Accommodation (
    AccommodationID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    HostFacultyID INT NOT NULL,
    AddressLine VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20),
    MonthlyCost DECIMAL(10,2),
    MoveInDate DATE,
    MoveOutDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (HostFacultyID) REFERENCES Faculty(FacultyID)
);

CREATE TABLE CourseGrade (
    ApplicationID  INT NOT NULL,
    CourseID       INT NOT NULL,
    Grade          VARCHAR(5)     NOT NULL,
    CreditsEarned  INT            CHECK (CreditsEarned >= 0),
    PRIMARY KEY (ApplicationID, CourseID),
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID),
    FOREIGN KEY (CourseID)       REFERENCES Course(CourseID)
);

CREATE TABLE Document (
    DocumentID INT PRIMARY KEY IDENTITY(1,1),
    Title VARCHAR(255) NOT NULL
);

CREATE TABLE ApplicationCourses (
    ApplicationID INT NOT NULL,
    CourseID INT NOT NULL,
    PRIMARY KEY (ApplicationID, CourseID),
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

CREATE TABLE ApplicationTarget (
    ApplicationID INT NOT NULL,
    FacultyID INT NOT NULL,
    PRIMARY KEY (ApplicationID, FacultyID),
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID),
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);

CREATE TABLE DocumentRequirements (
    DocumentID INT NOT NULL,
    ApplicationID INT NOT NULL,
    DeadlineDate DATE NOT NULL,
    PRIMARY KEY (DocumentID, ApplicationID),
    FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
);

-- INSERTING THE DATA INTO THE TABLES

SET IDENTITY_INSERT University ON;
INSERT INTO University (UniversityID, UniversityName, EUCountry) VALUES
 (1 ,'Vienna University'           ,'AT'), (2 ,'Brussels University'         ,'BE'),
 (3 ,'Sofia University'            ,'BG'), (4 ,'Zagreb University'           ,'HR'),
 (5 ,'Cyprus University'           ,'CY'), (6 ,'Prague Charles University'   ,'CZ'),
 (7 ,'Copenhagen University'       ,'DK'), (8 ,'Tallinn University'          ,'EE'),
 (9 ,'Helsinki University'         ,'FI'), (10,'Sorbonne University'         ,'FR'),
 (11,'Berlin Tech University'      ,'DE'), (12,'Athens University'           ,'GR'),
 (13,'Budapest University'         ,'HU'), (14,'Dublin University'           ,'IE'),
 (15,'Sapienza University Rome'    ,'IT'), (16,'Riga Tech University'        ,'LV'),
 (17,'Vilnius University'          ,'LT'), (18,'Luxembourg University'       ,'LU'),
 (19,'Malta University'            ,'MT'), (20,'Amsterdam University'        ,'NL'),
 (21,'Warsaw University'           ,'PL'), (22,'Lisbon University'           ,'PT'), 
 (23,'Bucharest University'        ,'RO'), (24,'Bratislava University'       ,'SK'), 
 (25,'Ljubljana University'        ,'SI'), (26,'Madrid University'           ,'ES'), 
 (27,'Stockholm University'        ,'SE'), (28,'Oslo University'             ,'NO'),
 (29,'Reykjavik University'        ,'IS'), (30,'Liechtenstein University'    ,'LI');
SET IDENTITY_INSERT University OFF;

SET IDENTITY_INSERT Coordinator ON;
INSERT INTO Coordinator (CoordinatorID, CoordinatorName, CoordinatorEmail, Phone) VALUES
 (1 ,'Dr Anna Novak'      ,'annnov@uni.vie.at' ,'+43 660 111 111'),
 (2 ,'Dr Luc Peeters'     ,'lucpee@uni.bru.be' ,'+32 470 222 222'),
 (3 ,'Dr Maria Petrova'   ,'marpet@uni.sof.bg' ,'+359 88 333 333'),
 (4 ,'Dr Ivan Horvat'     ,'ivahor@uni.zag.hr' ,'+385 99 444 444'),
 (5 ,'Dr Eleni Ioannou'   ,'eleioa@uni.nic.cy' ,'+357 99 555 555'),
 (6 ,'Dr Jan Svoboda'     ,'jansvo@uni.pra.cz' ,'+420 607 666 666'),
 (7 ,'Dr Lars Jensen'     ,'larjen@uni.cop.dk' ,'+45 21 777 777'),
 (8 ,'Dr Aino Korhonen'   ,'ainkor@uni.tal.ee' ,'+372 55 888 888'),
 (9 ,'Dr Veikko Niemi'    ,'veinim@uni.hel.fi' ,'+358 50 999 999'),
 (10,'Dr Claire Martin'   ,'clamart@uni.par.fr','+33 6 010 101'),
 (11,'Dr Karl Müller'     ,'karmul@uni.ber.de' ,'+49 151 020 202'),
 (12,'Dr Nikos Papas'     ,'nikpap@uni.ath.gr' ,'+30 697 030 303'),
 (13,'Dr Ágnes Kovács'    ,'agkova@uni.bud.hu' ,'+36 70 040 404'),
 (14,'Dr Sean O’Neill'    ,'seaone@uni.dub.ie' ,'+353 87 050 505'),
 (15,'Dr Luca Rossi'      ,'lucros@uni.rom.it' ,'+39 348 060 606'),
 (16,'Dr Inese Ozola'     ,'ineozo@uni.rig.lv' ,'+371 29 070 707'),
 (17,'Dr Jonas Petrauskas','jonpet@uni.vil.lt' ,'+370 699 080 808'),
 (18,'Dr Jean Schmit'     ,'jeasch@uni.lux.lu' ,'+352 621 090 909'),
 (19,'Dr Maria Vella'     ,'marvel@uni.val.mt' ,'+356 9921 01010'),
 (20,'Dr Bram van Dijk'   ,'brvdij@uni.ams.nl' ,'+31 6 011 011'),
 (21,'Dr Piotr Kowalski'  ,'piokow@uni.war.pl' ,'+48 501 021 021'),
 (22,'Dr Leonor Silva'    ,'leosil@uni.lis.pt' ,'+351 912 031 031'),
 (23,'Dr Andrei Popescu'  ,'andpop@uni.buc.ro' ,'+40 723 041 041'),
 (24,'Dr Peter Novak'     ,'petnov@uni.bra.sk' ,'+421 903 051 051'),
 (25,'Dr Sara Zupan'      ,'sarzup@uni.lju.si' ,'+386 40 061 061'),
 (26,'Dr Eva Sanchez'     ,'evasan@uni.mad.es' ,'+34 645 071 071'),
 (27,'Dr Karin Larsson'   ,'karlar@uni.sto.se' ,'+46 70 081 081'),
 (28,'Dr Ole Berg'        ,'oleber@uni.osl.no' ,'+47 400 091 091'),
 (29,'Dr Helga Björnsson' ,'helbjo@uni.rek.is' ,'+354 860 101 101'),
 (30,'Dr Lars Weber'      ,'larweb@uni.vad.li' ,'+423 660 111 121');
SET IDENTITY_INSERT Coordinator OFF;

SET IDENTITY_INSERT Faculty ON;
INSERT INTO Faculty (FacultyID, UniversityID, FacultyName, CoordinatorID) VALUES
 (1 ,1 ,'Engineering',1 ),   (2 ,2 ,'Computer Science',2 ),
 (3 ,3 ,'Humanities',3 ),    (4 ,4 ,'Medicine',4 ),
 (5 ,5 ,'Business',5 ),      (6 ,6 ,'Physics',6 ),
 (7 ,7 ,'Law',7 ),           (8 ,8 ,'Art & Design',8 ),
 (9 ,9 ,'Data Science',9 ),  (10,10,'Mathematics',10),
 (11,11,'Economics',11),     (12,12,'Architecture',12),
 (13,13,'Chemistry',13),     (14,14,'Linguistics',14),
 (15,15,'History',15),       (16,16,'Robotics',16),
 (17,17,'Statistics',17),    (18,18,'Finance',18),
 (19,19,'Tourism',19),       (20,20,'Aerospace',20),
 (21,21,'Network Eng.',21),  (22,22,'Oceanography',22),
 (23,23,'ICT',23),           (24,24,'Psychology',24),
 (25,25,'Entrepreneurship',25),(26,26,'Philosophy',26),
 (27,27,'Genetics',27),      (28,28,'Geology',28),
 (29,29,'Software Eng.',29), (30,30,'Sustainability',30);
SET IDENTITY_INSERT Faculty OFF;

INSERT INTO Student (StudentID, FirstName, LastName, Email, HomeFacultyID, GradeAverage, Gender, BirthDate) VALUES
 (1001,'Ava'  ,'Novak'   ,'avanov@uni.vie.at',1 ,4.5,'F','2002-01-10'),
 (1002,'Ben'  ,'Peeters' ,'benpee@uni.bru.be',2 ,4.2,'M','2001-02-14'),
 (1003,'Clara','Petrova' ,'clapet@uni.sof.bg',3 ,4.1,'F','2002-03-18'),
 (1004,'David','Horvat'  ,'davhor@uni.zag.hr',4 ,3.9,'M','2001-04-22'),
 (1005,'Eva'  ,'Ioannou' ,'evaioa@uni.nic.cy',5 ,4.7,'F','2002-05-26'),
 (1006,'Finn' ,'Svoboda' ,'finsvo@uni.pra.cz',6 ,3.8,'M','2001-06-30'),
 (1007,'Greta','Jensen'  ,'grejen@uni.cop.dk',7 ,4.3,'F','2002-07-04'),
 (1008,'Heidi','Korhonen','heikor@uni.tal.ee',8 ,4.0,'F','2001-08-08'),
 (1009,'Ivan' ,'Niemi'   ,'ivaniem@uni.hel.fi',9 ,3.8,'M','2002-09-12'),
 (1010,'Julia','Martin'  ,'julmar@uni.par.fr',10,4.6,'F','2001-10-16'),
 (1011,'Karl' ,'Müller'  ,'karmue@uni.ber.de',11,4.2,'M','2002-11-20'),
 (1012,'Lena' ,'Papas'   ,'lenpap@uni.ath.gr',12,4.6,'F','2001-12-24'),
 (1013,'Mate' ,'Kovacs'  ,'matkov@uni.bud.hu',13,3.9,'M','2002-01-28'),
 (1014,'Nora' ,'ONeill'  ,'norone@uni.dub.ie',14,4.4,'F','2001-02-05'),
 (1015,'Omar' ,'Rossi'   ,'omaros@uni.rom.it',15,4.1,'M','2002-03-09'),
 (1016,'Paula','Ozola'   ,'paozol@uni.rig.lv',16,3.8,'F','2001-04-13'),
 (1017,'Quinn','Petra'   ,'qupetr@uni.vil.lt',17,4.5,'X','2002-05-17'),
 (1018,'Rok'  ,'Schmit'  ,'roksch@uni.lux.lu',18,4.0,'M','2001-06-21'),
 (1019,'Sara' ,'Vella'   ,'sarvel@uni.val.mt',19,4.4,'F','2002-07-25'),
 (1020,'Tom'  ,'Dijk'    ,'tomdij@uni.ams.nl',20,4.1,'M','2001-08-29'),
 (1021,'Ula'  ,'Kowalska','ulakow@uni.war.pl',21,3.9,'F','2002-09-02'),
 (1022,'Vera' ,'Silva'   ,'versil@uni.lis.pt',22,4.6,'F','2001-10-06'),
 (1023,'Wiktor','Popescu','wikpop@uni.buc.ro',23,4.3,'M','2002-11-10'),
 (1024,'Xenia','Novak'   ,'xenova@uni.bra.sk',24,4.0,'F','2001-12-14'),
 (1025,'Yannis','Zupan'  ,'yanzup@uni.lju.si',25,4.5,'M','2002-01-18'),
 (1026,'Zoë'  ,'Sanchez' ,'zoesan@uni.mad.es',26,4.3,'F','2001-02-22'),
 (1027,'Åke'  ,'Larsson' ,'akelar@uni.sto.se',27,3.9,'M','2002-03-26'),
 (1028,'Bjørn','Berg'    ,'bjberg@uni.osl.no',28,4.2,'M','2001-04-30'),
 (1029,'Dagny','Bjorn'   ,'dagbjo@uni.rek.is',29,4.6,'F','2002-05-04'),
 (1030,'Emil' ,'Weber'   ,'emiweb@uni.vad.li',30,4.0,'M','2001-06-08');

SET IDENTITY_INSERT Course ON;
INSERT INTO Course (CourseID, FacultyID, CourseName, ECTS, Term) VALUES
 (1 , 1 ,'Fluid Mechanics'     , 6 ,'Fall'  ), (2 , 2 ,'Algorithms'           , 5 ,'Spring'),
 (3 , 3 ,'World Literature'    , 4 ,'Fall'  ), (4 , 4 ,'Anatomy'              , 6 ,'Spring'),
 (5 , 5 ,'Marketing Basics'    , 5 ,'Fall'  ), (6 , 6 ,'Quantum Physics'      , 6 ,'Spring'),
 (7 , 7 ,'EU Law'              , 5 ,'Fall'  ), (8 , 8 ,'UX Design'            , 6 ,'Spring'),
 (9 , 9 ,'Machine Learning'    , 6 ,'Fall'  ), (10,10,'Number Theory'        , 5 ,'Spring'),
 (11,11,'Microeconomics'       , 6 ,'Fall'  ), (12,12,'Urban Design'         , 5 ,'Spring'),
 (13,13,'Organic Chemistry'    , 6 ,'Fall'  ), (14,14,'Syntax'               , 4 ,'Spring'),
 (15,15,'Ancient History'      , 5 ,'Fall'  ), (16,16,'Robot Control'        , 6 ,'Spring'),
 (17,17,'Data Mining'          , 6 ,'Fall'  ), (18,18,'Risk Management'      , 5 ,'Spring'),
 (19,19,'Hospitality Ops'      , 4 ,'Fall'  ), (20,20,'Flight Dynamics'      , 6 ,'Spring'),
 (21,21,'Cyber Security'       , 5 ,'Fall'  ), (22,22,'Marine Biology'       , 6 ,'Spring'),
 (23,23,'Cloud Computing'      , 6 ,'Fall'  ), (24,24,'Cognitive Psychology' , 5 ,'Spring'),
 (25,25,'Startup Finance'      , 5 ,'Fall'  ), (26,26,'Ethics'               , 4 ,'Spring'),
 (27,27,'Human Genetics'       , 6 ,'Fall'  ), (28,28,'Glaciology'           , 5 ,'Spring'),
 (29,29,'Agile Methods'        , 5 ,'Fall'  ), (30,30,'Green Design'         , 6 ,'Spring');
SET IDENTITY_INSERT Course OFF;

 INSERT INTO Agreement (HomeFacultyID, HostFacultyID, ScholarshipAmount) VALUES
 (1 ,2 ,600),(2 ,3 ,650),(3 ,4 ,700),(4 ,5 ,750),(5 ,6 ,800),
 (6 ,7 ,650),(7 ,8 ,600),(8 ,9 ,550),(9 ,10,500),(10,11,650),
 (11,12,700),(12,13,750),(13,14,800),(14,15,650),(15,16,600),
 (16,17,550),(17,18,500),(18,19,650),(19,20,700),(20,21,750),
 (21,22,800),(22,23,650),(23,24,600),(24,25,550),(25,26,500),
 (26,27,650),(27,28,700),(28,29,750),(29,30,800),(30,1 ,600);

 SET IDENTITY_INSERT Application ON;
INSERT INTO Application (ApplicationID, StudentID, SubmissionDate, AppStatus, AppTerm) VALUES
 (1 ,1001,'2024-01-10','Submitted','AY25'), (2 ,1002,'2024-02-11','Approved','AY25'),
 (3 ,1003,'2024-03-12','Draft','AY25'),     (4 ,1004,'2024-04-13','Submitted','AY25'),
 (5 ,1005,'2024-05-14','Approved','AY25'),  (6 ,1006,'2024-06-15','Draft','AY25'),
 (7 ,1007,'2024-07-16','Submitted','AY25'), (8 ,1008,'2024-08-17','Approved','AY25'),
 (9 ,1009,'2024-09-18','Draft','AY25'),     (10,1010,'2024-10-19','Submitted','AY25'),
 (11,1011,'2024-11-20','Approved','AY25'),  (12,1012,'2024-12-21','Draft','AY25'),
 (13,1013,'2025-01-22','Submitted','AY26'), (14,1014,'2025-02-23','Approved','AY26'),
 (15,1015,'2025-03-24','Draft','AY26'),     (16,1016,'2025-04-25','Submitted','AY26'),
 (17,1017,'2025-05-26','Approved','AY26'),  (18,1018,'2025-06-27','Draft','AY26'),
 (19,1019,'2025-07-28','Submitted','AY26'), (20,1020,'2025-08-29','Approved','AY26'),
 (21,1021,'2025-09-30','Draft','AY26'),     (22,1022,'2025-10-31','Submitted','AY26'),
 (23,1023,'2025-11-01','Approved','AY26'),  (24,1024,'2025-12-02','Draft','AY26'),
 (25,1025,'2026-01-03','Submitted','AY27'), (26,1026,'2026-02-04','Approved','AY27'),
 (27,1027,'2026-03-05','Draft','AY27'),     (28,1028,'2026-04-06','Submitted','AY27'),
 (29,1029,'2026-05-07','Approved','AY27'),  (30,1030,'2026-06-08','Draft','AY27');
SET IDENTITY_INSERT Application OFF;

SET IDENTITY_INSERT ExchangePeriod ON;
INSERT INTO ExchangePeriod (ExchangeID, ApplicationID, HostFacultyID, StartDate, EndDate) VALUES
 (1 ,1 ,2 ,'2025-02-01','2025-06-30'),
 (2 ,2 ,3 ,'2025-02-01','2025-06-30'),
 (3 ,3 ,4 ,'2025-02-01','2025-06-30'),
 (4 ,4 ,5 ,'2025-02-01','2025-06-30'),
 (5 ,5 ,6 ,'2025-02-01','2025-06-30'),
 (6 ,6 ,7 ,'2025-09-01','2026-01-31'),
 (7 ,7 ,8 ,'2025-09-01','2026-01-31'),
 (8 ,8 ,9 ,'2025-09-01','2026-01-31'),
 (9 ,9 ,10,'2025-09-01','2026-01-31'),
 (10,10,11,'2025-09-01','2026-01-31'),
 (11,11,12,'2026-02-01','2026-06-30'),
 (12,12,13,'2026-02-01','2026-06-30'),
 (13,13,14,'2026-02-01','2026-06-30'),
 (14,14,15,'2026-02-01','2026-06-30'),
 (15,15,16,'2026-02-01','2026-06-30'),
 (16,16,17,'2026-09-01','2027-01-31'),
 (17,17,18,'2026-09-01','2027-01-31'),
 (18,18,19,'2026-09-01','2027-01-31'),
 (19,19,20,'2026-09-01','2027-01-31'),
 (20,20,21,'2026-09-01','2027-01-31'),
 (21,21,22,'2027-02-01','2027-06-30'),
 (22,22,23,'2027-02-01','2027-06-30'),
 (23,23,24,'2027-02-01','2027-06-30'),
 (24,24,25,'2027-02-01','2027-06-30'),
 (25,25,26,'2027-02-01','2027-06-30'),
 (26,26,27,'2027-09-01','2028-01-31'),
 (27,27,28,'2027-09-01','2028-01-31'),
 (28,28,29,'2027-09-01','2028-01-31'),
 (29,29,30,'2027-09-01','2028-01-31'),
 (30,30,1 ,'2027-09-01','2028-01-31');
SET IDENTITY_INSERT ExchangePeriod OFF;

SET IDENTITY_INSERT ScholarshipPayment ON;
INSERT INTO ScholarshipPayment (PaymentID, ApplicationID, PaymentDate, Amount, Currency) VALUES
 (1 ,1 ,'2025-02-15',300,'EUR'),  (2 ,2 ,'2025-02-15',310,'EUR'),
 (3 ,3 ,'2025-02-15',320,'EUR'),  (4 ,4 ,'2025-02-15',330,'EUR'),
 (5 ,5 ,'2025-02-15',340,'EUR'),  (6 ,6 ,'2025-10-15',350,'EUR'),
 (7 ,7 ,'2025-10-15',360,'EUR'),  (8 ,8 ,'2025-10-15',370,'EUR'),
 (9 ,9 ,'2025-10-15',380,'EUR'),  (10,10,'2025-10-15',390,'EUR'),
 (11,11,'2026-02-20',400,'EUR'),  (12,12,'2026-02-20',410,'EUR'),
 (13,13,'2026-02-20',420,'EUR'),  (14,14,'2026-02-20',430,'EUR'),
 (15,15,'2026-02-20',440,'EUR'),  (16,16,'2026-10-20',450,'EUR'),
 (17,17,'2026-10-20',460,'EUR'),  (18,18,'2026-10-20',470,'EUR'),
 (19,19,'2026-10-20',480,'EUR'),  (20,20,'2026-10-20',490,'EUR'),
 (21,21,'2027-02-25',500,'EUR'),  (22,22,'2027-02-25',510,'EUR'),
 (23,23,'2027-02-25',520,'EUR'),  (24,24,'2027-02-25',530,'EUR'),
 (25,25,'2027-02-25',540,'EUR'),  (26,26,'2027-10-25',550,'EUR'),
 (27,27,'2027-10-25',560,'EUR'),  (28,28,'2027-10-25',570,'EUR'),
 (29,29,'2027-10-25',580,'EUR'),  (30,30,'2027-10-25',590,'EUR');
SET IDENTITY_INSERT ScholarshipPayment OFF;

SET IDENTITY_INSERT Accommodation ON;
INSERT INTO Accommodation (AccommodationID, StudentID, HostFacultyID, AddressLine, City, PostalCode, MonthlyCost, MoveInDate, MoveOutDate) VALUES
 (1 ,1001,2 ,'Ringstraße 12'          ,'Vienna'     ,'1010',450,'2025-02-01','2025-06-30'),
 (2 ,1002,3 ,'Rue Royale 8'           ,'Brussels'   ,'1000',420,'2025-02-01','2025-06-30'),
 (3 ,1003,4 ,'Vitosha Blvd 15'        ,'Sofia'      ,'1000',400,'2025-02-01','2025-06-30'),
 (4 ,1004,5 ,'Ilica 55'               ,'Zagreb'     ,'10000',380,'2025-02-01','2025-06-30'),
 (5 ,1005,6 ,'Ledras 20'              ,'Nicosia'    ,'1010',410,'2025-02-01','2025-06-30'),
 (6 ,1006,7 ,'Karlova 3'              ,'Prague'     ,'11000',450,'2025-09-01','2026-01-31'),
 (7 ,1007,8 ,'Åboulevarden 14'        ,'Copenhagen' ,'1720',430,'2025-09-01','2026-01-31'),
 (8 ,1008,9 ,'Narva mnt 7'            ,'Tallinn'    ,'10117',410,'2025-09-01','2026-01-31'),
 (9 ,1009,10,'Mannerheimintie 33'     ,'Helsinki'   ,'00100',390,'2025-09-01','2026-01-31'),
 (10,1010,11,'Rue de Rivoli 120'      ,'Paris'      ,'75001',480,'2025-09-01','2026-01-31'),
 (11,1011,12,'Unter den Linden 5'     ,'Berlin'     ,'10117',470,'2026-02-01','2026-06-30'),
 (12,1012,13,'Panepistimiou 60'       ,'Athens'     ,'10564',450,'2026-02-01','2026-06-30'),
 (13,1013,14,'Kossuth Lajos 9'        ,'Budapest'   ,'1053',430,'2026-02-01','2026-06-30'),
 (14,1014,15,'College Green 2'        ,'Dublin'     ,'D02',  410,'2026-02-01','2026-06-30'),
 (15,1015,16,'Via Nazionale 70'       ,'Rome'       ,'00184',390,'2026-02-01','2026-06-30'),
 (16,1016,17,'Brīvības 55'           ,'Riga'       ,'LV-1010',440,'2026-09-01','2027-01-31'),
 (17,1017,18,'Gedimino 1'             ,'Vilnius'    ,'LT-01103',420,'2026-09-01','2027-01-31'),
 (18,1018,19,'Avenue Monterey 20'     ,'Luxembourg' ,'L-2163',400,'2026-09-01','2027-01-31'),
 (19,1019,20,'Triq ir-Repubblika 10'  ,'Valletta'   ,'VLT1111',380,'2026-09-01','2027-01-31'),
 (20,1020,21,'Prinsengracht 251'      ,'Amsterdam'  ,'1016',450,'2026-09-01','2027-01-31'),
 (21,1021,22,'Piwna 4'                ,'Warsaw'     ,'00-265',430,'2027-02-01','2027-06-30'),
 (22,1022,23,'Rua das Flores 18'      ,'Lisbon'     ,'1200',410,'2027-02-01','2027-06-30'),
 (23,1023,24,'Calea Victoriei 12'     ,'Bucharest'  ,'010082',390,'2027-02-01','2027-06-30'),
 (24,1024,25,'Hviezdoslavovo 8'       ,'Bratislava' ,'81102',370,'2027-02-01','2027-06-30'),
 (25,1025,26,'Vegova ulica 5'         ,'Ljubljana'  ,'1000',350,'2027-02-01','2027-06-30'),
 (26,1026,27,'Calle Mayor 22'         ,'Madrid'     ,'28013',390,'2027-09-01','2028-01-31'),
 (27,1027,28,'Drottninggatan 50'      ,'Stockholm'  ,'11121',410,'2027-09-01','2028-01-31'),
 (28,1028,29,'Karl Johans gate 7'     ,'Oslo'       ,'0154',430,'2027-09-01','2028-01-31'),
 (29,1029,30,'Austurstræti 6'         ,'Reykjavik'  ,'101',  450,'2027-09-01','2028-01-31'),
 (30,1030,1 ,'Städtle 15'             ,'Vaduz'      ,'9490',470,'2027-09-01','2028-01-31');
SET IDENTITY_INSERT Accommodation OFF;

INSERT INTO CourseGrade (ApplicationID, CourseID, Grade, CreditsEarned) VALUES
 (1 ,2 ,5,5),(2 ,3 ,4,4),(3 ,4 ,4,6),(4 ,5 ,3,5),(5 ,6 ,5,6),
 (6 ,7 ,4,5),(7 ,8 ,5,6),(8 ,9 ,4,6),(9 ,10,3,5),(10,11,4,6),
 (11,12,5,6),(12,13,4,5),(13,14,3,4),(14,15,4,6),(15,16,5,6),
 (16,17,4,6),(17,18,5,5),(18,19,4,6),(19,20,5,6),(20,21,4,5),
 (21,22,5,6),(22,23,4,6),(23,24,5,5),(24,25,4,6),(25,26,5,5),
 (26,27,4,4),(27,28,5,6),(28,29,4,5),(29,30,5,6),(30,1 ,4,5);

 SET IDENTITY_INSERT Document ON;
INSERT INTO Document (DocumentID, Title) VALUES
 (1 ,'Learning Agreement'),(2 ,'Motivation Letter'),(3 ,'Transcript'),
 (4 ,'Passport Copy'),     (5 ,'CV'),               (6 ,'Language Cert.'),
 (7 ,'Insurance Proof'),   (8 ,'Arrival Form'),     (9 ,'Departure Form'),
 (10,'Confirmation of Stay'),(11,'Grant Agreement'),(12,'Visa'),
 (13,'ID Photo'),          (14,'Accommodation Proof'),(15,'Bank Statement'),
 (16,'Recommendation'),    (17,'Research Proposal'), (18,'Study Plan'),
 (19,'Course Catalogue'),  (20,'Health Form'),      (21,'COVID Cert.'),
 (22,'Tax ID'),            (23,'Emergency Contact'),(24,'Non-Compete'),
 (25,'Ethics Form'),       (26,'Internship Plan'),  (27,'Thesis Outline'),
 (28,'Exam Card'),         (29,'Library Card'),     (30,'IT Access Form');
SET IDENTITY_INSERT Document OFF;

INSERT INTO ApplicationCourses (ApplicationID, CourseID) VALUES
 (1 ,2 ),(2 ,3 ),(3 ,4 ),(4 ,5 ),(5 ,6 ),
 (6 ,7 ),(7 ,8 ),(8 ,9 ),(9 ,10),(10,11),
 (11,12),(12,13),(13,14),(14,15),(15,16),
 (16,17),(17,18),(18,19),(19,20),(20,21),
 (21,22),(22,23),(23,24),(24,25),(25,26),
 (26,27),(27,28),(28,29),(29,30),(30,1 );

 INSERT INTO ApplicationTarget (ApplicationID, FacultyID) VALUES
 (1 ,2 ),(2 ,3 ),(3 ,4 ),(4 ,5 ),(5 ,6 ),
 (6 ,7 ),(7 ,8 ),(8 ,9 ),(9 ,10),(10,11),
 (11,12),(12,13),(13,14),(14,15),(15,16),
 (16,17),(17,18),(18,19),(19,20),(20,21),
 (21,22),(22,23),(23,24),(24,25),(25,26),
 (26,27),(27,28),(28,29),(29,30),(30,1 );

 INSERT INTO DocumentRequirements (DocumentID, ApplicationID, DeadlineDate) VALUES
 (1 ,1 ,'2024-04-01'),  (2 ,2 ,'2024-05-01'),  (3 ,3 ,'2024-06-01'),
 (4 ,4 ,'2024-07-01'),  (5 ,5 ,'2024-08-01'),  (6 ,6 ,'2024-09-01'),
 (7 ,7 ,'2024-10-01'),  (8 ,8 ,'2024-11-01'),  (9 ,9 ,'2024-12-01'),
 (10,10,'2025-01-15'),  (11,11,'2025-02-15'),  (12,12,'2025-03-15'),
 (13,13,'2025-04-15'),  (14,14,'2025-05-15'),  (15,15,'2025-06-15'),
 (16,16,'2025-07-15'),  (17,17,'2025-08-15'),  (18,18,'2025-09-15'),
 (19,19,'2025-10-15'),  (20,20,'2025-11-15'),  (21,21,'2026-01-10'),
 (22,22,'2026-02-10'),  (23,23,'2026-03-10'),  (24,24,'2026-04-10'),
 (25,25,'2026-05-10'),  (26,26,'2026-06-10'),  (27,27,'2026-07-10'),
 (28,28,'2026-08-10'),  (29,29,'2026-09-10'),  (30,30,'2026-10-10');

 -- REPORTING QUERIES

 -- 1. How many applications are in each status per academic year-term

 SELECT
    AppStatus,
    AppTerm,
    COUNT(*)                                         AS TotalApplications,
    SUM(CASE WHEN AppStatus = 'Approved' THEN 1 END) AS ApprovedCount
FROM Application
GROUP BY AppStatus, AppTerm
ORDER BY AppTerm, AppStatus;

--2. Cumulative amount & number of payments per student

SELECT
    s.StudentID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
    SUM(sp.Amount)                       AS TotalScholarshipEUR,
    COUNT(sp.PaymentID)                  AS PaymentsMade
FROM ScholarshipPayment sp
JOIN Application       a ON sp.ApplicationID = a.ApplicationID
JOIN Student           s ON a.StudentID     = s.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName
ORDER BY TotalScholarshipEUR DESC;

-- 3. Average & count of scholarships by host country
SELECT
    cc.CountryName                       AS HostCountry,
    AVG(sp.Amount)                       AS AvgScholarshipEUR,
    COUNT(DISTINCT a.ApplicationID)      AS Applications
FROM ScholarshipPayment sp
JOIN Application       a  ON sp.ApplicationID = a.ApplicationID
JOIN ExchangePeriod    ep ON ep.ApplicationID = a.ApplicationID
JOIN Faculty           f  ON ep.HostFacultyID = f.FacultyID
JOIN University        u  ON f.UniversityID   = u.UniversityID
JOIN CountryCode       cc ON u.EUCountry      = cc.CountryCode
GROUP BY cc.CountryName
ORDER BY AvgScholarshipEUR DESC;

-- 4. Rank students on the basis of their average grade
SELECT
    s.StudentID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
    f.FacultyName AS HomeFaculty,
    s.GradeAverage,
    RANK() OVER (ORDER BY s.GradeAverage DESC) AS RankByGrade
FROM Student s
JOIN Faculty f ON s.HomeFacultyID = f.FacultyID
ORDER BY RankByGrade;

-- 5. Coordinators with their faculty, university, and country

SELECT
    c.CoordinatorID,
    c.CoordinatorName,
    f.FacultyName,
    u.UniversityName,
    cc.CountryName
FROM Coordinator   c
JOIN Faculty       f  ON c.CoordinatorID = f.CoordinatorID
JOIN University    u  ON f.UniversityID  = u.UniversityID
JOIN CountryCode   cc ON u.EUCountry     = cc.CountryCode
ORDER BY
    cc.CountryName,
    u.UniversityName,
    f.FacultyName;

	-- 6. Average accommodation cost per country
SELECT
    cc.CountryName,
    COUNT(*)              AS AccommodationCount,
    AVG(a.MonthlyCost)    AS AvgMonthlyCost
FROM Accommodation a
JOIN Faculty     f  ON a.HostFacultyID = f.FacultyID
JOIN University  u  ON f.UniversityID  = u.UniversityID
JOIN CountryCode cc ON u.EUCountry     = cc.CountryCode
GROUP BY cc.CountryName
ORDER BY AvgMonthlyCost DESC;

-- 7.Course performance report

SELECT
    c.CourseName,
    AVG(CASE cg.Grade               
            WHEN '5' THEN 5
            WHEN '4' THEN 4
            WHEN '3' THEN 3 END)    AS AvgGrade,
    COUNT(*)                        AS GradesRecorded
FROM CourseGrade cg
JOIN Course      c ON cg.CourseID = c.CourseID
GROUP BY c.CourseName
HAVING AVG(CASE cg.Grade WHEN '5' THEN 5 WHEN '4' THEN 4 WHEN '3' THEN 3 END) >= 4
ORDER BY AvgGrade DESC;

-- 8.  Assign every payment to one of four equal-sized bins
SELECT
    PaymentID,
    Amount,
    NTILE(4) OVER (ORDER BY Amount) AS AmountQuartile
FROM ScholarshipPayment
ORDER BY Amount;

-- 9. Overall number of female and male students

SELECT
    Gender,
    COUNT(*) AS StudentCount
FROM Student
WHERE Gender IN ('F','M', 'X')     
GROUP BY Gender
ORDER BY Gender;

-- 10.  Average span, in days, of all exchanges

SELECT
    AVG(DATEDIFF(DAY, StartDate, EndDate) + 1) AS AvgExchangeSpanDays
FROM ExchangePeriod;

-- 11. Overall sum of all scholarship payments
SELECT
    SUM(Amount) AS TotalScholarshipEUR
FROM ScholarshipPayment
WHERE Currency = 'EUR';

-- 12. Show all applications with student name, status, and submission date

SELECT
    a.ApplicationID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
    sc.Description                       AS ApplicationStatus,
    a.SubmissionDate
FROM Application a
JOIN Student     s  ON a.StudentID = s.StudentID
JOIN StatusCode  sc ON a.AppStatus = sc.StatusCode
ORDER BY a.SubmissionDate DESC,      
         StudentName;

-- 13. List of application targets (one row per target faculty)

SELECT
    a.ApplicationID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
    u.UniversityName,
    f.FacultyName                        AS TargetFaculty,
    cc.CountryName                       AS Country
FROM ApplicationTarget at
JOIN Application  a  ON at.ApplicationID = a.ApplicationID
JOIN Student      s  ON a.StudentID      = s.StudentID
JOIN Faculty      f  ON at.FacultyID     = f.FacultyID
JOIN University   u  ON f.UniversityID   = u.UniversityID
JOIN CountryCode  cc ON u.EUCountry      = cc.CountryCode
ORDER BY
    a.ApplicationID,
    u.UniversityName,
    f.FacultyName;

-- 14. List of host universities/faculties selected in each student application

SELECT
    s.StudentID,
    CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
    a.ApplicationID,
    u.UniversityName                     AS HostUniversity,
    f.FacultyName                        AS HostFaculty
FROM ApplicationTarget at
JOIN Application a ON at.ApplicationID = a.ApplicationID
JOIN Student     s ON a.StudentID     = s.StudentID
JOIN Faculty     f ON at.FacultyID    = f.FacultyID
JOIN University  u ON f.UniversityID  = u.UniversityID
ORDER BY
    StudentName,
    a.ApplicationID,
    HostUniversity;

