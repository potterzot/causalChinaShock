*******************************************************************
* IPUMS Czones - Plots for Change in Mfg Share, 1991-2007
*******************************************************************

* David Dorn, October 19, 2010
* This version April 17, 2012

* This file crates OLS plots for change in mfg share (long change 1991-2007)

* Input file: workfile_china_long.dta


* Administrative Commands
cap log close
set more off
clear
set memory 20m

log using ../log/czone_plot_import_long_final.log, replace text

use ../dta/workfile_china_long.dta, clear


* Descriptive stats
summ d_pct_manuf d_tradeusch_pw d_tradeotch_pw_lag [aw=timepwt48], detail

* 2SLS 1st Stage Regression
reg d_tradeusch_pw d_tradeotch_pw_lag l_shind_manuf_cbp [aw=timepwt48], cluster(statefip)

#delimit;
set scheme s2color;
avplot d_tradeotch_pw_lag,
t1("First Stage Regression, 1990-2007")
xtitle("Chg in Predicted Import Exposure per Worker (in kUSD)")
ytitle("Change in Import Exposure per Worker (in kUSD)")
msymbol(circle)
ylabel(-10(10)50)
saving(../gph/mfg_imppw_9007long_2sls1_av.gph, replace);
#delimit cr

* Reduced Form OLS
reg d_pct_manuf d_tradeotch_pw_lag l_shind_manuf_cbp [aw=timepwt48], cluster(statefip)
#delimit;
set scheme s2color;
avplot d_tradeotch_pw_lag,
t1("Change in Manufacturing Emp by Commuting Zone, 1990-2007")
xtitle("Chg in Predicted Import Exposure per Worker (in kUSD)")
ytitle("Change % Manufacturing Emp in Working Age Pop")
msymbol(circle)
saving(../gph/mfg_imppw_9007long_olsred_av.gph, replace);
#delimit cr

log close
