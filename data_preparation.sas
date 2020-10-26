libname project "/folders/myfolders/STAT330MidtermProject/STAT330MidtermProject";

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
	xaxis label = "GDP";
	yaxis label = "Life Expectancy (Years)";
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
	yaxis label = "Gender Inequality Index" values = (0 to 1 by 0.1);
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

proc sql;
	create table us_co2_gdp as
	select country, year, co2_emissions, gdp from gap_temp
	where country = "United States"
	and co2_emissions is not missing
	and gdp is not missing;
quit;

data gini;
	input year gini;
	
	datalines;
		1974 35.3
		1979 34.5
		1986 37.4
		1991 38
		1994 40
		1997 40.5
		2000 40.1
		2004 40.3
		2007 40.8
		2010 40
		2013 40.7
		2016 41.1
	;
run;

proc sql;
	create table final_data as
	select us_co2_gdp.year, co2_emissions, gdp, gini from us_co2_gdp
	inner join gini on us_co2_gdp.year = gini.year;
quit;

/* title "How United States GDP and CO2 Emissions Vary Across Time, Beginning in 1960"; */
ods graphics / width=2.5in height=1.5in;
ods pdf file = '/folders/myfolders/STAT330MidtermProject/grid.pdf';
ods layout gridded columns=3 advance=table;

proc sgplot data = final_data;
	series x = year y = gdp;
	xaxis label = "Year";
	yaxis label = "GDP";
run;

proc sgplot data = final_data;
	series x = year y = co2_emissions;
	xaxis label = "Year";
	yaxis label = "CO2 Emissions";
run;

proc sgplot data = final_data;
	series x = year y = gini;
	xaxis label = "Year";
	yaxis label = "GINI Index";
run;
ods pdf close;
ods layout end;
ods graphics / reset = all;

proc corr data = final_data;
	var gdp;
	with co2_emissions;
run;

proc reg data = final_data;
	model gini = gdp;
run;

/* Discussion */

proc sql;
	create table ready_df as 
	select gap_temp.year, co2_emissions, gdp, hdi, life_exp from gap_temp
	where country = "United States"
	and co2_emissions is not missing
	and gdp is not missing
	and hdi is not missing;
quit;

proc sql;
	create table hdi_df as
	select * from ready_df
	inner join
	gii
	on ready_df.year = gii.year;
quit;

ods graphics / width=2.5in height=1.5in;
ods pdf file = '/folders/myfolders/STAT330MidtermProject/grid2.pdf';
ods layout gridded columns=3 rows=2 advance=table;

proc sgplot data = hdi_df;
	series x = year y = hdi;
	xaxis label = "Year";
	yaxis label = "HDI";
run;

proc sgplot data = hdi_df;
	series x = year y = life_exp;
	xaxis label = "Year";
	yaxis label = "Life Expectancy (Years)";
	
proc sgplot data = hdi_df;
	series x = year y = gii;
	xaxis label = "Year";
	yaxis label = "GII";
run;

proc sgplot data = final_data;
	series x = year y = co2_emissions;
	xaxis label = "Year";
	yaxis label = "CO2 Emissions";
run;

proc sgplot data = final_data;
	series x = year y = gini;
	xaxis label = "Year";
	yaxis label = "Gini Index";
run;
ods pdf close;
ods layout end;
ods graphics / reset = all;