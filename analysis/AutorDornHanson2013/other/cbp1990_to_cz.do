*******************************************************************
* Map industry structure from the CBP 1990 to Commuting Zones
*******************************************************************

* David Dorn, May 29, 2009
* update February 12, 2010: eliminate chewing gum correction
* update September 27, 2010: create summary obs. for AK, HI

* Input file: CBP_1990adj.dta, cw_n97_s87.dta
* Output file: cz_industry_1990.dta


*******************************************************************
* Administrative Commands
*******************************************************************

cap log close
set more off
clear
set memory 8g


log using ../log/cbp1990_to_cz.log, replace

use ../dta/CBP_1990adj.dta, clear


*******************************************************************
* Adjust geography to 1990 Census conventions
*******************************************************************

* change county id for Washington DC
replace countyid=11001 if countyid==11999

* drop observations with missing county identification
gen floor=floor(countyid/1000)
drop if (countyid-floor*1000)==999
drop floor

* set county code to 15001 for all counties in AK, HI
replace countyid=15001 if countyid>=2001 & countyid<=2999
replace countyid=15001 if countyid>=15001 & countyid<=15999


*******************************************************************
* Keep 4-digit SIC observations
*******************************************************************

keep if level==4
rename code4 sic4
keep sic4 imp_emp countyid


*******************************************************************
* Rename codes for auxiliary industries
*******************************************************************

replace sic4=0980 if sic4==10001   /* Agriculture, Forestry, Fishery */
replace sic4=1490 if sic4==20001   /* Mineral Industries */
replace sic4=1790 if sic4==30001   /* Construction */
replace sic4=3990 if sic4==40001   /* Manufacturing */
replace sic4=4970 if sic4==50001   /* Transportation, Communication, Utilities */
replace sic4=5190 if sic4==60001   /* Wholesale Trade */
replace sic4=5990 if sic4==70001   /* Retail Trade */
replace sic4=6790 if sic4==80001   /* FIRE */
replace sic4=8990 if sic4==90001   /* Service Industries */


*******************************************************************
* Rename incorrect 4-digit SIC72 codes
* (Note: The CBP data does not report 4-digit counts for 3-digit
* industries that have only one associated 4-digit code. I generally
* assume that the 4-digit code relating to the 3-digit industry "###"
* is "###1". However, the correct code is sometimes "###2" etc.)
*******************************************************************

replace sic4=2273 if sic4==2271
replace sic4=2353 if sic4==2351
replace sic4=3199 if sic4==3191
replace sic4=3743 if sic4==3741
replace sic4=3812 if sic4==3811
replace sic4=3873 if sic4==3871


*******************************************************************
* Compute total non-agriculture employment
* (excluding obs with missing county or industry information)
*******************************************************************

egen tot_emp=sum(imp_emp*(sic4>1000 & sic4<9000))


*******************************************************************
* Aggregate 4-digit SIC-county observations to CZones
*******************************************************************

rename countyid cty_fips
sort cty_fips

joinby cty_fips using ../dta/cw_cty_czone.dta
assert czone!=.
tab cty_fips if imp_emp==.
drop if imp_emp==.

keep imp_emp czone sic4 tot_emp
egen group=group(sic4 czone)
collapse (sum) imp_emp (mean) czone sic4 tot_emp, by(group)
drop group

save ../dta/czone_industry1990.dta, replace

log close
