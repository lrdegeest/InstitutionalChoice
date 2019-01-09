//==============================================================================
// Statistical tests for "Endowment Heterogeneity, Incomplete Information & Institutional Choice in Public Good Experiments"
// authors: @lrdegeest and @davidckingsley
//==============================================================================

use all_treatments_s17_labels, clear

//==============================================================================
// TABLE 1
//==============================================================================
table endow_observe institution if period <10, c(mean mean_earn_group_phase sd mean_earn_group_phase)
kwallis mean_earn_group_phase	if institution == 0 & period == 1 & indnum == 1, by(endow_observe)
kwallis exo_fs_earn   			if period == 18 & indnum == 1, by(endow_observe)
kwallis exo_fs_earn_late		if period == 18 & indnum == 1, by(endow_observe)
kwallis exo_is_earn   			if period == 18 & indnum == 1, by(endow_observe)
kwallis exo_is_earn_late		if period == 18 & indnum == 1, by(endow_observe)
ranksum	  exo_is_earn			if period == 18 & indnum == 1 & endow_observe == 2 | period == 18 & indnum == 1 & endow_observe == 1, by(homo)
ranksum	  exo_is_earn			if period == 18 & indnum == 1 & endow_observe == 2 | period == 18 & indnum == 1 & endow_observe == 0, by(homo)
ranksum	  exo_is_earn			if period == 18 & indnum == 1 & homo == 0, by(endow_observe)

//==============================================================================
// FIGURE 2
//==============================================================================
tab formal endow_observe if period == 10 & indnum == 1 & endow_observe == 2 | period == 10 & indnum == 1 & endow_observe == 0 | ///
							period == 13 & indnum == 1 & endow_observe == 2 | period == 13 & indnum == 1 & endow_observe == 0 | ///
							period == 16 & indnum == 1 & endow_observe == 2 | period == 16 & indnum == 1 & endow_observe == 0, chi2
							
tab formal endow_observe if period == 10 & indnum == 1 & endow_observe == 0 | period == 10 & indnum == 1 & endow_observe == 1 | ///
							period == 13 & indnum == 1 & endow_observe == 0 | period == 13 & indnum == 1 & endow_observe == 1 | ///
							period == 16 & indnum == 1 & endow_observe == 0 | period == 16 & indnum == 1 & endow_observe == 1, chi2

tab formal endow_observe if period == 10 & indnum == 1 & endow_observe == 2 | period == 10 & indnum == 1 & endow_observe == 1 | ///
							period == 13 & indnum == 1 & endow_observe == 2 | period == 13 & indnum == 1 & endow_observe == 1 | ///
							period == 16 & indnum == 1 & endow_observe == 2 | period == 16 & indnum == 1 & endow_observe == 1, chi2

tab vote endow_observe if period == 10 & low == 1 & endow_observe == 0 | period == 10 & low == 1 & endow_observe == 1 | ///
						period == 13 & low == 1 & endow_observe == 0 | period == 13 & low == 1 & endow_observe == 1 | ///
						period == 16 & low == 1 & endow_observe == 0 | period == 16 & low == 1 & endow_observe == 1, chi2

tab vote endow_observe if period == 10 & middle == 1 & endow_observe == 0 | period == 10 & middle == 1 & endow_observe == 1 | ///
						period == 13 & middle == 1 & endow_observe == 0 | period == 13 & middle == 1 & endow_observe == 1 | ///
						period == 16 & middle == 1 & endow_observe == 0 | period == 16 & middle == 1 & endow_observe == 1, chi2						

tab vote endow_observe if period == 10 & high == 1 & endow_observe == 0 | period == 10 & high == 1 & endow_observe == 1 | ///
						period == 13 & high == 1 & endow_observe == 0 | period == 13 & high == 1 & endow_observe == 1 | ///
						period == 16 & high == 1 & endow_observe == 0 | period == 16 & high == 1 & endow_observe == 1, chi2

//==============================================================================
// FIGURE 3	
//==============================================================================
ranksum	  exo_is_cont				   if period == 18 & indnum == 1 & homo == 0, by(endow_observe)
ranksum	  exo_is_earn				   if period == 18 & indnum == 1 & homo == 0, by(endow_observe)
ranksum	  exo_is_cont_high			   if period == 18 & indnum == 4 & homo == 0, by(endow_observe)
ranksum	  exo_is_cont_middle		   if period == 18 & indnum == 3 & homo == 0, by(endow_observe)
ranksum	  exo_is_cont_low			   if period == 18 & indnum == 1 & homo == 0, by(endow_observe)
ranksum	  exo_is_earn_high			   if period == 18 & indnum == 4 & homo == 0, by(endow_observe)
ranksum	  exo_is_earn_middle		   if period == 18 & indnum == 3 & homo == 0, by(endow_observe)
ranksum	  exo_is_earn_low			   if period == 18 & indnum == 1 & homo == 0, by(endow_observe)

//==============================================================================
// ORDER EFFECTS (APPENDIX)
//==============================================================================
ranksum	  exo_is_earn				   if period == 18 & indnum == 1 & endow_observe == 0, by(treatment)
ranksum	  exo_fs_earn				   if period == 18 & indnum == 1 & endow_observe == 0, by(treatment)
ranksum	  exo_is_earn				   if period == 18 & indnum == 1 & endow_observe == 1, by(treatment)
ranksum	  exo_fs_earn				   if period == 18 & indnum == 1 & endow_observe == 1, by(treatment)
