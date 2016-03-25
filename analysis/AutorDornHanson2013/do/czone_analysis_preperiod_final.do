***********************************************
* Impact of Imports on Local Labor Markets
***********************************************

* David Dorn, February 15, 2011
* This version May 31, 2011

* Testing for anticipated impact of import exposure

* Input files: workfile_china_preperiod.dta


***********************************************
* Administrative Commands
***********************************************

cap log close                       /* closes open log files */
set more off                        /* tells Stata not to pause after each step of calculation */
clear                               /* clears current memory */
set memory 500m                     /* increases available memory */


log using ../log/czone_analysis_preperiod.log, replace text

use ../dta/workfile_china_preperiod.dta, clear


***********************************************
* Results by period, 1970-2007
***********************************************

eststo clear
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) [aw=timepwt48] if yr==1990, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) [aw=timepwt48] if yr==2000, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw=d_tradeotch_pw_lag) t2000 [aw=timepwt48] if yr>=1990, cluster(statefip)

eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw_future=d_tradeotch_pw_lag_future) [aw=timepwt48] if yr==1970, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw_future=d_tradeotch_pw_lag_future) [aw=timepwt48] if yr==1980, cluster(statefip)
eststo: ivregress 2sls d_sh_empl_mfg (d_tradeusch_pw_future=d_tradeotch_pw_lag_future) t1980 [aw=timepwt48] if yr>=1970 & yr<1990, cluster(statefip)
esttab using ../log/tab_ipw_mfg_byperiod.scsv, b(%9.3f) se(%9.3f) nostar r2 drop(t*) replace

log close