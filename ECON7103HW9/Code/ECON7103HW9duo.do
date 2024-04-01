// Install necessary packages
ssc install sdid, replace
ssc install xtreg
ssc install blindschemes, all
ssc install did_multiplegt, replace
ssc install reghdfe, replace
ssc install synth, all

// Set the plotting scheme to plain and blind
set scheme plotplainblind, permanently

// Load the data file and change directory for output
clear
use "C:\Users\sedat\Desktop\Iphone stata\ECON7103HW9\recycling_hw.dta" 
cd "C:\Users\sedat\Desktop\Iphone stata\ECON7103HW9\output3"

/********** Question 1 **********/


// Calculate average recycling rate by year and state
egen avgrecycle = mean(recyclingrate), by(year nyc nj ma)


// Create line graph of average recycling rate by year and state
graph twoway (line avgrecycle year if nyc==1, lc(red)) ///
             (line avgrecycle year if nj==1, lc(orange)) ///
             (line avgrecycle year if ma==1, lc(green)), ///
             xtitle("Year") ytitle("Recycling Rate") ///
             legend(label(1 "NYC") label(2 "NJ") label(3 "MA"))

// Export graph as PDF
graph export "HW9Q1.pdf", replace


/********** Question 2 **********/

// Load the data file and drop observations for years after 2004
clear
use "C:\Users\sedat\Desktop\Iphone stata\ECON7103HW9\recycling_hw.dta" 
drop if year > 2004


// Create treatment variable
gen treatment = (year >= 2002) & nyc == 1

// Run fixed effects regression with clustered standard errors
reghdfe recyclingrate treatment, absorb(nyc year) cluster(id)


/********** Question 3 **********/

// Create post-treatment period indicator
gen post = year > 2001

// Create treated indicator
gen treated = nyc == 1

// Create pause indicator
gen pause = 1 if nyc ==1 & year > 2001 & year < 2005

// Replace missing values with 0
replace pause = 0 if pause == . 

// Run synthetic control analysis with placebo test
sdid recyclingrate region year pause, vce(placebo) graph


/********** Question 4 **********/

// Create a new variable for region
encode region, gen(region2)

// Set panel data structure
xtset region2 year

// Run fixed effects regression with interaction term and clustered standard errors
xtreg recyclingrate treated##ib2001.year, fe cluster(region2)

// Store the estimates
estimates store m1

// Create coefficient plot with confidence intervals
coefplot (m1), drop (_cons ) ci xtitle(Year) ytitle(Recycling Rate) caption("95% confidence intervals") ylabel(1 "1997" 2 "1998" 3 "1999" 4 "2000" 5 "2002" 6 "2003" 7 "2004" 8 "2005" 9 "2006" 10 "2007" 11 "2008" 12 "Treat x 1997" 13 "Treat x 1998" 14 "Treat x 1999" 15 "Treat x 2000" 16 "Treat x 2002" 17 "Treat x 2003" 18 "Treat x 2004" 19 "Treat x 2005" 20 "Treat x 2006" 21 "Treat x 2007" 22 "Treat x 2008")

// Export coefficient plot as PDF
graph export "HW9Q4.pdf", replace


/********** Question 5 **********/

// Collapse data to get average recycling rate by year and treatment group
collapse(mean) recyclingrate, by(year nyc)

// Create line graph of average recycling rate by year and treatment group
line recyclingrate year if nyc == 1, lc(orange) || line recyclingrate year if nyc == 0, lc(green)  xtitle("Year") ytitle("Avg Recycling Rate") legend(label(1 "Treated") label (2 "Control")) 

// Export graph as PDF
graph export "HW9Q5a.pdf", replace

*5b) Prepare data and run Synthetic Control method

*Load the data file
clear 
use "C:\Users\sedat\Desktop\Iphone stata\ECON7103HW8\recycling_hw.dta"

*Create a variable "state" to identify the state in which each observation is located
gen state = "nyc"
replace state = "nj" if nj==1
replace state = "ma" if ma==1

*Encode the "state" variable as a numeric variable "nstate"
encode state, gen(nstate)

*Encode the "region" variable as a numeric variable "nregion"
encode region, gen(nregion)

*Calculate the average recycling rate for NYC by year
egen average_nyc = mean(recyclingrate) if nyc ==1, by(year nyc)

*Replace missing values with actual recycling rates
replace average_nyc = recyclingrate if average_nyc ==. 

*Drop observations from the Bronx and Queens
drop if region == "Bronx" |region == "Queens"

*Sort the data by state, region, and year
sort state region year

*Create an identifier variable for each state-region combination
egen stateregionid = concat(state region)

*Rename the "average_nyc" variable to "outcomes"
rename average_nyc outcomes

*Encode the "stateregionid" variable as a numeric variable "nstateregion"
replace stateregionid = "NYC" if stateregionid == "nycBrooklyn"
encode stateregionid, gen(nstateregion)

*Tabulate the "nstateregion" variable
tab nstateregion

*Create a graph to show the average recycling rates for treated and control regions by year
graph twoway (line recyclingrate year if stateregionid != "NYC", lc(orange)) ///
            (line recyclingrate year if stateregionid == "NYC", lc(green)), ///
			xtitle("Year") ytitle("Recycling Rate") ///
			xlabel(1997(2)2008) legend(label(1 "Controls") label(2 "NYC"))

*Run the Synthetic Control method
tsset nstateregion year
synth outcomes incomepercapita(1997(1)2001) nonwhite(1997(1)2001) munipop2000 collegedegree2000 democratvoteshare2000, trunit(1) trperiod(2002) fig

*Export the output graph as a PDF file
graph export "HWQ5b2.pdf", replace

*Run the Synthetic Control method and generate variables for effect graphs
synth_runner outcomes incomepercapita(1997(1)2001) nonwhite(1997(1)2001) munipop2000 collegedegree2000 democratvoteshare2000, trunit(1) trperiod(2002) gen_vars

*Create effect graphs
effect_graphs , trlinediff(-1) effect_gname(effect) tc_gname(outcomes_synth)
single_treatment_graphs, trlinediff(-1) raw_gname(outcomes) effects_gname(effects)

* (c) The plot of estimated synthetic control effects and placebo effects over time

* Define effect as the difference between the unit's outcome and its synthetic control for that time period.
gen effect = outcomes - outcomes_synth

* Plot the estimated synthetic control effects and placebo effects over time.
graph twoway (line effect year if stateregionid != "NYC", lc(orange)) ///
            (line effect year if stateregionid == "NYC", lc(green)), ///
			xtitle("Year") ytitle("Recycling Rate") ///
			xlabel(1997(2)2008) legend(label(1 "Placebo Effects") label(2 "NYC"))

* Export the plot as a PDF file.
graph export "Q5c.pdf", replace


* (d) The plot of final synthetic control estimates over time


gen depvar_synth = outcomes_synth

* Plot the final synthetic control estimates over time.
graph twoway (line depvar_synth year if stateregionid != "NYC", lc(orange)) ///
            (line depvar_synth year if stateregionid == "NYC", lc(green)), ///
			xtitle("Year") ytitle("Recycling Rate") ///
			xlabel(1997(2)2008) legend(label(1 "Donors") label(2 "NYC"))

* Export the plot as a PDF file.
graph export "Q5d.pdf", replace

