********************************************************************************
********************************************************************************
********************************************************************************
***************			 Strategic Task Portfolios				****************
***************								Jonghoon Lee		****************
***************								2025/06/30			****************
********************************************************************************
********************************************************************************
********************************************************************************
* This do-file is about analyzing Antitrust workload dataset. 
* Required data set: Master.dta
********************************************************************************
* Settings
clear all

cd "./"
use "./main.dta", clear
cd "./Analysis/"

tsset Year

********************************************************************************
* Figure 3 
* Litigation Compositions over Time
preserve
gen percent1 = p_Criminal 
gen percent2 = p_Criminal + p_nonMciv
gen percent3 =  p_Criminal + p_nonMciv + p_Merger
gen zero = 0
gen upper = 1
gen Year_shifted = Year - 0.5

twoway rarea zero percent1 Year, color(gs4) /// 
    || rarea percent1 percent2 Year, color(gs12) /// 
    || rarea percent2 percent3 Year, color(gs7)  /// 
	||  bar upper Year_shifted if dum_Budget == 1, bcolor(gs9%30) lwidth(none) barwidth(1) ///
    ||, legend(order(1 "Criminal" 2 "Non-Merger" 3 "Merger") cols(3) position(6)) /// 
     xla() ytitle(Litigation Composition) scheme(plotplain) ///
	graphregion(margin(2 2 2 2)) plotregion(margin(2 2 0 0))
graph export "~/Figures/Figure3.pdf", replace
restore

********************************************************************************
* Table 2
* Main Regression Table 
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer, ///
	dvs(p_Criminal p_Merger p_nonMciv) ar(1) ///
	dummy(dum_Budget) sigs(90 95)
estimates store tab1

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal p_Merger p_nonMciv) ar(1) ///
	dummy(President AAG prelection dum_Budget) sigs(90 95)
estimates store tab2

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal p_Merger p_nonMciv) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store tab3

estout tab1 tab2 tab3, unstack ///
		 order(L1_p_Merger_p_Criminal L1_p_nonMciv_p_Criminal dum_Budget President AAG ///
		 prelection diff__Inflation diff__Unemploy diff__eratio  lag__p_Inv_Crim lag__p_Inv_Mer trend) ///
		 starlevels(* 0.10 ** 0.05 *** 0.01) cells("b(fmt(%9.2f)) se(par fmt(%9.2f))" p(fmt(%9.2f))) ///
		 drop(a1976 a1977 a1993) stats(r2 N, fmt(%9.3f %9.0g)) ///
		 varlabels(L1_p_Merger_p_Criminal "$s_{t-1}$" L1_p_nonMciv_p_Criminal "$s_{t-1}$" dum_Budget "Budget Reduction$_t$" ///
		 President "Presidential Partisanship$_t$" AAG "Head Appointment$_t$" prelection "Presidential Election$_t$" ///
		 diff__Inflation "\Delta Inflation Rate$_t$" diff__Unemploy "\Delta Unemployment Rate$_t$" ///
		 diff__eratio "\Delta Professional Composition$_t$" lag__p_Inv_Crim "Criminal Investigation$_{t-1}$" ///
		 lag__p_Inv_Mer "Merger Investigation$_{t-1}$" trend "Trend" _cons "Constant") style(tex)
		 
********************************************************************************
* Figure 4
* Parameter Estimates - Main Model
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal p_Merger p_nonMciv) ar(1) ///
	dummy(President AAG dum_Budget prelection) sigs(95) angle(45) vert killtable
	
* Coefficient Plot
graph use allg_dum_Budget.gph
graph display, scheme(plotplain) 
graph export "~/Figures/Figure4.pdf", replace

********************************************************************************
* Figure 5
* Cumulative Plots - Main Model
dynsimpie l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_nonMciv p_Criminal p_Merger) ar(1) ///
	dummyshockvar(dum_Budget) dummy(President AAG prelection) dummyset(0 0 0)
	
cfbplot
graph export "~/Figures/Figure5.pdf", replace

********************************************************************************
* Figure 6
* Slice the Pie Differently
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(President AAG prelection dum_Budget) sigs(95) angle(45) vert killtable

* Coeffcient Plot
graph use allg_dum_Budget.gph
graph display, scheme(plotplain) 
graph export "~/Figures/Figure6.pdf", replace


********************************************************************************
* Table 3 
* Mean Difference t-Test for Failure rates
ttest FR_m, by(dum_Budget) 
ttest FR_m2, by(dum_Budget)
ttest FR_other, by(dum_Budget)
ttest FR_Mer, by(dum_Budget)
ttest FR_nMer, by(dum_Budget)
ttest FR, by(dum_Budget)



********************************************************************************
********************************************************************************
* Appendix
********************************************************************************
********************************************************************************
* Figure B2
* Litigation Trend over Time 
tsset Year
tsline p_Criminal p_Merger p_nonMciv, legend(order(1 "Criminal" 2 "Merger" 3 "Non-Merger"))

graph export "~/Figures/FigureB2.pdf", replace

********************************************************************************
* Figure B3
* Litigation Compositions in Count over Time

preserve
gen Year_shifted = Year - 0.5
gen upper = 120
gen percent1 = N_Criminal 
gen percent2 = N_Criminal + N_nonMciv
gen percent3 =  N_Criminal + N_nonMciv + N_Merger
gen zero = 0
twoway rarea zero percent1 Year, color(gs4) /// 
    || rarea percent1 percent2 Year, color(gs12) /// 
    || rarea percent2 percent3 Year, color(gs7)  /// 
	||  bar upper Year_shifted if dum_Budget == 1 , bcolor(gs9%30) lwidth(none) barwidth(1) ///
    ||, legend(order(1 "Criminal" 2 "Non-Merger" 3 "Merger") cols(3) position(6)) /// 
     xla() yla(0(50)120) ytitle(Litigation Composition) scheme(plotplain) ///
	graphregion(margin(2 2 2 2)) plotregion(margin(2 2 0 0))
graph export FigureB3.pdf, replace
drop zero percent1 percent2 percent3 upper Year_shifted

graph export "~/Figures/FigureB3.pdf", replace
restore

********************************************************************************
* Table B2
* Summary Statistics
summarize p_Criminal p_Merger p_nonMciv dum_Budget log_Budget p_Inv_Crim p_Inv_Mer ///
	eratio President AAG prelection Inflation Unemploy 

********************************************************************************
* Figure B4
* Cumulative Plots for Different Specifications		 
		 
dynsimpie l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Merger2 p_Criminal2 p_Other2 p_nonMciv2) ar(1) ///
	dummyshockvar(dum_Budget) dummy(President AAG prelection) dummyset(0 0 0)
cfbplot
graph export "~/Figures/FigureB4.pdf", replace

********************************************************************************
* Table B3
* Regression Table for Different Specifications
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(dum_Budget) sigs(90 95)
estimates store tab4

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(President AAG prelection dum_Budget) sigs(90 95)
estimates store tab5

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store tab6

estout tab4 tab5 tab6, unstack ///
		 order(L1_p_Merger2_p_Criminal2 L1_p_nonMciv2_p_Criminal2 L1_p_Other2_p_Criminal2 dum_Budget President AAG ///
		 prelection diff__Inflation diff__Unemploy diff__eratio  lag__p_Inv_Crim lag__p_Inv_Mer trend) ///
		 starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f )) se(par fmt(%9.3f ))) ///
		 drop(a1976 a1977 a1993) stats(r2 N, fmt(%9.3f %9.0g)) style(tex) ///
		 varlabels(L1_p_Merger_p_Criminal "$y_{t-1}$" L1_p_nonMciv_p_Criminal "$y_{t-1}$" dum_Budget "Budget Reduction$_t$" ///
		 President "Presidential Partisanship$_t$" AAG "Head Appointment$_t$" prelection "Presidential Election$_t$" ///
		 diff__Inflation "\Delta Inflation Rate$_t$" diff__Unemploy "\Delta Unemployment Rate$_t$" ///
		 diff__eratio "\Delta Professional Composition$_t$" lag__p_Inv_Crim "Criminal Investigation$_{t-1}$" ///
		 lag__p_Inv_Mer "Merger Investigation$_{t-1}$" trend "Trend" _cons "Constant")
		 
********************************************************************************
* Figure B5a
* Institutional and legal changes 
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal p_Merger p_nonMciv) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store p1 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal p_nonMciv p_Merger) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store p2 
	
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Merger p_nonMciv p_Criminal) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store p3 
	
coefplot (p1, msymbol(O) label(Merger/ Criminal)) ///
		 (p2, msymbol(S) label(Non-Merger/ Criminal)) ///
		 (p3, msymbol(T) label(Non-Merger/ Merger)) ///
	|| , keep(a1976 a1977 a1993) xline(0) levels(95) scheme(plotplain) ///
	mfcolor(white) legend(pos(6) rows(2))
graph export "~/Figures/Figure5a.pdf", replace
		 
********************************************************************************
* Figure B5b
* Institutional and legal changes with Fine-Grained Specification
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store s1 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_nonMciv2 p_Merger2 p_Other2) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store s2 
	
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Other2 p_nonMciv2 p_Merger2) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store s3 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Merger2 p_nonMciv2 p_Criminal2 p_Other2) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store s4 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Merger2 p_Other2 p_nonMciv2 p_Criminal2) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store s5 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_nonMciv2 p_Other2 p_Criminal2 p_Merger2) ar(1) ///
	dummy(President AAG prelection a1976 a1977 a1993 dum_Budget) sigs(90 95)
estimates store s6 

	
coefplot (s1, msymbol(O) label(Merger/ Criminal)) ///
		 (s2, msymbol(S) label(Non-Merger/ Criminal)) ///
		 (s3, msymbol(T) label(Other/ Criminal)) ///
		 (s4, msymbol(D) label(Non-Merger/ Merger)) ///		 
		 (s5, msymbol(+) label(Other/ Merger)) ///
		 (s6, msymbol(X) label(Other/ Non-Merger)) ///
	|| , keep(a1976 a1977 a1993) xline(0) levels(95) scheme(plotplain) ///
	mfcolor(white) legend(pos(6) rows(2))
graph export "~/Figures/FigureB5b.pdf", replace
		 
********************************************************************************
* Figure B6
* Different Specifications of Budget Reduction

* Dummy without CPI Adjustment
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(President AAG prelection dum_Budget_noCPI) sigs(95) angle(45) vert killtable
* Coefficient Plot
graph use allg_dum_Budget_noCPI.gph
graph display, scheme(plotplain) 
graph export "~/Figures/FigureB6a.pdf", replace

* Logged Continuous Budget with CPI Adjustment	
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(President AAG prelection log_Budget) sigs(95) angle(45) vert killtable
* Coefficient Plot
graph use allg_log_Budget.gph
graph display, scheme(plotplain) 
graph export "~/Figures/FigureB6b.pdf", replace	


********************************************************************************
* Figures B7 & 8 
* Interaction between Budget Reduction an Presidential Partisanship

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Merger2 p_nonMciv2 p_Other2) ar(1) ///
	dummy(President AAG prelection dum_Budget partisan_budget) sigs(90 95)
estimates store q1 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_nonMciv2 p_Merger2 p_Other2) ar(1) ///
	dummy(President AAG prelection dum_Budget partisan_budget) sigs(90 95)
estimates store q2 
	
dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Criminal2 p_Other2 p_nonMciv2 p_Merger2) ar(1) ///
	dummy(President AAG prelection dum_Budget partisan_budget) sigs(90 95)
estimates store q3 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Merger2 p_nonMciv2 p_Criminal2 p_Other2) ar(1) ///
	dummy(President AAG prelection dum_Budget partisan_budget) sigs(90 95)
estimates store q4 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Merger2 p_Other2 p_nonMciv2 p_Criminal2) ar(1) ///
	dummy(President AAG prelection dum_Budget partisan_budget) sigs(90 95)
estimates store q5 

dynsimpiecoef l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_nonMciv2 p_Other2 p_Criminal2 p_Merger2) ar(1) ///
	dummy(President AAG prelection dum_Budget partisan_budget) sigs(90 95)
estimates store q6 
	
coefplot (q1, msymbol(O) label(Merger/ Criminal)) ///
		 (q2, msymbol(S) label(Non-Merger/ Criminal)) ///
		 (q3, msymbol(T) label(Other/ Criminal)) ///
		 (q4, msymbol(D) label(Non-Merger/ Merger)) ///		 
		 (q5, msymbol(+) label(Other/ Merger)) ///
		 (q6, msymbol(X) label(Other/ Non-Merger)) ///
	|| , keep(President dum_Budget partisan_budget) xline(0) levels(95) scheme(plotplain) ///
	mfcolor(white) legend(pos(6) rows(2)) ///
	ylabel(1 "Presidential Partisanship" 2 "Budget Reduction" 3 "Interaction Term") 
graph export "~/Figures/FigureB7.pdf", replace

	
* Republican Presidency	
dynsimpie l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Other2 p_Criminal2 p_Merger2 p_nonMciv2) ar(1) ///
	shockvars(dum_Budget) shockvals(1) dummy(AAG prelection) dummyset(0 0) ////
	interaction(President) intype(off)
cfbplot
graph export "~/Figures/FigureB8a.pdf", replace

* Democrat Presidency	
dynsimpie l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend, ///
	dvs(p_Other2 p_Criminal2 p_Merger2 p_nonMciv2) ar(1) ///
	shockvars(dum_Budget) shockvals(1) dummy(AAG prelection) dummyset(0 0) ////
	interaction(President) intype(on)
cfbplot
graph export "~/Figures/FigureB8b.pdf", replace
********************************************************************************
* Table B4
* Granger-Causality Tests and Endogeneity

preserve

* Make DVs.
gen mtoc = ln(p_Merger/ p_Criminal)
gen nmtoc = ln(p_nonMciv/ p_Criminal)
gen nmtom = ln(p_nonMciv/ p_Merger)

* Structural VAR
matrix A = (1,.\0,1)
matrix B = (.,0\0,.)

svar nmtoc dum_Budget, lags(1)  exog(l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend President AAG prelection) aeq(A) beq(B)
vargranger

svar mtoc dum_Budget, lags(1) exog(l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation ///
	d.Unemploy trend President AAG prelection) aeq(A) beq(B)
vargranger

svar nmtom dum_Budget, lags(1)  exog(l.p_Inv_Crim l.p_Inv_Mer d.eratio d.Inflation d.Unemploy trend President AAG prelection) aeq(A) beq(B)
vargranger
restore

********************************************************************************
* Table B5
* Count outcome 

sureg (N_Criminal l.N_Criminal dum_Budget l.Inv_m l.Inv_Mer) ///
	(N_Merger l.N_Merger dum_Budget l.Inv_m l.Inv_Mer) ///
	(N_nonMciv l.N_nonMciv dum_Budget l.Inv_m l.Inv_Mer)
estimates store tab7

sureg (N_Criminal l.N_Criminal dum_Budget President AAG prelection d.Inflation d.Unemploy d.eratio l.Inv_m l.Inv_Mer trend) ///
	(N_Merger l.N_Merger dum_Budget President AAG prelection d.Inflation d.Unemploy d.eratio l.Inv_m l.Inv_Mer trend) ///
	(N_nonMciv l.N_nonMciv dum_Budget President AAG prelection d.Inflation d.Unemploy d.eratio l.Inv_m l.Inv_Mer trend)
estimates store tab8

sureg (N_Criminal l.N_Criminal dum_Budget President AAG prelection d.Inflation d.Unemploy d.eratio l.Inv_m l.Inv_Mer a1976 a1977 a1993 trend) ///
	(N_Merger l.N_Merger dum_Budget President AAG prelection d.Inflation d.Unemploy d.eratio l.Inv_m l.Inv_Mer a1976 a1977 a1993 trend) ///
	(N_nonMciv l.N_nonMciv dum_Budget President AAG prelection d.Inflation d.Unemploy d.eratio l.Inv_m l.Inv_Mer a1976 a1977 a1993 trend)
estimates store tab9

estout tab7 tab8 tab9, ///
		 order(L.N_Criminal L.N_Merger L.N_nonMciv dum_Budget President AAG ///
		 prelection D.Inflation D.Unemploy D.eratio  L.Inv_m L.Inv_Mer trend) ///
		 starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(%9.2f)) se(par fmt(%9.2f))) ///
		 drop(a1976 a1977 a1993) stats(r2 N, fmt(%9.3f %9.0g)) style(tex) ///
		 varlabels(L.N_Criminal "$y_{t-1}$" L.N_Merger "$y_{t-1}$" L.N_nonMciv "$y_{t-1}$" dum_Budget "Budget Reduction$_t$" ///
		 President "Presidential Partisanship$_t$" AAG "Head Appointment$_t$" prelection "Presidential Election$_t$" ///
		 D.Inflation "\Delta Inflation Rate$_t$" D.Unemploy "\Delta Unemployment Rate$_t$" ///
		 D.eratio "\Delta Professional Composition$_t$" L.Inv_m "Criminal Investigation$_{t-1}$" ///
		 L.Inv_Mer "Merger Investigation$_{t-1}$" trend "Trend" _cons "Constant")
