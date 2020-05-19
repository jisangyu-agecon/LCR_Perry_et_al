clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
local gs mar_oct
use ddayreg_89_2014_`gs'.dta

*Corn counties
preserve
keep loss_lia cropcode stcofips year
keep if loss_lia!=. & cropcode==41
collapse (mean) loss_lia, by(stcofips)
save corn_counties.dta, replace
restore

*baseline weather
use corn_counties.dta, clear
gen fips=stcofips
merge 1:m fips using PRISM_1989_2016_`gs'
keep if _merge==3
drop _merge

xtset fips year

*tempbin
egen tempbin_minus9=rowtotal(tempBinMinus9C tempBinMinus8C tempBinMinus7C)
egen tempbin_minus6=rowtotal(tempBinMinus6C tempBinMinus5C tempBinMinus4C)
egen tempbin_minus3=rowtotal(tempBinMinus3C tempBinMinus2C tempBinMinus1C)

gen tempbin_negative=tempbin_minus9+tempbin_minus6+tempbin_minus3

*ddays for corn reg
	gen DD0_10=dday0C-dday10C
	
local c1=27
local c2=37

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

local c1=29
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d

local c1=28
local c2=37


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m


local c1=30
local c2=39

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

local c1=24
local c2=36

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

local c1=35
local c2=40

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_hw
rename DD`c1'_`c2' DDsecond_hw
rename DD`c2'_inf DDthird_hw
save baseline_corn.dta, replace

*plusone weather
use corn_counties.dta, clear
gen fips=stcofips
merge 1:m fips using PRISM_1989_2016_v2plus1_`gs'
keep if _merge==3
drop _merge

xtset fips year

*tempbin
egen tempbin_minus9=rowtotal(tempBinMinus9C tempBinMinus8C tempBinMinus7C)
egen tempbin_minus6=rowtotal(tempBinMinus6C tempBinMinus5C tempBinMinus4C)
egen tempbin_minus3=rowtotal(tempBinMinus3C tempBinMinus2C tempBinMinus1C)

gen tempbin_negative_1=tempbin_minus9+tempbin_minus6+tempbin_minus3
drop tempbin_minus*

*ddays for corn reg
	gen DD0_10_1=dday0C-dday10C
	
local c1=27
local c2=37

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia_1
rename DD`c1'_`c2' DDsecond_loss_lia_1
rename DD`c2'_inf DDthird_loss_lia_1


local c1=29
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_d_1
rename DD`c1'_`c2' DDsecond_d_1
rename DD`c2'_inf DDthird_d_1


local c1=28
local c2=37

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_m_1
rename DD`c1'_`c2' DDsecond_m_1
rename DD`c2'_inf DDthird_m_1


local c1=30
local c2=39

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_h_1
rename DD`c1'_`c2' DDsecond_h_1
rename DD`c2'_inf DDthird_h_1


local c1=24
local c2=36

	gen DD0_10=dday0C-dday10C
	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_f_1
rename DD`c1'_`c2' DDsecond_f_1
rename DD`c2'_inf DDthird_f_1

local c1=35
local c2=40

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_hw_1
rename DD`c1'_`c2' DDsecond_hw_1
rename DD`c2'_inf DDthird_hw_1

save plusone_corn.dta, replace

*merge
use baseline_corn.dta, clear
merge 1:1 stcofips year using plusone_corn.dta
drop _merge

collapse (mean) DD* tempbin_negative*
save warming_corn_`gs'.dta, replace




clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
local gs mar_oct
use ddayreg_89_2014_`gs'.dta

*Soybeans counties
preserve
keep loss_lia cropcode stcofips year
keep if loss_lia!=. & cropcode==81
collapse (mean) loss_lia, by(stcofips)
save soy_counties.dta, replace
restore

*baseline weather
use soy_counties.dta, clear
gen fips=stcofips
merge 1:m fips using PRISM_1989_2016_`gs'
keep if _merge==3
drop _merge

xtset fips year

*ddays for soy reg
local c1=28
local c2=38

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

local c1=30
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d

local c1=32
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

local c1=33
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

local c1=24
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

local c1=34
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_hw
rename DD`c1'_`c2' DDsecond_hw
rename DD`c2'_inf DDthird_hw

save baseline_soy.dta, replace

*plusone weather
use soy_counties.dta, clear
gen fips=stcofips
merge 1:m fips using PRISM_1989_2016_v2plus1_`gs'
keep if _merge==3
drop _merge

xtset fips year

*tempbin
egen tempbin_minus9=rowtotal(tempBinMinus9C tempBinMinus8C tempBinMinus7C)
egen tempbin_minus6=rowtotal(tempBinMinus6C tempBinMinus5C tempBinMinus4C)
egen tempbin_minus3=rowtotal(tempBinMinus3C tempBinMinus2C tempBinMinus1C)

gen tempbin_negative_1=tempbin_minus9+tempbin_minus6+tempbin_minus3
drop tempbin_minus*

*ddays for soy reg
	gen DD0_10_1=dday0C-dday10C

local c1=28
local c2=38

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia_1
rename DD`c1'_`c2' DDsecond_loss_lia_1
rename DD`c2'_inf DDthird_loss_lia_1

local c1=30
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_d_1
rename DD`c1'_`c2' DDsecond_d_1
rename DD`c2'_inf DDthird_d_1

local c1=32
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_m_1
rename DD`c1'_`c2' DDsecond_m_1
rename DD`c2'_inf DDthird_m_1

local c1=33
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h_1
rename DD`c1'_`c2' DDsecond_h_1
rename DD`c2'_inf DDthird_h_1

local c1=24
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f_1
rename DD`c1'_`c2' DDsecond_f_1
rename DD`c2'_inf DDthird_f_1

local c1=34
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_hw_1
rename DD`c1'_`c2' DDsecond_hw_1
rename DD`c2'_inf DDthird_hw_1

save plusone_soy.dta, replace


*merge
use baseline_soy.dta, clear
merge 1:1 stcofips year using plusone_soy.dta
drop _merge

collapse (mean) DD* tempbin_negative*
save warming_soy_`gs'.dta, replace



