clear
import delimited "/Users/sedators/Documents/GitHub/phdee-2024-db//instrumentalvehicles.csv"
cd "/Users/sedators/Documents/GitHub/phdee-2024-SO/ECON7103HW7/Output"

gen rd = length - 225
gen rdl = 0
replace rdl = 1 if length > 225 
rdrobust price rd
rdplot price rd

rdbwselect price rd, bwselect(mserd)
rdbwselect price rd, kernel(uniform) c(0) p(4)

ivregress 2sls price car (mpg = rd), vce(robust) first small
outreg2 using Q12.doc, replace ctitle("2SLS Results: 2sls Estimator")
outreg2 using Q12.tex, replace ctitle("2SLS Results: 2sls Estimator")