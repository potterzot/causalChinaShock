*******************************************************************
* SIC87dd Codes
*******************************************************************

* David Dorn, February 8, 2010
* Update August 13, 2011: Adjust for new version of the trade data

* This file creates a classification of manufacturing industries
* that is based on aggregated 4-digit SIC codes.
* Each of the resulting aggregate SIC codes
* - can be matched to HS import codes
* - can be matched to NAICS industry codes in the weighted Census crosswalk
* - can be consistently observed in the NBER Manufacturing Database

* This file can be called whenever the master data contains the 4-digit
* SIC industry variable "sic87"

gen sic87dd=sic87

*******************************************************************
* Step 1a: Aggregate SIC Codes that are missing due to HS-SIC
* crosswalk, using 1992 product concordance. [53 industries]
* A HS product code may map to several 4-digit SIC industries.
* For 1992, the Census provides a detailled mapping where nearly
* every SIC industry is associated with some HS codes (hs_sic5_imports_92.dta).
* However, the main HS-SIC crosswalk of the Census that is adopted by
* Pierce and Schott (2009) assigns every HS code to the one most important
* SIC industry to which it matches ("baseroot SIC"). As a consequence,
* there are some SIC codes to which no HS code maps. If a SIC industry X
* is associated with some HS codes in 1992 but does not serve as the
* baseroot for any of these codes, I determine the industry Y that is the
* baseroot for most of the HS codes ("tab sicbaseroot if sic4==X"),
* and then merge industry X into industry Y.
* E.g.: All the HS codes that map to SIC code 2052 have a baseroot
* SIC code 2051. Therefore, I merge 2052 into 2051.
*******************************************************************

replace sic87dd=2011 if sic87dd==2013
replace sic87dd=2099 if sic87dd==2038
replace sic87dd=2051 if sic87dd==2052
replace sic87dd=2051 if sic87dd==2053
replace sic87dd=2062 if sic87dd==2061
replace sic87dd=2062 if sic87dd==2063
replace sic87dd=912 if sic87dd==2092
replace sic87dd=2252 if sic87dd==2251
replace sic87dd=2341 if sic87dd==2254
replace sic87dd=2392 if sic87dd==2259

replace sic87dd=2211 if sic87dd==2261
replace sic87dd=2221 if sic87dd==2262
replace sic87dd=2824 if sic87dd==2282
replace sic87dd=2325 if sic87dd==2326
replace sic87dd=2331 if sic87dd==2361
replace sic87dd=2389 if sic87dd==2387
replace sic87dd=2395 if sic87dd==2397
replace sic87dd=2449 if sic87dd==2441
replace sic87dd=2599 if sic87dd==2511
replace sic87dd=2599 if sic87dd==2512

replace sic87dd=2599 if sic87dd==2519
replace sic87dd=2599 if sic87dd==2521
replace sic87dd=2599 if sic87dd==2531
replace sic87dd=2599 if sic87dd==2541
replace sic87dd=2621 if sic87dd==2631
replace sic87dd=2621 if sic87dd==2671
replace sic87dd=2752 if sic87dd==2754
replace sic87dd=2752 if sic87dd==2759
replace sic87dd=2874 if sic87dd==2875
replace sic87dd=3069 if sic87dd==3061

replace sic87dd=3089 if sic87dd==3086
replace sic87dd=3089 if sic87dd==3087
replace sic87dd=3312 if sic87dd==3316
replace sic87dd=3312 if sic87dd==3317
replace sic87dd=3321 if sic87dd==3322
replace sic87dd=3321 if sic87dd==3324
replace sic87dd=3321 if sic87dd==3325
replace sic87dd=3357 if sic87dd==3355
replace sic87dd=3365 if sic87dd==3363
replace sic87dd=3499 if sic87dd==3364

replace sic87dd=3499 if sic87dd==3366
replace sic87dd=3499 if sic87dd==3369
replace sic87dd=3499 if sic87dd==3451
replace sic87dd=3499 if sic87dd==3463
replace sic87dd=3482 if sic87dd==3483
replace sic87dd=3496 if sic87dd==3495
replace sic87dd=3494 if sic87dd==3498
replace sic87dd=3577 if sic87dd==3575
replace sic87dd=3714 if sic87dd==3592
replace sic87dd=3648 if sic87dd==3645

replace sic87dd=3648 if sic87dd==3646
replace sic87dd=3711 if sic87dd==3716
replace sic87dd=3728 if sic87dd==3769


*******************************************************************
* Step 1b: Aggregate SIC Codes that are missing due to HS-SIC
* crosswalk, using hand matching. [9 industries]
* This step aggregates SIC codes that are not matched with any HS
* codes in the 1992 product crosswalk.
*******************************************************************

* Aggregation of 4-digit codes within the same 3-digit industry:

* finishing plants, nec to finishing plants, manmade (which in turn merges into broadwoven fabric mills, manmade)
replace sic87dd=2221 if sic87dd==2269
* books printing to books publishing
replace sic87dd=2731 if sic87dd==2732
* bookbinding and related work to blankbooks and looseleaf binding
replace sic87dd=2782 if sic87dd==2789
* typesetting to platemaking services
replace sic87dd=2796 if sic87dd==2791
* metal heat treating to primary metal products, nec
replace sic87dd=3399 if sic87dd==3398
* dolls and stuffed toys to games, toys, and children's vehicles
replace sic87dd=3944 if sic87dd==3942
* burial caskets to mfg industries nec
replace sic87dd=3999 if sic87dd==3995

* Other aggregation:

* plating and polishing to fabricated metal products, nec
replace sic87dd=3499 if sic87dd==3471
* metal coating and allied services to metal products, nec
replace sic87dd=3499 if sic87dd==3479


*******************************************************************
* Retain only manufacturing codes
*******************************************************************

* keep if sic87dd>=2011 & sic87dd<=3999
