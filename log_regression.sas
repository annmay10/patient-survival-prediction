
*\ Data set was obtained from the UCI Machine Learning Repository:

*\https://archive.ics.uci.edu/ml/datasets/Heart+failure+clinical+records;

data heartf;
	infile '/home/u63105230/final/heart_failure_clinical_records_dataset.csv' dsd 
		missover firstobs=2;
	input age anaemia creatinine_p diab eject_f hbp plat serum_c serum_s sex smk 
		time Death_E;
run;

proc univariate data=heartf;
	var age plat creatinine_p;
	histogram age plat creatinine_p;
	probplot age plat creatinine_p;
	ods select Histogram ProbPlot;
run;

proc univariate data=heartf normal;
	var age plat creatinine_p;
	histogram age plat creatinine_p /normal;
	ods select Histogram GoodnessOfFit TestsForNormality;
run;

proc corr data=heartf;
	var creatinine_p plat serum_c serum_s eject_f time age;
	with Death_E;
run;

/*smoking x death*/
proc freq data=heartf;
	tables smk*Death_E/chisq exact nocol norow;
run;

/*anaemia x death*/
proc freq data=heartf;
	tables anaemia*Death_E/chisq exact nocol norow;
run;

/*diabetes x death*/
proc freq data=heartf;
	tables Death_E*diab/chisq exact nocol norow;
run;

/*high bp x death*/
proc freq data=heartf;
	tables hbp*Death_E/chisq exact nocol norow;
run;

/*sex x death*/
proc freq data=heartf;
	tables sex*Death_E/chisq exact nocol norow;
run;

/*  */
/* proc corr data=heartf; */
/*    var creatinine_p plat serum_c serum_s eject_f time age; */
/*    with Death_E; */
/* run; */
/*continuous variables x death*/
proc means data=heartf N MEAN STD T PRT MAXDEC=2;
	class Death_E;
	var creatinine_p plat serum_c serum_s eject_f time age;
run;

/* serum_c serm_s eject_f time age */
proc logistic data=heartf;
	model Death_E=serum_c serum_s eject_f time age;
	ods select ClassLevelInfo OddsRatios ParameterEstimates GlobalTests ModelInfo 
		FitStatistics;
run;

* use backward selection on all main effects with same coding as before;

proc logistic data=heartf;
	model Death_E=serum_c serum_s eject_f time age/selection=backward;
	ods select ClassLevelInfo OddsRatios ParameterEstimates GlobalTests ModelInfo 
		FitStatistics;
run;

proc genmod data=heartf;
	model Death_E = serum_c eject_f time age/
	dist = bin link = logit type1 type3;
	ods select ModelInfo ModelFit ParameterEstimates Type1 ModelANOVA;
run;

proc logistic data=heartf desc;
	model Death_E=serum_c eject_f time age;
	output predprobs=individual out=death_out1;
	ods select ClassLevelInfo OddsRatios ParameterEstimates GlobalTests ModelInfo 
		FitStatistics;
run;

proc freq data=death_out1;
    tables Death_E * _into_/ nocol norow;
run;
