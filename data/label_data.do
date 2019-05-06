*===============================================================================
* Do file to label datasets
* authors: @lrdegeest and @davidckingsley
*===============================================================================

version 15

*===============================================================================
// 1. all treatments data
*===============================================================================
use /Users/LawrenceDeGeest/Desktop/notebook/research/InstitutionalChoice/data/all_treatments_s17, clear
// generate self-type indicator
gen self_type = 1 if low == 1
replace self_type = 2 if middle == 1
replace self_type = 3 if high == 1
// labels
label define self_type 1 "Low" 2 "Middle" 3 "High"
label values self_type self_type
label define observe 0 "Unobserved" 1 "Observed"
label values endow_observe observe
// save
save /Users/LawrenceDeGeest/Desktop/notebook/research/heterogeous_endowments/data/all_treatments_s17_labels, replace

*===============================================================================
// 2. punishment data
*===============================================================================
use /Users/LawrenceDeGeest/Desktop/notebook/research/InstitutionalChoice/data/data_punish_targets, clear
// 1. generate self-type indicator
gen self_type = 1 if low == 1
replace self_type = 2 if middle == 1
replace self_type = 3 if high == 1
// 2. generate target-type indicator
gen target_type = 1 if target_low == 1
replace target_type = 2 if target_med == 1
replace target_type = 3 if target_high == 1
// 3. generate cost of sanctions received
gen target_sanctioncost = target_sanction*4
// 4. labels
label define self_type 1 "Low" 2 "Middle" 3 "High"
label values self_type self_type
label define target_type 1 "Low" 2 "Middle" 3 "High"
label values target_type self_type
label define observe 0 "Unobserved" 1 "Observed"
label values endow_observe observe
// 5. trim and order
keep sanctioncost treatment session period subject_id group_id self_type target_type target_endow contribute target_cont sanction target_sanction endowment profit endow_observe institution target_rank hetero target_sanctioncost gender gpa major economics age semesters
order treatment session group_id subject_id period self_type target_type contribute target_cont sanction target_sanction
sort group_id subject_id period
egen mean_contribute = mean(contribute), by(group_id period)
sort group_id subject_id period
encode gender, gen(gender_id) // 1 = Female, 2 = Male
// 6. save
save /Users/LawrenceDeGeest/Desktop/notebook/research/InstitutionalChoice/data/data_punish_targets_labels, replace
