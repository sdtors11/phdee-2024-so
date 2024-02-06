clear
cd "/Users/sedators/Documents/GitHub/phdee-2024-so/ECON7103_HW3/Output"
import delimited "/Users/sedators/Documents/GitHub/phdee-2024-db/homework2/kwh.csv"

gen lnelectricity = ln(electricity)
gen lnsqft = ln(sqft)
gen lnretrofit = ln(retrofit)
gen lntemp = ln(temp)


regress lnelectricity lnsqft lntemp retrofit

regress lnelectricity lnsqft lntemp retrofit, vce(bootstrap, reps(1000) dots(1))
*Q5


eststo treated:
		mat betas = J(1000,4,.) 
		forvalues i = 1/1000 {
			preserve 
				bsample 
				
				reg lnelectricity lnsqft lntemp retrofit
				
				mat betas[`i',1] = _b[lnsqft] 
				mat betas[`i',2] = _b[retrofit]
				mat betas[`i',3] = _b[lntemp]
				mat betas[`i',4] = _b[_cons]
			restore 
		}
		
		
		capture program drop bootstrapsample
		program define bootstrapsample, eclass
		
			tempname betas betas1 betas2 betas3 betas4
			
			mat `betas' = J(1000,4,.)
			forvalues i = 1/1000 {
				preserve
					bsample 
					quietly: reg lnelectricity lnsqft lntemp retrofit
					
					mat `betas'[`i',1] = _b[lnsqft] 
					mat `betas'[`i',2] = _b[retrofit]
					mat `betas'[`i',3] = _b[lntemp]
					mat `betas'[`i',4] = _b[_cons]
					di `i' 
				restore
			}
			svmat `betas', name(temp)
				corr temp1 temp2 temp3 temp4, cov 
				mat A = r(C) 
				drop temp1 temp2 temp3 temp4
				
			reg lnelectricity lnsqft lntemp retrofit
			ereturn repost V = A 
		end
		
		bootstrapsample 
		estimates store bootreg
		
		
		outreg2 [bootreg] using sampleoutput_stata.tex, label stat(coef ci) tex(frag) dec(2) replace ctitle("OLS")
		
		
		regress lnelectricity lnsqft lntemp retrofit
		
		margins, dydx(*)
		
		eststo controls:
		mat betas = J(1000,4,.) 
		forvalues i = 1/1000 {
			preserve 
				bsample 
				
				reg lnelectricity lnsqft lntemp retrofit
				
				mat betas[`i',1] = _b[lnsqft] 
				mat betas[`i',2] = _b[retrofit]
				mat betas[`i',3] = _b[lntemp]
				mat betas[`i',4] = _b[_cons]
			restore 
		}
		
		
		capture program drop bootstrapsample
		program define bootstrapsample, eclass
		
			tempname betas betas1 betas2 betas3 betas4
			
			mat `betas' = J(1000,4,.)
			forvalues i = 1/1000 {
				preserve
					bsample 
					quietly: reg lnelectricity lnsqft lntemp retrofit
					
					mat `betas'[`i',1] = _b[lnsqft] 
					mat `betas'[`i',2] = _b[retrofit]
					mat `betas'[`i',3] = _b[lntemp]
					mat `betas'[`i',4] = _b[_cons]
					di `i' 
				restore
			}
			svmat `betas', name(temp)
				corr temp1 temp2 temp3 temp4, cov 
				mat A = r(C) 
				drop temp1 temp2 temp3 temp4
				
			reg lnelectricity lnsqft lntemp retrofit
			ereturn repost V = A 
		end
		
		bootstrapsample 
		estimates store bootreg2
		
		
		esttab treated controls, cells("b(star pattern(1 1 ) fmt(2))" ci(pattern(1 1))) label nonumbers mtitles("Coefficient" "Marginal Effects")
		
		teffects ra (electricity sqft temp) (retrofit), pomeans vce(bootstrap, reps(1000))
margins, dydx(*)
marginsplot
graph export HW3Q6.pdf, replace
