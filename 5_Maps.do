clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use ddayreg_89_2014_`gs'.dta

*Corn
*regressions
local c1=27
local c2=37

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips) 
estimate save "total", replace

local c1=29
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d


areg cause_10_loss_lia DD*d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips)
estimate save "drought", replace


local c1=28
local c2=37


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

areg cause_12_loss_lia DD*m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips) 
estimate save "moisture", replace



local c1=30
local c2=39

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

areg cause_25_loss_lia DD*h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips)
estimate save "heat", replace


local c1=24
local c2=36

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

areg cold_related_loss_lia DD*f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips)
estimate save "freeze", replace


preserve
keep DD*loss_lia loss_lia year cropcode stcofips ppt ppt2 statecode time time2 total_acres 
keep if loss_lia!=. & cropcode==41
save baseline.dta, replace
restore

preserve
keep DD*d cause_10_loss_lia year cropcode stcofips 
keep if cause_10_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

preserve
keep DD*m cause_12_loss_lia year cropcode stcofips 
keep if cause_12_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

preserve
keep DD*h cause_25_loss_lia year cropcode stcofips 
keep if cause_25_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

preserve
keep DD*f cold_related_loss_lia year cropcode stcofips 
keep if cold_related_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

*warming impacts;
use Dryland1989_2014_warmingapr_sep.dta, clear

*cold-related losses (freeze is often used as the naming purpose)
gen cold_related_loss_lia=cause_6_loss_lia+cause_21_loss_lia+cause_22_loss_lia

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

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_f_1
rename DD`c1'_`c2' DDsecond_f_1
rename DD`c2'_inf DDthird_f_1



preserve
keep DD*loss_lia_1 loss_lia year cropcode stcofips 
keep if loss_lia!=. & cropcode==41
save plusone.dta, replace
restore

preserve
keep DD*d_1 cause_10_loss_lia year cropcode stcofips 
keep if cause_10_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore

preserve
keep DD*m_1 cause_12_loss_lia year cropcode stcofips 
keep if cause_12_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore

preserve
keep DD*h_1 cause_25_loss_lia year cropcode stcofips 
keep if cause_25_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore

preserve
keep DD*f_1 cold_related_loss_lia year cropcode stcofips 
keep if cold_related_loss_lia!=. & cropcode==41
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore

**** baseline and warming data****
use baseline.dta, clear
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta

preserve
keep if cropcode==41
rename stcofips fips

collapse loss_lia, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format loss_lia %5.3f
spmap loss_lia using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(PuBuGn) title("Corn")  
graph export fig2_average_lcr_corn.eps, replace
restore

*map
preserve
keep if cropcode==41 
est use "total"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_loss_lia=DDfirst_loss_lia_1 if dup==2
replace DDsecond_loss_lia=DDsecond_loss_lia_1 if dup==2
replace DDthird_loss_lia=DDthird_loss_lia_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==41

keep if cropcode==41 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips)  ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Oranges) title("Corn")  saving(total, replace)
graph export fig4_warming_total_corn.eps, replace
restore

*map
preserve
keep if cropcode==41 
est use "drought"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_d=DDfirst_d_1 if dup==2
replace DDsecond_d=DDsecond_d_1 if dup==2
replace DDthird_d=DDthird_d_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==41

keep if cropcode==41 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips)  ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Reds) title("Drought")  saving(drought, replace)
restore

*map
preserve
keep if cropcode==41 
est use "moisture"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_m=DDfirst_m_1 if dup==2
replace DDsecond_m=DDsecond_m_1 if dup==2
replace DDthird_m=DDthird_m_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==41

keep if cropcode==41 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips)  ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Greens) title("Excess Moisture")  saving(moisture, replace)
restore

*map
preserve
keep if cropcode==41 
est use "heat"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_h=DDfirst_h_1 if dup==2
replace DDsecond_h=DDsecond_h_1 if dup==2
replace DDthird_h=DDthird_h_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==41

keep if cropcode==41 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Heat) title("Heat")  saving(heat, replace)
restore

*map
preserve
keep if cropcode==41 
est use "freeze"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_f=DDfirst_f_1 if dup==2
replace DDsecond_f=DDsecond_f_1 if dup==2
replace DDthird_f=DDthird_f_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==41

keep if cropcode==41 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Blues) title("Cold-related")  saving(cold_related, replace)
restore

graph combine drought.gph moisture.gph heat.gph cold_related.gph, col(2) graphregion(color(white)) imargin(0 0 0 0) title("Corn")
graph export fig5_warming_by_cause_corn.eps, replace


rm baseline.dta
rm plusone.dta
rm total.ster
rm drought.ster
rm moisture.ster
rm heat.ster
rm freeze.ster


*Soybeans

clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use ddayreg_89_2014_`gs'.dta

*regressions
local c1=28
local c2=38

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) 
estimate save "total", replace

local c1=30
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d

areg cause_10_loss_lia DD*d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips)  
estimate save "drought", replace

local c1=32
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

areg cause_12_loss_lia DD*m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips)  
estimate save "moisture", replace

local c1=33
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

areg cause_25_loss_lia DD*h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) 
estimate save "heat", replace

local c1=24
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

areg cold_related_loss_lia DD*f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips)  
estimate save "freeze", replace


preserve
keep DD*loss_lia loss_lia year cropcode stcofips ppt ppt2 statecode time time2 total_acre 
keep if loss_lia!=. & cropcode==81
save baseline.dta, replace
restore

preserve
keep DD*d cause_10_loss_lia year cropcode stcofips 
keep if cause_10_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

preserve
keep DD*m cause_12_loss_lia year cropcode stcofips 
keep if cause_12_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

preserve
keep DD*h cause_25_loss_lia year cropcode stcofips 
keep if cause_25_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

preserve
keep DD*f cold_related_loss_lia year cropcode stcofips 
keep if cold_related_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip cropcode stcofip using baseline.dta
drop _merge
save baseline.dta, replace
restore

*warming impacts;
use Dryland1989_2014_warmingapr_sep.dta, clear

*cold-related losses
gen cold_related_loss_lia=cause_6_loss_lia+cause_21_loss_lia+cause_22_loss_lia


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

preserve
keep DD*loss_lia_1 loss_lia year cropcode stcofips 
keep if loss_lia!=. & cropcode==81
save plusone.dta, replace
restore

preserve
keep DD*d_1 cause_10_loss_lia year cropcode stcofips 
keep if cause_10_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore

preserve
keep DD*m_1 cause_12_loss_lia year cropcode stcofips 
keep if cause_12_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore

preserve
keep DD*h_1 cause_25_loss_lia year cropcode stcofips 
keep if cause_25_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore

preserve
keep DD*f_1 cold_related_loss_lia year cropcode stcofips 
keep if cold_related_loss_lia!=. & cropcode==81
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta
drop _merge
save plusone.dta, replace
restore


**** Baseline and warming data
use baseline.dta, clear
merge 1:1 year cropcode stcofip cropcode stcofip  using plusone.dta

preserve
keep if cropcode==81
rename stcofips fips

collapse loss_lia, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format loss_lia %5.3f
spmap loss_lia using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(PuBuGn) title("Soybeans")  
graph export fig2_average_lcr_soybeans.eps, replace
restore

*map
preserve
keep if cropcode==81 
est use "total"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_loss_lia=DDfirst_loss_lia_1 if dup==2
replace DDsecond_loss_lia=DDsecond_loss_lia_1 if dup==2
replace DDthird_loss_lia=DDthird_loss_lia_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==81

keep if cropcode==81 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Oranges) title("Soybeans")  saving(total, replace)
graph export fig4_warming_total_soybeans.eps, replace
restore

*map
preserve
keep if cropcode==81 
est use "drought"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_d=DDfirst_d_1 if dup==2
replace DDsecond_d=DDsecond_d_1 if dup==2
replace DDthird_d=DDthird_d_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==81

keep if cropcode==81 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Reds) title("Drought")  saving(drought, replace)
restore

*map
preserve
keep if cropcode==81 
est use "moisture"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_m=DDfirst_m_1 if dup==2
replace DDsecond_m=DDsecond_m_1 if dup==2
replace DDthird_m=DDthird_m_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==81

keep if cropcode==81 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Greens) title("Excess Moisture")  saving(moisture, replace)
restore

*map
preserve
keep if cropcode==81 
est use "heat"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_h=DDfirst_h_1 if dup==2
replace DDsecond_h=DDsecond_h_1 if dup==2
replace DDthird_h=DDthird_h_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==81

keep if cropcode==81 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Heat) title("Heat")  saving(heat, replace)
restore

*map
preserve
keep if cropcode==81 
est use "freeze"
areg
expand 2
bys year cropcode stcofip: gen dup=_n

replace DDfirst_f=DDfirst_f_1 if dup==2
replace DDsecond_f=DDsecond_f_1 if dup==2
replace DDthird_f=DDthird_f_1 if dup==2

predict totalhat if dup==1
predict totalhat_1 if dup==2

bys year cropcode stcofip: egen totalloss=sum(totalhat)
bys year cropcode stcofip: egen totalloss_1=sum(totalhat_1)

gen difftotal=totalloss_1-totalloss

summ difftotal if cropcode==81

keep if cropcode==81 & dup==1
rename stcofips fips

collapse difftotal, by(fips)
merge m:1 fips using "cb_2017_us_county_20m_dryland.dta"

format difftotal %5.3f
spmap difftotal using "cb_2017_us_county_20m_shp_dryland.dta", id(fips) ndf(gray) ndl("no data") cln(5) ///
legend(pos(4)) fcolor(Blues) title("Cold-related")  saving(cold_related, replace)
restore

graph combine drought.gph moisture.gph heat.gph cold_related.gph, col(2) graphregion(color(white)) imargin(0 0 0 0) title("Soybeans")
graph export fig5_warming_by_cause_soybeans.eps, replace

rm baseline.dta
rm plusone.dta
rm total.ster
rm drought.ster
rm moisture.ster
rm heat.ster
rm freeze.ster

rm drought.gph 
rm moisture.gph
rm heat.gph 
rm cold_related.gph




