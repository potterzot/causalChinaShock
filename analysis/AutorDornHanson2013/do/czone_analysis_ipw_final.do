***********************************************
* Impact of Chines Imports on Local Labor Markets
***********************************************

* David Dorn, July 28, 2010
* Final version, April 11, 2012

* Input file: workfile9007.dta

* This file creates the results for Tables 2-10, Appendix Tables 1-5


***********************************************
* Administrative Commands
***********************************************

cap log close                       
set more off                        
clear                             
set memory 500m                   

log using ../log/czone_analysis_ipw_final.log, replace text

use ../dta/workfile_china.dta, clear


******************************************************************************************************************************************************************************************
* Appendix Table 1: Imports per Worker
******************************************************************************************************************************************************************************************

* Growth in Chinese imports per worker, U.S. (in 1000 USD/worker)
by yr, sort: summ d_tradeusch_pw [aw=timepwt48], detail

* Dummy for 40 largest CZs (1990 pop)
gen pop1990=l_popcount*(yr==1990)
gsort -pop1990
gen pop40=(_n<=40)
by czone, sort: egen top40=sum(pop40)
save temp.dta, replace

* Largest and smalles exposure, top 40 cities, 1990s
keep if top40==1 & yr==1990

gsort -d_tradeusch_pw
foreach v in 1 2 3 4 5 6 7 8 9 10 20 21 31 32 33 34 35 36 37 38 39 40 {
   tab city if _n==`v'
   summ d_tradeusch_pw if _n==`v'
}

* Largest and smalles exposure, top 40 cities, 2000s
use temp.dta, clear

keep if top40==1 & yr==2000

gsort -d_tradeusch_pw
foreach v in 1 2 3 4 5 6 7 8 9 10 20 21 31 32 33 34 35 36 37 38 39 40 {
   tab city if _n==`v'
   summ d_tradeusch_pw if _n==`v'
}

use temp.dta, clear
erase temp.dta

* Additional information: Relationship between China exposure and manufacturing share
reg d_tradeusch_pw l_shind_manuf_cbp [aw=timepwt48] if yr==1990, cluster(statefip)
reg d_tradeusch_pw l_shind_manuf_cbp [aw=timepwt48] if yr==2000, cluster(statefip)


******************************************************************************************************************************************************************************************
* Appendix Table 2: Descriptive Statistics
******************************************************************************************************************************************************************************************

* Growth in Chinese imports per worker, U.S. (in 1000 USD/worker)
by yr, sort: summ d_tradeusch_pw [aw=timepwt48]

* Create rebased per-worker level variables
by czone, sort: egen l_no_workers_totcbp_1990=total(l_no_workers_totcbp*(yr==1990))
by czone, sort: egen l_no_workers_totcbp_2000=total(l_no_workers_totcbp*(yr==2000))
foreach v in usch otch {
   * year-2000 imports relative to 1990 workforce
   gen x=l_trade`v'_pw*l_no_workers_totcbp/l_no_workers_totcbp_1990*(yr==2000)
   by czone, sort: egen l_trade`v'_pw90_2000=total(x)
   drop x
   * year-2007 imports relative to 2000 workforce
   gen l_trade`v'_pw00_2007=l_trade`v'_pw+d_trade`v'_pw*0.7
   * year-2007 imports relative to 1990 workforce
   gen l_trade`v'_pw90_2007=l_trade`v'_pw00_2007*l_no_workers_totcbp/l_no_workers_totcbp_1990*(yr==2000)
   * year-1991 imports relative to 2000 workforce
   gen l_trade`v'_pw00_1991=l_trade`v'_pw*l_no_workers_totcbp_1990/l_no_workers_totcbp_2000*(yr==1990)
}

* Summary stats: 1991/2000/2007 imports relative to 1990 workforce
summ l_tradeusch_pw if yr==1990 [aw=timepwt48]
summ l_tradeusch_pw90_2000 if yr==2000 [aw=timepwt48]
summ l_tradeusch_pw90_2007 if yr==2000 [aw=timepwt48]

* Summary stats: 1991/2000/2007 imports relative to 2000 workforce
summ l_tradeusch_pw00_1991 if yr==1990 [aw=timepwt48]
summ l_tradeusch_pw if yr==2000 [aw=timepwt48]
summ l_tradeusch_pw00_2007 if yr==2000 [aw=timepwt48]

* Changes and levels of main outcome variables
gen l_popcount_2007=l_popcount+0.7*d_popcount
foreach z in sh_empl sh_empl_mfg sh_empl_nmfg sh_unempl sh_nilf sh_ssadiswkrs avg_lnwkwage_mfg avg_lnwkwage_nmfg trans_totindiv_pc trans_ssaret_pc trans_ssadis_pc trans_totmed_pc trans_fedinc_pc trans_unemp_pc trans_taaimp_pc avg_hhincsum_pc_pw avg_hhincwage_pc_pw {
   gen l_`z'_2007=l_`z'+0.7*d_`z'
   summ l_`z' if yr==1990 [aw=l_popcount]
   summ l_`z' if yr==2000 [aw=l_popcount]
   summ l_`z'_2007 if yr==2000 [aw=l_popcount_2007]
}
by yr, sort: summ d_sh_empl d_sh_empl_mfg d_sh_empl_nmfg d_sh_unempl d_sh_nilf d_sh_ssadiswkrs d_avg_lnwkwage_mfg d_avg_lnwkwage_nmfg [aw=timepwt48]
by yr, sort: summ d_trans_totindiv_pc d_trans_ssaret_pc d_trans_ssadis_pc d_trans_totmed_pc d_trans_fedinc_pc d_trans_unemp_pc d_trans_taaimp_pc [aw=timepwt48]
by yr, sort: summ d_avg_hhincsum_pc_pw d_avg_hhincwage_pc_pw [aw=timepwt48]


******************************************************************************************************************************************************************************************
* Table 3: Change in Manuf/Pop, Pooled Regressions with Controls
******************************************************************************************************************************************************************************************

eststo clear
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* l_sh_popedu_c l_sh_popfborn l_sh_empl_f t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp reg* l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip) first
esttab using ../log/tab_ipw_manuf_2.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Table 4: Population Change
******************************************************************************************************************************************************************************************

eststo clear
eststo: ivregress 2sls lnchg_popworkage (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age1634 (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age3549 (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age5064 (d_tradeusch_pw=d_tradeotch_pw_lag) t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage (d_tradeusch_pw=d_tradeotch_pw_lag) reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age1634 (d_tradeusch_pw=d_tradeotch_pw_lag) reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age3549 (d_tradeusch_pw=d_tradeotch_pw_lag) reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age5064 (d_tradeusch_pw=d_tradeotch_pw_lag) reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age1634 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age3549 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_popworkage_age5064 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ipw_pop.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t*) replace


******************************************************************************************************************************************************************************************
* Table 5: Change in Employment, Unemployment and Non-Employment
******************************************************************************************************************************************************************************************

* descriptives
by yr, sort: summ l_sh_empl_mfg l_sh_empl_nmfg l_sh_unempl l_sh_nilf l_sh_ssadiswkrs [aw=timepwt48]
by yr, sort: summ l_sh_empl_mfg_edu_c l_sh_empl_nmfg_edu_c l_sh_unempl_edu_c l_sh_nilf_edu_c [aw=timepwt48]
by yr, sort: summ l_sh_empl_mfg_edu_nc l_sh_empl_nmfg_edu_nc l_sh_unempl_edu_nc l_sh_nilf_edu_nc [aw=timepwt48]

* overall employment rate (sum of columns 1 and 2 in Table 5)
ivregress 2sls d_sh_empl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
ivregress 2sls d_sh_empl_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
ivregress 2sls d_sh_empl_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

eststo clear
eststo: ivregress 2sls lnchg_no_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_empl_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_nilf (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_ssadiswkrs (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_ssadiswkrs (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ipw_empl.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Table 6: Wage Changes
******************************************************************************************************************************************************************************************

eststo clear
eststo: ivregress 2sls d_avg_lnwkwage (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_m (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_f (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_c_m (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_c_f (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nc_m (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nc_f (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ipw_wage.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Table 7: Manufacturing vs. Non-Manufacturing
******************************************************************************************************************************************************************************************

eststo clear
eststo: ivregress 2sls lnchg_no_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_empl_mfg_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_empl_mfg_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_empl_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_empl_nmfg_edu_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_no_empl_nmfg_edu_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

eststo: ivregress 2sls d_avg_lnwkwage_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_mfg_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_mfg_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nmfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nmfg_c (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nmfg_nc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ipw_mfgnmfg.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Table 8: Transfer Receipts
******************************************************************************************************************************************************************************************

eststo clear
eststo: ivregress 2sls lnchg_trans_totindiv_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_taaimp_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_unemp_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_ssaret_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_ssadis_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_totmed_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp  l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_fedinc_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_othinc_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_totedu_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_totindiv_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_taaimp_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_unemp_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_ssaret_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_ssadis_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_totmed_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_fedinc_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_othinc_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_trans_totedu_pc (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ipw_trans.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Table 9: Household Income p.c.
******************************************************************************************************************************************************************************************

* household income per person, person-weighted
eststo clear
eststo: ivregress 2sls relchg_avg_hhincsum_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_avg_hhincwage_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_avg_hhincbusinv_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_avg_hhinctrans_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_med_hhincsum_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_med_hhincwage_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_hhincsum_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_hhincwage_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_hhincbusinv_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_hhinctrans_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_med_hhincsum_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_med_hhincwage_pc_pw (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ipw_hhinc_pw.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Table 10: Alternative Exposure Measures
******************************************************************************************************************************************************************************************

* Domestic plus International Exposure
summ d_tradex_usch_pw [aw=timepwt48]

eststo clear
eststo: ivregress 2sls d_sh_empl_mfg (d_tradex_usch_pw=d_tradex_otch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_nmfg (d_tradex_usch_pw=d_tradex_otch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_mfg (d_tradex_usch_pw=d_tradex_otch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nmfg (d_tradex_usch_pw=d_tradex_otch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_totindiv_pc (d_tradex_usch_pw=d_tradex_otch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_avg_hhincwage_pc_pw (d_tradex_usch_pw=d_tradex_otch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_expoff_iv.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


* Final Goods and Intermediate Imports
summ d_tradeusch_pw d_tradeusch_netinput_pw [aw=timepwt48], detail

eststo clear
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_netinput_pw=d_tradeotch_pw_lag d_inputotch_pw_lag) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_nmfg (d_tradeusch_netinput_pw=d_tradeotch_pw_lag d_inputotch_pw_lag) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_mfg (d_tradeusch_netinput_pw=d_tradeotch_pw_lag d_inputotch_pw_lag) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nmfg (d_tradeusch_netinput_pw=d_tradeotch_pw_lag d_inputotch_pw_lag) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_totindiv_pc (d_tradeusch_netinput_pw=d_tradeotch_pw_lag d_inputotch_pw_lag) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_avg_hhincwage_pc_pw (d_tradeusch_netinput_pw=d_tradeotch_pw_lag d_inputotch_pw_lag) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_intermediates.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


* Net Imports
summ d_netimpusch_pw [aw=timepwt48], detail

eststo clear
eststo: ivregress 2sls d_sh_empl_mfg (d_netimpusch_pw=d_tradeotch_pw_lag d_expotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_nmfg (d_netimpusch_pw=d_tradeotch_pw_lag d_expotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_mfg (d_netimpusch_pw=d_tradeotch_pw_lag d_expotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nmfg (d_netimpusch_pw=d_tradeotch_pw_lag d_expotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_totindiv_pc (d_netimpusch_pw=d_tradeotch_pw_lag d_expotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_avg_hhincwage_pc_pw (d_netimpusch_pw=d_tradeotch_pw_lag d_expotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_nipw_iv.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


* Gravity Residual, Reduced Form OLS
summ d_traderes_pw_lag [aw=timepwt48]

eststo clear
eststo: reg d_sh_empl_mfg d_traderes_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg d_sh_empl_nmfg d_traderes_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg d_avg_lnwkwage_mfg d_traderes_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg d_avg_lnwkwage_nmfg d_traderes_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg lnchg_trans_totindiv_pc d_traderes_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg relchg_avg_hhincwage_pc_pw d_traderes_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_nipw_grav.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


* Factor Content of Net Imports
summ d_nettradefactor_usch_io [aw=timepwt48], detail

eststo clear
eststo: ivregress 2sls d_sh_empl_mfg (d_nettradefactor_usch_io=d_tradefactor_otch_lag_io d_expfactor_otch_lag_io) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_nmfg (d_nettradefactor_usch_io=d_tradefactor_otch_lag_io d_expfactor_otch_lag_io) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_mfg (d_nettradefactor_usch_io=d_tradefactor_otch_lag_io d_expfactor_otch_lag_io) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_avg_lnwkwage_nmfg (d_nettradefactor_usch_io=d_tradefactor_otch_lag_io d_expfactor_otch_lag_io) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls lnchg_trans_totindiv_pc (d_nettradefactor_usch_io=d_tradefactor_otch_lag_io d_expfactor_otch_lag_io) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls relchg_avg_hhincwage_pc_pw (d_nettradefactor_usch_io=d_tradefactor_otch_lag_io d_expfactor_otch_lag_io) reg* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ifactor_net_io.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Appendix Table 3: Impact of 1990-2000 and 2000-2007 Import Exposure on 1990-2000 Change in Manufacturing Employment Share
******************************************************************************************************************************************************************************************

* Exposure variable and instrument, 1990s and 2000s
by czone, sort: egen exposure9000=total(d_tradeusch_pw*(yr==1990))
by czone, sort: egen instrument9000=total(d_tradeotch_pw_lag*(yr==1990))
by czone, sort: egen exposure0007=total(d_tradeusch_pw*(yr==2000))
by czone, sort: egen instrument0007=total(d_tradeotch_pw_lag*(yr==2000))

* Quartile of CZs with largest relative increase in import exposure, 2000-2007 vs 1990-2000
gen growth=exposure0007/exposure9000
summ growth if yr==1990, detail
_pctile growth if yr==1990 , nquantiles(100)
gen g4=r(r75)

* Regression analysis
eststo clear
eststo: ivregress 2sls d_sh_empl_mfg (exposure9000=instrument9000) [aw=timepwt48] if yr==1990 & growth>g4, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (exposure9000=instrument9000) l_shind_manuf_cbp [aw=timepwt48] if yr==1990 & growth>g4, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (exposure0007=instrument0007) [aw=timepwt48] if yr==1990 & growth>g4, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (exposure0007=instrument0007) l_shind_manuf_cbp [aw=timepwt48] if yr==1990 & growth>g4, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (exposure9000=instrument9000) [aw=timepwt48] if yr==1990, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (exposure9000=instrument9000) l_shind_manuf_cbp [aw=timepwt48] if yr==1990, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (exposure0007=instrument0007) [aw=timepwt48] if yr==1990, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (exposure0007=instrument0007) l_shind_manuf_cbp [aw=timepwt48] if yr==1990, cluster(statefip)
esttab using ../log/tab_ipw_manuf_pre.scsv, b(%9.3f) se(%9.3f) nostar r2 replace


******************************************************************************************************************************************************************************************
* Appendix Table 4: Change in Manuf/Pop, Alternative Sets of Exporters
******************************************************************************************************************************************************************************************

* descriptives
summ d_tradeusch_pw d_tradeuschlw_pw d_tradeuschce_pw d_tradeusce_pw d_tradeushi_pw [aw=timepwt48]

* full controls, OLS and 2SLS
eststo clear
eststo: reg d_sh_empl_mfg d_tradeusch_pw l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg d_sh_empl_mfg d_tradeuschlw_pw l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg d_sh_empl_mfg d_tradeuschce_pw l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg d_sh_empl_mfg d_tradeusce_pw l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: reg d_sh_empl_mfg d_tradeushi_pw l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)

eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeuschlw_pw=d_tradeotchlw_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeuschce_pw=d_tradeotchce_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusce_pw=d_tradeotce_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip) first
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeushi_pw=d_tradeothi_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip) first
esttab using ../log/tab_ipw_manuf_exporters.scsv, b(%9.4f) se(%9.4f) nostar r2 drop(t* reg*) replace


******************************************************************************************************************************************************************************************
* Appendix Table 5: Change in Employment, Unemployment and Non-Employment: By Gender and Age Group
******************************************************************************************************************************************************************************************

* descriptives
by yr, sort: summ l_sh_empl_mfg_m l_sh_empl_nmfg_m l_sh_unempl_m l_sh_nilf_m [aw=timepwt48]
by yr, sort: summ l_sh_empl_mfg_f l_sh_empl_nmfg_f l_sh_unempl_f l_sh_nilf_f [aw=timepwt48]
by yr, sort: summ l_sh_empl_mfg_age1634 l_sh_empl_nmfg_age1634 l_sh_unempl_age1634 l_sh_nilf_age1634 [aw=timepwt48]
by yr, sort: summ l_sh_empl_mfg_age3549 l_sh_empl_nmfg_age3549 l_sh_unempl_age3549 l_sh_nilf_age3549 [aw=timepwt48]
by yr, sort: summ l_sh_empl_mfg_age5064 l_sh_empl_nmfg_age5064 l_sh_unempl_age5064 l_sh_nilf_age5064 [aw=timepwt48]

eststo clear
eststo: ivregress 2sls d_sh_empl_mfg_m (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg_m (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl_m (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf_m (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg_f (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg_f (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl_f (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf_f (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg_age1634 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg_age1634 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl_age1634 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf_age1634 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg_age3549 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg_age3549 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl_age3549 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf_age3549 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg_age5064 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_empl_nmfg_age5064 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_unempl_age5064 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
eststo: ivregress 2sls d_sh_nilf_age5064 (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource reg* t2 [aw=timepwt48], cluster(statefip)
esttab using ../log/tab_ipw_empl2.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t* reg*) replace



log close
