clear all 
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
local gs apr_sep
log using robustness_more_var.tex, replace

*************************************
*************************************
*************************************
*get most popular buyup cov level, total acreage, % cat vs buyup, month of loss, and vpd data;
*************************************
*************************************
*************************************

use all_sob_1989_2014.dta

rename total_premium premium
keep if crop_code==41 | crop_code==81
sort state_code county_code crop_year crop_code insurance_plan coverage_level
rename state_code statecode
rename county_code countycode
rename crop_code cropcode
rename crop_year year

preserve

*avg cov level;
keep if coverage_category == "BUYUP"
drop if coverage_level == 0
collapse (mean) coverage_level [fweight=net_reported_acres], by(statecode countycode year cropcode)
rename coverage_level AvgBuyCovLev
save AvgBuyCovLev.dta, replace


*% cat vs buyup;
restore
preserve
tab coverage_category, missing
collapse (sum) net_reported_acres, by(statecode countycode year cropcode coverage_category) 
egen t = group(coverage_category)
egen id = group(statecode countycode year cropcode)
tsset id t
tsfill, full
replace net_reported_acres = 0 if net_reported_acres == .
egen tot = sum(net_reported_acres), by(id)
drop if tot == 0
sort id t
gen ratio = net_reported_acres/tot if t == 1
egen BuyupRatio = max(ratio), by(id)
collapse (max) BuyupRatio, by(statecode countycode year cropcode)
drop if year == .
save BuyupRatio.dta, replace


*total acreage ;
restore
collapse (sum) net_reported_acres, by(statecode countycode year cropcode)
drop if net_reported_acres == 0
rename net_reported_acres TotAcres
save TotAcres.dta, replace


*month of loss;
*note only have data from 2001 on;
use col_all_48to15.dta, clear
drop if year < 1989
keep if cropcode==41 | cropcode==81
sort statecode countycode year cropcode 
replace loss = round(loss)
drop if loss < 0
collapse (mean) monthcode [fweight=loss], by(statecode countycode year cropcode)
rename monthcode AvgMonOfLoss
save AvgMonOfLoss.dta, replace


*vpd;
use PRISMvpd_1989_2016_apr_sep, replace
gen statecode = floor(fips/1000)
gen countycode = fips - 1000*statecode
drop fips
rename vpd VPD
save VPD.dta, replace



*************************************
*************************************
*************************************
* Out of sample prediction exercise, Corn
*************************************
*************************************
*************************************

use ddayreg_89_2014_`gs'.dta, clear
merge 1:1 statecode countycode year cropcode using AvgBuyCovLev.dta, nogen
merge 1:1 statecode countycode year cropcode using BuyupRatio.dta, nogen
merge 1:1 statecode countycode year cropcode using TotAcres.dta, nogen
merge 1:1 statecode countycode year cropcode using AvgMonOfLoss.dta, nogen
merge m:1 statecode countycode year using VPD.dta, nogen

gen tot = AvgBuyCovLev + BuyupRatio + TotAcres + AvgMonOfLoss + VPD
drop if tot == .
drop tot
drop if loss_lia == . 

*Corn regressions
local c1=27
local c2=37

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

keep if cropcode==41

save CornRegData.dta, replace

*
use CornRegData.dta, clear

summ loss_lia 
local c = .8*r(N)
display `c'

set seed 106723

forvalues b = 1/1000 {

  display "b: `b'"

  use CornRegData.dta, clear
  gen u = runiform()
  sort u
  gen insam = (_n <= `c')
  summ insam
  summ loss_lia if insam == 1 
  
  quietly {
    *note that these errors ignore the absorbed FE;
    areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resPre, dr

    areg loss_lia DD*loss_lia AvgBuyCovLev ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resCov, dr

    areg loss_lia DD*loss_lia BuyupRatio ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resBuy, dr

    areg loss_lia DD*loss_lia TotAcres ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resAcr, dr

    areg loss_lia DD*loss_lia AvgMonOfLoss ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resMon, dr

    areg loss_lia DD*loss_lia VPD ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resVpd, dr

    areg loss_lia DD*loss_lia AvgBuyCovLev BuyupRatio TotAcres AvgMonOfLoss VPD ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resAll, dr

    keep if insam == 0
    keep res*

    foreach v in Pre Cov Buy Acr Mon Vpd All {
      gen rmse`v' = res`v'^2
    }  
  
    collapse (mean) rmse*

    foreach v in Pre Cov Buy Acr Mon Vpd All {
      replace rmse`v' = sqrt(rmse`v')
    }  
  

    gen boot = `b'
  }
  
  if `b' == 1 {
    save RMSECorn.dta, replace
  } 

  if `b' != 1 {
    append using RMSECorn.dta
    save RMSECorn.dta, replace
  }
 
}
*

use RMSECorn.dta, clear
collapse (mean) rmse*
list


*************************************
*************************************
*************************************
* Out of sample prediction exercise, Soybeans
*************************************
*************************************
*************************************

use ddayreg_89_2014_`gs'.dta, clear
merge 1:1 statecode countycode year cropcode using AvgBuyCovLev.dta, nogen
merge 1:1 statecode countycode year cropcode using BuyupRatio.dta, nogen
merge 1:1 statecode countycode year cropcode using TotAcres.dta, nogen
merge 1:1 statecode countycode year cropcode using AvgMonOfLoss.dta, nogen
merge m:1 statecode countycode year using VPD.dta, nogen

gen tot = AvgBuyCovLev + BuyupRatio + TotAcres + AvgMonOfLoss + VPD
drop if tot == .
drop tot
drop if loss_lia == . 

*Soybean regressions
local c1=28
local c2=38

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

keep if cropcode==81

save SoyRegData.dta, replace

*
use SoyRegData.dta, clear

summ loss_lia 
local c = .8*r(N)
display `c'

set seed 106723

forvalues b = 1/1000 {

  display "b: `b'"

  use SoyRegData.dta, clear
  gen u = runiform()
  sort u
  gen insam = (_n <= `c')
  summ insam
  summ loss_lia if insam == 1 
  
  quietly {
    *note that these errors ignore the absorbed FE;
    areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resPre, dr

    areg loss_lia DD*loss_lia AvgBuyCovLev ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resCov, dr

    areg loss_lia DD*loss_lia BuyupRatio ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resBuy, dr

    areg loss_lia DD*loss_lia TotAcres ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resAcr, dr

    areg loss_lia DD*loss_lia AvgMonOfLoss ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resMon, dr

    areg loss_lia DD*loss_lia VPD ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resVpd, dr

    areg loss_lia DD*loss_lia AvgBuyCovLev BuyupRatio TotAcres AvgMonOfLoss VPD ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if insam == 1, absorb(stcofips) 
    predict resAll, dr

	keep if insam == 0
    keep res*

    foreach v in Pre Cov Buy Acr Mon Vpd All {
      gen rmse`v' = res`v'^2
    }  
  
    collapse (mean) rmse*

    foreach v in Pre Cov Buy Acr Mon Vpd All {
      replace rmse`v' = sqrt(rmse`v')
    }  
  

    gen boot = `b'
  }
  
  if `b' == 1 {
    save RMSESoy.dta, replace
  } 

  if `b' != 1 {
    append using RMSESoy.dta
    save RMSESoy.dta, replace
  }
 
}
*

use RMSESoy.dta, clear
collapse (mean) rmse*
list




*************************************
*************************************
*************************************
* Warming impacts for alternatives, Corn  
*************************************
*************************************
*************************************

use CornRegData.dta, clear

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "CornPref", replace

areg loss_lia DD*loss_lia AvgBuyCovLev ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "CornCov", replace

areg loss_lia DD*loss_lia BuyupRatio ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "CornBuy", replace

areg loss_lia DD*loss_lia TotAcres ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "CornAcr", replace

areg loss_lia DD*loss_lia AvgMonOfLoss ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "CornMon", replace

areg loss_lia DD*loss_lia VPD ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "CornVpd", replace


use warming_corn.dta, clear

foreach m in Pref Cov Buy Acr Mon Vpd {
  est use "Corn`m'"
  display "model: `m'"
  nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
        (DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
        (DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
		outreg2 using warming_corn_`m'.tex, replace
}



*************************************
*************************************
*************************************
* Warming impacts for alternatives, Soy  
*************************************
*************************************
*************************************

use SoyRegData.dta, clear

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "SoyPref", replace

areg loss_lia DD*loss_lia AvgBuyCovLev ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "SoyCov", replace

areg loss_lia DD*loss_lia BuyupRatio ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "SoyBuy", replace

areg loss_lia DD*loss_lia TotAcres ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "SoyAcr", replace

areg loss_lia DD*loss_lia AvgMonOfLoss ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "SoyMon", replace

areg loss_lia DD*loss_lia VPD ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "SoyVpd", replace

use warming_soy.dta, clear

foreach m in Pref Cov Buy Acr Mon Vpd {
  est use "Soy`m'"
  display "model: `m'"
  nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
        (DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
        (DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
				outreg2 using warming_soy_`m'.tex, replace
}


log close

st;







