libname b "L:\Mount Sinai\SAS\datasets";

proc import out=b.boost file="L:\Mount Sinai\SAS\datasets\f3.xlsx" dbms=EXCEL REPLACE;
range="Panel B - Scatterplot$";
run;

proc import out=b.vax file="L:\Mount Sinai\SAS\datasets\f3.xlsx" dbms=EXCEL REPLACE;
range="Panel A - Scatterplot$";
run;

proc import out=b.Demo file="L:\Mount Sinai\SAS\datasets\f3.xlsx" dbms=EXCEL REPLACE;
range="Demographics$";
run;

proc contents data=b.boost;
run;

proc contents data=b.vax;
run;

proc contents data=b.Demo;
run;

proc print data=b.boost (obs=20);
run;

proc print data=b.vax (obs=20);
run;

proc print data=b.Demo (obs=20);
run;

data vax;
	set b.vax;

	Log2AUC = log2(AUC);
run;

data boost;
	set b.boost;
run;

data Demo;
	set B.Demo;
run;

proc sort data=vax;
	by ID;
run;

proc sort data=boost;
	by ID;
run;

proc sort data=Demo;
	by ID;
run;

data vax;
	merge vax demo;
	by ID;
run;

data boost;
	merge boost Demo;
	by ID;
run;

proc sort data=vax;
	by Infection_Pre_Vaccine;
run;

proc sort data=boost;
	by Infection_Pre_Vaccine;
run;

ods graphics on;

proc nlmixed data=vax tech=trureg cov;
	title "Vax Combined Informing Model";
	pred = log2(exp(a) * exp(-(b/100)*(Days_from_2nd_Vaccine_Dose-14)) + exp(c));
	model Log2AUC ~ normal(pred,s1);
	ods output parameterestimates = vaxest;
run;

data b.vaxest;
	set vaxest;

	keep parameter estimate;
run;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Vax Strat\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;
	title "Vax Stratified Model";
	parms v2 =0 / data=b.vaxest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_2nd_Vaccine_Dose-14)) + exp(c + r2));
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLprestrat_re;
	ods output ParameterEstimates=b.NLprestrat_pe;
	predict Log2AUC out=b.NLprestrat;
	by Infection_Pre_Vaccine;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));
run;

ods pdf close;

proc export data=b.NLprestrat
	outfile="L:\Mount Sinai\SAS\datasets\Vax Strat\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLprestrat_re
	outfile="L:\Mount Sinai\SAS\datasets\Vax Strat\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLprestrat_pe
	outfile="L:\Mount Sinai\SAS\datasets\Vax Strat\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Boost Non-strat\NLmixed Run Info.pdf";

proc nlmixed data=boost tech=trureg cov;
	title "Boost Combined Informing Model";
	pred= log2(exp(a) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose - 14)) + exp(c));
	model Log2AUC ~ normal(pred,s1);
	ods output parameterestimates = boostest;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

data b.boostest;
	set boostest;

	keep parameter estimate;
run;

proc nlmixed data=boost tech=trureg cov;
	title "Boost Combined Informed model";
	parms / data=b.boostest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose - 14)) + exp(c + r2));
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLboost_re;
	ods output ParameterEstimates=b.NLboost_pe;
	predict Log2AUC out=b.NLboost;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

ods pdf close;

proc print data=boost (obs=5);
run;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Boost Strat\NLmixed Run Info.pdf";

proc nlmixed data=boost tech=trureg cov;
	title "Boost Stratified Model";
	parms  / data=b.boostest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose - 14)) + exp(c + r2));
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLbooststrat_re;
	ods output ParameterEstimates=b.NLbooststrat_pe;
	predict Log2AUC out=b.NLbooststrat;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));
	by Infection_Pre_Vaccine;
run;

ods pdf close;

proc export data=b.NLboost
	outfile="L:\Mount Sinai\SAS\datasets\Boost Non-Strat\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLboost_re
	outfile="L:\Mount Sinai\SAS\datasets\Boost Non-Strat\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLboost_pe
	outfile="L:\Mount Sinai\SAS\datasets\Boost Non-Strat\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLbooststrat
	outfile="L:\Mount Sinai\SAS\datasets\Boost Strat\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLbooststrat_re
	outfile="L:\Mount Sinai\SAS\datasets\Boost Strat\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLbooststrat_pe
	outfile="L:\Mount Sinai\SAS\datasets\Boost Strat\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

* Recoding in the VAX dataset to make indicators
;

data vax;
	set vax;

	if vaccine_type="Pfizer" then vt1=0;
	if vaccine_type="Moderna" then vt1=1;

	if Infection_Pre_Vaccine = "yes" then ipv=1;
	else ipv = 0;

	if gender = "Female" then gen=1;
	if gender = "Male" then gen=0;

	if Ethnicity__Hispanic_or_Latino= "No" then his=0;
	else if Ethnicity__Hispanic_or_Latino="Unknown" then his=.;
	else his=1;

	if race="Black or African American" then ra1=1;
	else ra1=0;

	if race="Asian" | race="Asian Indian" then ra2=1;
	else ra2=0;

	if race="More than one race" then ra3=1;
	else ra3=0;

	if race="Other" | race="American Indian or Alaskan Native" then ra4=1;
	else ra4=0;

	if race="Unknown" then ra=.;
	else ra=1;
run;

*	v1 Unvax Strat!;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v1\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;

	title "Vax Demographic Model v1";
	parms v2 = 0 / data=b.vaxest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_2nd_Vaccine_Dose-14)) + exp(c + r2)) + (b_age*age+b_gen*gen+b_his*his+bv_type*vt1+(ra*(b_rAfam*ra1+b_rAsia*ra2+b_rMult*ra3+b_rOth*ra4)));
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemVmodstrat1_re;
	ods output ParameterEstimates=b.NLDemVmodstrat1_pe;
	predict Log2AUC out=b.NLDemVmodstrat1;
	by Infection_Pre_Vaccine;
	footnote "Initial STRAT MODEL all included";
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemVmodstrat1
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v1\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat1_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v1\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat1_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v1\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods PDF close;

*	v2 Unvax Strat Removed: Rmove Asi and oth race to see if significant;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v2\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;
	title "Vax Demographic Model v2";
	parms v2 = 0 / data=b.vaxest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_2nd_Vaccine_Dose-14)) + exp(c + r2)) + (b_age*age+b_gen*gen+b_his*his+bv_type*vt1+(ra*(b_rAfam*ra1+b_rMult*ra3)));
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemVmodstrat2_re;
	ods output ParameterEstimates=b.NLDemVmodstrat2_pe;
	predict Log2AUC out=b.NLDemVmodstrat2;
	by Infection_Pre_Vaccine;
	footnote "RACE destablizes the model due to low category counts";
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemVmodstrat2
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v2\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat2_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v2\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat2_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v2\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

*	v3 Unvax Strat Removed: Race																																									;
Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v3\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;
	title "Vax Demographic Model v3";
	parms v2 = 0 / data=b.vaxest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_2nd_Vaccine_Dose-14)) + exp(c + r2)) + (b_age*age+b_gen*gen+b_his*his+bv_type*vt1);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemVmodstrat3_re;
	ods output ParameterEstimates=b.NLDemVmodstrat3_pe;
	predict Log2AUC out=b.NLDemVmodstrat3;
	by Infection_Pre_Vaccine;
	footnote "Removed Race variable (destabalized the model)";
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemVmodstrat3
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v3\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat3_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v3\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat3_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v3\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

*	v4 Unvax Strat Removed: race gen																																								;
Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v4\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;
	title "Vax Demographic Model v4";
	parms v2 = 0 / data=b.vaxest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_2nd_Vaccine_Dose-14)) + exp(c + r2)) + (b_age*age+b_his*his+bv_type*vt1);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemVmodstrat4_re;
	ods output ParameterEstimates=b.NLDemVmodstrat4_pe;
	predict Log2AUC out=b.NLDemVmodstrat4;
	by Infection_Pre_Vaccine;
	footnote "race and gen removed";
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemVmodstrat4
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v4\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat4_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v4\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat4_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\v4\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

*	v4 Unvax No Strat Removed: race gen his																																									;
Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\Final\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;
	title "Vax Demographic Final Model";
	parms v2 = 0 / data=b.vaxest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_2nd_Vaccine_Dose-14)) + exp(c + r2)) + (b_age*age+bv_type*vt1);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemVmodstrat5_re;
	ods output ParameterEstimates=b.NLDemVmodstrat5_pe;
	predict Log2AUC out=b.NLDemVmodstrat5;
	by Infection_Pre_Vaccine;
	FOOTNOTE "Removed Race Gen His";
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemVmodstrat5
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\Final\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat5_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\Final\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemVmodstrat5_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Vax Strat\Final\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

data boost;
	set boost;

	if vaccine_type="Pfizer" then vt1=0;
	if vaccine_type="Moderna" then vt1=1;

	if Infection_Pre_Vaccine = "yes" then ipv=1;
	else ipv = 0;

	if gender = "Female" then gen=1;
	if gender = "Male" then gen=0;

	if Ethnicity__Hispanic_or_Latino= "No" then his=0;
	else if Ethnicity__Hispanic_or_Latino="Unknown" then his=.;
	else his=1;

	if race="Black or African American" then ra1=1;
	else ra1=0;

	if race="Asian" | race="Asian Indian" then ra2=1;
	else ra2=0;

	if race="More than one race" then ra3=1;
	else ra3=0;

	if race="Other" | race="American Indian or Alaskan Native" then ra4=1;
	else ra4=0;

	if race="Unknown" then ra=.;
	else ra=1;
run;

*v1 Boost Strat!																																												;
Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v1\NLmixed Run Info.pdf";

proc nlmixed data=boost tech=trureg cov;
	title "Boost Demographic Model v1";
	parms v2=0 / data=b.boostest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose-14)) + exp(c + r2)) + (b_age*age+b_gen*gen+b_his*his+bv_type*vt1+(ra*(b_rAfam*ra1+b_rAsia*ra2+b_rMult*ra3+b_rOth*ra4)));
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemBmods1_re;
	ods output ParameterEstimates=b.NLDemBmods1_pe;
	predict Log2AUC out=b.NLDemBmods1;
	by Infection_Pre_Vaccine;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemBmods1
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v1\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods1_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v1\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods1_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v1\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods PDF close;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v2\NLmixed Run Info.pdf";
* dropped race;

proc nlmixed data=boost tech=trureg cov;
	title "Boost Demographic Model v2";
	parms v2=0 / data=b.boostest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose-14)) + exp(c + r2)) + (b_age*age+b_gen*gen+b_his*his+bv_type*vt1);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemBmods2_re;
	ods output ParameterEstimates=b.NLDemBmods2_pe;
	predict Log2AUC out=b.NLDemBmods2;
	by Infection_Pre_Vaccine;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemBmods2
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v2\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods2_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v2\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods2_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v2\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v3\NLmixed Run Info.pdf";

* dropped age;

proc nlmixed data=boost tech=trureg cov;
	title "Boost Demographic Model v3";
	parms v2=0 / data=b.boostest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose-14)) + exp(c + r2)) + (b_gen*gen+b_his*his+bv_type*vt1);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemBmods3_re;
	ods output ParameterEstimates=b.NLDemBmods3_pe;
	predict Log2AUC out=b.NLDemBmods3;
	by Infection_Pre_Vaccine;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));

run;

proc export data=b.NLDemBmods3
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v3\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods3_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v3\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods3_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v3\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v4\NLmixed Run Info.pdf";
*drop his;

proc nlmixed data=boost tech=trureg cov;
	title "Boost Demographic Model v4";
	parms v2=0 / data=b.boostest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose-14)) + exp(c + r2)) + (b_gen*gen+bv_type*vt1);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemBmods4_re;
	ods output ParameterEstimates=b.NLDemBmods4_pe;
	predict Log2AUC out=b.NLDemBmods4;
	by Infection_Pre_Vaccine;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));
run;

proc export data=b.NLDemBmods4
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v4\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods4_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v4\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmods4_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\v4\NLmixed pe.csv" REPLACE
	dbms=csv;
run;


*v1_5 Boost Strat!																																												;
Ods pdf file= "L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\Final\NLmixed Run Info.pdf";

proc nlmixed data=boost tech=trureg cov;
	title "Boost Demographic Final Model";
	parms  bv_type=0 / data=b.boostest;
	pred= log2(exp(a+r1) * exp(-(b/100)*(Days_from_3rd_Vaccine_Dose-14)) + exp(c + r2)) + (bv_type*vt1);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NLDemBmodq1_re;
	ods output ParameterEstimates=b.NLDemBmodq1_pe;
	predict Log2AUC out=b.NLDemBmodq1;
	by Infection_Pre_Vaccine;
	estimate "A+C log2 exp" log2(exp(a)+exp(c));
run;

proc export data=b.NLDemBmodq1
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\Final\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmodq1_re
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\Final\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NLDemBmodq1_pe
	outfile="L:\Mount Sinai\SAS\datasets\Dem Models\Boost Strat\Final\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods PDF close;

proc univariate data=vax normal;
	var Log2AUC;
	qqplot;
run;

proc ttest data=vax alpha=0.05;
	var Log2AUC;
run;

data vax2;
	set vax;

	days_power = Days_from_2nd_Vaccine_Dose-13;
	log2days = log2(days_power);

run;

data boost2;
	set boost;

	days_power = Days_from_3rd_Vaccine_Dose-13;
	log2days = log2(days_power);

run;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Linear Models\vax\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;
	title "Vax Exponential Decay Model";
	pred= (A+r1)-((B+r2)/100)*(Days_from_2nd_Vaccine_Dose - 14);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NL_lin_re;
	ods output ParameterEstimates=b.NL_lin_pe;
	predict Log2AUC out=b.NL_lin;
	by Infection_Pre_Vaccine;

run;

proc export data=b.NL_lin
	outfile="L:\Mount Sinai\SAS\datasets\Linear Models\vax\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_re
	outfile="L:\Mount Sinai\SAS\datasets\Linear Models\vax\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_pe
	outfile="L:\Mount Sinai\SAS\datasets\Linear Models\vax\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Linear Models\boost\NLmixed Run Info.pdf";

proc nlmixed data=boost tech=trureg cov;
	title "Boost Exponential Decay Model";
	pred= (A+r1)-((B+r2)/100)*(Days_from_3rd_Vaccine_Dose - 14);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NL_lin_re;
	ods output ParameterEstimates=b.NL_lin_pe;
	predict Log2AUC out=b.NL_lin;
	by Infection_Pre_Vaccine;

run;

proc export data=b.NL_lin
	outfile="L:\Mount Sinai\SAS\datasets\Linear Models\boost\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_re
	outfile="L:\Mount Sinai\SAS\datasets\Linear Models\boost\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_pe
	outfile="L:\Mount Sinai\SAS\datasets\Linear Models\boost\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;




Ods pdf file= "L:\Mount Sinai\SAS\datasets\Power Models\vax\NLmixed Run Info.pdf";

proc nlmixed data=vax tech=trureg cov;
	title "Vax Power-Law Model";
	parms v1=0.5 v2=0.5 v3=0.5;
	pred= (A+r1)-(B+r2)*log2((Days_from_2nd_Vaccine_Dose - 13));
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NL_lin_re;
	ods output ParameterEstimates=b.NL_lin_pe;
	predict Log2AUC out=b.NL_lin;
	by Infection_Pre_Vaccine;

run;

proc export data=b.NL_lin
	outfile="L:\Mount Sinai\SAS\datasets\Power Models\vax\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_re
	outfile="L:\Mount Sinai\SAS\datasets\Power Models\vax\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_pe
	outfile="L:\Mount Sinai\SAS\datasets\Power Models\vax\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;

Ods pdf file= "L:\Mount Sinai\SAS\datasets\Power Models\boost\NLmixed Run Info.pdf";

proc nlmixed data=boost tech=trureg cov;
	title "Boost Power-Law model";
	pred= (A+r1)-(B+r2)*log2(Days_from_3rd_Vaccine_Dose - 13);
	model Log2AUC ~ normal(pred, s1);
	random r1 r2 ~ normal([0,0] , [v1, v2, v3]) subject=id out=b.NL_lin_re;
	ods output ParameterEstimates = b.NL_lin_pe;
	predict Log2AUC out=b.NL_lin;
	by Infection_Pre_Vaccine;

run;

proc export data=b.NL_lin
	outfile="L:\Mount Sinai\SAS\datasets\Power Models\boost\NLmixed.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_re
	outfile="L:\Mount Sinai\SAS\datasets\Power Models\boost\NLmixed re.csv" REPLACE
	dbms=csv;
run;

proc export data=b.NL_lin_pe
	outfile="L:\Mount Sinai\SAS\datasets\Power Models\boost\NLmixed pe.csv" REPLACE
	dbms=csv;
run;

ods pdf close;
