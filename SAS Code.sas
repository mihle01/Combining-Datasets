/*Part A*/
libname HW4 "/home/u60739998/BS 805/Class 4";

filename one "/home/u60739998/BS 805/Class 4/trial01_f22.xlsx";
filename two "/home/u60739998/BS 805/Class 4/trial02_f22.xlsx";
filename three "/home/u60739998/BS 805/Class 4/trial03_f22.xlsx";

proc import datafile=one
	out=trial1
	dbms=xlsx
	replace;
run;
proc import datafile=two
	out=trial2
	dbms=xlsx
	replace;
run;
proc import datafile=three
	out=trial3
	dbms=xlsx
	replace;
run;

data append;
	set trial1 trial2 trial3;
run;

proc sort data=append;
	by id;
run;

proc means noprint data=append;
	by id; *tells SAS we want a mean tjc for each individual by id, not a total mean for the whole sample and to call it mean_tjc
	        if they have the same value for id, take the mean of their tjc values and put that in mean_tjc;
	var tjc;
	output out=stats1 mean=mean_tjc;
run;
*since we used proc means, instead of a data step, it will onlyu print out what we want it to, in this case just mean_tjc;

/*Part B*/
filename four "/home/u60739998/BS 805/Class 4/trial04_f22.xlsx";

proc import datafile=four
	out=trial4
	dbms=xlsx
	replace;
run;

data trials1_4;
	merge stats1 trial4;
	by id; *don't have to do a proc sort because all these datasets are already sorted by id;
	diff_tjc=tjc-mean_tjc;
run;

proc means data=trials1_4;
	var diff_tjc;
run;

/*Part C*/
filename five "/home/u60739998/BS 805/Class 4/trial05_f22.xlsx";

proc import datafile=five
	out=trial5
	dbms=xlsx
	replace;
run;

data trials1_5;
	merge trials1_4 trial5;
	by id;
run;

*gives mean tjc for each treatment-duration combo and puts it in diffmean column in a new dataset called diffmeans;
proc sort data=trials1_5;
	by treatment duration;
run;

proc means noprint data=trials1_5;
	by treatment duration;
	var diff_tjc;
	output out=difmns mean=diffmean;
run;

proc gplot data=difmns;
	symbol1 i=join c=black line=1;
	symbol2 i=join c=black line=2;
	symbol3 i=join c=black line=3;
	** will plot 3 lines, one for each duration **;
	plot diffmean*treatment=duration;
	title 'Part C - Plot of Mean Differences';
run;

title;

/*Part D*/
*two-factor ANOVA;
*check whether there is significant interaction or not;
proc glm data=trials1_5;
	class treatment duration;
	model diff_tjc=treatment duration treatment*duration;
	lsmeans treatment*duration / stderr tdiff adjust=tukey;
	*means treatment*duration / cldiff tukey;
run;

*check balance of design;
proc freq data=trials1_5;
	tables treatment*duration;
run;