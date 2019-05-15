*===============================================================================
* Do file for statistical models in "Endowment Heterogeneity, Incomplete Information & Institutional Choice in Public Good Experiments"
* authors: @lrdegeest and @davidckingsley
*===============================================================================

version 15

*===============================================================================
* TABLE 3
*===============================================================================
use all_treatments_s17_labels, clear
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
use all_treatments_s17_labels, clear
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
