*===============================================================================
* Do file for statistical models in "Endowment Heterogeneity, Incomplete Information & Institutional Choice in Public Good Experiments"
* authors: @lrdegeest and @davidckingsley
*===============================================================================

version 15

use all_treatments_s17_labels, clear

*===============================================================================
* TABLE 2
*===============================================================================
preserve
keep if endow_observe != 2 & period == 10
qui eststo m_all: probit vote exo_earn_diff i.endow_observe, vce(cluster group_id)
forvalues i = 1/3 {
	qui eststo m_`i': probit vote exo_earn_diff i.endow_observe if self_type == `i', vce(cluster group_id)
	//margins
	//margins, dydx(endow_observe)
}
restore
esttab m_all m_1 m_2 m_3 using voting_regs.tex, replace /// 
	varlabels(exo_earn_diff "Earning Difference" 1.endow_observe Observed ) ///
	drop(0.endow_observe) //
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars nomtitles booktabs ///
	label legend  ///
	collabels(none) ///
	addnotes("Standard errors clustered at the group level.") 

*===============================================================================
* TABLE 3
*===============================================================================
preserve
gen others_cont = sumc - contribute
keep if institution == 1 & period < 10 & endow_observe != 2
local endowments 10 20 30
local n : word count `endowments'
forvalues i = 1/`n' {
	local t : label self_type `i'
	local j : word `i' of `endowments'
	di "Results for `t':"
	qui eststo m_`i': reg profit contribute others_cont i.endow_observe exo_period  if self_type == `i', vce(cluster group_id)
	margins, dydx(endow_observe) atmeans
	qui eststo m_`i'_interact: reg profit c.contribute##i.endow_observe exo_period others_cont if self_type == `i', vce(cluster group_id)
	margins, dydx(contribute) at(endow_observe = (0 1))
	margins, dydx(endow_observe) atmeans 
	if `j' < 30 {
		qui eststo margins_`j': margins i.endow_observe, at(contribute = (0(1)`j'))
	} 
	else {
		qui eststo margins_`j': margins i.endow_observe, at(contribute = (0(5)`j'))
	}
	di ""
}
restore
esttab m_1 m_1_interact m_2 m_2_interact m_3 m_3_interact using profit_regs_pp.tex, replace /// 
	varlabels(exo_period Period contribute Contribute others_cont "Others contribution" _cons Constant endow_observe Observed 1.endow_observe#c.contribute "Information X Observed") ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("Low" "Middle" "High", pattern(1 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	addnotes("Standard errors clustered at the group level.") 

*===============================================================================
* TABLE 4
*===============================================================================
preserve
gen others_cont = sumc - contribute
keep if institution == 1 & period < 10 & endow_observe != 2
local endowments 10 20 30
local n : word count `endowments'
forvalues i = 1/`n' {
	local t : label self_type `i'
	local j : word `i' of `endowments'
	di "Results for `t':"
	qui eststo m_`i': reg sanctioncost contribute others_cont i.endow_observe exo_period  if self_type == `i', vce(cluster group_id)
	margins, dydx(endow_observe) atmeans
	qui eststo m_`i'_interact: reg sanctioncost c.contribute##i.endow_observe exo_period others_cont if self_type == `i', vce(cluster group_id)
	margins, dydx(contribute) at(endow_observe = (0 1))
	margins, dydx(endow_observe) atmeans 
	if `j' < 30 {
		qui eststo margins_`j': margins i.endow_observe, at(contribute = (0(1)`j'))
	} 
	else {
		qui eststo margins_`j': margins i.endow_observe, at(contribute = (0(5)`j'))
	}
	di ""
}
restore
esttab m_1 m_1_interact m_2 m_2_interact m_3 m_3_interact using sanctioncost_regs_pp.tex, replace /// 
	varlabels(exo_period Period contribute Contribute others_cont "Others contribution" _cons Constant endow_observe Observed 1.endow_observe#c.contribute "Information X Observed") ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("Low" "Middle" "High", pattern(1 0 1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	addnotes("Standard errors clustered at the group level.") 

	
*===============================================================================
* PUNISHMENT TARGETING
*===============================================================================
	
*=======================================
* SET UP
use "/Users/LawrenceDeGeest/Desktop/notebook/research/InstitutionalChoice/data/data_punish_targets_labels.dta", clear
* just PP+exogenous observations
keep if institution == 1 & period < 10 & endow_observe != 2
* proportion variables for sender and target
gen self_prop= 100*(contribute/endowment)
gen target_prop= 100*(target_cont/target_endow)
* negative (absolute) and positive deviations
gen neg_dev = abs(cond(target_prop < self_prop, target_prop - self_prop, 0))
gen pos_dev = cond(target_prop > self_prop, target_prop - self_prop, 0)
*=======================================

*=======================================
* REGRESSIONS
xtset subject_id
global controls mean_cont neg_dev pos_dev gender_id gpa economics
global interactions i.self_type#c.neg_dev i.self_type#c.pos_dev
** 1. Observed
qui eststo m1: xtprobit target_sanction $controls if endow_observe == 1, re vce(cluster group_id)
qui eststo m12: xtprobit target_sanction $controls $interactions if endow_observe == 1, re vce(cluster group_id)

** 2. Unobserved
qui eststo m2: xtprobit target_sanction $controls if endow_observe == 0, re vce(cluster group_id)
qui eststo m22: xtprobit target_sanction $controls $interactions if endow_observe == 0, re vce(cluster group_id)


** table
esttab m1 m12 m2 m22 using targeting.tex, replace /// 
	varlabels(	mean_contribute "Avg. Contribution" neg_dev "Neg. Dev" pos_dev "Pos. Dev" ///
				2.self_type#c.neg_dev "Neg. Dev x Self: Middle" 2.self_type#c.pos_dev "Pos. Dev x Self: Middle" ///
				3.self_type#c.neg_dev "Neg. Dev x Self: High" 3.self_type#c.pos_dev "Pos. Dev x Self: High" ///
				gender_id "Gender" gpa "GPA" economics "#EconClasses" _cons "Constant" ///
			) /// 
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("Observed" "Unobserved", pattern(1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	drop(1.self_type#c.neg_dev 1.self_type#c.pos_dev) ///
	addnotes("Standard errors clustered at the group level.") 

*=======================================
