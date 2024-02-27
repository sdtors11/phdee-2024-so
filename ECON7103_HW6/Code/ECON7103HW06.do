* Initial setup
* Uncomment the lines below if you need to install the packages
* ssc install statastates
* ssc install colrspace
* ssc install csdid
* ssc install eret2
* Install pbalchk manually from the provided URL

* Set working directory and load hourly data
cd "C:\Users\sedat\Desktop\ECON7103_2024\phdee-2024-so\ECON7103_HW6\Output"
use "C:\Users\sedat\Desktop\ECON7103_2024\phdee-2024-db\ECON7103_HW6\energy_staggered.dta", clear

* Part 1: Hourly Data Analysis

* Q1: Generate daytime variable and create cohort
gen double daytime = clock(datetime, "MDYhms")
format daytime %tc
egen cohort_var=csgvar(treatment), ivar(id) tvar(daytime)
sort
egen hour=seq(), by(id)
levelsof treated, local(unique_values)
local num_cohort : word count `unique_values'
display "Cohort_var_num: " `num_cohort'

* Q2: Run fixed effects model with treatment and controls
twowayfeweights energy cohort_var hour treatment, type(feTR)

* Q3: Regression with high dimensional fixed effects
reghdfe energy treatment temperature precipitation relativehumidity, absorb(daytime id) vce(cluster id)


*Part 2: Daily Data Analysis

* Clear the workspace and set the directory for daily data
clear
cd "C:\Users\sedat\Desktop\ECON7103_2024\phdee-2024-so\ECON7103_HW6\Output"
use "C:\Users\sedat\Desktop\ECON7103_2024\phdee-2024-db\ECON7103_HW6\energy_staggered.dta", clear

* Format datetime and collapse data to daily
gen double daytime = clock(datetime, "MDYhms")
format daytime %tc
gen day=dofc(daytime)
format day %td
collapse (max) treatment (sum) energy (mean) temperature precipitation relativehumidity, by(id day)

* Generate day number and treatment cohort variable
sort day
egen daynumber=seq(), by(id)
egen double cohortvar=csgvar(treatment), ivar(id) tvar(day)  

* P2Q1: Regression for daily data
reghdfe energy treatment temperature precipitation relativehumidity, absorb(day id) vce(cluster id)
outreg2 using P2Q1.tex, replace  

* P2Q2: Event study setup and execution
gen event_time = day - cohortvar
* Generate and omit event time dummies
char event_time[omit] -1
xi i.event_time, pref(_T)

* Define positions for the event study
local pos_of_neg_2 = 28 
local pos_of_zero = `pos_of_neg_2' + 2
local pos_of_max = `pos_of_zero' + 29

* Run the event study regression
reghdfe energy _T* temperature precipitation relativehumidity, absorb(id) vce(cluster id)

* Prepare data for graphing the event study results
capture drop order b high low
gen order = .
gen b = . 
gen high = . 
gen low = .


* Loop through the first segment of the event study period
foreach day in 1/`pos_of_neg_2' {
    local event_time = `day' - 2 - `pos_of_neg_2'
    replace order = `event_time' in `i'
    
    replace b = b_`day' in `i'
    replace high = b_`day' + 1.96*se_v2_`day' in `i'
    replace low = b_`day' - 1.96*se_v2_`day' in `i'
    
    local i = `i' + 1
}

* Set the observation for the reference point
replace order = -1 in `i'
replace b = 0 in `i'
replace high = 0 in `i'
replace low = 0 in `i'
local i = `i' + 1

* Loop through the second segment of the event study period
foreach day in `pos_of_zero'/`pos_of_max' {
    local event_time = `day' - 2 - `pos_of_neg_2'
    replace order = `event_time' in `i'
    
    replace b = b_`day' in `i'
    replace high = b_`day' + 1.96*se_v2_`day' in `i'
    replace low = b_`day' - 1.96*se_v2_`day' in `i'
    
    local i = `i' + 1
}

* Plotting the event study results
twoway (rarea low high order if order<=29 & order >= -29, fcolor(gs21) color(green) msymbol(1)) ///
    

* Export the graph
graph export "P2graph1.pdf", replace

* P2Q3 - Conducting an event study analysis and generating a graph

* Conduct the event study analysis with high-dimensional fixed effects
eventdd energy temperature precipitation relativehumidity, hdfe absorb(id) timevar(event_time) cluster(id)

* I cannot run the result. It says that "command matsort is unrecognized". 


* P2Q4 - Estimating effects with Cross-Sectional Dependence-Adjusted DiD and plotting

* Perform the csdid analysis for energy consumption with relevant variables and clustering
csdid energy temperature precipitation relativehumidity, ivar(id) time(day) gvar(cohortvar) wboot reps(50)

* Display simple event study results
estat simple

* Display event study results with graphical representation
estat event


