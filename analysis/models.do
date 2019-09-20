*===============================================================================
* Do file for models in "Endowment Heterogeneity, Incomplete Information & Institutional Choice in Public Good Experiments"
* authors: @lrdegeest and @davidckingsley
*===============================================================================

* set up
version 15
set scheme lean2
use all_treatments_s17_labels, clear
global dem_controls male semesters economics

capture program drop print_ame
program define print_ame
	local partial = el(r(b),1,1)
	local stderror = sqrt(el(r(V), 1, 1))
	local tstat  = `partial'  / `stderror'
	di as text "AME = " as result %9.2f `partial' 		
	di as text "standard error = " as result %9.2f `stderror'
	di as text "p-value = " as result %9.2f 2*ttail(e(df_r),abs(`tstat'))
end	

*===============================================================================
* Table 1 (summary)
*===============================================================================
table endow_observe institution if period <10, ///
	c(mean mean_earn_group_phase sd mean_earn_group_phase) ///
	format(%9.2f) center
*===============================================================================

*===============================================================================
* Tables B6 and B7 (initial and final profits)
*===============================================================================
preserve
keep if period < 10 
replace exo_period = period if institution == 0
levelsof institution, local(institutions)
foreach i in `institutions' {
	// all periods within an institution (exo_period = 1 2 3)
	qui eststo m`i': reg profit ib2.endow_observe $dem_controls if institution == `i', vce(cluster group_id)
	qui eststo m`i'_initial: reg stage1profit ib2.endow_observe  $dem_controls if institution == `i', vce(cluster group_id)
	// last periods within an institution (exo_period = 3)
	qui eststo m`i'_last: reg profit ib2.endow_observe $dem_controls if institution == `i' & exo_period == 3, vce(cluster group_id)
	qui eststo m`i'_initial_last: reg stage1 ib2.endow_observe $dem_controls if institution == `i' & exo_period == 3, vce(cluster group_id)
}
restore

* table of final payoff regs
esttab m0 m1 m2 m0_last m1_last m2_last using finalprofit_appendix.tex, replace /// 
	varlabels(0.endow_observe "Unobserved" 1.endow_observe "Observed" _cons "Constant") /// 
	stats(N r2_a, fmt(0 3) labels("N" "Adjusted R-squared")) ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars  booktabs ///
	mtitles("VCM" "PP" "CA" "VCM" "PP" "CA") ///
	mgroups("All Periods" "Last Period", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	drop(2.endow_observe) ///
	indicate("Demographics Controls" = male semesters economics) ///
	addnotes(	"Demographic controls: Gender (Male/Female), number of undergraduate semesters, and" /// 
				"number of undergraduate economics classes." ///
				"Standard errors clustered at the group level." ) 

* table of initial payoff regs
esttab 	m0_initial m1_initial m2_initial ///
		m0_initial_last m1_initial_last m2_initial_last ///
		using initialprofit_appendix.tex, replace /// 
			varlabels(0.endow_observe "Unobserved" 1.endow_observe "Observed" _cons "Constant") /// 
			stats(N r2_a, fmt(0 3) labels("N" "Adjusted R-squared")) ///
			cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
			numbers nodepvars  booktabs ///
			mtitles("VCM" "PP" "CA" "VCM" "PP" "CA") ///
			mgroups("All Periods" "Last Period", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
			label legend  ///
			collabels(none) ///
			drop(2.endow_observe) ///
			indicate("Demographics Controls" = male semesters economics) ///
			addnotes(	"Demographic controls: Gender (Male/Female), number of undergraduate semesters, and" /// 
				"number of undergraduate economics classes." ///
				"Standard errors clustered at the group level." ) 

			
*===============================================================================
* TABLE 2 (voting)
*===============================================================================
use all_treatments_s17_labels, clear
preserve
keep if endow_observe != 2
qui eststo m_all: probit vote exo_earn_diff i.endow_observe, vce(cluster group_id)
local base_controls exo_earn_diff 1.endow_observe
qui eststo mall: probit vote `base_controls' $dem_controls if period == 10, vce(cluster group_id)
qui eststo mall_phase: probit vote `base_controls' $dem_controls 1.phase5 1.phase6, vce(cluster group_id)
forvalues i = 1/3 {
	qui eststo m`i': probit vote  `base_controls' $dem_controls if self_type == `i' & period == 10, vce(cluster group_id)
	qui eststo m`i'_phase: probit vote `base_controls' $dem_controls 1.phase5 1.phase6  if self_type == `i', vce(cluster group_id)
}	
restore
esttab mall m1 m2 m3 mall_phase m1_phase m2_phase m3_phase using voting_reg_updated.tex, replace /// 
	varlabels(	exo_earn_diff "Earning Difference" 1.endow_observe Observed /// 
				1.phase5 "Phase 5 Vote" 1.phase6 "Phase 6 Vote" ///
				_cons "Constant") ///
	stats(N r2_p, fmt(0 3) labels("N" "Pseudo R-squared")) ///			
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	mgroups("First Vote" "All Votes", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	numbers nodepvars booktabs ///
	mtitle("All" "Low" "Middle" "High" "All" "Low" "Middle" "High") ///
	label legend  ///
	collabels(none) ///
	indicate("Demographics Controls" = male semesters economics) ///
	addnotes(	"Demographic controls: Gender (Male/Female), number of undergraduate semesters, and" /// 
				"number of undergraduate economics classes." ///
				"Standard errors clustered at the group level." ) 



*===============================================================================
* Table 3 (profits)
*===============================================================================
preserve
gen others_cont = sumc - contribute
keep if institution == 1 & period < 10 & endow_observe != 2
local dem_controls male semesters economics
local base_controls contribute others_cont i.endow_observe exo_period
local interaction c.contribute#i.endow_observe
forvalues i = 1/3 {
	qui eststo m`i': reg profit `base_controls' $dem_controls if self_type == `i', vce(cluster group_id)
	qui eststo m`i'_interact: reg profit `base_controls' `interaction' $dem_controls if self_type == `i', vce(cluster group_id)
	if `i' == 1 {
		// AME of contribution
		di as text "AME of contribution for Low" 
		qui margins, dydx(contribute) at(endow_observe = 1)
		print_ame
		// AME of treatment at focal contributions
		qui margins, dydx(endow_observe) at(contribute=(0 5 10))
		qui marginsplot, title("Low") xtitle("Contribution") ytitle("Predicted difference in earnings") ylabel(,nogrid) ///
					 ciopt(lcolor(%0) fcolor(%10)) recastci(rarea) ///
					 plotopts(msymbol(O) msize(2) lwidth(*2) ) ///
					 legend(off) yline(0, lcolor(red)) name(pi_low, replace) nodraw
		di " "
	}
	else if `i' == 2 {
		// AME of contribution
		di as text "AME of contribution for Middle"
		qui margins, dydx(contribute) at(endow_observe = 1)
		print_ame
		// AME of treatment at focal contributions
		qui margins, dydx(endow_observe) at(contribute=(0 10 20))
		qui marginsplot, title("Middle") xtitle("Contribution") ytitle("Predicted difference in earnings") ylabel(,nogrid) ///
					 ciopt(lcolor(%0) fcolor(%10)) recastci(rarea) ///
					 plotopts(msymbol(O) msize(2) lwidth(*2) ) ///
					 legend(off) yline(0, lcolor(red)) name(pi_middle, replace) nodraw
		di " "
	}
	else if `i' == 3 {
		// AME of contribution
		di as text "AME of contribution for High"
		qui margins, dydx(contribute) at(endow_observe = 1)
		print_ame
		// AME of treatment at focal contributions
		qui margins, dydx(endow_observe) at(contribute=(0 10 20 30)) 
		qui marginsplot, title("High") xtitle("Contribution") ytitle("Predicted difference in earnings") ylabel(,nogrid) ///
					 ciopt(lcolor(%0) fcolor(%10)) recastci(rarea) ///
					 plotopts(msymbol(O) msize(2) lwidth(*2) ) ///
					 legend(off) yline(0, lcolor(red)) name(pi_high, replace) nodraw
		di " "
	}			
}
restore
* figure
gr combine pi_low pi_middle pi_high, ycommon cols(3) ///
	ysize(2.5) graphregion(margin(zero))
* table
esttab m1 m1_interact m2 m2_interact m3 m3_interact using profit_regs_pp_updated.tex, replace /// 
	varlabels(exo_period Period contribute Contribute others_cont "Others contribution" _cons Constant endow_observe Observed 1.endow_observe#c.contribute "Observed X Contribute") ///
	stats(N r2_a, fmt(0 3) labels("N" "Adjusted R-squared")) ///		
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("Low" "Middle" "High", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	drop(0.endow_observe 0.endow_observe#c.contribute) ///
	indicate("Demographics Controls" = male semesters economics) ///
	addnotes(	"Demographic controls: Gender (Male/Female), number of undergraduate semesters, and" /// 
				"number of undergraduate economics classes." ///
				"Standard errors clustered at the group level." ) 

*===============================================================================
	

*===============================================================================
* Table 4 (sanctions)
*===============================================================================
preserve
gen others_cont = sumc - contribute
keep if institution == 1 & period < 10 & endow_observe != 2
local dem_controls male semesters economics
local base_controls contribute others_cont i.endow_observe exo_period
local interaction c.contribute#i.endow_observe
forvalues i = 1/3 {
	qui eststo m`i': reg sanctioncost `base_controls' $dem_controls if self_type == `i', vce(cluster group_id)
	qui eststo m`i'_interact: reg sanctioncost `base_controls' `interaction' $dem_controls if self_type == `i', vce(cluster group_id)
	if `i' == 1 {
		// AME of contribution
		di as text "AME of contribution for Low" 
		qui margins, dydx(contribute) at(endow_observe = 1)
		print_ame
		// AME of treatment at focal contributions
		qui margins, dydx(endow_observe) at(contribute=(0 5 10))
		qui marginsplot, title("Low") xtitle("Contribution") ytitle("Predicted difference in punishment") ylabel(,nogrid) ///
					 ciopt(lcolor(%0) fcolor(%10)) recastci(rarea) ///
					 plotopts(msymbol(O) msize(2) lwidth(*2) ) ///
					 legend(off) yline(0, lcolor(red)) name(s_low, replace) nodraw
		di " "
	}
	else if `i' == 2 {
		// AME of contribution
		di as text "AME of contribution for Low" 
		qui margins, dydx(contribute) at(endow_observe = 1)
		print_ame
		// AME of treatment at focal contributions
		qui margins, dydx(endow_observe) at(contribute=(0 10 20))
		qui marginsplot, title("Middle") xtitle("Contribution") ytitle("Predicted difference in punishment") ylabel(,nogrid) ///
					 ciopt(lcolor(%0) fcolor(%10)) recastci(rarea) ///
					 plotopts(msymbol(O) msize(2) lwidth(*2) ) ///
					 legend(off) yline(0, lcolor(red)) name(s_middle, replace) nodraw
		di " "
	}
	else if `i' == 3 {
		// AME of contribution
		di as text "AME of contribution for Low" 
		qui margins, dydx(contribute) at(endow_observe = 1)
		print_ame
		// AME of treatment at focal contributions
		qui margins, dydx(endow_observe) at(contribute=(0 10 20 30)) 
		qui marginsplot, title("High") xtitle("Contribution") ytitle("Predicted difference in punishment") ylabel(,nogrid) ///
					 ciopt(lcolor(%0) fcolor(%10)) recastci(rarea) ///
					 plotopts(msymbol(O) msize(2) lwidth(*2) ) ///
					 legend(off) yline(0, lcolor(red)) name(s_high, replace) nodraw
		di " "
	}			
}
restore
* figure
gr combine s_low s_middle s_high, ycommon cols(3) ///
	ysize(2.5) graphregion(margin(zero))
* table
esttab m1 m1_interact m2 m2_interact m3 m3_interact using sanctioncost_regs_pp_updated.tex, replace /// 
	stats(N r2_a, fmt(0 3) labels("N" "Adjusted R-squared")) ///		
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("Low" "Middle" "High", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	drop(0.endow_observe 0.endow_observe#c.contribute) ///
	indicate("Demographics Controls" = male semesters economics) ///
	addnotes(	"Demographic controls: Gender (Male/Female), number of undergraduate semesters, and" /// 
				"number of undergraduate economics classes." ///
				"Standard errors clustered at the group level." ) 	
*===============================================================================


*===============================================================================
* Table D8 (profits and sanctions)
*===============================================================================
preserve
gen others_cont = sumc - contribute
keep if institution == 1 & period < 10 & endow_observe == 0 & contribute < 11
qui eststo m_profit_appendix: reg profit i.self_type##c.contribute others_cont $dem_controls, vce(cluster group_id)
qui eststo m_sanction_appendix: reg sanctioncost i.self_type##c.contribute others_cont $dem_controls, vce(cluster group_id)
restore
esttab m_profit_appendix m_sanction_appendix using profit_sanction_regs_appendix.tex, replace /// 
	varlabels(	exo_period Period contribute Contribute others_cont "Others contribution"  ///
				_cons Constant 2.self_type Middle 3.self_type High  ///
				2.self_type#c.contribute  "Middle X Contribute" 3.self_type#c.contribute "High X Contribute") /// 
    stats(N r2_a, fmt(0 3) labels("N" "Adjusted R-squared")) ///		
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars booktabs ///
	mtitles("Earnings" "Sanctions") ///
	label legend  ///
	collabels(none) ///
	drop(1.self_type 1.self_type#c.contribute) ///
	indicate("Demographics Controls" = male semesters economics) ///
	addnotes(	"Data include contributions less than or equal to 10." ///
				"Demographic controls: Gender (Male/Female), number of undergraduate semesters, and" /// 
				"number of undergraduate economics classes." ///
				"Standard errors clustered at the group level.")
*===============================================================================


*===============================================================================
* Targeting (reviewer comments)
*===============================================================================
	
*=======================================
* SET UP
use data_punish_targets_labels.dta, clear
* just PP+exogenous observations
preserve
keep if institution == 1 & period < 10 & endow_observe != 2
* negative (absolute) and positive deviations
gen neg_dev = abs(cond(target_cont < contribute, target_cont - contribute, 0))
gen pos_dev = cond(target_cont > contribute, target_cont - contribute, 0)
*=======================================

*=======================================
* REGRESSIONS
xtset subject_id
global controls mean_cont neg_dev pos_dev i.self_type gender_id semesters economics
global interactions i.self_type#c.neg_dev i.self_type#c.pos_dev
** 1. Observed
qui eststo m1: xtprobit target_sanction $controls if endow_observe == 1, re vce(cluster group_id)
qui eststo m12: xtprobit target_sanction $controls $interactions if endow_observe == 1, re vce(cluster group_id)
** 2. Unobserved
qui eststo m2: xtprobit target_sanction $controls if endow_observe == 0, re vce(cluster group_id)
qui eststo m22: xtprobit target_sanction $controls $interactions if endow_observe == 0, re vce(cluster group_id)
*=======================================
restore
** table
esttab m1 m12 m2 m22 using targeting.tex, replace /// 
	varlabels(	mean_contribute "Avg. Contribution" neg_dev "Neg. Dev" pos_dev "Pos. Dev" ///
				2.self_type#c.neg_dev "Neg. Dev x Sender: Middle" 2.self_type#c.pos_dev "Pos. Dev x Sender: Middle" ///
				3.self_type#c.neg_dev "Neg. Dev x Sender: High" 3.self_type#c.pos_dev "Pos. Dev x Sender: High" ///
				gender_id "Gender" gpa "GPA" economics "#EconClasses" _cons "Constant" ///
				2.self_type "Sender: Middle" 3.self_type "Sender: High" ///
			) /// 
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("Observed" "Unobserved", pattern(1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	drop(1.self_type 1.self_type#c.neg_dev 1.self_type#c.pos_dev) ///
	indicate("Demographics Controls" = gender_id semesters economics) ///
	addnotes("Standard errors clustered at the group level.") 
