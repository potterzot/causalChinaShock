drop _all

* THIS FILE GRAPHS THE SHARE OF US GOODS IMPORTS FROM CHINA 1987 TO 2007 (Autor-Dorn-Hanson, Figure 1)

set scheme s2color

use ../dta/figure1_data.dta, clear

twoway (line impr year, lpattern(solid) yaxis(1)) (line cpsman year, lpattern(dash) yaxis(2)) if year>1986 & year<2008, xlab(1987(2)2007) legend(cols(1) lab(1 "China import penetration ratio") lab(2 "Manufacturing employment/Population")) saving(../gph/figure1.gph,replace)
