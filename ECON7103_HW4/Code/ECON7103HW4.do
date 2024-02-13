clear

. import delimited "/Users/sedators/Documents/GitHub/phdee-2024-db/homework4/fishbycatch.csv"
cd "/Users/sedators/Documents/GitHub/phdee-2024-so/ECON7103HW4/Output"

reshape long shrimp salmon bycatch, i(firm) j(month)

*Q1a


reg bycatch treated shrimp salmon i.firm i.month, vce(cluster firm) 

estimates store Q1a

*Q1b


	tab month, gen(month)

	su firm
	local firms = `r(max)'

	local varlist "bycatch treated shrimp salmon month1 month2 month3 month4 month5 month6 month7 month8 month9 month10 month11 month12 month13 month14 month15 month16 month17 month18 month19 month20 month21 month22 month23 month24"
	foreach x of local varlist {
		gen `x'_2 = .
		forvalues f = 1/`firms' {
			su `x' if firm == `f'
			replace `x'_2 = `x' - `r(mean)' if firm == `f'
		}
	}


		reg bycatch_2 treated_2 shrimp_2 salmon_2 month2_2 month3_2 month4_2 month5_2 month6_2 month7_2 month8_2 month9_2 month10_2 month11_2 month12_2 month13_2 month14_2 month15_2 month16_2 month17_2 month18_2 month19_2 month20_2 month21_2 month22_2 month23_2 month24_2, vce(cluster firm)

		reg bycatch_2 treated_2 shrimp_2 salmon_2 i.month, vce(cluster firm)

		estimates store Q1b
		
*Q1c

outreg2 [Q1a] using hw4c.tex, label 2aster tex(frag) dec(2) replace ctitle("Model (a)") keep (treated shrimp salmon)

outreg2 [Q1b] using hw4c.tex, label 2aster tex(frag) dec(2) append ctitle("Model (b)") keep (treated_2 shrimp_2 salmon_2)
