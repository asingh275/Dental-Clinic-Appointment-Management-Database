/* Comments
Q.10 To get the current date in mysql the function name is CURDATE() instead GETDATE()
Q.11 Full join querry works on MS SQL not on MySQL
Q.14 Natural Join is not supported by MS SQL so this querry*/

/*Q1. Shows patient and dentist who have appointment and with whom at a specific date*/
SELECT P.PID AS 'Patient ID', PName AS 'Patient Name', Dentist.SSN AS 'Dentist ID', CONCAT(Dentist.FName, ' ', Dentist.Lname) AS 'Dentist Name'
FROM (Dentist_Patient_Appointment DP JOIN Patient P ON P.PID = DP.PID) JOIN Dentist ON DP.SSN = Dentist.SSN
WHERE Ap_DATE = '2021-07-13'; 

/*Q2. Shows the number of patients came on the different dates to analyze data for marketing+*/
SELECT COUNT(PID) AS 'No. of Patients', Ap_Date AS 'DATE'
FROM Dentist_Patient_Appointment
GROUP BY Ap_Date
ORDER BY Ap_Date;

/*Q3. Shows all the patients who have open payment plan*/
SELECT Plan_ID, P.PID, PName
FROM Payment_Plan PP JOIN Patient P ON PP.PID = P.PID
WHERE Plan_Status = 'Open';

/*Q4. When all amount is paid plan status is closed OR The plan is closed when all amount is paid off
Run the code below to see which plan is open even the whole amount is paid
SELECT *
FROM Payment_Plan;
*/
UPDATE Payment_Plan
SET Plan_Status = 'Closed'
WHERE Total_Remaining_Amt = 0;
/*We can also use UPDATE querry to update name of a patient or dentist, speacialization of dentist, payment plan and many more
but we just used this otherwise all other are similar*/

/*Q5. Cancelling appointment
SELECT *
FROM Dentist_Patient_Appointment;
*/
DELETE FROM Dentist_Patient_Appointment
WHERE PID = '123456'
	  AND Ap_Date = '2021-07-12'; /*OR SSN = '' Patient or dentist can cancel appointment date. 
	  Time can also be included using AND Ap_Time = '' in the WHERE clause to cancel one appointment on a specific date */

/*Q6. Shows all patient who got registered but did not visited clinic(means did not have or had appointment) as it is online website patient can register but not visit*/
SELECT PID, PName
FROM Patient
WHERE PID NOT IN(SELECT PID 
					FROM Dentist_Patient_Appointment 
					GROUP BY PID, SSN);

/*Q7. select all patients who do not have any insurance*/
SELECT Patient.PID, PName
FROM Patient LEFT JOIN Patient_have_Insurer ON Patient.PID = Patient_have_Insurer.PID
WHERE Insurer_Name IS NULL;
                    
/*Q8. ALL PATIENTS AND DENTIST THEY GET APPOINTED (shows all patients even 
if they didn't came to clinic in other words never attented or had appointment
)*/
SELECT P.PID, SSN 
FROM Patient P LEFT JOIN Dentist_Patient_Appointment D 
ON P.PID = D.PID;

/*Q9. Income value of a month */
SELECT SUM(PaidAmount)
FROM Payment
WHERE Payment_Date BETWEEN '2019-02-01' AND '2019-03-01';

/*Q10. SELECTS all upcoming appointments and the doctors they have appointment with*/
SELECT PID, SSN, Ap_Date
FROM Dentist_Patient_Appointment
WHERE Ap_Date > GETDATE()/* To get the current date in mysql the function name is CURDATE() instead GETDATE()*/
ORDER BY Ap_Date ASC;
 
/*Q11. Created view which selects all the bills of patients and the payments of the bills and the remaining amount to be paid.If bill paid through installments shows the paid amount*/
CREATE VIEW PatientBillsPayments AS
SELECT P.PID, PB.BillID, PB.TotalAmount, Total_Remaining_Amt, CONCAT(BFP.ReceiptID, PPI.ReceiptID) AS ReceiptID, PaidAmount
FROM ((Patient P RIGHT JOIN Patient_Bill PB ON P.PID = PB.PID) FULL JOIN Bill_Full_Payment BFP ON BFP.BillID = PB.BillID)
	FULL JOIN (((PaymentPlan_Payment_Installment PPI JOIN Payment_Plan PPlan ON PPI.Plan_ID = PPlan.Plan_ID)
	JOIN Patient_Bill ON PPlan.BillID = Patient_Bill.BillID)
	JOIN Payment ON Payment.ReceiptID = PPI.ReceiptID) ON PB.BillID = PPlan.BillID;

SELECT *
FROM PatientBillsPayments;

DROP VIEW PatientBillsPayments;

/*Q12 Selects all the bills and payments of the bills of a patient*/
SELECT PID AS 'Patient Name', BillID, ReceiptID
FROM PatientBillsPayments
WHERE PID = '123456';
/*Now as we got the ReceiptID and bills of patient we can get when payment was done by
SELECT Payment_Date, Payment_Time
FROM Payment
WHERE ReceiptID = '123456784';

AND how the payment was done by 
SELECT PaymentMode
FROM Money
WHERE ReceiptID = '123456784'

or

SELECT Insurer_Name
FROM Insurance
WHERE ReceiptID = '123456784'
*/

/*Q13. Showing the name of patient treated by the specific dentist who is specialized in their feild */
SELECT Dentist.FName AS 'Dentist', Patient.PName AS 'Patient'
FROM Patient Cross Join Dentist Cross Join Dentist_Patient_Appointment 
Where Dentist_Patient_Appointment.PID = Patient.PID 
	AND Dentist_Patient_Appointment.SSN = Dentist.SSN
GROUP BY Dentist.FName, Patient.PName;

/*Q14. Find patients who did full payment for their bill*/
SELECT PID, PName 
FROM (Patient NATURAL JOIN Patient_Bill) NATURAL JOIN Bill_Full_Payment
ORDER BY PName ASC;

/*Q15. shows only those patient who referred new patient (Their IDs and Name)*/
SELECT CurrentPatient_PID, Pname AS 'Current', NewPatient_PID, (SELECT PName FROM Patient WHERE PID = NewPatient_PID) AS New
FROM CurrentPatient_Refers_NewPatient, Patient
WHERE patient.PID= CurrentPatient_Refers_NewPatient.CurrentPatient_PID;

/*Q16. finds the dentists who are free (do not have appointments)on a specific date so that are made avilable for appointments*/
SELECT SSN, CONCAT(FName, LName) AS NAME
FROM Dentist 
WHERE SSN NOT IN (SELECT SSN FROM Dentist_Patient_Appointment WHERE Ap_Date = '2021-07-31' /* We can also add Ap_Time to find the availability at specific time on a day*/);

/*Q17. displays all the dentists a patient attended */
SELECT DISTINCT  Dentist.SSN, CONCAT(FName,' ', LName) AS 'Name'
FROM Dentist JOIN Dentist_Patient_Appointment Ap ON Dentist.SSN = Ap.SSN
WHERE PID = '123456';

/*Q18. DELETING the patients who are not did not made any apppontment in 10 years*/  
DELETE FROM Patient
WHERE PID NOT IN (SELECT PID FROM Dentist_Patient_Appointment
					WHERE Ap_Date > DATEADD(YEAR, -10, GETDATE()));
/*My SQL version of this querry
DELETE FROM Patient
WHERE PID NOT IN (SELECT PID FROM Dentist_Patient_Appointment
					WHERE Ap_Date > DATE_ADD(CURDATE(), INTERVAL 10 YEAR));
*/

/*Q19. Display top insurers in terms of amount they paid*/
SELECT Insurer_Name, SUM(PaidAmount)
FROM Insurance I INNER JOIN Payment P ON I.ReceiptID = P.ReceiptID
GROUP BY Insurer_Name
ORDER BY SUM(PaidAmount) DESC;

/*Q20. Displaying total number of appointments a patient booked */
SELECT PID, COUNT(Ap_Date) AS 'Number of Appointments'
FROM Dentist_Patient_Appointment
GROUP BY PID
HAVING COUNT(Ap_Date) >=1;
