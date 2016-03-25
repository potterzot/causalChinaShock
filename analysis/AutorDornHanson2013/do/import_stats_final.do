*******************************************************************
* Import and Export Statistics
*******************************************************************

* David Dorn, July 28, 2010

* Input file: import_levels.dta, export_levels.dta

* This file creates descriptive statistics for import and export volumes


*******************************************************************
* Administrative Commands
*******************************************************************

cap log close
set more off
clear
set memory 50m

log using ../log/import_stats_final.log, text replace


*******************************************************************
* Import levels
*******************************************************************

use ../dta/import_levels.dta, clear

foreach v in usch uslw usce ushi otch otlw otce othi {
   foreach y in 1991 2000 2007 {
	  disp "imports `v', year `y'"
      summ l_totimp_`v'_`y'
   }
}


*******************************************************************
* Export levels
*******************************************************************

use ../dta/export_levels.dta, clear


foreach v in usch otch {
   foreach y in 1992 2000 2007 {
	  disp "exports `v', year `y'"
      summ l_totexp_`v'_`y'
   }
}

log close
