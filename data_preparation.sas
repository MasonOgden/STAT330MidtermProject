libname project "/folders/myfolders/STAT330MidtermProject";

proc print data = project.gapminder_data (obs = 40);
run;

/*
To do:
	1. Find out what units GDP is in 
		a. Interpret coefficient of GDP with literacy rate
*/

data gap_temp;
	set project.gapminder_data;
run;

proc sql;
	create table us_lit as
	select * from gap_temp
	where country = 'United States'
	and life_exp is not missing
	and gdp is not missing;
quit;

ods html path = "/folders/myfolders/STAT330MidtermProject" file = "out.png";
title "United States Life Expectancy vs. GDP, Beginning in 1960";
proc sgplot data = us_lit;
	scatter x = gdp y = life_exp;
/* 	lineparm x = 17600 y = 66.06860 slope = 0.00024918; */
	xaxis label = "GDP";
	yaxis label = "Life Expectancy";
run;
ods html close;

proc corr data = us_lit;
	var life_exp;
	with gdp;
run;

proc reg data = us_lit;
	model life_exp = gdp;
	output out = us_lit_resids residual = resids;
quit;

proc univariate data = us_lit_resids normal;
	var resids;
run;

/* proc template; */
/* 	list styles; */
/* run; */

data gii;
	input year gii;

	datalines;
		1995 0.305
		2005 0.263
		2010 0.254
		2011 0.25
		2012 0.24
		2013 0.235
		2014 0.225
		2015 0.219
		2016 0.211
		2017 0.202
		2018 0.182
	;
run;

proc sql;
	create table us_gii as
	select us_lit.year, gdp, gii from us_lit
	inner join gii on us_lit.year = gii.year;
run;
	
ods html path = "/folders/myfolders/STAT330MidtermProject" file = "out.png";
title "United States Gender Inequality vs. GDP, Beginning in 1995";
proc sgplot data = us_gii;
	scatter x = gdp y = gii;
	xaxis label = "GDP";
	yaxis label = "Gender Inequality Index (0 is equal)" values = (0 to 1 by 0.1);
run;
ods html close;

proc corr data = us_gii;
	var gii;
	with gdp;
run;

proc reg data = us_gii;
	model gii = gdp;
run;

/*
To do next: go into jupyterlab and make usa_gini_full.csv only keep year on the date column,
then load it into here with datalines and merge it with us_lit. Plot both lines 
(gini and co2 emissions) on the same graph using (https://communities.sas.com/t5/Graphics-Programming/proc-sgplot-with-2-y-axes/td-p/453729)
and then turn that into a macro to go with year, animate it. 
*/