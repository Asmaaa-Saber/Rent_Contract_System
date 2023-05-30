DECLARE
   CURSOR INST_clinet IS
      SELECT * FROM HR.CONTRACTS;
   number_months NUMBER(10,8);---number of months between 'start date' 'end date' 
   result NUMBER(8);--- remaining value after daposit المبلغ المسستحق للدفع 
   v_installments_per_year number (2); ----The number of payments per year 
   Pay_periods NUMBER(6);---Payment periods  هدفع كام مره ف السنه 
   pay_amount NUMBER(8);---The value of Installment هدفع اد ايه كل مره 
   v_installment_date DATE; ----The date the installment was paid تاريخ الدفع 
   v_paid NUMBER(2) := 1; --constant 
  v_count_inst_contract_id number (5); --- count of contract id is instalment_paid tabel 
  
BEGIN 
   FOR inst_record IN INST_clinet LOOP 
   ---------calculate Total Months----
      number_months := MONTHS_BETWEEN(inst_record.CONTRACT_ENDDATE, inst_record.CONTRACT_STARTDATE);
      DBMS_OUTPUT.PUT_LINE('v_months =' || number_months);
     --------The remaining value after the deposit------
        result := inst_record.CONTRACT_TOTAL_FEES - nvl(inst_record.CONTRACT_DEPOSIT_FEES,0)  ;
------Get Number of  payments in each year Based on Payment Type ----
      IF inst_record.CONTRACT_PAYMENT_TYPE = 'ANNUAL' THEN 
         v_installments_per_year := 1; 
         Pay_periods := number_months / 12; 
         pay_amount := result / Pay_periods;
      ELSIF inst_record.CONTRACT_PAYMENT_TYPE = 'QUARTER' THEN
        v_installments_per_year := 4;
        Pay_periods := number_months / 3;
        pay_amount := result / Pay_periods;
      ELSIF inst_record.CONTRACT_PAYMENT_TYPE = 'MONTHLY' THEN
             v_installments_per_year := 12;
         Pay_periods := number_months / 1;
            pay_amount := result / Pay_periods;
      ELSIF inst_record.CONTRACT_PAYMENT_TYPE = 'HALF_ANNUAL' THEN
         v_installments_per_year := 2;
         Pay_periods := number_months / 6;
         pay_amount := result / Pay_periods;
      END IF;
      -----to insert data into instalments paid tabel 
FOR i IN 1..Pay_periods LOOP
    v_installment_date := ADD_MONTHS(inst_record.CONTRACT_STARTDATE, (i-1) * 12 / v_installments_per_year);
      INSERT INTO HR.INSTALLMENTS_PAID (INSTALLMENT_ID, CONTRACT_ID, INSTALLMENT_DATE, INSTALLMENT_AMOUNT, PAID)
      values(INSTALLMENTS_PAID_SEQ.NEXTVAL,inst_record.contract_id, v_installment_date, pay_amount, v_paid);
      end loop;
      end loop;
END;
select * from INSTALLMENTS_PAID