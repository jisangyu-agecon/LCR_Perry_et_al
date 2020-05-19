clear all 
set more off
set matsize 10000
cd "C:\Users\EdPerry\Dropbox\RMA_cause_of_loss\data_jisang"
*cd "/Users/edwardperry/Dropbox/RMA_cause_of_loss/data_jisang"
local gs apr_sep

*apr_sep mar_aug
use ddayreg_89_2014_`gs'.dta, clear

drop if loss_lia==.

********************************************************************************
*************************************CORN***************************************
********************************************************************************

keep if cropcode==41

local c1=27
local c2=37

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

egen state_year = group(statecode year)

******************************BASELINE MODEL************************************
preserve
areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year, absorb(stcofips) cluster(year)
estimate save "Baseline", replace

use "warming_corn.dta", clear

est use "Baseline"
nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
      (DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
      (DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
	   outreg2 using adaptcorn.tex, replace ctitle(Baseline) 

restore

******************************HSIANG MODELS*************************************
*NOTE: BK FILTER DOESN'T WORK BECAUSE OF "GAPS". WILL USE BASIC MA INSTEAD.
******************************MA5
preserve
tsset stcofips year
sort stcofips year
by stcofips: gen index = _n

foreach x of varlist loss_lia DD*loss_lia ppt*  { 
	egen ma`x' = filter(`x'), lags(0/4) normalise
	drop `x'
	rename ma`x' `x'
}

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year, absorb(stcofips) cluster(year)
estimate save "MA5", replace

restore
******************************MA10
preserve
tsset stcofips year

foreach x of varlist loss_lia DD*loss_lia ppt*  { 
	egen ma`x' = filter(`x'), lags(0/9) normalise
	drop `x'
	rename ma`x' `x'
}

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year, absorb(stcofips) cluster(year)
estimate save "MA10", replace

use "warming_corn.dta", clear

restore
******************************LONG DIFF MODEL***********************************
preserve
ge trend = year-1989
ge subperiod = int(trend/13)
egen state_period = group(statecode subperiod)

foreach x of varlist loss_lia DD*loss_lia ppt* {
	bysort cropcode stcofips subperiod: egen long`x' = mean(`x')
	drop `x'
	rename long`x' `x'
}

duplicates drop cropcode stcofips subperiod, force

tab statecode, gen(state_)
foreach x of varlist state_* {
	ge `x'_per = `x'*subperiod
}

areg loss_lia DD*loss_lia ppt* i.state_period, absorb(stcofips) cluster(statecode)
estimate save "LongDiff", replace

restore
***************************CROSS-SECTION****************************************
preserve

foreach x of varlist loss_lia DD*loss_lia ppt* {
	bysort cropcode stcofips: egen cs`x' = mean(`x')
	drop `x'
	rename cs`x' `x'
}

duplicates drop stcofips cropcode, force

reg loss_lia DD*loss_lia ppt* i.statecode, cluster(statecode)  
estimate save "CrossSection", replace

restore
************************************TABLE***************************************


use "warming_corn.dta", clear

foreach m in MA5 MA10 LongDiff CrossSection {
	est use "`m'"
	nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
      (DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
      (DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
	  outreg2 using adaptcorn.tex, append ctitle(`m')
}


********************************************************************************
*************************************SOY****************************************
********************************************************************************
*apr_sep mar_aug
use ddayreg_89_2014_apr_sep.dta, clear

drop if loss_lia==.

keep if cropcode==81

local c1=28
local c2=38

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

******************************BASELINE MODEL************************************
preserve
areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year, absorb(stcofips) cluster(year)
estimate save "Baseline", replace

use "warming_soy.dta", clear

est use "Baseline"
nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
      (DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
      (DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
	   outreg2 using adaptsoy.tex, replace ctitle(Baseline) 

restore

******************************HSIANG MODELS*************************************
*NOTE: BK FILTER DOESN'T WORK BECAUSE OF "GAPS". WILL USE BASIC MA INSTEAD.
******************************MA5
preserve
tsset stcofips year

foreach x of varlist loss_lia DD*loss_lia ppt*  { 
	egen ma`x' = filter(`x'), lags(0/4) normalise
	drop `x'
	rename ma`x' `x'
}

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year, absorb(stcofips) cluster(year)
estimate save "MA5", replace

restore

******************************MA10
preserve
tsset stcofips year
 
foreach x of varlist loss_lia DD*loss_lia ppt*  { 
	egen ma`x' = filter(`x'), lags(0/9) normalise
	drop `x'
	rename ma`x' `x'
}

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year, absorb(stcofips) cluster(year)
estimate save "MA10", replace

restore

******************************LONG DIFF MODEL***********************************
preserve
ge trend = year-1989
ge subperiod = int(trend/13)
egen state_period = group(statecode subperiod)
*ge subperiod = (year>=1996 & year<=2007) + 2*(year>=2008)
*drop if subperiod==1
*tab subperiod year

foreach x of varlist loss_lia DD*loss_lia ppt* {
	bysort cropcode stcofips subperiod: egen long`x' = mean(`x')
	drop `x'
	rename long`x' `x'
}

duplicates drop cropcode stcofips subperiod, force 

areg loss_lia DD*loss_lia ppt* i.state_period, absorb(stcofips) cluster(statecode)
estimate save "LongDiff", replace

restore
***************************CROSS-SECTION****************************************
preserve

foreach x of varlist loss_lia DD*loss_lia ppt* {
	bysort cropcode stcofips: egen cs`x' = mean(`x')
	drop `x'
	rename cs`x' `x'
}

duplicates drop stcofips cropcode, force

reg loss_lia DD*loss_lia ppt* i.statecode, cluster(statecode)  
estimate save "CrossSection", replace

restore

************************************TABLE***************************************


use "warming_soy.dta", clear

foreach m in MA5 MA10 LongDiff CrossSection {
	est use "`m'"
	nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
      (DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
      (DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
	  outreg2 using adaptsoy.tex, append ctitle(`m')
}
stop



