CREATE TABLE Dentist(
	SSN INT PRIMARY KEY CHECK (SSN>99999999 AND SSN<=999999999),
    FName VARCHAR(30),
    LName VARCHAR(30),
    Specialization VARCHAR(30),
    Salary INT,
    Dentist_DOB DATE
);

CREATE TABLE Patient(
	PID INT PRIMARY KEY CHECK (PID > 99999 AND PID <=999999),
    PName VARCHAR(30),
    PAddress VARCHAR(100),
    Patient_DOB DATE,
    PhNumber NUMERIC CHECK (PhNumber > 999999999 AND PhNumber <=9999999999)
);

CREATE TABLE Insurer(
	Insurer_Name VARCHAR(30) PRIMARY KEY,
    Insurer_Address VARCHAR(100)
);

CREATE TABLE Payment_Plan(
	Plan_ID INT PRIMARY KEY CHECK (Plan_ID > 999999 AND Plan_ID <=9999999),
    Plan_Status VARCHAR(6),
    Start_Date_of_Plan DATE,
    Last_Date_of_Plan DATE,
    Total_Remaining_Amt INT,
	Due_Day DATE,
    After_Every_Month TINYINT,
    PID INT CHECK (PID > 99999 AND PID <=999999),
    BillID NUMERIC(6),
    FOREIGN KEY (PID, BillID) REFERENCES Patient_Bill(PID, BillID)
);

CREATE TABLE Payment(
	ReceiptID INT PRIMARY KEY CHECK (ReceiptID > 99999999 AND ReceiptID <= 999999999),
    Payment_Date Date, 
    PaidAmount INT,
    Payment_Time Time    
);
    
CREATE TABLE Money(
	ReceiptID INT PRIMARY KEY CHECK (ReceiptID > 99999999 AND ReceiptID <= 999999999),
	PaymentMode VARCHAR(30),
	FOREIGN KEY (ReceiptID) REFERENCES Payment( ReceiptID) ON DELETE CASCADE
);

CREATE TABLE Insurance(
	ReceiptID INT PRIMARY KEY CHECK (ReceiptID > 99999999 AND ReceiptID <= 999999999),
    PolicyNumber NUMERIC(8),
    Insurer_Name VARCHAR(30) REFERENCES Insurer (Insurer_Name) ON DELETE CASCADE,
    FOREIGN KEY (ReceiptID) REFERENCES Payment(ReceiptID) ON DELETE CASCADE
);

CREATE TABLE Dentist_Patient_Appointment(
	SSN  INT CHECK (SSN>99999999 AND SSN<=999999999) REFERENCES Dentist(SSN) ON DELETE CASCADE,
    PID INT CHECK (PID > 99999 AND PID <=999999) REFERENCES Patient(PID) ON DELETE CASCADE,
    Ap_Date DATE,
    Ap_Time TIME,
    PRIMARY KEY(SSN, PID, Ap_Date, Ap_Time)
);

CREATE TABLE Patient_Bill(
    PID INT CHECK (PID > 99999 AND PID <=999999) REFERENCES Patient(PID) ON DELETE CASCADE,
	BillID NUMERIC(6),
    TotalAmount INT,
    PRIMARY KEY(BillID, PID)
);

CREATE TABLE Bill_Full_Payment(
	PID INT CHECK (PID > 99999 AND PID <=999999),
    BillID NUMERIC(6),
    ReceiptID INT PRIMARY KEY CHECK (ReceiptID > 99999999 AND ReceiptID <= 999999999),
    FOREIGN KEY(ReceiptID) REFERENCES Payment(ReceiptID) ON DELETE CASCADE,
	FOREIGN KEY (BillID, PID) REFERENCES Patient_Bill(BillID, PID) ON DELETE CASCADE
);

CREATE TABLE PaymentPlan_Payment_Installment(
	 ReceiptID INT PRIMARY KEY CHECK (ReceiptID > 99999999 AND ReceiptID <= 999999999),
     InstallmentNumber INT,
     Plan_ID INT CHECK (Plan_ID > 999999 AND Plan_ID <=9999999) REFERENCES Payment_Plan(Plan_ID) ON DELETE CASCADE, 
     FOREIGN KEY(ReceiptID) REFERENCES Payment(ReceiptID) ON DELETE CASCADE
);

CREATE TABLE Patient_have_Insurer(
	PID INT CHECK (PID > 99999 AND PID <=999999) REFERENCES Patient(PID) ON DELETE CASCADE,
    Insurer_Name VARCHAR(30) REFERENCES Insurer (Insurer_Name) ON DELETE CASCADE,
    InsuranceContractNumber NUMERIC(9),
    PRIMARY KEY(PID, Insurer_Name)
);

CREATE TABLE CurrentPatient_Refers_NewPatient(
	CurrentPatient_PID INT CHECK (CurrentPatient_PID > 99999 AND CurrentPatient_PID <=999999),
    NewPatient_PID INT CHECK (NewPatient_PID > 99999 AND NewPatient_PID <=999999) PRIMARY KEY,
    FOREIGN KEY(CurrentPatient_PID) REFERENCES Patient(PID),
    FOREIGN KEY(NewPatient_PID) REFERENCES Patient(PID)
);