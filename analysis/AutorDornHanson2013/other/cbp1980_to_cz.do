*******************************************************************
* Map industry structure from the CBP 1980 to Commuting Zones
*******************************************************************

* David Dorn, June 11, 2009
* update February 12, 2010: eliminate chewing gum correction

* Input file: CBP_1980adj.dta, cw_s72_s87_nber.dta, cw_s72_s87_add.dta
* Output file: cz_industry_1980.dta


*******************************************************************
* Administrative Commands
*******************************************************************

cap log close
set more off
clear
set memory 8g


log using ../log/cbp1980_to_cz.log, replace

use ../dta/CBP_1980adj.dta, clear


*******************************************************************
* Adjust geography to 1990 Census conventions
*******************************************************************

* change county id for Washington DC
replace countyid=11001 if countyid==11999

* change a suspected mislabeling of a county in Missouri
replace countyid=29186 if countyid==29193

* drop an undocumented county in South Dakota (less than 20 workers)
drop if countyid==46131

* split county 4027 into 4027 and 4012 (ratio 106895:13844)
save temp.dta, replace
keep if countyid==4027
replace countyid=4012
replace imp_emp=imp_emp*(13844/(106895+13844))
save temp2.dta, replace
use temp.dta, clear
replace imp_emp=imp_emp*(106895/(106895+13844)) if countyid==4027
append using temp2.dta
erase temp.dta
erase temp2.dta

* drop observations with missing county identification
gen floor=floor(countyid/1000)
drop if (countyid-floor*1000)==999
drop floor


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

replace sic4=3069 if sic4==3061
replace sic4=3079 if sic4==3071
replace sic4=3199 if sic4==3191
replace sic4=3743 if sic4==3741
replace sic4=3832 if sic4==3831
replace sic4=3873 if sic4==3871


*******************************************************************
* Compute total non-agriculture employment
* (excluding obs with missing county or industry information)
*******************************************************************

egen tot_emp=sum(imp_emp*(sic4>1000 & sic4<9000))



*******************************************************************
* Compute total CBP employment by Czone
*******************************************************************

rename countyid cty_fips
save cbp_temp.dta, replace

* create total employment by county
by cty_fips, sort: egen tot_emp_cz=sum(imp_emp*(sic4>1000 & sic4<9000))

* keep one observation per county
egen tag=tag(cty_fips)
keep if tag==1

* aggregate to Czone
keep cty_fips tot_emp_cz
sort cty_fips

joinby cty_fips using ../dta/cw_cty_czone.dta
assert czone!=.

collapse (sum) tot_emp_cz, by(czone)
sort czone
save cbp_cztot.dta, replace


*******************************************************************
* Retain only the manufacturing industry (this is the only industry
* covered by the NBER crosswalk)
*******************************************************************

use cbp_temp.dta, clear
erase cbp_temp.dta
keep if (sic4>2000 & sic4<=4000)


*******************************************************************
* Crosswalk SIC72 to SIC87
*******************************************************************

summ imp_emp
egen sum_emp=sum(imp_emp)
rename sic4 sic72
sort sic72
save temp.dta, replace

use ../dta/cw_s72_s87_nber.dta
append using ../dta/cw_s72_s87_add.dta

by sic72, sort: egen sum72=sum(sh7287)
assert sum72==1
keep sic72 sic87 sh7287
sort sic72
joinby sic72 using temp.dta, unmatched(both)

summ imp_emp
replace imp_emp=imp_emp*sh7287
summ imp_emp
egen sum_emp2=sum(imp_emp)
gen ratio=sum_emp/sum_emp2
assert ratio>.999999 & ratio<1.000001

rename sic87 sic4
erase temp.dta


*******************************************************************
* Aggregate 4-digit SIC-county observations to CZones
*******************************************************************

sort cty_fips
joinby cty_fips using ../dta/cw_cty_czone.dta
assert czone!=.
tab cty_fips if imp_emp==.
drop if imp_emp==.

keep imp_emp tot_emp czone sic4
egen group=group(sic4 czone)
collapse (sum) imp_emp (mean) czone sic4 tot_emp, by(group)
drop group

* merge with total employment of cbp
sort czone
merge czone using cbp_cztot.dta
assert _merge==3
drop _merge
erase cbp_cztot.dta

save ../dta/czone_industry1980.dta, replace

log close
