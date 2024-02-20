clear
import delimited "/Users/sedators/Documents/GitHub/phdee-2024-db/homework5/instrumentalvehicles.csv"
cd "/Users/sedators/Documents/GitHub/phdee-2024-so/ECON7103HW4/Output"
ssc install weakivtest
*Q1
ivregress liml price car  height length (mpg = weight), vce(robust)
outreg2 using Q11.doc, replace ctitle("2SLS Results: Liml Estimator")
outreg2 using Q11.tex, replace ctitle("2SLS Results: Liml Estimator")
ivregress 2sls price car  height length (mpg = weight), vce(robust) first small

estat endog
outreg2 using Q13.doc, replace ctitle("Test of endogeneity")


estat firststage
outreg2 using Q14.doc, replace ctitle("Instruments are weak?")
outreg2 using Q14.tex, replace ctitle("Instruments are weak?")

*Q2

weakivtest
outreg2 using Q2.doc, replace ctitle("Weak Instrumental Test")
outreg2 using Q2.tex, replace ctitle("Weak Instrumental Test")
