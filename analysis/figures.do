*===============================================================================
// Do file for figures in "Endowment Heterogeneity, Incomplete Information & Institutional Choice in Public Good Experiments"
// authors: @lrdegeest and @davidckingsley
*===============================================================================
version 15
set scheme lean2

*===============================================================================
* FIGURE 2
*===============================================================================
use all_treatments_s17_labels, clear
preserve
gen did_vote = 1 if period == 10 | period == 13 | period == 16
replace did_vote = 0 if did_vote == .
label define vote 0 "PP" 1 "CA"
label values vote vote
label values formal vote
label define endow 0 "Unobs." 1 "Obs."  2 "Equal"
label values endow_observe endow
catplot formal endow_observe if did_vote == 1 & indnum == 1, percent(endow_observe) asyvars ylabel(,nogrid) ///	
	bar(1, bcolor(white) lcolor(black)) bar(2, bcolor(black)) stack  ///
	ytitle("Percent of total") subtitle("{bf:A}", ring(0) pos(10) size(large)) ///
	yline(50,lcolor(red)) name(vote_total, replace) legend(cols(2)) nodraw
catplot vote endow_observe if did_vote == 1, asyvars percent(self_type endow_observe) over(self_type) ylabel(,nogrid) ///
	bar(1, bcolor(white) lcolor(black)) bar(2, bcolor(black)) stack ///
	ytitle("Percent of total") subtitle("{bf:B}", ring(0) pos(10) size(large)) ///
	yline(50,lcolor(red)) name(vote_type, replace) recast(bar)  nodraw	
grc1leg vote_total vote_type, legendfrom(vote_total) 
restore

*===============================================================================
* FIGURE 3
*===============================================================================
preserve
gen percent_contribute = 100*(contribute/endowment)
keep if institution == 1 & period < 10 & hetero == 1 & endow_observe != 2
cibar contribute, ///
	over1(self_type) over2(endow_observe) ///
	barcolor(gray*0.33 gray*0.66 gray) ///
	ciopts(lcolor(black)) ///
	graphopts( ///
		legend(cols(3)) ytitle("Contribution") ylabel(0(5)30,nogrid) ///
		subtitle("{bf:A}", ring(0) pos(10) size(large)) ///
		name(contribute, replace) nodraw)
cibar percent_contribute, ///
	over1(self_type) over2(endow_observe) ///
	barcolor(gray*0.33 gray*0.66 gray) ///
	ciopts(lcolor(black)) ///
	graphopts( ///
		legend(cols(3)) ytitle("Contribution (% of endowment)") ylabel(0(20)100,nogrid) ///
		subtitle("{bf:B}", ring(0) pos(10) size(large)) ///
		name(percent_contribute, replace) nodraw)		
cibar profit, ///
	over1(self_type) over2(endow_observe) ///
	barcolor(gray*0.33 gray*0.66 gray) ///
	ciopts(lcolor(black)) ///
	graphopts( ///
		ytitle("Payoff") ylabel(,nogrid) ///
		subtitle("{bf:C}", ring(0) pos(10) size(large)) ///
		name(payoff, replace) nodraw)
restore		
grc1leg contribute percent_contribute payoff, cols(3) name(contribution_payoff, replace)
graph display contribution_payoff, xsize(9.0) ysize(4.0)


*===============================================================================
* FIGURE 4
*===============================================================================
use data_punish_targets_labels, clear
preserve
keep if institution == 1 & target_rank != 0 & hetero == 1
cibar target_sanction if period < 10, ///
	over1(self_type) over2(endow_observe) ///
	barcolor(gray*0.33 gray*0.66 gray) ///
	ciopts(lcolor(black)) ///
	graphopts( ///
		legend(cols(3)) ytitle("Average sanction sent") ylabel(0(0.5)4,nogrid) ///
		subtitle("{bf:A}", ring(0) pos(10) size(large)) ///
		name(senders, replace) nodraw)
cibar target_sanctioncost if period < 10, ///
	over1(target_type) over2(endow_observe) ///
	barcolor(gray*0.33 gray*0.66 gray) ///
	ciopts(lcolor(black)) ///
	graphopts( ///
		ytitle("Average sanction received") ylabel(0(0.5)4,nogrid) ///
		subtitle("{bf:B}", ring(0) pos(10) size(large)) ///
		name(receivers, replace) nodraw)		
restore
grc1leg senders receivers, ycommon legendfrom(senders) 
