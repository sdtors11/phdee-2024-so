clear
 use "C:\Users\sedat\Desktop\ECON7103_2024\phdee-2024-db\ECON7103_HW8\electric_matching (3).dta" 

cd"C:\Users\sedat\Desktop\ECON7103_2024\phdee-2024-so\ECON7103_HW8\Output"

*Q1a)
gen lnmw = ln(mw)
encode zone, gen(zone1)
gen treatment = 0
	replace treatment = 1 if year == 2020 & month >= 3

regress lnmw treatment temp pcp i.month i.dow i.hour i.zone1 , vce(robust)
outreg2 using regression_results.doc, replace word
*Q1b)

replace treatment = 1 if (year >=2020 & month >=3 & day >= 1 & hour >= 0)
 drop if month < 3
teffects nnmatch (lnmw temp pcp) (treat), ematch(zone1 dow hour month) atet vce(robust) nneighbor(1)


*Q1c) One potential issue with the regression approach in part (a) is omitted variable bias, if there are important factors affecting both treatment assignment and the outcome that are not included in the model. Another issue is the potential for unobserved heterogeneity, if there are unmeasured differences between the treated and untreated groups that affect the outcome.

*The matching approach in part (b) can help address some of these issues by controlling for observable confounding factors and reducing unobserved heterogeneity. However, there may still be unmeasured factors that affect both treatment assignment and the outcome, which could bias the treatment effect estimate. In addition, the matching approach relies on the assumption that the control group is a valid counterfactual for the treated group, which may not be true if there are systematic differences between the two groups that are not accounted for in the matching.

*Q2a)
reg lnmw i.zone1 i.month i.dow i.hour i.year treatment temp pcp, vce(robust)
outreg2 using regression_results.doc, append word
*Q2b)
* By adding an indicator for year of sample, equation (2) allows for the possibility that there are time-varying factors that affect both treatment assignment and the outcome, and that are not captured by the other variables in the model. This can help address the issue of omitted variable bias that was a potential concern in 1(c). Including a year indicator also allows for the possibility of different treatment effects in different years, which may be important if there are changes in the treatment or in the population over time. Overall, including a year indicator in the model can provide more control for time-varying confounding factors and increase the validity of the treatment effect estima

*Q3a
gen year2020 = 0
replace year2020 = 1 if year == 2020

 teffects nnmatch (lnmw temp pcp i.month i.day i.year i.dow i.hour) (year2020), ematch(dow hour month zone1) dmvariables generate(logmw_hat)
 reg (lnmw - logmw_hat1) treatment, vce(robust)
 outreg2 using regression_results.doc, append word
 *Q3b
 
 *The standard errors for the coefficient estimate from the nnmatch command might not be trustworthy if the matching process results in poor quality matches, such as if the matching variables are poorly chosen or if there is too much variation in the data. In this case, the coefficient estimates may be biased or unstable, and the standard errors may be too small or too large.

*Another reason to be cautious with the standard errors is if there is clustering of the observations within the matched pairs. If the observations within matched pairs are more similar to each other than to observations in other pairs, then the standard errors may be underestimated, leading to incorrect inference.

