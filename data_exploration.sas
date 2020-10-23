libname project "/folders/myfolders/STAT330MidtermProject/STAT330MidtermProject";

proc print data = project.gapminder_data (obs = 40);
run;

/*
Ideas: 
1. Compare early-industrializing countries to countries that are currently developing. Look at CO2 emissions
   in different parts of the world, how much developing countries are 'catching up'. 

2. Investigate gpd vs. co2 emissions. Correlated? Maybe take a look at life expectancy too.

3. Economics standpoint: people say that GDP doesn't measure the good things that really matter and improve
   quality of life, but it's said to be correlated with all those things. Investigate that.
   		- Discussion: But is it correlated with bad things too, like CO2 emissions?
4. 
*/