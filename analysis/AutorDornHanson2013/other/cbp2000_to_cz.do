*******************************************************************
* Map industry structure from the CBP 2000 to Commuting Zones
*******************************************************************

* David Dorn, May 29, 2009
* update September 27, 2010: create summary obs. for AK, HI

* Input file: CBP_2000adj.dta
* Output file: cz_industry_2000.dta


*******************************************************************
* Administrative Commands
*******************************************************************

cap log close
set more off
clear
set memory 8g


log using ../log/cbp2000_to_cz.log, replace

use ../dta/CBP_2000adj.dta, clear


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
* Keep 6-digit NAICS observations
*******************************************************************

keep if level==5
rename code5 naics6
keep naics6 imp_emp countyid


*******************************************************************
* Compute total non-agriculture employment
* (excluding obs with missing county or industry information)
*******************************************************************

egen tot_emp=sum(imp_emp*(naics6>210000 & naics6<900000))


*******************************************************************
* Aggregate 6-digit NAICS-county observations to CZones
*******************************************************************

rename countyid cty_fips
sort cty_fips

joinby cty_fips using ../dta/cw_cty_czone.dta
assert czone!=.
tab cty_fips if imp_emp==.
drop if imp_emp==.
keep naics6 imp_emp czone tot_emp


*******************************************************************
* Crosswalk NAICS to SIC
*******************************************************************

egen sum_emp=sum(imp_emp)

sort naics6
joinby naics6 using ../dta/cw_n97_s87.dta

replace imp_emp=imp_emp*weight

egen sum_emp2=sum(imp_emp)
gen ratio=sum_emp/sum_emp2
assert ratio>.999999 & ratio<1.000001


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
* Collapse to SIC-czone observations
*******************************************************************

keep imp_emp czone sic4 tot_emp
egen group=group(sic4 czone)
collapse (sum) imp_emp (mean) czone sic4 tot_emp, by(group)
drop group

save ../dta/czone_industry2000.dta, replace

log close
