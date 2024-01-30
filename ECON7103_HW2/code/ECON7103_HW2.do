clear

cd "/Users/sedators/Desktop/ECON7103_2024/phdee-2024-so/ECON7103_HW2/output"
import delimited "/Users/sedators/Desktop/ECON7103_2024/phdee-2024-db-main/homework2/kwh.csv"


*Stata Question 1 
eststo control: quietly estpost summarize electricity sqft temp if retrofit == 0
eststo treatment: quietly estpost summarize electricity sqft temp if retrofit == 1
eststo diff: quietly estpost ttest electricity sqft temp, by(retrofit) unequal
esttab control treatment diff, cells("mean(pattern(1 1 0) fmt(3)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(3)) t(pattern(0 0 1) par fmt(3))") label nonumbers mtitles("Treatment" "Control" "Difference")
esttab control treatment diff, cells("mean(pattern(1 1 0) fmt(3)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(3)) t(pattern(0 0 1) par fmt(3))") label nonumbers mtitles("Treatment" "Control" "Difference")


esttab treatment control diff using HW2Q1.tex, tex cells("mean(pattern(1 1 0) fmt(%9.2fc) label(Mean))  b(star pattern(0 0 1) fmt(%9.2fc) label(Diff.))" "sd(pattern(1 1 0) par label(SD)) p(pattern(0 0 1) par fmt(%9.2fc) label(p-value))") stats(N obs, fmt(%9.0fc) labels("Observations")) starlevels(* 0.05 ** 0.01) mtitles(Treatment Control Difference) label replace prehead({\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{3}{cc}} \hline) prefoot( & & & \\) postfoot(\hline \multicolumn{4}{c}{ ** p$<$0.01, * p$<$0.05} \\ \end{tabular} })
 
 
*Question 2
 
twoway (scatter electricity sqft, sort mcolor(green) msymbol(square)), ytitle(electricity) xtitle(sqft) title(twoway sccaterplot of electricity and sqft)
graph export HW2Q2.pdf, replace

*Question 3
reg electricity sqft retrofit temp
outreg2 using hw2Q3.doc, word dec (3) replace ctitle(model1)
outreg2 using hw2Q3.tex, dec (3) replace ctitle(model1)
