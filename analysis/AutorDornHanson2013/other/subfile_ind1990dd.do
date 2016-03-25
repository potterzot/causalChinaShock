*******************************************************************
* IPUMS Time-Consistent Industry Codes 1980-2005
*******************************************************************

* David Dorn, March 8, 2010

* This subfile creates a balanced panel of industries for the
* Census 5% samples 1980-2000, and the 2005 ACS. The industry variable
* ind1990dd is an aggregate of the IPUMS variable ind1990.

* The file can be called whenever the data in memory contains the
* variable ind1990.


*******************************************************************
* Industry Recoding
*******************************************************************

gen ind1990dd=ind1990

* veterinary services to agricultural services, nec
replace ind1990dd=30 if ind1990==12

* yarn, thread, and fabric mills to misc. textile mill products
replace ind1990dd=150 if ind1990==142

* leather tanning and finishing to leather products except footwear
replace ind1990dd=222 if ind1990==220

* wood buildings and mobile homes to misc wood products
replace ind1990dd=241 if ind1990==232

* screw machine products to metal industries, nec
replace ind1990dd=301 if ind1990==290

* office and accounting machines to computers and related equipment
replace ind1990dd=322 if ind1990==321

* electrical machinery, equipment and supplies, ns to electrical machinery, equipment and supplies, nec
replace ind1990dd=342 if ind1990==350

* photographic equipment and supplies to misc manufacturing industries
replace ind1990dd=391 if ind1990==380

* watches, clocks, and clockwork operated devices to misc manufacturing industries
replace ind1990dd=391 if ind1990==381

* pipe lines, except natural gas to services incidental to transportation
replace ind1990dd=432 if ind1990==422

* telegraph and misc communication services to telephone communications
replace ind1990dd=441 if ind1990==442

* mobile home dealers to misc general merchandise stores
replace ind1990dd=600 if ind1990==590

* variety stores to misc general merchandise stores
replace ind1990dd=600 if ind1990==592

* dairy product stores to food stores nec
replace ind1990dd=611 if ind1990==602

* household appliance stores to misc retail stores
replace ind1990dd=682 if ind1990==632

* music stores to misc retail stores
replace ind1990dd=682 if ind1990==640

* jewelry stores to misc retail stores
replace ind1990dd=682 if ind1990==660

* automobile parking and carwashers to automotive rental and leasing, without drivers
replace ind1990dd=742 if ind1990==750

* dressmaking shops to misc personal services
replace ind1990dd=791 if ind1990==790

* offices and clinics of health practitioners, nec to health services, nec
replace ind1990dd=840 if ind1990==830

* vocational schools to educational services, nec
replace ind1990dd=860 if ind1990==851

* family child care homes to child day care service
replace ind1990dd=862 if ind1990==863

* executive and legislative offices to general government nec
replace ind1990dd=901 if ind1990==900

* all branches of active duty military (air force, navy, etc) to single category (army)
replace ind1990dd=940 if (ind1990>=941 & ind1990<=960)
