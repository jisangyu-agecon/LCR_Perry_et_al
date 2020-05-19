clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use ddayreg_89_2014_`gs'.dta

preserve
keep if cropcode==41
xtset stcofips year

xtsum loss_lia
restore

*table 1
preserve
keep if cropcode==41
corr loss_lia cause_10_loss_lia cause_12_loss_lia cause_25_loss_lia cause_26_loss_lia cold_related_loss_lia dday29 prec
summ loss_lia cause_10_loss_lia cause_12_loss_lia cause_25_loss_lia cause_26_loss_lia cold_related_loss_lia dday29 prec if loss_lia!=.
restore

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
areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "total", replace

local c1=29
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d


areg cause_10_loss_lia DD*d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "drought", replace


local c1=28
local c2=37


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

areg cause_12_loss_lia DD*m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "moisture", replace



local c1=30
local c2=39

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

areg cause_25_loss_lia DD*h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "heat", replace


local c1=24
local c2=36

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

areg cold_related_loss_lia DD*f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "freeze", replace

local c1=35
local c2=40

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_hw
rename DD`c1'_`c2' DDsecond_hw
rename DD`c2'_inf DDthird_hw

areg cause_26_loss_lia DD*hw ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "hw", replace

*warming impact 
use warming_corn.dta, clear

est use "total"
areg
nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
(DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
(DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
outreg2 using warming_corn.tex, replace

est use "drought"
areg
nlcom (DDfirst_d_1-DDfirst_d)*_b[DDfirst_d]+ ///
(DDsecond_d_1-DDsecond_d)*_b[DDsecond_d]+ ///
(DDthird_d_1-DDthird_d)*_b[DDthird_d], post
outreg2 using warming_corn.tex, append

est use "moisture"
areg
nlcom (DDfirst_m_1-DDfirst_m)*_b[DDfirst_m]+ ///
(DDsecond_m_1-DDsecond_m)*_b[DDsecond_m]+ ///
(DDthird_m_1-DDthird_m)*_b[DDthird_m], post
outreg2 using warming_corn.tex, append

est use "heat"
areg
nlcom (DDfirst_h_1-DDfirst_h)*_b[DDfirst_h]+ ///
(DDsecond_h_1-DDsecond_h)*_b[DDsecond_h]+ ///
(DDthird_h_1-DDthird_h)*_b[DDthird_h], post
outreg2 using warming_corn.tex, append

est use "freeze"
areg
nlcom (DDfirst_f_1-DDfirst_f)*_b[DDfirst_f]+ ///
(DDsecond_f_1-DDsecond_f)*_b[DDsecond_f]+ ///
(DDthird_f_1-DDthird_f)*_b[DDthird_f], post
outreg2 using warming_corn.tex, append

est use "hw"
areg
nlcom (DDfirst_hw_1-DDfirst_hw)*_b[DDfirst_hw]+ ///
(DDsecond_hw_1-DDsecond_hw)*_b[DDsecond_hw]+ ///
(DDthird_hw_1-DDthird_hw)*_b[DDthird_hw], post
outreg2 using warming_corn.tex, append

rm total.ster
rm drought.ster
rm moisture.ster
rm heat.ster
rm freeze.ster
rm hw.ster


*Soybeans

clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use ddayreg_89_2014_`gs'.dta

preserve
keep if cropcode==81
xtset stcofips year
xtsum loss_lia
restore

*table 2
preserve
keep if cropcode==81
corr loss_lia cause_10_loss_lia cause_12_loss_lia cause_25_loss_lia cause_26_loss_lia cold_related_loss_lia dday29 prec
summ loss_lia cause_10_loss_lia cause_12_loss_lia cause_25_loss_lia cause_26_loss_lia cold_related_loss_lia dday29 prec if loss_lia!=.
restore

*regressions
local c1=28
local c2=38

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "total", replace

local c1=30
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d

areg cause_10_loss_lia DD*d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)  cluster(year)   
estimate save "drought", replace

local c1=32
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

areg cause_12_loss_lia DD*m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)   
estimate save "moisture", replace

local c1=33
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

areg cause_25_loss_lia DD*h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)  
estimate save "heat", replace

local c1=24
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

areg cold_related_loss_lia DD*f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "freeze", replace

local c1=34
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_hw
rename DD`c1'_`c2' DDsecond_hw
rename DD`c2'_inf DDthird_hw

areg cause_26_loss_lia DD*hw ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "hw", replace

*warming impacts
use warming_soy.dta, clear

est use "total"
areg
nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
(DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
(DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
outreg2 using warming_soy.tex, replace

est use "drought"
areg
nlcom (DDfirst_d_1-DDfirst_d)*_b[DDfirst_d]+ ///
(DDsecond_d_1-DDsecond_d)*_b[DDsecond_d]+ ///
(DDthird_d_1-DDthird_d)*_b[DDthird_d], post
outreg2 using warming_soy.tex, append

est use "moisture"
areg
nlcom (DDfirst_m_1-DDfirst_m)*_b[DDfirst_m]+ ///
(DDsecond_m_1-DDsecond_m)*_b[DDsecond_m]+ ///
(DDthird_m_1-DDthird_m)*_b[DDthird_m], post
outreg2 using warming_soy.tex, append

est use "heat"
areg
nlcom (DDfirst_h_1-DDfirst_h)*_b[DDfirst_h]+ ///
(DDsecond_h_1-DDsecond_h)*_b[DDsecond_h]+ ///
(DDthird_h_1-DDthird_h)*_b[DDthird_h], post
outreg2 using warming_soy.tex, append

est use "freeze"
areg
nlcom (DDfirst_f_1-DDfirst_f)*_b[DDfirst_f]+ ///
(DDsecond_f_1-DDsecond_f)*_b[DDsecond_f]+ ///
(DDthird_f_1-DDthird_f)*_b[DDthird_f], post
outreg2 using warming_soy.tex, append

est use "hw"
areg
nlcom (DDfirst_hw_1-DDfirst_hw)*_b[DDfirst_hw]+ ///
(DDsecond_hw_1-DDsecond_hw)*_b[DDsecond_hw]+ ///
(DDthird_hw_1-DDthird_hw)*_b[DDthird_hw], post
outreg2 using warming_soy.tex, append


rm total.ster
rm drought.ster
rm moisture.ster
rm heat.ster
rm freeze.ster
rm hw.ster






