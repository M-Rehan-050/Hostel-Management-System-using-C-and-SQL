--STUDENTS, ROOM,WARDENS,PAYMENTS TOTAL 4 TABLE HAIN
--INSIDE STUDENT ,ROOM NUMBER IS USED AS FOREIGN KEY
CREATE DATABASE Hostel_db
DROP DATABASE Hostel_db
go

DROP TABLE if EXISTS Room
Create table Room(
Room_Number INT PRIMARY KEY,
Capacity INT ,
Occupied INT,
Status  AS(
CASE
 WHEN Occupied >= Capacity THEN'FULL'
 ELSE 'ASSIGNED'
END
)

);
DROP TABLE if EXISTS Students 
Create table Students(
Student_ID  INT PRIMARY KEY IDENTITY(1,1),
Name      VARCHAR(250),
Age       INT CHECK (Age >=18 AND Age <=50),
Room_Number INT Foreign Key References Room(Room_Number),
Join_Date  date,
Contact VARCHAR(250) DEFAULT('DONT HAVE'),
National_Identity_Card VARCHAR(250)
);



DROP TABLE if EXISTS Wardens
Create table Wardens(
Staff_ID INT PRIMARY KEY,
Name     VARCHAR(250),
Role   VARCHAR(250) DEFAULT('UN-ASSIGNED'),
Contact VARCHAR(250),
Shift  VARCHAR(250)
);

DROP TABLE if EXISTS Payments
Create table Payments(
Payment_ID INT PRIMARY KEY,
Student_ID INT FOREIGN KEY REFERENCES Students(Student_ID) ON DELETE CASCADE,
Amount     INT,
Payment_Date DATE,
Status     VARCHAR(250) DEFAULT('UN-ASSIGNED'),
);

INSERT INTO Room(Room_Number,Capacity,Occupied)
VALUES
(1,3,0);



--PROCEDURES TO MANAGE STUDENT

CREATE PROCEDURE SHOW_STUDENT_DETAILS
AS
SELECT *from Students
GO;

CREATE PROCEDURE DROP_STUDENT_DETAILS @Student_ID INT
AS
DELETE FROM Students 
WHERE Student_ID= @Student_ID

CREATE PROCEDURE SEARCH_STUDENT_DETAILS @Student_ID INT
AS
SELECT *FROM Students WHERE Student_ID=@Student_ID

CREATE PROCEDURE UPDATE_STUDENT_DETAILS @Name VARCHAR(250),@Student_ID INT
AS
UPDATE Students SET
Name=@Name
Where Student_ID=@Student_ID
DROP PROCEDURE INSERT_STUDENT
CREATE PROCEDURE INSERT_STUDENT @Name VARCHAR (250),@Age INT,@Room_Number INT,@Join_Date date,@Contact VARCHAR (250), @National_Identity_Card VARCHAR(250)
AS
BEGIN
IF(SELECT Occupied FROM Room WHERE Room_Number=@Room_Number) >=(SELECT Capacity FROM Room WHERE Room_Number=@Room_Number)
BEGIN
RAISERROR ('Room is Already FULL !!' ,16,1);
RETURN;
END
INSERT INTO Students(Name,Age ,Room_Number,Join_Date,Contact,National_Identity_Card)
VALUES(@Name, @Age, @Room_Number,@Join_Date ,@Contact,@National_Identity_Card);
Update Room
SET Occupied=Occupied+1
Where Room_Number=@Room_Number;
END



SHOW_STUDENT_DETAILS;
EXEC DROP_STUDENT_DETAILS @Student_ID=3;--DELETE CASCADE IS USED BECAUSE DIRECTLY CANNOT DELETE DUE TO FOREIGN KEY USED ELSE REMOVE IT FROM TABLE ABOVE 
EXEC SEARCH_STUDENT_DETAILS @Student_ID = 1;
EXEC UPDATE_STUDENT_DETAILS @Name='Rehann' ,@Student_ID=2
EXEC INSERT_STUDENT @Name='Zohaib', @Age=39, @Room_Number=1, @Join_Date='2025-09-03', @Contact='0000001',@National_Identity_Card='3660100000005';
EXEC INSERT_STUDENT @Name='ABDULLAH', @Age=28, @Room_Number=3, @Join_Date='2025-09-04', @Contact='999999',@National_Identity_Card='3660100000004';
EXEC INSERT_STUDENT @Name='rEHANNN', @Age=39, @Room_Number=3, @Join_Date='2025-09-03', @Contact='0000001',@National_Identity_Card='3660100000005';

DROP PROCEDURE IF EXISTS INSERT_STUDENT;

--ROOM MANAGEMENT

CREATE PROCEDURE ADD_ROOM @Room_Number INT ,@Capacity INT ,@Occupied INT
AS
INSERT INTO Room(Room_Number,Capacity,Occupied)
VALUES(@Room_Number,@Capacity,@Occupied)


CREATE PROCEDURE UPDATE_ROOM_DETAILS @Capacity INT,@Room_Number INT
AS
UPDATE Room SET
Capacity=@Capacity
Where Room_Number=@Room_Number


CREATE PROCEDURE DELETE_ROOM @Room_Number INT
AS
Delete from Room
Where Room_Number= @Room_Number

CREATE PROCEDURE Availability_Check @Room_Number INT
AS
SELECT Room_Number= @Room_Number From Room
GROUP BY Status


EXEC Availability_Check @Room_Number =1
SHOW_ROOM_DETAILS;
EXEC ADD_ROOM @Room_Number=10, @Capacity=1, @Occupied=0
EXEC UPDATE_ROOM_DETAILS @Room_Number =10 ,@Capacity=3
EXEC DELETE_ROOM @Room_Number =10

--WARDEN MANAGEMENT
CREATE PROCEDURE SHOW_WARDEN_DETAILS 
AS
Select *from Wardens
GO;

CREATE PROCEDURE ADD_WARDEN @Staff_ID INT ,@Name VARCHAR(250), @Role VARCHAR(250), @Contact VARCHAR(250), @Shift VARCHAR(250)
AS
INSERT INTO Wardens(Staff_ID,Name,Role,Contact,Shift)
VALUES(@Staff_ID, @Name ,@Role,@Contact,@Shift);

CREATE PROCEDURE UPDATE_WARDEN @Staff_ID INT ,@Shift VARCHAR(250)
AS
UPDATE Wardens SET
Shift=@Shift
WHERE Staff_ID=@Staff_ID

CREATE PROCEDURE DELETE_WARDEN @Staff_ID INT
AS
DELETE From Wardens
WHERE Staff_ID=@Staff_ID

SHOW_WARDEN_DETAILS;
EXEC ADD_WARDEN @Staff_ID=1123 ,@Name='ZOHAIB',@Role='MESS INCHARGE', @Contact='0334', @Shift='MORNING';
EXEC ADD_WARDEN @Staff_ID=1124 ,@Name='HAMZA',@Role='SECURITY', @Contact='033356666', @Shift='EVENING';

EXEC UPDATE_WARDEN @Staff_ID=1123 ,@Shift='EVENING'
EXEC DELETE_WARDEN @Staff_ID =1123

--PAYMENT MANAGEMENT
CREATE PROCEDURE SHOW_PAYMENT
AS
SELECT *FROM Payments
GO;

CREATE PROCEDURE ADD_PAYMENT @Payment_ID INT ,@Student_ID INT ,@Amount INT,@Payment_Date Date ,@Status VARCHAR(250)
AS
INSERT INTO Payments(Payment_ID,Student_ID,Amount,Payment_Date,Status)
VALUES (@Payment_ID,@Student_ID,@Amount,@Payment_Date,@Status)

CREATE PROCEDURE VIEW_PENDING @Student_ID INT
AS
SELECT Student_ID,Amount,Status from Payments AS Pending_Payments
WHERE Student_ID = @Student_ID
GROUP BY Student_ID,Amount,Status;


EXEC SHOW_PAYMENT;
EXEC ADD_PAYMENT @Payment_ID= 001, @Student_ID=3, @Amount=500 , @Payment_Date='2025-01-01', @Status='Paid'
EXEC ADD_PAYMENT @Payment_ID= 002, @Student_ID=4, @Amount=9000 , @Payment_Date='2022-02-09', @Status='Pending'
EXEC VIEW_PENDING @Student_ID =2


DROP PROCEDURE IF EXISTS VIEW_PENDING

--REPORT MANAGEMENT TWO TYPES

CREATE PROCEDURE REPORTS_GENERATION_COMPLETE
AS
SELECT *FROM
Students As S
FULL JOIN Payments As P
On S.Student_ID=P.Student_ID

CREATE PROCEDURE REPORTS_GENERATION_MATCHED_ONES
AS
SELECT *FROM
Students As S
INNER JOIN Payments As P
On S.Student_ID=P.Student_ID


EXEC REPORTS_GENERATION_COMPLETE
EXEC REPORTS_GENERATION_MATCHED_ONES
DROP PROCEDURE IF EXISTS REPORTS_GENERATION_COMPLETE

