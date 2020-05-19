clear all 
set more off
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang/"
local gs apr_sep

*COL data
use col_all_48to15.dta
bys year statecode countycode cropcode: egen total_loss=sum(loss)
encode cause, gen(causecode_alp)
tabulate causecode_alp, gen(cause_d_)
keep if year>1988 & year<2015
keep if cropcode==41 | cropcode==81

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
save col_1989_2014, replace

*SOB data
clear all
set more off
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang/"
use all_sob_1989_2014.dta

rename total_premium premium
keep if crop_code==41 | crop_code==81

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
merge 1:1 year statecode countycode cropcode using "col_1989_2014.dta"
rename _merge mergesobcol

*fips code
gen stcofips=statecode*1000+countycode
gen fips=stcofips

*Weather Data apr_sep
preserve
merge m:1 year fips using PRISM_1989_2016_`gs'

keep if _merge==3
drop _merge

merge m:1 stcofips using uscounty_coor_cont.dta
keep if _merge==3

drop _merge

keep if longitude>-100
keep if year<2015

egen tempbin_minus9=rowtotal(tempBinMinus9C tempBinMinus8C tempBinMinus7C)
label var tempbin_minus9 "Temperature -9°C"
egen tempbin_minus6=rowtotal(tempBinMinus6C tempBinMinus5C tempBinMinus4C)
label var tempbin_minus6 "Temperature -6°C"
egen tempbin_minus3=rowtotal(tempBinMinus3C tempBinMinus2C tempBinMinus1C)
label var tempbin_minus3 "Temperature -3°C"

gen tempbin_negative=tempbin_minus9+tempbin_minus6+tempbin_minus3
label var tempbin_negative "Aggregate negative temperature exposure"

save Dryland1989_2014_`gs'.dta, replace
restore

*+1 warming Data apr_sep
preserve
merge m:1 year fips using /Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang/PRISM_1989_2016_v2plus1_`gs'
keep if _merge==3
drop _merge

merge m:1 stcofips using uscounty_coor_cont.dta
keep if _merge==3

drop _merge

keep if longitude>-100

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

egen tempbin_minus9=rowtotal(tempBinMinus9C tempBinMinus8C tempBinMinus7C)
label var tempbin_minus9 "Temperature -9°C"
egen tempbin_minus6=rowtotal(tempBinMinus6C tempBinMinus5C tempBinMinus4C)
label var tempbin_minus6 "Temperature -6°C"
egen tempbin_minus3=rowtotal(tempBinMinus3C tempBinMinus2C tempBinMinus1C)
label var tempbin_minus3 "Temperature -3°C"

gen tempbin_negative=tempbin_minus9+tempbin_minus6+tempbin_minus3
label var tempbin_negative "Aggregate negative temperature exposure"

forval i=0(3)36{
local plus1=`i'+1
local plus2=`i'+2
gen tempbin_`i'=tempBin`i'C+tempBin`plus1'C+tempBin`plus2'C
label var tempbin_`i' "Temperature `i'°C"
}
egen tempbin_39=rowtotal(tempBin39C tempBin40C tempBin41C tempBin42C tempBin43C tempBin44C tempBin45C tempBin46C tempBin47C tempBin48C tempBin49C)
label var tempbin_39 "Temperature 39°C"

replace tempbin_36=tempbin_36+tempbin_39
drop tempbin_39

*Quadratic trends
gen time2=time^2

*Quadratic precipitation
gen ppt2=ppt^2

*ln yields
gen lnyield=ln(yield)

keep if year<2015

save Dryland1989_2014_warming`gs'.dta, replace
restore

*reg data
use Dryland1989_2014_`gs'.dta, clear

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

save ddayreg_89_2014_`gs'.dta, replace



