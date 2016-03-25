*******************************************************************
* County Business Patterns 2000
*
* Imputation of Employment Counts
*******************************************************************

* David Dorn, May 16, 2009
* This version May 22, 2009
* Update September 27, 2010: Keep AK, HI

* Input file: CBP_2000.dta
* Output file: CBP_2000adj.dta

* This file closely follows the imputations from cbp1980_imputations.do
* for 1980.


*******************************************************************
* Administrative Commands
*******************************************************************

cap log close
set more off
clear
set memory 6g


log using ../log/cbp2000_imputations.log, replace

use ../dta/CBP_2000.dta, clear


* drop unused payroll variables
drop ap


*******************************************************************
* Adjust to variable name convention of CBP 1980
*******************************************************************

rename fipscty fipscty2
rename empflag flag
rename emp tempmm
rename n1_4 ctyemp1
rename n5_9 ctyemp2
rename n10_19 ctyemp3
rename n20_49 ctyemp4
rename n50_99 ctyemp5
rename n100_249 ctyemp6
rename n250_499 ctyemp7
rename n500_999 ctyemp8
rename n1000 ctyemp9
rename n1000_1 ctyemp10
rename n1000_2 ctyemp11
rename n1000_3 ctyemp12
rename n1000_4 ctyemp13


*******************************************************************
* Geographic selection
*******************************************************************

* drop Alaska and Hawaii
*****drop if fipstate==2 | fipstate==15


*******************************************************************
* County identifiers
*******************************************************************

* unique county identifier
gen countyid=fipstate*1000+fipscty2

* county counter
sort countyid
egen tag=tag(countyid)
gen countyct=sum(tag)
summ countyct
egen max=max(countyct)
local x=max
drop tag max


*******************************************************************
* Variables for industry codes
*
* Note: The CBP reports 6 levels of aggregation: county totals
* (naics "------") subtotals of multiple 2-digit codes ("##----"),
* and three to six digit codes ("###///", "####//", etc).
*******************************************************************

* determine differentiation level of observation
gen level=0 if naics=="------"
replace level=1 if substr(naics,3,4)=="----" & level!=0
replace level=2 if substr(naics,4,3)=="///"
replace level=3 if substr(naics,5,2)=="//" & level!=2
replace level=4 if substr(naics,6,1)=="/" & level!=2 & level!=3
replace level=5 if level==.

tab level

* replace "/" and "-" with "0"
gen code=naics
foreach v of var code {
   replace `v' = subinstr(`v',"/","0",3)
   replace `v' = subinstr(`v',"-","0",6)
}

destring code, replace
forvalues v=1/5 {
    gen code`v'=code if level==`v'
}
drop code

assert floor(code4/10)*10==code4
assert floor(code3/100)*100==code3
assert floor(code2/1000)*1000==code2
assert floor(code1/10000)*10000==code1


* level 2-4 codes for level 3-5 observations
replace code4=10*floor(code5/10) if level==5
replace code3=100*floor(code5/100) if level==5
replace code2=1000*floor(code5/1000) if level==5
replace code3=100*floor(code4/100) if level==4
replace code2=1000*floor(code4/1000) if level==4
replace code2=1000*floor(code3/1000) if level==3

* level 1 industry codes for level 2+ observations
replace code1=110000 if code2>=111000 & code2<209000
replace code1=210000 if code2>=211000 & code2<219000
replace code1=220000 if code2>=221000 & code2<229000
replace code1=230000 if code2>=231000 & code2<309000
replace code1=310000 if code2>=311000 & code2<419000
replace code1=420000 if code2>=421000 & code2<439000
replace code1=440000 if code2>=441000 & code2<479000
replace code1=480000 if code2>=481000 & code2<509000
replace code1=510000 if code2>=511000 & code2<519000
replace code1=520000 if code2>=521000 & code2<529000
replace code1=530000 if code2>=531000 & code2<539000
replace code1=540000 if code2>=541000 & code2<549000
replace code1=550000 if code2>=551000 & code2<559000
replace code1=560000 if code2>=561000 & code2<609000
replace code1=610000 if code2>=611000 & code2<619000
replace code1=620000 if code2>=621000 & code2<709000
replace code1=710000 if code2>=711000 & code2<719000
replace code1=720000 if code2>=721000 & code2<809000
replace code1=810000 if code2>=811000 & code2<949000
replace code1=950000 if code2>=951000 & code2<989000
replace code1=990000 if code2>=991000 & code2<999000

* assert that all observations except county totals have level 1 codes
assert code1!=. if naics!="------"

save temp.dta, replace


*******************************************************************
* Descriptives
*******************************************************************

forvalues v=0/5 {
   disp "total observations, level `v'"
   summ level if level==`v'
}


*******************************************************************
* Create level 2-5 observations for observations with missing
* industry (which only have a 1-digit code)
*******************************************************************

save temp.dta, replace

forvalues v=2/5 {
   use temp.dta, clear
   keep if code1==950000 | code1==990000
   local z=2
   while `z'<=`v' {
      replace code`z'=code1
      local z=`z'+1
   }
   replace level=`v'
   save temp`v'.dta, replace
}

* consolidate
use temp.dta, clear
forvalues k=2/5 {
   append using temp`k'.dta
   erase temp`k'.dta
}
save temp.dta, replace


*******************************************************************
* Add observations for missing county-industry cells
* (these are used when firms with imprecise industry identification
* are assigned to subindustries)
*******************************************************************

summ countyct
save temp1.dta, replace

* key to link county count and county id
egen tag=tag(countyct)
keep if tag==1
keep countyct countyid
sort countyct
save ctyid.dta, replace

* unique industry identifier
use temp1.dta, clear
gen double id_ind=0 if level==0
forvalues v=1/5 {
   replace id_ind=level*1000000+code`v' if level==`v'
}
* unique county-industry identifier
gen double id_obs=countyct*10000000+id_ind
egen tag=tag(id_obs)
assert tag==1
drop tag
save temp1.dta, replace

* file with one observation per industry
egen tag=tag(id_ind)
keep if tag==1
keep id_ind level code*
tab id_ind
save ind.dta, replace
gen countyct=1
save ctytemp.dta, replace

use temp1.dta, clear
drop id_ind countyct countyid level code*
sort id_obs
save temp1.dta, replace

forvalues v=2/`x' {
   use ind.dta, clear
   gen countyct=`v'
   append using ctytemp.dta
   quietly save ctytemp.dta, replace
}
summ countyct
tab id_ind

* merge with county identifier
sort countyct
merge countyct using ctyid.dta
tab _merge
assert _merge==3
drop _merge

* merge with main data file
gen double id_obs=countyct*10000000+id_ind
egen tag=tag(id_obs)
assert tag==1
drop tag
sort id_obs
merge id_obs using temp1.dta
tab _merge
assert _merge!=2
drop _merge

assert floor(code4/10)*10==code4
assert floor(code3/100)*100==code3
assert floor(code2/1000)*1000==code2
assert floor(code1/10000)*10000==code1

* show list of occupation codes
tab code1
tab code2
tab code3
tab code4
tab code5

* create rows with zero counts
replace tempmm=0 if tempmm==.
forvalues v=1/13 {
   replace ctyemp`v'=0 if ctyemp`v'==.
}

erase ind.dta
erase ctyid.dta
erase ctytemp.dta
erase temp1.dta

save cbp2000temp.dta, replace

use cbp2000temp.dta, clear


*******************************************************************
* Drop redundant establishment size bracket 1000+
*******************************************************************

* establishment size brackets
* 1: 1-4 employees
* 2: 5-9
* 3: 10-19
* 4: 20-49
* 5: 50-99
* 6: 100-249
* 7: 250-499
* 8: 500-999
* 9: 1000+
* 10: 1000-1499
* 11: 1500-2499
* 12: 2500-4999
* 13: 5000+

* establishment size 9 is a sum of establishment size 10-13
* drop this variable and rename brackets 10-13 to 9-12
assert ctyemp9==ctyemp10+ctyemp11+ctyemp12+ctyemp13
drop ctyemp9
forvalues z=10/13 {
   local k=`z'-1
   rename ctyemp`z' ctyemp`k'
}


*******************************************************************
* Descriptives
*******************************************************************

forvalues v=0/5 {
   disp "total observations, level `v'"
   summ level if level==`v'
}


*******************************************************************
* Bounds for employment counts (1/2)
*
* 1) The imputed employment of a county-industry cell has to lie
* within the indicated employment bracket
* 2) Narrow down the employment range of a county-industry cell
* using the firm size distribution of the cell (unless the firm size
* distribution cannot be reconciled with the indicated employment bracket)
*******************************************************************

gen lb_emp=tempmm
gen ub_emp=tempmm

replace lb_emp=0 if flag=="A"
replace lb_emp=20 if flag=="B"
replace lb_emp=100 if flag=="C"
replace lb_emp=250 if flag=="E"
replace lb_emp=500 if flag=="F"
replace lb_emp=1000 if flag=="G"
replace lb_emp=2500 if flag=="H"
replace lb_emp=5000 if flag=="I"
replace lb_emp=10000 if flag=="J"
replace lb_emp=25000 if flag=="K"
replace lb_emp=50000 if flag=="L"
replace lb_emp=100000 if flag=="M"

replace ub_emp=19 if flag=="A"
replace ub_emp=99 if flag=="B"
replace ub_emp=249 if flag=="C"
replace ub_emp=499 if flag=="E"
replace ub_emp=999 if flag=="F"
replace ub_emp=2499 if flag=="G"
replace ub_emp=4999 if flag=="H"
replace ub_emp=9999 if flag=="I"
replace ub_emp=24999 if flag=="J"
replace ub_emp=49999 if flag=="K"
replace ub_emp=99999 if flag=="L"
replace ub_emp=100000000 if flag=="M"

assert lb_emp<=ub_emp


* lower bound and upper bound of employment according to establishment size counts

gen lb_fsize=1*ctyemp1+5*ctyemp2+10*ctyemp3+20*ctyemp4+50*ctyemp5+100*ctyemp6+250*ctyemp7+500*ctyemp8+1000*ctyemp9+1500*ctyemp10+2500*ctyemp11+5000*ctyemp12
gen ub_fsize=4*ctyemp1+9*ctyemp2+19*ctyemp3+49*ctyemp4+99*ctyemp5+249*ctyemp6+499*ctyemp7+999*ctyemp8+1499*ctyemp9+2499*ctyemp10+4999*ctyemp11+100000000*ctyemp12

assert lb_fsize<=ub_fsize


* check consistency by identifying cases where a lower bound exceeds and upper bound
gen deviation=0
replace deviation=lb_emp-ub_fsize if lb_emp-ub_fsize>0
replace deviation=-(lb_fsize-ub_emp) if lb_fsize-ub_emp>0
gen error_consistency=0
replace error_consistency=1 if deviation!=0

forvalues v=0/5 {
   disp "***** Employment/Firm Size Consistency Error, Observations Level `v' *****"
   summ error_consistency if level==`v'
   disp "***** Employment/Firm Size Consistency Error, Except Firms with Missing Industry, Observations Level `v' *****"
   summ error_consistency if level==`v' & code1!=95000 & code1!=99000
   disp "***** Employment/Firm Size Consistency Error - More Employment than Firms, Observations Level `v' *****"
   summ deviation if level==`v' & deviation>0
   disp "***** Employment/Firm Size Consistency Error - More Firms than Employment, Observations Level `v' *****"
   summ deviation if level==`v' & deviation<0
}


* adjusted employment brackets
gen lb_adj=lb_emp
gen ub_adj=ub_emp

* use tighter firm size brackets, unless inconsistent with employment counts
replace lb_adj=lb_fsize if lb_fsize>lb_adj & lb_fsize<=ub_adj
replace ub_adj=ub_fsize if ub_fsize>=lb_adj & ub_fsize<ub_adj

* set adjusted bracket to corner value when brackets do not overlap
replace lb_adj=ub_adj if ub_adj<lb_fsize
replace ub_adj=lb_adj if lb_adj>ub_fsize


*******************************************************************
* Bounds for employment counts (2/2)
*
* 3) Narrow down the resulting employment range using the employment
* range that is implied by the aggregation of subindustries and employment
* in firms with missing subindustry designation (unless this information
* cannot be reconciled with the employment bracket of step 2)0
*******************************************************************

* county x industry identifiers
gen double code0cty=1000000*countyct
gen double code1cty=1000000*countyct+code1
gen double code2cty=1000000*countyct+code2
gen double code3cty=1000000*countyct+code3
gen double code4cty=1000000*countyct+code4


* aggregation of establishment size counts
* identify firms that do not have precise industry information ("miss_firm#")
forvalues z=1/12 {
   gen miss_firm`z'=.
   forvalues v=0/4 {
      local k=`v'+1
      by code`v'cty, sort: egen sum`v'_`z'=sum(ctyemp`z'*(level==`k'))
      by code`v'cty, sort: replace miss_firm`z'=ctyemp`z'-sum`v'_`z' if level==`v'
      drop sum`v'_`z'
   }
}


* identify data errors where "miss_firm#"<0
gen error_aggfirm=0
#delimit ;
replace error_aggfirm=1 if (miss_firm1<0 | miss_firm2<0 | miss_firm3<0 | miss_firm4<0 | miss_firm5<0 | miss_firm6<0
| miss_firm7<0 | miss_firm8<0 | miss_firm9<0 | miss_firm10<0 | miss_firm11<0 | miss_firm12<0);
#delimit cr
* treat negative values of "miss_firm#" as zeros
forvalues z=1/12 {
   replace miss_firm`z'=0 if miss_firm`z'<0
}

forvalues v=0/4 {
   disp "***** Total Firm Aggregation Errors, Observation Level `v' *****"
   summ error_aggfirm if level==`v'
}


* aggregation of adjusted employment brackets

gen error_aggregation=0
local v=4
while `v'>=0 {
   local k=`v'+1
   by code`v'cty, sort: egen lb`v'_agg=sum(lb_adj*(level==`k'))
   by code`v'cty, sort: egen ub`v'_agg=sum(ub_adj*(level==`k'))
   #delimit ;
   replace lb`v'_agg=lb`v'_agg+miss_firm1*0+miss_firm2*5+miss_firm3*10+miss_firm4*20+miss_firm5*50+miss_firm6*100
   +miss_firm7*250+miss_firm8*500+miss_firm9*1000+miss_firm10*1500+miss_firm11*2500+miss_firm12*5000 if level==`v';
   replace ub`v'_agg=ub`v'_agg+miss_firm1*4+miss_firm2*9+miss_firm3*19+miss_firm4*49+miss_firm5*99+miss_firm6*249
   +miss_firm7*499+miss_firm8*999+miss_firm9*1499+miss_firm10*2499+miss_firm11*4999+miss_firm12*10000000 if level==`v';
   #delimit cr

   * flag cases where brackets do not overlap
   replace error_aggregation=1 if ub_adj<lb`v'_agg & level==`v'
   replace error_aggregation=1 if lb_adj>ub`v'_agg & level==`v'

   * use tighter aggregated brackets, unless inconsistent with employment counts
   replace lb_adj=lb`v'_agg if lb`v'_agg>lb_adj & lb`v'_agg<=ub_adj & level==`v'
   replace ub_adj=ub`v'_agg if ub`v'_agg>=lb_adj & ub`v'_agg<ub_adj & level==`v'

   * set adjusted bracket to corner value when brackets do not overlap
   replace lb_adj=ub_adj if ub_adj<lb`v'_agg & level==`v'
   replace ub_adj=lb_adj if lb_adj>ub`v'_agg & level==`v'

   local v=`v'-1
}


forvalues v=0/4 {
   disp "***** Total Aggregation Errors, Observation Level `v' *****"
   summ error_aggregation if level==`v'
}


gen error_tot=(error_consistency+error_aggregation>=1)

forvalues v=0/5 {
   disp "***** Total Aggregation and Consistency Errors, Observations Level `v' *****"
   summ error_tot if level==`v'
}


*******************************************************************
* Recursive estimation of typical employment size per establishment
* size bracket
*******************************************************************

* Start values for employment per firm size bracket are equal to bracket midpoints

gen imp0_cat1=9.5 if flag=="A" & level==5
gen imp0_cat2=59.5 if flag=="B" & level==5
gen imp0_cat3=174.5 if flag=="C" & level==5
gen imp0_cat4=374.5 if flag=="E" & level==5
gen imp0_cat5=749.5 if flag=="F" & level==5
gen imp0_cat6=1749.5 if flag=="G" & level==5
gen imp0_cat7=3749.5 if flag=="H" & level==5
gen imp0_cat8=7499.5 if flag=="I" & level==5
gen imp0_cat9=17499.5 if flag=="J" & level==5
gen imp0_cat10=37499.5 if flag=="K" & level==5
gen imp0_cat11=74999.5 if flag=="L" & level==5
gen imp0_cat12=150000 if flag=="M" & level==5

forvalues v=1/12 {
   gen imp1_cat`v'=imp0_cat`v'
}
gen imp_emp5=.

local z=100000

while `z'>=.1 {
    forvalues v=1/12 {
      replace imp0_cat`v'=imp1_cat`v'
   }
   * employment per level 5 industry based on establishment size distribution and constrained by employment brackets
   #delimit ;
   replace imp_emp5=ctyemp1*imp0_cat1+ctyemp2*imp0_cat2+ctyemp3*imp0_cat3+ctyemp4*imp0_cat4+ctyemp5*imp0_cat5+ctyemp6*imp0_cat6
   +ctyemp7*imp0_cat7+ctyemp8*imp0_cat8+ctyemp9*imp0_cat9+ctyemp10*imp0_cat10+ctyemp11*imp0_cat11+ctyemp12*imp0_cat12 if level==5;
   #delimit cr
   replace imp_emp5=lb_adj if imp_emp5<lb_adj & level==5
   replace imp_emp5=ub_adj if imp_emp5>ub_adj & level==5
   * regress imputed employment on establishment size distribution
   reg imp_emp5 ctyemp*, noconstant
   forvalues v=1/12 {
      replace imp1_cat`v'=_b[ctyemp`v']
   }
   * compute absolute sum of coefficient changes
   #delimit ;
   local z=abs(imp1_cat1-imp0_cat1)+abs(imp1_cat2-imp0_cat2)+abs(imp1_cat3-imp0_cat3)+abs(imp1_cat4-imp0_cat4)+abs(imp1_cat5-imp0_cat5)+abs(imp1_cat6-imp0_cat6)
   +abs(imp1_cat7-imp0_cat7)+abs(imp1_cat8-imp0_cat8)+abs(imp1_cat9-imp0_cat9)+abs(imp1_cat10-imp0_cat10)+abs(imp1_cat11-imp0_cat11)+abs(imp1_cat12-imp0_cat12);
   #delimit cr
}

assert imp0_cat1>=0 & imp0_cat1<=4
assert imp0_cat2>=5 & imp0_cat2<=9
assert imp0_cat3>=10 & imp0_cat3<=19
assert imp0_cat4>=20 & imp0_cat4<=49
assert imp0_cat5>=50 & imp0_cat5<=99
assert imp0_cat6>=100 & imp0_cat6<=249
assert imp0_cat7>=250 & imp0_cat7<=499
assert imp0_cat8>=500 & imp0_cat8<=999
assert imp0_cat9>=1000 & imp0_cat9<=1499
assert imp0_cat10>=1500 & imp0_cat10<=2499
assert imp0_cat11>=2500 & imp0_cat11<=4999
assert imp0_cat12>=5000


*******************************************************************
* Imputed employment in firms with missing detailled industry codes
* and
* Aggregate imputed employment to 3-, 2-, 1-digit and county level
*******************************************************************

* employment in missing firms, boundaries
#delimit ;
gen lb_miss=miss_firm1*0+miss_firm2*5+miss_firm3*10+miss_firm4*20+miss_firm5*50+miss_firm6*100
+miss_firm7*250+miss_firm8*500+miss_firm9*1000+miss_firm10*1500+miss_firm11*2500+miss_firm12*5000 if level<=3;
gen ub_miss=miss_firm1*4+miss_firm2*9+miss_firm3*19+miss_firm4*49+miss_firm5*99+miss_firm6*249
+miss_firm7*499+miss_firm8*999+miss_firm9*1499+miss_firm10*2499+miss_firm11*4999+miss_firm12*10000000 if level<=3;
#delimit cr
assert lb_miss<=ub_miss


* create seperate employment bound variables by industry level

forvalues v=0/5 {
   gen lb`v'=lb_adj if level==`v'
   gen ub`v'=ub_adj if level==`v'
}
forvalues v=0/4 {
   local z=`v'+1
   replace lb`z'=lb_miss if level==`v'
   replace ub`z'=ub_miss if level==`v'
}


local v=4
while `v'>=0 {
   local z=`v'+1

   * (a) impute employment in firms with missing `z'-digit code, point estimate
   #delimit ;
   replace imp_emp`z'=miss_firm1*imp0_cat1+miss_firm2*imp0_cat2+miss_firm3*imp0_cat3+miss_firm4*imp0_cat4+miss_firm5*imp0_cat5+miss_firm6*imp0_cat6
   +miss_firm7*imp0_cat7+miss_firm8*imp0_cat8+miss_firm9*imp0_cat9+miss_firm10*imp0_cat10+miss_firm11*imp0_cat11+miss_firm12*imp0_cat12 if level==`v';
   #delimit cr
   disp "imputed employment in firms that have a `v'-digit industry code but no `z'-digit code"
   summ imp_emp`z' if level==`v'
   summ imp_emp`z' if level==`v' & imp_emp`z'!=0

   * (b) impute employment in n-digit industries as sum of imputed (n+1)-digit employment and imputed employment in firms with missing (n+1)-digit code
   by code`v'cty, sort: egen imp_emp`v'raw=sum(imp_emp`z')
   replace imp_emp`v'raw=. if level!=`v'

   * constrain imputed employment to lie within industry employment brackets
   gen imp_emp`v'=imp_emp`v'raw if level==`v'
   replace imp_emp`v'=lb`v' if lb`v'>imp_emp`v'raw & level==`v'
   replace imp_emp`v'=ub`v' if ub`v'<imp_emp`v'raw & level==`v'

   local v=`v'-1
}

assert imp_emp`z'<=ub`z'
assert imp_emp`z'>=lb`z'


*******************************************************************
* Descriptives before adjustments for hierarchical consistency
*******************************************************************

* imputed employment
forvalues v=0/5 {
   disp "Employment counts, level `v', before consistency adjustments"
   summ imp_emp`v' if level==`v'
   summ imp_emp`v' if level==`v' & imp_emp`v'!=0
}


* aggregation of employment counts
forvalues v=0/4 {
   local z=`v'+1
   * (n+1)-digit counts sum to n-digit totals
   gen agg`v'ok=(imp_emp`v'raw==imp_emp`v')*(level==`v')
   * absolute value of relative deviations
   gen reldev`v'=(abs(imp_emp`v'raw-imp_emp`v'))/imp_emp`v' if level==`v'
   replace reldev`v'=0 if imp_emp`v'==0
   gen agg`v'approxok=(abs(reldev`v')<.001) if level==`v'

   disp "sum of level `z' equals to level `v'"
   summ agg`v'ok if level==`v'
   disp "sum of level `z' within 0.1% of level `v'"
   summ agg`v'approxok if level==`v'
   disp "sum of level `z' within 0.1% of level `v', no aggregation flag"
   summ agg`v'approxok if level==`v' & error_aggregation==0
   disp "absolute value of relative deviations, level `v'"
   summ reldev`v' if level==`v'

   drop agg`v'* reldev`v'
}


*******************************************************************
* Adjust imputed employment for hierarchical consistency
*******************************************************************


gen tot_red_0=.

forvalues v=0/4 {
   local z=`v'+1

   * absolute value of all deviations of imputed employment numbers from target values, level `v'
   drop tot_red_0
   egen tot_red_0=sum(abs((imp_emp`v'raw-imp_emp`v')*(level==`v')))
   disp "absolute value of required adjustments to level `z' observations"
   summ tot_red_0 if level==`v'

   local k=2
   while `k'>1 {

      * required reduction of imputed level `z' employment counts, by level `v' industry-county cell
      drop imp_emp`v'raw
      by code`v'cty, sort: egen imp_emp`v'raw=sum(imp_emp`z')
      by code`v'cty, sort: egen tot_red`z'=sum((imp_emp`v'raw-imp_emp`v')*(level==`v'))
      summ tot_red`z' if level==`v'
      summ tot_red`z' if level==`v' & error_aggregation==0
      summ tot_red`z' if tot_red`z'>0 & level==`v'
      summ tot_red`z' if tot_red`z'<0 & level==`v'
      * compute employment in subindustries where upper/lower bound of employment bracket is not binding
      by code`v'cty, sort: egen base_red`z'=sum(imp_emp`z'*(imp_emp`z'>lb`z')) if tot_red`z'>0
      by code`v'cty, sort: egen base_incr`z'=sum(imp_emp`z'*(imp_emp`z'<ub`z')) if tot_red`z'<0
      summ base_red`z' base_incr`z' if level==`v'
      * compute share of employment reduction that will be atrributed to given industry
      gen sh_red`z'=0 if (level==`v' | level==`z')
      replace sh_red`z'=imp_emp`z'/base_red`z' if imp_emp`z'>lb`z' & tot_red`z'>0 & base_red`z'>0 & (level==`v' | level==`z')
      * compute share of employment increase (negative reduction) for given industry
      * note: the only observations with zero imputed employment are those that do not have firms. No employment should be attributed
      * to these observations in this step.
      replace sh_red`z'=imp_emp`z'/base_incr`z' if imp_emp`z'<ub`z' & tot_red`z'<0 & base_incr`z'>0  & (level==`v' | level==`z')
      * assert that shares add to one
      by code`v'cty, sort: egen sum_sh`z'=sum(sh_red`z') if ((tot_red`z'>0 & base_red`z'>0) | (tot_red`z'<0 & base_incr`z'>0)) & (level==`v' | level==`z')
      summ sum_sh`z'
      summ sum_sh`z' if error_aggregation==0
      * compute change attributed to subindustry
      gen chg`z'=-sh_red`z'*tot_red`z' if tot_red`z'!=0 & (sh_red`z'>0 & sh_red`z'<=1) & (level==`v' | level==`z')
      summ chg`z' if tot_red`z'>0
      summ chg`z' if tot_red`z'<0
      * adjust imputed subindustry employment
      replace imp_emp`z'=imp_emp`z'+chg`z' if  tot_red`z'!=0 & (sh_red`z'>0 & sh_red`z'<=1) & (level==`v' | level==`z')

      * constrain imputed employment to lie within bracket borders
      replace imp_emp`z'=ub`z' if imp_emp`z'>ub`z'
      replace imp_emp`z'=lb`z' if imp_emp`z'<lb`z'

      * compute sum of adjusted subindustry employment
      drop imp_emp`v'raw
      by code`v'cty, sort: egen imp_emp`v'raw=sum(imp_emp`z')
      replace imp_emp`v'raw=. if level!=`v'

      * absolute value of all deviations of imputed employment numbers from target values
      egen tot_red_1=sum(abs((imp_emp`v'raw-imp_emp`v')*(level==`v')))
      disp "absolute value of required adjustments to level `z' observations"
      summ tot_red_1 if level==`v'
      local k=tot_red_0-tot_red_1
      replace tot_red_0=tot_red_1

      drop tot_red`z' tot_red_1 base* sh_red* chg* sum_sh*
   }
}


*******************************************************************
* Descriptives before adjustments for firms with imprecise industry
* information
*******************************************************************

* imputed employment
forvalues v=0/5 {
   disp "Employment counts, level `v', before consistency adjustments"
   summ imp_emp`v' if level==`v'
   summ imp_emp`v' if level==`v' & imp_emp`v'!=0
}


* aggregation of employment counts
forvalues v=0/4 {
   local z=`v'+1
   * (n+1)-digit counts sum to n-digit totals
   gen agg`v'ok=(imp_emp`v'raw==imp_emp`v')*(level==`v')
   * absolute value of relative deviations
   gen reldev`v'=(abs(imp_emp`v'raw-imp_emp`v'))/imp_emp`v' if level==`v'
   replace reldev`v'=0 if imp_emp`v'==0
   gen agg`v'approxok=(abs(reldev`v')<.001) if level==`v'

   disp "sum of level `z' equals to level `v'"
   summ agg`v'ok if level==`v'
   disp "sum of level `z' within 0.1% of level `v'"
   summ agg`v'approxok if level==`v'
   disp "sum of level `z' within 0.1% of level `v', no aggregation flag"
   summ agg`v'approxok if level==`v' & error_aggregation==0
   disp "absolute value of relative deviations, level `v'"
   summ reldev`v' if level==`v'

   drop agg`v'* reldev`v'
}


*******************************************************************
* Proportionally assign firms with missing industry code to subindustries
* Note: As a consequence of this step, employment in subindustries can
* exceed the indicated employment brackets
*******************************************************************

gen code0=0
gen imp_emp6=.
forvalues v=0/4 {
   local z=`v'+1
   local y=`z'+1

   * employment in firms with n-digit code that lack a (n+1)-digit code
   by code`v'cty, sort: egen tot_chg`z'=sum(imp_emp`z'*(level==`v'))
   summ tot_chg`z' if level==`v'
   * compute employment in all subindustries, by county
   by code`v'cty, sort: egen base_`z'=sum(imp_emp`z'*(level==`z'))
   * compute share of employment reduction that will be atributed to given industry
   gen sh_chg`z'=imp_emp`z'/base_`z' if level==`z' & base_`z'!=0
   summ sh_chg`z' if level==`z'

   * if county employment in subindustries is zero: assign employment according to national distribution
   * compute employment in all subindustries, nationwide
   by code`v', sort: egen base_`v'ntl=sum(imp_emp`z'*(level==`z'))
   by code`z', sort: egen base_`z'ntl=sum(imp_emp`z'*(level==`z'))
   summ base_`v'ntl if level==`v'
   summ base_`z'ntl if level==`z'
   * compute share of employment reduction that will be atrributed to given industry
   replace sh_chg`z'=base_`z'ntl/base_`v'ntl if level==`z' & base_`z'==0
   summ sh_chg`z' if level==`z'

   * check that attribution shares sum to one
   by code`v'cty, sort: egen tot_shchg`z'=sum(sh_chg`z'*(level==`z'))
   summ tot_shchg`z' if level==`z'

   * adjust imputed subindustry employment
   summ imp_emp`z' if level==`z'
   gen imp_empadd`z'=sh_chg`z'*tot_chg`z' if level==`z'
   summ imp_empadd`z' if level==`z'
   replace imp_emp`z'=imp_emp`z'+imp_empadd`z' if level==`z' & imp_empadd`z'>0
   summ imp_emp`z' if level==`z'

   * employment that has been newly assigned to level n has missing (n+1) code
   summ imp_emp`y' if level==`z'
   replace imp_emp`y'=imp_emp`y'+imp_empadd`z' if level==`z' & imp_empadd`z'>0
   summ imp_emp`y' if level==`z'

   drop base_*ntl
}
drop imp_emp6



*******************************************************************
* Descriptives after adjustments for firms with imprecise industry
* information
*******************************************************************

* imputed employment
forvalues v=0/5 {
   disp "Employment counts, level `v', before consistency adjustments"
   summ imp_emp`v' if level==`v'
   summ imp_emp`v' if level==`v' & imp_emp`v'!=0
}


* aggregation of employment counts
forvalues v=0/4 {
   local z=`v'+1
   drop imp_emp`v'raw
   by code`v'cty, sort: egen imp_emp`v'raw=sum(imp_emp`z'*(level==`z'))
   * (n+1)-digit counts sum to n-digit totals
   gen agg`v'ok=(imp_emp`v'raw==imp_emp`v')*(level==`v')
   * absolute value of relative deviations
   gen reldev`v'=(abs(imp_emp`v'raw-imp_emp`v'))/imp_emp`v' if level==`v'
   replace reldev`v'=0 if imp_emp`v'==0
   gen agg`v'approxok=(abs(reldev`v')<.001) if level==`v'

   disp "sum of level `z' equals to level `v'"
   summ agg`v'ok if level==`v'
   disp "sum of level `z' within 0.1% of level `v'"
   summ agg`v'approxok if level==`v'
   disp "sum of level `z' within 0.1% of level `v', no aggregation flag"
   summ agg`v'approxok if level==`v' & error_aggregation==0
   disp "absolute value of relative deviations, level `v'"
   summ reldev`v' if level==`v'

   drop agg`v'* reldev`v'
}


* share of employment in unclassified auxiliary industries

egen totemp=sum(imp_emp2*(level==2))
egen missing=sum(imp_emp2*(level==2)*(code1==950000))
gen sh_indmissing=missing/totemp
summ sh_indmissing if level==0
drop missing sh_indmissing

* share of employment that does not have an industry code

egen missing=sum(imp_emp2*(level==2)*(code1==990000))
gen sh_indmissing=missing/totemp
summ sh_indmissing if level==0

* share of employment that does not have a county code (only a state code)

egen ctymiss=sum(imp_emp2*(level==2)*(fipscty2==999))
gen sh_ctymissing=ctymiss/totemp
summ sh_ctymissing if level==0


*******************************************************************
* Generate single employment variable
*******************************************************************

gen imp_emp=.
forvalues v=0/5 {
   replace imp_emp=imp_emp`v' if level==`v'
}


*******************************************************************
* Save file
*******************************************************************

drop code0 code*cty
keep countyid code* level imp_emp est
gen yr=2000

save ../dta/CBP_2000adj.dta, replace

erase cbp2000temp.dta

log close
