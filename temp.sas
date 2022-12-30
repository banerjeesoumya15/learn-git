/*libname Claims 'E:\Sas_files\MotorDB-Sep21\Required for pricing';*/
libname CLMDB 'C:\Users\ashamseldien\Desktop\OPERATION\OP\AUG22';
Libname InhRes 'C:\Users\ashamseldien\Desktop\OPERATION\OP\AUG22';
/*%let Path='E:\Sas_files\MotorDB-Jun19\Updated_Logic_5Aug19\Test9';*/
%let VDate='31JUL2022:00:00:00'dt;
%let FDate='01Jan2019'd ;
%Let File1 =Claims_dataset;
/*%Let ExPeriod = EarnedExp_Sep_21;*/


data testcld_2019_Mot;
set CLMDB.&File1;
if CLASS_DESC ="MOTOR" then output;
run;

data Testcld_2019_mot_m;
set  testcld_2019_Mot;
if ESTM_CLOSED = "YES" then OS_adj = 0;
else if ESTM_CLOSED = "No" then OS_adj = OS ;run;


Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID   APPROVAL_DT PAYMENT RECOVER_OS CLOSE_DT;run;


data Testcld_2019_mot_m;
set  Testcld_2019_mot_m;
Myserial = _n_;run;


data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by ESTM_ID notsorted;
if first.ESTM_ID then sumOSbyid=0;
 sumOSbyid+OS;run;
data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by ESTM_ID notsorted;
if last.ESTM_ID then Balance_Ind= "Y";
 run;


 /*SAVED POINT*/
DATA InhRes.Testcld_2019_mot_m_0;
SET  Testcld_2019_mot_m;


 /*SAVED POINT*/
Proc sort data=Testcld_2019_mot_m; ;by   ESTM_ID Myserial  ;run;

data Testcld_2019_mot_m;
   if 0 then set Testcld_2019_mot_m;
   do until(not missing(datepart(CLOSE_DT)) or last.ESTM_ID );
      set Testcld_2019_mot_m;
      by ESTM_ID;  
      if first.ESTM_ID then ltemp=.;
      end;
   temp=CLOSE_DT;
   do until(not missing(datepart(CLOSE_DT)) or last.ESTM_ID );
      set Testcld_2019_mot_m;
      by ESTM_ID;
      _CLOSE_DT=coalesce(temp,ltemp);
      output;
      end;
   retain ltemp;
   ltemp=temp;
   drop temp ltemp;
   format _CLOSE_DT DATETIME20.;
   run;*/*;
Data Testcld_2019_mot_m;
Set Testcld_2019_mot_m;
if Balance_Ind = "Y" and not missing (datepart(_CLOSE_DT)) and datepart(_CLOSE_DT) <> '01Jan1960'd then Closing_balance = -sumOSbyid;run;
/*else if Balance_Ind = "Y" and sumOSbyid <0 then Closing_balance = -sumOSbyid;*/
*/stopped here/*;
Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID   APPROVAL_DT PAYMENT RECOVER_OS _CLOSE_DT Myserial;run;
Data Testcld_2019_mot_m;
Set Testcld_2019_mot_m;
Myserial2=_n_;
Diff=Myserial2-Myserial;
run;
Data Invalid_sorting;
Set Testcld_2019_mot_m;
if Diff ne 0 then output;run;

/*Once you see 0 difference you can proceed*/;

data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by ESTM_ID notsorted;
if first.ESTM_ID then sumOSRecbyid=0;
 sumOSRecbyid+RECOVER_OS;run;
Data Testcld_2019_mot_m;
Set Testcld_2019_mot_m;
if Balance_Ind = "Y" and not missing (datepart(_CLOSE_DT)) and datepart(_CLOSE_DT) <> '01Jan1960'd then ClosingOSRec_balance = -sumOSRecbyid;
/*else if Balance_Ind = "Y" and sumOSRecbyid >0 then ClosingOSRec_balance = -sumOSRecbyid;*/
run;*/stopped here/*;
Data Testcld_2019_mot_m;
Set Testcld_2019_mot_m;
if Balance_Ind = "Y" and  missing (datepart(_CLOSE_DT)) and (CLAIM_CURRENT_STS)= "Closed" and not missing (datepart(_CLOSE_DT)) then  ClosingOSRec_balance2=-sumOSRecbyid;run;



proc sql print;
   select count(distinct TYPE_OF_CLAIM)
      into :n
      from Testcld_2019_mot_m;
   select distinct TYPE_OF_CLAIM
      into :TYPE_OF_CLAIM1 - :TYPE_OF_CLAIM%left(&n)
      from Testcld_2019_mot_m;
quit;

data Testcld_2019_mot_m;
set Testcld_2019_mot_m;LENGTH RECOVERY_TYPE $ 150;
if TYPE_OF_CLAIM = "RECOVERY FROM CUSTOMER" then RECOVERY_TYPE ="Recovery from Insured";
else if TYPE_OF_CLAIM = "Recovery- Other" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery from Third Party" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "RECOVERY FROM THIRD PARTY" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "RECOVERY FROM THIRD PARTY" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - Third Party Property" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - Salvage of Insured Vehicle" then RECOVERY_TYPE ="Salvage";
else if TYPE_OF_CLAIM = "Recovery - Salvage of Insured Vehicle" then RECOVERY_TYPE ="Salvage";
else if TYPE_OF_CLAIM = "Recovery - Salvage of Third Party Vehicle" then RECOVERY_TYPE ="Salvage";
else if TYPE_OF_CLAIM = "Recovery on False Settlement" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - P & I" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - Salvage" then RECOVERY_TYPE ="Salvage";

else if TYPE_OF_CLAIM = "REVERSAL OF RECOVERY - MARINE" then RECOVERY_TYPE ="Reversal of Recovery";
else if TYPE_OF_CLAIM = "Recovery - From Insured" then RECOVERY_TYPE ="Recovery from Insured";
else if TYPE_OF_CLAIM = "Reversal of Recovery Motor" then RECOVERY_TYPE ="Reversal of Recovery";
else if TYPE_OF_CLAIM = "REVERSAL OF RECOVERY - MOTOR" then RECOVERY_TYPE ="Reversal of Recovery";

else if TYPE_OF_CLAIM = "Recovery - from insurance Company" then RECOVERY_TYPE ="Recovery - from insurance Company";

else if TYPE_OF_CLAIM = "Recovery - Other Insurance Company" then RECOVERY_TYPE ="Recovery - from insurance Company";
else if TYPE_OF_CLAIM = "Recovery - Shipping Agen" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - Insured" then RECOVERY_TYPE ="Recovery from Insured";
else if TYPE_OF_CLAIM = "Recovery - Insurance Company" then RECOVERY_TYPE ="Recovery - from insurance Company";
else if TYPE_OF_CLAIM = "REVERSAL OF RECOVERY - ENG" then RECOVERY_TYPE ="Reversal of Recovery";
else if TYPE_OF_CLAIM = "Recovery - False Settlement" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "REVERSAL OF RECOVERY - ENG" then RECOVERY_TYPE ="Reversal of Recovery";
else if TYPE_OF_CLAIM = "REVERSAL OF RECOVERY - MOTOR" then RECOVERY_TYPE ="Reversal of Recovery";
else if TYPE_OF_CLAIM = "Recovery - Insured Employee" then  RECOVERY_TYPE ="Recovery from Insured";
else if TYPE_OF_CLAIM = "Recovery - Other" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - Other Third Party" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - on Salvage" then RECOVERY_TYPE ="Salvage";
else if TYPE_OF_CLAIM = "Recovery - General Averag" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "Recovery - Land Transporter" then RECOVERY_TYPE ="Recovery- Other";
else if TYPE_OF_CLAIM = "REVERSAL OF RECOVERY - FIRE" then RECOVERY_TYPE ="Reversal of Recovery";
else if TYPE_OF_CLAIM = "Recovery - Reinsurer" then RECOVERY_TYPE ="Recovery - from insurance Company";
else if TYPE_OF_CLAIM = "RECOVERY FROM CUSTOMER" then RECOVERY_TYPE ="Recovery from Insured";
else if TYPE_OF_CLAIM = "REVERSAL OF RECOVERY (GA)" then RECOVERY_TYPE ="Reversal of Recovery";
run;

proc sql print;
   select count(distinct RECOVERY_TYPE)
      into :n
      from Testcld_2019_mot_m;
   select distinct RECOVERY_TYPE
      into :RECOVERY_TYPE1 - :RECOVERY_TYPE%left(&n)
      from Testcld_2019_mot_m;
quit;
data Recovery; 
set Testcld_2019_mot_m ;keep TYPE_OF_CLAIM  RECOVERY_TYPE;;run;

Proc sort data=Recovery nodupkey;by   _all_   ;run;

Proc sort data=Testcld_2019_mot_m; ;by   ESTM_ID Myserial  ;run;
Proc sort data=Testcld_2019_mot_m; ;by   ESTM_ID Myserial  ;run;

 data Testcld_2019_mot_m;
 set Testcld_2019_mot_m ;drop Recovery_Pr Recovery_Pr2 Recovery_Pr3 Recovery_Pr4  DAYS;run;


data Testcld_2019_mot_m;
 set Testcld_2019_mot_m;
if missing (REPORTING_DT)   then Recovery_Pr= datdif(datepart(LOSS_DT),datepart(&VDate),'act/act');


else if  missing (LOSS_DT) then Recovery_Pr= datdif(datepart(REPORTING_DT),datepart(&VDate),'act/act');
else  Recovery_Pr= datdif(datepart(CREATION_DATE),datepart(&VDate),'act/act');
run;

%macro change (Testcld_2019_mot_m, Closing_balance);
data &Testcld_2019_mot_m;
set &Testcld_2019_mot_m;
if &Closing_balance = . then &Closing_balance=0;
run;
%mend change ;

%change (Testcld_2019_mot_m, Closing_balance);

%macro change (Testcld_2019_mot_m, ClosingOSRec_balance);
data &Testcld_2019_mot_m;
set &Testcld_2019_mot_m;
if &ClosingOSRec_balance = . then &ClosingOSRec_balance=0;
run;
%mend change ;

%change (Testcld_2019_mot_m, ClosingOSRec_balance);
%change (Testcld_2019_mot_m, ClosingOSRec_balance2);


proc sql print;
   select count(distinct PRODUCT_DESC)
      into :n
      from Testcld_2019_mot_m;
   select distinct PRODUCT_DESC
      into :PRODUCT_DESC1 - :PRODUCT_DESC%left(&n)
      from Testcld_2019_mot_m;
quit;

Data Test_closed;
set Testcld_2019_mot_m;
if Closing_balance ne 0 then output;
else if ClosingOSRec_balance ne 0 then output;
else if ClosingOSRec_balance2 ne 0 then output;
run;
Data Test_closed;
set  Test_closed;
Test_closed ='Y';run;

data want;
  set Test_closed;
  if Test_closed ='Y' then call missing(of OS PAYMENT RECOVER_OS  RECOVERY_PAYMENT);
run;
data want;
   set want;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run ;
data Testcld_2019_mot_m;
 set Testcld_2019_mot_m want;run;
data Testcld_2019_mot_m;
set Testcld_2019_mot_m;format Trans_date DATETIME20.;
if Test_closed ='Y' and not missing((_CLOSE_DT)) and (_CLOSE_DT) ne '01Jan1960'd then Trans_date= (_CLOSE_DT);
else Trans_date= (APPROVAL_DT);run;
Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID Trans_date  PAYMENT RECOVER_OS  Myserial;run;

data InhRes.Testcld_2019_mot_m_1;
 set Testcld_2019_mot_m;
if Test_closed ='Y' then OS_balance = OS + Closing_balance;
else OS_balance = OS;run;

/*(AMEER OS)*/

data Testcld_2019_mot_m;
 set InhRes.Testcld_2019_mot_m_1;
if Test_closed ='Y' then RECOVER_OS_balance = RECOVER_OS+ClosingOSRec_balance+ClosingOSRec_balance2;
else  RECOVER_OS_balance = RECOVER_OS;
run;

data Testcld_2019_mot_m;
 set Testcld_2019_mot_m;
if missing (REPORTING_DT)   then Recovery_Pr= datdif(datepart(LOSS_DT),datepart(&VDate),'act/act');

else if  missing (LOSS_DT) then Recovery_Pr= datdif(datepart(REPORTING_DT),datepart(&VDate),'act/act');
else  Recovery_Pr= datdif(datepart(REPORTING_DT),datepart(&VDate),'act/act');
run;
/**/
/*data Testcld_2019_mot_m;set Testcld_2019_mot_m;*/
/*Recovery_Pr= datdif(REPORTING_DT,&VDate,'act/act');run;*/

data Testcld_2019_mot_m;set Testcld_2019_mot_m;
if RECOVERY_TYPE = 'Salvage' and  Recovery_Pr >= 365.25 then Adj_Rec1=0;
else if  RECOVERY_TYPE = 'Salvage' and Recovery_Pr < 365.25 then Adj_Rec1=(0.975*RECOVER_OS_balance);
else Adj_Rec1=0;run;
data Testcld_2019_mot_m;set Testcld_2019_mot_m;
if RECOVERY_TYPE = 'Recovery - from insurance Company' and  Recovery_Pr >= 365.25 then Adj_Rec2=0;
else if  RECOVERY_TYPE = 'Recovery - from insurance Company' and Recovery_Pr < 365.25 then Adj_Rec2=(0.5*RECOVER_OS_balance);
else Adj_Rec2=0;run;

data Testcld_2019_mot_m;set Testcld_2019_mot_m;
if RECOVERY_TYPE = 'Recovery from Insured' and  Recovery_Pr >= 365.25 then Adj_Rec3=0;
else if  RECOVERY_TYPE = 'Recovery from Insured' and Recovery_Pr < 365.25 then Adj_Rec3=(0.5*RECOVER_OS_balance);
else Adj_Rec3=0;run;

data Testcld_2019_mot_m;set Testcld_2019_mot_m;
if RECOVERY_TYPE = 'Recovery- Other' and  Recovery_Pr >= 365.25 then Adj_Rec4=0;
else if  RECOVERY_TYPE = 'Recovery- Other' and Recovery_Pr < 365.25 then Adj_Rec4=(0.5*RECOVER_OS_balance);
else Adj_Rec4=0;run;


data Testcld_2019_mot_m;set Testcld_2019_mot_m;
if RECOVERY_TYPE = 'Reversal of Recovery' and  Recovery_Pr >= 365.25 then Adj_Rec5=0;
else if  RECOVERY_TYPE = 'Reversal of Recovery' and Recovery_Pr < 365.25 then Adj_Rec5=(0.5*RECOVER_OS_balance);
else Adj_Rec5=0;run;
%macro change (Testcld_2019_mot_m, Adj_Rec);
data &Testcld_2019_mot_m;
set &Testcld_2019_mot_m;
if &Adj_Rec = . then &Adj_Rec=0;
run;
%mend change ;

%change (Testcld_2019_mot_m, Adj_Rec1);
%change (Testcld_2019_mot_m, Adj_Rec2);
%change (Testcld_2019_mot_m, Adj_Rec3);
%change (Testcld_2019_mot_m, Adj_Rec4);
%change (Testcld_2019_mot_m, Adj_Rec5);

data Testcld_2019_mot_m;set Testcld_2019_mot_m;
 Adj_Rec=Adj_Rec1+Adj_Rec2+Adj_Rec3+Adj_Rec4+Adj_Rec5 ;run;


Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID  Trans_date ESTM_ID PAYMENT RECOVER_OS  Myserial;run;

/*Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT Myserial;run;*/


data Testcld_2019_mot_m;
 set Testcld_2019_mot_m; by CLAIM_UNIQUE_ID;
if first.CLAIM_UNIQUE_ID then Claim_count=1;run;


*/continued 4/7/19/*;
 data InhRes.Testcld_2019_mot_m_2;
 set Testcld_2019_mot_m;

 Paid_net_Recov = PAYMENT +RECOVERY_PAYMENT;
run;

Data Testcld_2019_mot_m;
set InhRes.Testcld_2019_mot_m_2;
drop Priority; run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;

IF LOSS_DT <'01Jul2016:00:00:00'dt  then Priority = 500000;
else if '01Jul2016:00:00:00'dt  <=  LOSS_DT <'01Jan2018:00:00:00'dt then Priority = 750000;
else if '01Jan2018:00:00:00'dt  <=  LOSS_DT < '01Jan2020:00:00:00'dt  then Priority = 1000000;

else if '01Jan2020:00:00:00'dt  <=  LOSS_DT < '01Jan2021:00:00:00'dt  then Priority = 750000;
else if LOSS_DT >= '01Jan2021:00:00:00'dt  then Priority = 1000000;
run;
/*Data Testcld_2019_mot_m;*/
/*set Testcld_2019_mot_m;*/
/**/
/*Cum_NIC = Cum_Net_paid+Cum_OS;run;*/

data Testcld_2019_mot_m (drop = Cum_OS  Cum_Net_paid Cum_NIC Cum_Adj_Rec Cum_Gpaid Cum_Coll_Rec Cum_Ceded_NIC Cum_Ceded_paid Cum_Ceded_OS Cum_Ret_Paid Cum_Ret_OS Cum_Ret_NIC Cum_NIC
Cum_RetCoins_Paid Cum_RetCoins_OS Cum_CededCoins_Paid Cum_CededCoins_OS Cum_RetCoins_NIC Cum_CededCoins_NIC );
 set Testcld_2019_mot_m ;run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_OS=0;
Cum_OS+OS_balance;
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_Gpaid =0;
Cum_Gpaid+PAYMENT;
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_Net_paid=0;
Cum_Net_paid+Paid_net_Recov;
run;
Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
RI_COINS_Perc = ABS(RI_COINSURANCE/( RI_COINSURANCE+ RI_RETENTION));
RI_RetCoins_Perc = (1-RI_COINS_Perc);run;

%macro change (Testcld_2019_mot_m, RI_COINS_Perc);
data &Testcld_2019_mot_m;
set &Testcld_2019_mot_m;
if &RI_COINS_Perc = . then &RI_COINS_Perc=0;
run;
%mend change ;
%change (Testcld_2019_mot_m, RI_COINS_Perc);


%macro change (Testcld_2019_mot_m, RI_RetCoins_Perc);
data &Testcld_2019_mot_m;
set &Testcld_2019_mot_m;
if &RI_RetCoins_Perc = . then &RI_RetCoins_Perc=0;
run;
%mend change ;
%change (Testcld_2019_mot_m, RI_RetCoins_Perc);




Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
RetCoins_Paid=RI_RetCoins_Perc*Paid_net_Recov;
CededCoins_Paid=RI_COINS_Perc*Paid_net_Recov;
RetCoins_OS=RI_RetCoins_Perc*OS_balance;
CededCoins_OS=RI_COINS_Perc*OS_balance;
run;


data Testcld_2019_mot_m (drop = Cum_RetCoins_Paid  Cum_RetCoins_OS Cum_CededCoins_Paid Cum_CededCoins_OS Cum_RetCoins_NIC Cum_NIC Cum_CededCoins_NIC Cum_Ceded_NIC
Cum_Adj_Rec Cum_Coll_Rec  Cum_Coll_Rec Cum_Ceded_paid Cum_Ceded_OS Cum_Ceded_NIC);
 set Testcld_2019_mot_m ;run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_RetCoins_Paid=0;
Cum_RetCoins_Paid+RetCoins_Paid;
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_RetCoins_OS=0;
Cum_RetCoins_OS+RetCoins_OS;
run;
Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_CededCoins_Paid=0;
Cum_CededCoins_Paid+CededCoins_Paid;
run;
Data InhRes.Testcld_2019_mot_m_1;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_CededCoins_OS=0;
Cum_CededCoins_OS+CededCoins_OS;
run;
DATA Testcld_2019_mot_m_1_CHECK;
SET InhRes.Testcld_2019_mot_m_1;
WHERE CALIM_NO = 'CLM/01/61/2011/05103';RUN;



PROC EXPORT DATA= Testcld_2019_mot_m_1_CHECK
            OUTFILE= "Z:\Files subject to classification\Monthly SAS Data\AMK\Testcld_2019_mot_m_1_CHECK.XLSX" 
            DBMS=EXCEL LABEL REPLACE;
RUN;
/*AMEER SAVE POINT*/
Data Testcld_2019_mot_m;
set InhRes.Testcld_2019_mot_m_1;
Cum_RetCoins_NIC = Cum_RetCoins_Paid+Cum_RetCoins_OS;run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
Cum_CededCoins_NIC = Cum_CededCoins_OS+Cum_CededCoins_Paid;run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
Inc_NIC = Paid_net_Recov+OS_balance;run;
Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;

Cum_NIC = Cum_Net_paid+Cum_OS;run;
Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
IF LOSS_DT <'01Jul2016:00:00:00'dt and Cum_RetCoins_NIC>500000 then Cum_Ceded_NIC = Cum_RetCoins_NIC -500000+Cum_CededCoins_NIC;
else if  '01Jul2016:00:00:00'dt <=  LOSS_DT <'01Jan2018:00:00:00'dt and Cum_RetCoins_NIC>750000 then Cum_Ceded_NIC = Cum_RetCoins_NIC -750000+Cum_CededCoins_NIC;
else if '01Jan2018:00:00:00'dt <= LOSS_DT < '01Jan2020:00:00:00'dt and Cum_RetCoins_NIC>1000000 then Cum_Ceded_NIC = Cum_RetCoins_NIC -1000000+Cum_CededCoins_NIC;
else if '01Jan2020:00:00:00'dt <= LOSS_DT < '01Jan2021:00:00:00'dt and Cum_RetCoins_NIC>750000 then Cum_Ceded_NIC = Cum_RetCoins_NIC -750000+Cum_CededCoins_NIC;
else if  LOSS_DT >= '01Jan2021:00:00:00'dt and Cum_RetCoins_NIC>750000 then Cum_Ceded_NIC = Cum_RetCoins_NIC -1000000+Cum_CededCoins_NIC;
else Cum_Ceded_NIC =0+Cum_CededCoins_NIC;
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_Adj_Rec=0;
Cum_Adj_Rec+Adj_Rec;
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if first.CLAIM_UNIQUE_ID then Cum_Coll_Rec =0;
Cum_Coll_Rec+RECOVERY_PAYMENT;
run;


Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
IF Cum_RetCoins_Paid > Priority then Cum_Ceded_paid =Cum_RetCoins_Paid-Priority+Cum_CededCoins_Paid;
else Cum_Ceded_paid = 0+Cum_CededCoins_Paid;run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
Cum_Ceded_OS=Cum_Ceded_NIC-Cum_Ceded_paid;
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
Cum_Ret_Paid = Cum_RetCoins_Paid - Cum_Ceded_paid+Cum_CededCoins_paid;
Cum_Ret_OS = Cum_RetCoins_OS - Cum_Ceded_OS+Cum_CededCoins_OS;
Cum_Ret_NIC = Cum_Ret_Paid + Cum_Ret_OS
;run;
Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
Validate_CLMS= Cum_NIC - (Cum_Ceded_paid + Cum_Ceded_OS + Cum_Ret_Paid + Cum_Ret_OS);run;
data Invalid;
set Testcld_2019_mot_m;
if Validate_CLMS ne 0   then output;
run;

/*data test3;*/
/*set Testcld_2019_mot_m2;*/
/*if CALIM_NO = 'CLM/01/61/2015/03400' then output;run;*/

data Testcld_2019_mot_m_v2;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID  notsorted;
retain   lst_Cum_Ret_OS lst_Cum_Ret_NPaid lst_Cum_Ceded_OS lst_Cum_Ceded_paid;
if not first.CLAIM_UNIQUE_ID then do;
Inc_Ret_NPaid = Cum_Ret_Paid - lst_Cum_Ret_NPaid ;
Inc_Ret_OS = Cum_Ret_OS - lst_Cum_Ret_OS;
Inc_Ceded_paid = Cum_Ceded_paid - lst_Cum_Ceded_paid;
Inc_Ceded_OS = Cum_Ceded_OS - lst_Cum_Ceded_OS;
end;
else if first.CLAIM_UNIQUE_ID then do;
Inc_Ret_NPaid = Cum_Ret_Paid;
Inc_Ret_OS= Cum_Ret_OS;
Inc_Ceded_paid = Cum_Ceded_paid ;
Inc_Ceded_OS = Cum_Ceded_OS ;
end;
lst_Cum_Ret_NPaid=Cum_Ret_Paid ;
lst_Cum_Ret_OS=Cum_Ret_OS ;
lst_Cum_Ceded_OS=Cum_Ceded_OS;
lst_Cum_Ceded_paid=Cum_Ceded_paid;
run;
data Testcld_2019_mot_m_v2 (drop = Inc_Ret Inc_Ret_Paid Prev_Cum_Ceded_NIC Prev_Cum_Ret_Paid lst_Cum_Ret_OS lst_Cum_Ret_NPaid lst_Cum_Ceded_OS lst_Cum_Ceded_paid);
 set Testcld_2019_mot_m_v2 ;run;

Data Testcld_2019_mot_m_v2;
set Testcld_2019_mot_m_v2;
Validate_CLMS_Inc= Inc_NIC - (Inc_Ret_NPaid + Inc_Ret_OS + Inc_Ceded_paid + Inc_Ceded_OS);
Inc_Ret_NIC=Inc_Ret_NPaid + Inc_Ret_OS ;
Inc_Ceded_NIC= Inc_Ceded_paid + Inc_Ceded_OS;
run;
data Invalid;
set Testcld_2019_mot_m_v2;
if Validate_CLMS_Inc ne 0   then output;
run;

Proc sort data=Testcld_2019_mot_m_v2; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT Myserial;run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m_v2;
by CLAIM_UNIQUE_ID notsorted;
if last.CLAIM_UNIQUE_ID then do;
Final_Ceded_OS = Cum_Ceded_OS;
Final_Ceded_Paid = Cum_Ceded_paid;
Final_Ret_OS = Cum_Ret_OS;
Final_Ret_Paid = Cum_Ret_Paid;
Final_Adj_OS_Rec = Cum_Adj_Rec;
Final_Cum_Ceded_NIC = Cum_Ceded_NIC;
Final_Cum_NIC = Cum_NIC;
Final_Cum_Gpaid = Cum_Gpaid;
Final_Cum_Coll_Rec =Cum_Coll_Rec
;Final_Cum_Ret_NIC=Cum_Ret_NIC;
end;
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
Validate_CLMS_Fin= Final_Cum_NIC - (Final_Ceded_OS + Final_Ceded_Paid + Final_Ret_OS + Final_Ret_Paid);run;

data Invalid;
set Testcld_2019_mot_m;
if Validate_CLMS_Fin ne 0  and not missing(Validate_CLMS_Fin) then output;
run;
/*data test;*/
/*set Testcld_2019_mot_m;*/
/*if CLAIM_UNIQUE_ID = 1658155 then output;run;*/

/*I stopped here on 16th May 2019*/;


data Testcld_2019_mot_m;
set Testcld_2019_mot_m;LENGTH Claim_Peril $ 50;
if TYPE_OF_CLAIM = "CANCEL VAT INPUT - MOTOR" then Claim_Peril ="VAT";
else if TYPE_OF_CLAIM = "COURT FEES - THIRD PARTY" then Claim_Peril ="ALAE-Legal_fees";
else if TYPE_OF_CLAIM = "Cancellation of Settlement" then Claim_Peril ="Other";
else if TYPE_OF_CLAIM = "Court Award" then Claim_Peril ="ALAE-Legal_fees";
else if TYPE_OF_CLAIM = "DEATH - INSURED" then Claim_Peril ="PA-D";
else if TYPE_OF_CLAIM = "DEATH - THIRD PARTY" then Claim_Peril ="TPBI";

else if TYPE_OF_CLAIM = "Damage - Partial Loss to Insured Vehicle Labor Charges" and PRODUCT_CODE not in ("11B","20") and COVER_CODE in ("BCCOM","COM")then Claim_Peril ="OD";
else if TYPE_OF_CLAIM = "Damage - Partial Loss to Insured Vehicle Labor Charges" and PRODUCT_CODE not in ("11B","20") and COVER_CODE not in ("BCCOM","COM")then Claim_Peril =COVER_CODE;
else if TYPE_OF_CLAIM = "Damage - Partial Loss to Insured Vehicle Labor Charges" and PRODUCT_CODE in ("11B","20")  then Claim_Peril =COVER_CODE;

else if TYPE_OF_CLAIM = "Damage - Partial Loss to Insured Vehicle Spare Parts" and PRODUCT_CODE not in ("11B","20") and COVER_CODE in ("BCCOM","COM")then Claim_Peril ="OD";
else if TYPE_OF_CLAIM = "Damage - Partial Loss to Insured Vehicle Spare Parts" and PRODUCT_CODE not in ("11B","20") and COVER_CODE not in ("BCCOM","COM")then Claim_Peril =COVER_CODE;
else if TYPE_OF_CLAIM = "Damage - Partial Loss to Insured Vehicle Spare Parts" and PRODUCT_CODE in ("11B","20")  then Claim_Peril =COVER_CODE;


else if TYPE_OF_CLAIM = "Damage - Total Loss  to Insured Vehicle" and PRODUCT_CODE not in ("11B","20") and COVER_CODE in ("BCCOM","COM")then Claim_Peril ="OD";
else if TYPE_OF_CLAIM = "Damage - Total Loss  to Insured Vehicle" and PRODUCT_CODE not in ("11B","20") and COVER_CODE not in ("BCCOM","COM")then Claim_Peril =COVER_CODE;
else if TYPE_OF_CLAIM = "Damage - Total Loss  to Insured Vehicle" and PRODUCT_CODE in ("11B","20")  then Claim_Peril =COVER_CODE;


/*Check with Mot_claims_Manger_Almalki*/

else if TYPE_OF_CLAIM = "Depreciation - Partial Loss" then Claim_Peril ="Depreciation";
else if TYPE_OF_CLAIM = "Depreciation - Total Loss" then Claim_Peril ="Depreciation";
else if TYPE_OF_CLAIM = "Excess/Deductible" then Claim_Peril ="Deductible";
else if TYPE_OF_CLAIM = "Expenses - Emergency Medical driver/ psngrs" then Claim_Peril ="Med_Expenses";*************************************;
else if TYPE_OF_CLAIM = "Expenses - Endst - Burial Costs Extn." then Claim_Peril ="PA-D";*************************************;/*or PAP;*/
else if TYPE_OF_CLAIM = "Expenses - Endst - Defense Costs Exten." then  Claim_Peril ="ALAE-Legal_fees";
else if TYPE_OF_CLAIM = "Expenses - Endst - Driver Repatriation Extn." then Claim_Peril ="PA-D";/*or PAP;*/
else if TYPE_OF_CLAIM = "Expenses - Endst - Fire Brigade Charges Exten." then Claim_Peril ="ALAE";/*Mistake;*/
else if TYPE_OF_CLAIM = "Expenses - Endst - Goods in Transit Exten." then Claim_Peril ="ALAE";/*Mistake;*/
else if TYPE_OF_CLAIM = "Expenses - Endst - Loss of Keys Exten." then Claim_Peril ="Theft";/*Mistake;*/
else if TYPE_OF_CLAIM = "Expenses - Endst - New Replacement Vehicle V1 Exten." then Claim_Peril ="Replace_car";*************************************;
else if TYPE_OF_CLAIM = "Expenses - Endst - Protection & Towing Expenses Exten." then Claim_Peril ="RSA";
else if TYPE_OF_CLAIM = "Expenses - Endst - Substitute Vehicle Exten." then Claim_Peril ="Replace_car";*************************************;
else if TYPE_OF_CLAIM = "Expenses - Endst - Vehicle Return Extension" then Claim_Peril ="Replace_car";*************************************;
else if TYPE_OF_CLAIM = "Expenses - Endst - Wreckage Removal Exten." then Claim_Peril ="ALAE";/*Mistake;*/
else if TYPE_OF_CLAIM = "Expenses - Protection of Insured Vehicle" then Claim_Peril ="OD";*************************************;
else if TYPE_OF_CLAIM = "Expenses - Towing of Insured Vehicle" then Claim_Peril ="RSA";
else if TYPE_OF_CLAIM = "Fees - Lawyer" then Claim_Peril ="ALAE-Legal_fees";
else if TYPE_OF_CLAIM = "Fees - Legal" then Claim_Peril ="ALAE-Legal_fees";
else if TYPE_OF_CLAIM = "Fees - Loss Adjustor" then Claim_Peril ="ALAE-Survey_fees";
else if TYPE_OF_CLAIM = "Fees - Najm" then Claim_Peril ="ALAE-Survey_fees";
else if TYPE_OF_CLAIM = "Fees - Sheikh Al- Maared / Haraj" then Claim_Peril ="ALAE-Survey_fees";
else if TYPE_OF_CLAIM = "INJURY - COMPREHENSIVE" and  COVER_CODE in ("BCCOM","BCPAD","BCPAP","COM","PAB1")then Claim_Peril ="PA-D";/*in case no TP details*/
else if TYPE_OF_CLAIM = "INJURY - COMPREHENSIVE" and  COVER_CODE not in ("BCCOM","BCPAD","BCPAP","COM","PAB1")then Claim_Peril =COVER_CODE;/*in case no TP details*/

else if TYPE_OF_CLAIM = "LABOUR CHARGES - COMPREHENSIVE" then Claim_Peril ="OD";
else if TYPE_OF_CLAIM = "Liability - Driver" then Claim_Peril ="TPBI";*************************************;
else if TYPE_OF_CLAIM = "Liability - Passenger(s)" then Claim_Peril ="TPBI";*************************************;
else if TYPE_OF_CLAIM = "NAJM  ( CR FEES )" then Claim_Peril ="ALAE-Survey_fees";

else if TYPE_OF_CLAIM = "NAJM  ( DAMAGE ASSESSMENT FEES)" then Claim_Peril ="ALAE-Survey_fees";
else if TYPE_OF_CLAIM = "OTHER EXPENSES - COMPREHENSIVE" then Claim_Peril ="ALAE";
else if TYPE_OF_CLAIM = "PROPERTY DAMAGE - COMPREHENSIVE" then Claim_Peril ="TPPD";*************************************;
else if TYPE_OF_CLAIM = "PROPERTY DAMAGE - THIRD PARTY" then Claim_Peril ="TPPD";
else if TYPE_OF_CLAIM = "Personal Accident Benefit to Driver" and PRODUCT_CODE not in ("11B","20")  then Claim_Peril ="PA-D";
else if TYPE_OF_CLAIM = "Personal Accident Benefit to Driver" and PRODUCT_CODE in ("11B","20")  then Claim_Peril =COVER_CODE;

else if TYPE_OF_CLAIM = "Personal Accident Benefit to Passenger(s)" and PRODUCT_CODE not in ("11B","20")  then Claim_Peril ="PA-P";
else if TYPE_OF_CLAIM = "Personal Accident Benefit to Passenger(s)" and PRODUCT_CODE in ("11B","20")  then Claim_Peril =COVER_CODE;
else if TYPE_OF_CLAIM = "REVERSAL OF SETTLEMENT" then Claim_Peril ="Other";
else if TYPE_OF_CLAIM = "Reversal - for Claim Loss" then Claim_Peril ="Other";
else if TYPE_OF_CLAIM = "SURVEYOR FEES - MOTOR" then Claim_Peril ="ALAE-Survey_fees";
else if TYPE_OF_CLAIM = "TOWING CHARGES" then Claim_Peril ="RSA";
else if TYPE_OF_CLAIM = "TP - Bodily Injury or Death" then Claim_Peril ="TPBI";
else if TYPE_OF_CLAIM = "TP - Property Damage" then Claim_Peril ="TPPD";
else if TYPE_OF_CLAIM = "Theft of Insured Vehicle - Entire Vehicle" and cover_code in("BCTPL","TP")then Claim_Peril =COVER_CODE;
else if TYPE_OF_CLAIM = "Theft of Insured Vehicle - Entire Vehicle" and PRODUCT_CODE not in ("11B","20") and COVER_CODE not in("BCTPL","TP")then Claim_Peril ="Theft";

else if TYPE_OF_CLAIM = "Theft of Insured Vehicle - Partial Theft" and cover_code in("BCTPL","TP")then Claim_Peril =COVER_CODE;
else if TYPE_OF_CLAIM = "Theft of Insured Vehicle - Partial Theft" and PRODUCT_CODE not in ("11B","20") and COVER_CODE not in("BCTPL","TP")then Claim_Peril ="Theft";

else if TYPE_OF_CLAIM = "VAT INPUT - MOTOR" then Claim_Peril ="VAT";
else if not missing(RECOVERY_TYPE) then Claim_Peril =RECOVERY_TYPE;
else Claim_Peril =TYPE_OF_CLAIM;
run;
data Testcld_2019_mot_m;
set Testcld_2019_mot_m;LENGTH Refined_Claim_Peril $ 50;
if Claim_Peril in ('ALAE','ALAE-Legal_fees','ALAE-Survey_fees','Deductible','Depreciation','Other','Recovery - from insurance Company','Recovery from Insured'
'Recovery- Other','Replace_car','Reversal of Recovery','Salvage','VAT') then Refined_Claim_Peril = COVER_CODE;
else Refined_Claim_Peril = Claim_Peril;run;
data Testcld_2019_mot_m;
set Testcld_2019_mot_m;LENGTH Classified_Claim_Peril $ 50;
if Refined_Claim_Peril in ("BCTPL","TP") then Classified_Claim_Peril = "BCTPL";
else if Refined_Claim_Peril in ("BCCOM","COM") then Classified_Claim_Peril="BCCOM";
else if Refined_Claim_Peril in ("BCPAD","PA-D") then Classified_Claim_Peril="BCPAD";
else if Refined_Claim_Peril in ("BCPAP","PA-P","PAB1") then Classified_Claim_Peril="BCPAP";
else Classified_Claim_Peril = Refined_Claim_Peril;run;
/*data test;*/
/*set Testcld_2019_mot_m;*/
/*if CALIM_NO = 'CLM/02/61/2013/06367' then output;run;*/
/*data Test2 ;*/
/*set Testcld_2019_mot_m2;*/
/*if TYPE_OF_CLAIM = "Personal Accident Benefit to Passenger(s)" and PRODUCT_CODE  in ("11B","20")  then output;run;*/
proc sql print;
   select count(distinct Refined_Claim_Peril)
      into :n
      from Testcld_2019_mot_m;
   select distinct Refined_Claim_Peril
      into :Refined_Claim_Peril1 - :Refined_Claim_Peril%left(&n)
      from Testcld_2019_mot_m;
quit;
proc sql print;
   select count(distinct Classified_Claim_Peril)
      into :n
      from Testcld_2019_mot_m;
   select distinct Classified_Claim_Peril
      into :Classified_Claim_Peril1 - :Classified_Claim_Peril%left(&n)
      from Testcld_2019_mot_m;
quit;


data Negative_cases;
set Testcld_2019_mot_m;
if Final_cum_NIC < 0 and not missing (Final_cum_NIC)  then output;
else if  Final_Ret_Paid < 0 and not missing (Final_Ret_Paid)  then output;
run;



data Negative_cases ;set Negative_cases (keep= CLAIM_UNIQUE_ID RISK_VEHICLE_UNIQUE_ID);run;
data Negative_cases ;  length NL_Ind $20; ;set Negative_cases ; NL_Ind = "Y";run;
data Negative_cases ;retain CLAIM_UNIQUE_ID RISK_VEHICLE_UNIQUE_ID NL_Ind ;set Negative_cases;run;

Proc sort data=Negative_cases nodupkey; by _all_ ;run;

Proc sql;
create table  CLMS_Neg_L_Ind as

select L.*, R.NL_Ind

from Negative_cases as R
right join Testcld_2019_mot_m as L
on (L.RISK_VEHICLE_UNIQUE_ID = R.RISK_VEHICLE_UNIQUE_ID)  and (L.CLAIM_UNIQUE_ID = R.CLAIM_UNIQUE_ID)
;quit;
Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT Myserial;run;
Proc sort data=CLMS_Neg_L_Ind; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT;run;
data Testcld_2019_mot_m;
set CLMS_Neg_L_Ind;run;


proc sql print;
   select count(distinct TYPE_OF_CLAIM)
      into :n
      from Testcld_2019_mot_m;
   select distinct TYPE_OF_CLAIM
      into :TYPE_OF_CLAIM1 - :TYPE_OF_CLAIM%left(&n)
      from Testcld_2019_mot_m;
quit;

data Total_loss_clm;
set Testcld_2019_mot_m;
if TYPE_OF_CLAIM in ("Damage - Total Loss  to Insured Vehicle" ,"Depreciation - Total Loss")then output;
run;

data total_loss_clm2 ;set total_loss_clm (keep= CLAIM_UNIQUE_ID RISK_VEHICLE_UNIQUE_ID);run;
data total_loss_clm2 ;  length TL_Ind $20; ;set total_loss_clm2 ; TL_Ind = "Y";run;
data total_loss_clm2 ;retain CLAIM_UNIQUE_ID RISK_VEHICLE_UNIQUE_ID TL_Ind ;set total_loss_clm2;;run;

Proc sort data=total_loss_clm2 nodupkey; by _all_ ;run;

Proc sql;
create table  CLMS_Tot_L_Ind as

select L.*, R.TL_Ind

from total_loss_clm2 as R
right join Testcld_2019_mot_m as L
on (L.RISK_VEHICLE_UNIQUE_ID = R.RISK_VEHICLE_UNIQUE_ID)  and (L.CLAIM_UNIQUE_ID = R.CLAIM_UNIQUE_ID)
;quit;
Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT Myserial;run;
Proc sort data=CLMS_Tot_L_Ind; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT;run;
data Testcld_2019_mot_m;
set CLMS_Tot_L_Ind;run;




data XL_cases;
set Testcld_2019_mot_m;
if Cum_Ceded_NIC ne 0  and not missing(Cum_Ceded_NIC) then output;run;

data Excess_loss_clm2 ;set XL_cases (keep= CLAIM_UNIQUE_ID RISK_VEHICLE_UNIQUE_ID);run;
data Excess_loss_clm2 ;  length XL_Ind $20; ;set Excess_loss_clm2 ; XL_Ind = "Y";run;
data Excess_loss_clm2 ;retain CLAIM_UNIQUE_ID RISK_VEHICLE_UNIQUE_ID XL_Ind ;set Excess_loss_clm2;;run;

Proc sort data=Excess_loss_clm2 nodupkey; by _all_ ;run;
/**/
/*proc export data=XL_cases dbms=excel*/
/*outfile="E:\Sas_files\MotorDB-Jun19\Updated_claims_Jun19_New_24Jul19\XL_cases_Jun19.xlsx";run;*/


Proc sql;
create table  CLMS_XOL_L_Ind as

select L.*, R.XL_Ind

from Excess_loss_clm2 as R
right join Testcld_2019_mot_m as L
on (L.RISK_VEHICLE_UNIQUE_ID = R.RISK_VEHICLE_UNIQUE_ID)  and (L.CLAIM_UNIQUE_ID = R.CLAIM_UNIQUE_ID)
;quit;
Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT Myserial;run;
Proc sort data=CLMS_XOL_L_Ind; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT;run;
data Testcld_2019_mot_m;
set CLMS_XOL_L_Ind;run;

Proc sort data=Testcld_2019_mot_m; ;by  CLAIM_UNIQUE_ID ESTM_ID   Trans_date PAYMENT RECOVER_OS CLOSE_DT Myserial;run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
by CLAIM_UNIQUE_ID notsorted;
if last.CLAIM_UNIQUE_ID then Last_Obs= "Y";
run;

Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
Inc_Ret_Paid_GRec = Inc_Ret_NPaid - RECOVERY_PAYMENT;run;
Data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
AccQ= put(datepart(LOSS_DT), YYQ.);
RepQ= put (datepart(REPORTING_DT),YYQ.);
TraQ= put(datepart(Trans_date),YYQ.);
QAcc_Lag=intck('qtr',datepart(LOSS_DT),datepart(Trans_date));
QRep_Lag=intck('qtr',datepart(LOSS_DT),datepart(REPORTING_DT));
AccM= put(datepart(LOSS_DT), yymmd.);
TraM= put(datepart(Trans_date),  yymmd.);
RepM= put(datepart(REPORTING_DT),  yymmd.);
MAcc_Lag=intck('month',datepart(LOSS_DT),datepart(Trans_date));
MRep_Lag=intck('month',datepart(LOSS_DT),datepart(REPORTING_DT));
AccY = year(datepart(LOSS_DT));
TraY= year(datepart(Trans_date));
run;
Data Testcld_2019_mot_m;
Set Testcld_2019_mot_m;
ClosQ =put(datepart(_CLOSE_DT),  YYQ.);
ClosM =put(datepart(_CLOSE_DT),  yymmd.)
;run;

data Testcld_2019_mot_m2 ;length Mapped_Class $23.;informat Mapped_Class $23.;   
 format Mapped_Class $23.;  
   set Testcld_2019_mot_m2;
if PRODUCT_CODE in ("11B","20") then Mapped_Class = "TPL";
else if PRODUCT_CODE in("61","61I","61R") then Mapped_Class = "Comp";
else Mapped_Class = PRODUCT_CODE;
run;


data Testcld_2019_mot_m;
set Testcld_2019_mot_m;format Trans_date DATETIME20.;run;
 data Testcld_2019_mot_m;
set Testcld_2019_mot_m;
 if Final_Ret_OS = 0 then Closed_calim_count = 1;run;

data Testcld_2019_mot_m2(drop=i);
 
   set Testcld_2019_mot_m;
   by CLAIM_UNIQUE_ID  notsorted; 
 
   if (first.CLAIM_UNIQUE_ID or not last.CLAIM_UNIQUE_ID) then
      do i = 1 to 1 + (first.CLAIM_UNIQUE_ID and not last.CLAIM_UNIQUE_ID);
         set Testcld_2019_mot_m(keep=TraM rename=(TraM=next_TraM) );
      end;
   if last.CLAIM_UNIQUE_ID then 
      next_TraM = .;
 
run;
data Testcld_2019_mot_m2;
set Testcld_2019_mot_m2;
by CLAIM_UNIQUE_ID  notsorted;
if first.CLAIM_UNIQUE_ID and Cum_OS >0 and next_TraM ne TraM then Open_claim_count = 1;
else if first.CLAIM_UNIQUE_ID and Cum_OS >0 and missing(next_TraM)  then Open_claim_count = 1;
else if not first.CLAIM_UNIQUE_ID and Cum_OS >0 and missing(next_TraM)  then Open_claim_count = 1;
else if not first.CLAIM_UNIQUE_ID and Cum_OS >0 and next_TraM ne TraM  then Open_claim_count = 1;

else Open_claim_count =0;
 run;



data Testcld_2019_mot_m2 ;length Mapped_Class $23.;informat Mapped_Class $23.;   
 format Mapped_Class $23.;  
   set Testcld_2019_mot_m2;
if PRODUCT_CODE in ("11B","20","11M") then Mapped_Class = "TPL";
else if PRODUCT_CODE in("61","61I","61R") then Mapped_Class = "Comp";
else Mapped_Class = PRODUCT_CODE;
run;
Data InhRes.Testcld_2019_mot_m2;
set Testcld_2019_mot_m2;
UWYr= year(datepart(POLICY_EFF_DATE));
UWM= put(datepart(POLICY_EFF_DATE),  yymmd.);
run;



DATA SAS_TABLE 
(DROP= 
BURUJ_DRIVER_ID
);
SET InhRes.Testcld_2019_mot_m2;
RID = _N_;

DATA SAS_TABLE_PART_1 ;
SET SAS_TABLE;
IF RID < 500001   THEN OUTPUT; 

DATA SAS_TABLE_PART_2;
SET SAS_TABLE;
IF RID  >= 500001  AND RID < 1000001 THEN OUTPUT;
DATA SAS_TABLE_PART_3;
SET SAS_TABLE;
IF RID  >= 1000001   THEN OUTPUT;


PROC EXPORT DATA= SAS_TABLE_PART_1(DROP=RID)
            OUTFILE= 'C:\Users\ashamseldien\Desktop\OPERATION\August 2022 operation to Abdullah\TO BE SHARED WITH BADRI\SAS_MOT_IT_CL_ASAT_22M08P1.xlsx'
            DBMS=EXCEL LABEL REPLACE; 
RUN;

PROC EXPORT DATA= SAS_TABLE_PART_2(DROP=RID)
            OUTFILE= 'C:\Users\ashamseldien\Desktop\OPERATION\August 2022 operation to Abdullah\TO BE SHARED WITH BADRI\SAS_MOT_IT_CL_ASAT_22M08P2.xlsx'
            DBMS=EXCEL LABEL REPLACE; 
RUN;
PROC EXPORT DATA= SAS_TABLE_PART_3(DROP=RID)
            OUTFILE= 'C:\Users\ashamseldien\Desktop\OPERATION\August 2022 operation to Abdullah\TO BE SHARED WITH BADRI\SAS_MOT_IT_CL_ASAT_22M08P3.xlsx'
            DBMS=EXCEL LABEL REPLACE; 
RUN;



PROC SQL;
CREATE TABLE MOT_HOA_CL_22M08_SMRY_NO_VAT	AS
SELECT
CASE WHEN PRODUCT_CODE LIKE '%61%' THEN 'COMP' ELSE 'TPL' END AS	MOT_Class,
PRODUCT_CODE,
SUM(SUM(CASE WHEN (PUT(DATEPART(Trans_date),YEAR.) = '2022'  AND UPCASE(ESTM_DESC) NOT LIKE '%VAT%') THEN Paid_net_Recov ELSE 0 END),SUM(CASE WHEN UPCASE(ESTM_DESC) NOT LIKE '%VAT%' THEN OS_balance ELSE 0 END)) AS Gross_Incurred_Claims,
SUM(CASE WHEN (PUT(DATEPART(Trans_date),YEAR.) = '2022'  AND UPCASE(ESTM_DESC) NOT LIKE '%VAT%') THEN Paid_net_Recov ELSE 0 END) AS Gross_paid_less_recoveries,
SUM(CASE WHEN UPCASE(ESTM_DESC) NOT LIKE '%VAT%' THEN OS_balance ELSE 0 END) AS Outstanding_Claims,
SUM(CASE WHEN (PUT(DATEPART(Trans_date),YEAR.) = '2022'  AND UPCASE(ESTM_DESC) NOT LIKE '%VAT%') THEN PAYMENT ELSE 0 END) AS Paid_Claims,
SUM(CASE WHEN (PUT(DATEPART(Trans_date),YEAR.) = '2022'  AND UPCASE(ESTM_DESC) NOT LIKE '%VAT%') THEN RECOVERY_PAYMENT ELSE 0 END) AS Paid_Salvage_Subrogation,
SUM(SUM(CASE WHEN (PUT(DATEPART(Trans_date),YEAR.) = '2022'  AND UPCASE(ESTM_DESC) NOT LIKE '%VAT%') THEN Inc_Ret_NPaid ELSE 0 END),SUM(CASE WHEN UPCASE(ESTM_DESC) NOT LIKE '%VAT%' THEN Inc_Ret_OS ELSE 0 END)) AS Retained_Incurred_Claims,
SUM(CASE WHEN UPCASE(ESTM_DESC) NOT LIKE '%VAT%' THEN Inc_Ret_OS ELSE 0 END) AS Retained_OS_Claims,
SUM(CASE WHEN (PUT(DATEPART(Trans_date),YEAR.) = '2022'  AND UPCASE(ESTM_DESC) NOT LIKE '%VAT%') THEN Inc_Ret_NPaid ELSE 0 END) AS Retained_Paid_Claims,
SUM(CASE WHEN UPCASE(ESTM_DESC) NOT LIKE '%VAT%' THEN Inc_Ceded_OS ELSE 0 END) AS RI_OS,
SUM(CASE WHEN (PUT(DATEPART(Trans_date),YEAR.) = '2022'  AND UPCASE(ESTM_DESC) NOT LIKE '%VAT%') THEN Inc_Ceded_paid ELSE 0 END) AS RI_Paid

FROM
InhRes.testcld_2019_mot_m2
WHERE DATEPART(Trans_date) <= INTNX('MONTH',INPUT(COMPRESS('2022M08','M'),YYMMN6.),0,'E')
GROUP BY
MOT_Class,
PRODUCT_CODE;
QUIT;

PROC EXPORT DATA= MOT_HOA_CL_22M08_SMRY_NO_VAT
            OUTFILE= "C:\Users\ashamseldien\Desktop\OPERATION\August 2022 operation to Abdullah\TO BE SHARED WITH BADRI\MOT_HOA_CL_22M08_SMRY.XLSX" 
            DBMS=EXCEL LABEL REPLACE;
RUN;
