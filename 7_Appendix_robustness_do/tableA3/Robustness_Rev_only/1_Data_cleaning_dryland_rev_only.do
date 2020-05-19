clear all 
set more off
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang/"
local gs apr_sep

*COL data
use col_all_48to15.dta
encode cause, gen(causecode_alp)
tabulate causecode_alp, gen(cause_d_)
keep if year>1988 & year<2015
keep if cropcode==41 | cropcode==81
keep if plancode!=1 & plancode!=4 & plancode!=12 & plancode!=90
*keep if plancode==2 | plancode==3 | plancode==25 | plancode==42 | plancode==44
bys year statecode countycode cropcode: egen total_loss=sum(loss)

quietly{
forval i=1/44{
gen cause_`i'_loss=cause_d_`i'*loss
bys year statecode countycode cropcode: egen total_cause_`i'=sum(cause_`i'_loss)
replace total_cause_`i'=0 if total_cause_`i'==.
drop cause_`i'_loss cause_d_`i'
}
}
sort year statecode countycode cropcode plancode total_loss
bys year statecode countycode cropcode: gen sequence=_n
keep if sequence==1

keep year statecode countycode cropcode total_loss total_cause_*
save col_1989_2014_rev, replace

*SOB data
clear all
set more off
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang/"
use all_sob_1989_2014.dta

rename total_premium premium
keep if crop_code==41 | crop_code==81
keep if insurance_plan!=1 & insurance_plan!=4 & insurance_plan!=12 & insurance_plan!=90
*keep if insurance_plan==2 | insurance_plan==3 | insurance_plan==25 | insurance_plan==42 | insurance_plan==44


sort crop_year state_code county_code crop_code liability
bys crop_year state_code county_code crop_code: egen total_liability=sum(liability)
bys crop_year state_code county_code crop_code: egen total_premium=sum(premium)
bys crop_year state_code county_code crop_code: egen total_subsidy=sum(subsidy)
bys crop_year state_code county_code crop_code: egen total_indemnity=sum(indemnity)
bys crop_year state_code county_code crop_code: egen total_acres=sum(net_reported_acres)
bys crop_year state_code county_code crop_code: gen sequence=_n

keep if sequence==1
drop insurance_plan insurance_plan_abb coverage_category coverage_level delivery_id policies_sold policies_earning policies_ind net_reported_acres liability premium subsidy indemnity loss_ratio

merge m:1 crop_year using ppi
keep if _merge==3
drop _merge

merge m:1 crop_year state_code county_code crop_code using "corn_yield.dta"
drop _merge
merge m:1 crop_year state_code county_code crop_code using "soybeans_yield.dta", update
drop _merge

*rename variables
rename crop_year year
rename state_code statecode 
rename county_code countycode 
rename crop_code cropcode

*merge with cause of loss data
merge 1:1 year statecode countycode cropcode using "col_1989_2014_rev.dta"
rename _merge mergesobcol

*fips code
gen stcofips=statecode*1000+countycode
gen fips=stcofips

*Weather Data apr_sep
preserve
*merge m:1 year fips using PRISM_1989_2016_`gs'
merge m:1 year fips using PRISM_1989_2014_`gs'

keep if _merge==3
drop _merge

merge m:1 stcofips using uscounty_coor_cont.dta
keep if _merge==3

drop _merge

keep if longitude>-100
save Dryland1989_2014_`gs'_rev.dta, replace
restore


clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
local gs apr_sep
use Dryland1989_2014_`gs'_rev.dta

gen ppt=prec
gen time=year-1988

*loss per dollar of liability by cause (heat is 25)
quietly{
forval i=1/44{
gen cause_`i'_loss_lia=total_cause_`i'/total_liability
gen cause_`i'_share=total_cause_`i'/total_loss
gen lntotal_cause_`i'=ln(total_cause_`i')
}
}

*loss(indemnity) per dollar liabiltiy
gen loss_lia=total_loss/total_liability

*average premium per dollar of liability
gen avgpremiumrate=total_premium/total_liability

*Quadratic trends
gen time2=time^2

*Quadratic precipitation
gen ppt2=ppt^2

*ln yields
gen lnyield=ln(yield)

gen stcofips_crop=100*stcofips+cropcode

duplicates drop stcofips_crop year, force
tsset stcofips_crop year
  
*43C higher is same as 43C
forval i=44/66{
gen dday`i'C=dday43C
}

*cold-related losses
gen cold_related_loss_lia=cause_6_loss_lia+cause_21_loss_lia+cause_22_loss_lia

save ddayreg_89_2014_`gs'_rev.dta, replace


