clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
global result "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang/wider_gs_n_freeze_bin"

local gs mar_oct
use ddayreg_89_2014_`gs'.dta

*Corn
*regressions
local c1=27
local c2=37

	gen DD0_10=dday0C-dday10C
	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia
areg loss_lia tempbin_negative DD0_10 DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "total", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_c.tex", replace keep(tempbin_negative DD*) label ctitle(Corn, "Total") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=29
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d


areg cause_10_loss_lia tempbin_negative DD0_10 DD*d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "drought", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_c.tex", append keep(tempbin_negative DD*) label ctitle(Corn, "Drought") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=28
local c2=37


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

areg cause_12_loss_lia tempbin_negative DD0_10 DD*m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "moisture", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_c.tex", append keep(tempbin_negative DD*) label ctitle(Corn, "Moisture") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)


local c1=30
local c2=39


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

areg cause_25_loss_lia tempbin_negative DD0_10 DD*h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "heat", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_c.tex", append keep(tempbin_negative DD*) label ctitle(Corn, "Heat") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=24
local c2=36


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

areg cold_related_loss_lia tempbin_negative DD0_10 DD*f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "freeze", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_c.tex", append keep(tempbin_negative DD*) label ctitle(Corn, "Freeze") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=35
local c2=40


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_hw
rename DD`c1'_`c2' DDsecond_hw
rename DD`c2'_inf DDthird_hw

areg cause_26_loss_lia tempbin_negative DD0_10 DD*hw ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "hw", replace

*warming impact 
use warming_corn_`gs'.dta, clear

est use "total"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
(DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
(DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
outreg2 using "$result/warming_corn.tex", replace

est use "heat"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_h_1-DDfirst_h)*_b[DDfirst_h]+ ///
(DDsecond_h_1-DDsecond_h)*_b[DDsecond_h]+ ///
(DDthird_h_1-DDthird_h)*_b[DDthird_h], post
outreg2 using "$result/warming_corn.tex", append

est use "freeze"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_f_1-DDfirst_f)*_b[DDfirst_f]+ ///
(DDsecond_f_1-DDsecond_f)*_b[DDsecond_f]+ ///
(DDthird_f_1-DDthird_f)*_b[DDthird_f], post
outreg2 using "$result/warming_corn.tex", append

est use "drought"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_d_1-DDfirst_d)*_b[DDfirst_d]+ ///
(DDsecond_d_1-DDsecond_d)*_b[DDsecond_d]+ ///
(DDthird_d_1-DDthird_d)*_b[DDthird_d], post
outreg2 using "$result/warming_corn.tex", append

est use "moisture"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_m_1-DDfirst_m)*_b[DDfirst_m]+ ///
(DDsecond_m_1-DDsecond_m)*_b[DDsecond_m]+ ///
(DDthird_m_1-DDthird_m)*_b[DDthird_m], post
outreg2 using "$result/warming_corn.tex", append

/*est use "hw"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_hw_1-DDfirst_hw)*_b[DDfirst_hw]+ ///
(DDsecond_hw_1-DDsecond_hw)*_b[DDsecond_hw]+ ///
(DDthird_hw_1-DDthird_hw)*_b[DDthird_hw], post
outreg2 using "$result/warming_corn.tex", append
*/

rm total.ster
rm drought.ster
rm moisture.ster
rm heat.ster
rm freeze.ster
*rm hw.ster


*Soybeans

clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
local gs mar_oct
use ddayreg_89_2014_`gs'.dta


*regressions
local c1=28
local c2=38

	gen DD0_10=dday0C-dday10C
	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

areg loss_lia tempbin_negative DD0_10 DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "total", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_s.tex", replace keep(tempbin_negative DD*) label ctitle(Soybeans, "Total") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=30
local c2=41

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d

areg cause_10_loss_lia tempbin_negative DD0_10 DD*d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)  cluster(year) 
estimate save "drought", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_s.tex", append keep(tempbin_negative DD*) label ctitle(Soybeans, "Drought") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=32
local c2=36

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

areg cause_12_loss_lia tempbin_negative DD0_10 DD*m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)  
estimate save "moisture", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_s.tex", append keep(tempbin_negative DD*) label ctitle(Soybeans, "Moisture") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=33
local c2=41

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

areg cause_25_loss_lia tempbin_negative DD0_10 DD*h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)  
estimate save "heat", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_s.tex", append keep(tempbin_negative DD*) label ctitle(Soybeans, "Heat") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=24
local c2=36

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

areg cold_related_loss_lia tempbin_negative DD0_10 DD*f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "freeze", replace
outreg2 using "pwlinear_`gs'_twoknots_wider_gs_freeze_s.tex", append keep(tempbin_negative DD*) label ctitle(Soybeans, "Freeze") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius)

local c1=34
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_hw
rename DD`c1'_`c2' DDsecond_hw
rename DD`c2'_inf DDthird_hw

areg cause_26_loss_lia tempbin_negative DD0_10 DD*hw ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year) 
estimate save "hw", replace

*warming impacts
use warming_soy_`gs'.dta, clear

est use "total"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
(DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
(DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
outreg2 using "$result/warming_soy.tex", replace

est use "heat"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_h_1-DDfirst_h)*_b[DDfirst_h]+ ///
(DDsecond_h_1-DDsecond_h)*_b[DDsecond_h]+ ///
(DDthird_h_1-DDthird_h)*_b[DDthird_h], post
outreg2 using "$result/warming_soy.tex", append

est use "freeze"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_f_1-DDfirst_f)*_b[DDfirst_f]+ ///
(DDsecond_f_1-DDsecond_f)*_b[DDsecond_f]+ ///
(DDthird_f_1-DDthird_f)*_b[DDthird_f], post
outreg2 using "$result/warming_soy.tex", append

est use "drought"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_d_1-DDfirst_d)*_b[DDfirst_d]+ ///
(DDsecond_d_1-DDsecond_d)*_b[DDsecond_d]+ ///
(DDthird_d_1-DDthird_d)*_b[DDthird_d], post
outreg2 using "$result/warming_soy.tex", append

est use "moisture"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_m_1-DDfirst_m)*_b[DDfirst_m]+ ///
(DDsecond_m_1-DDsecond_m)*_b[DDsecond_m]+ ///
(DDthird_m_1-DDthird_m)*_b[DDthird_m], post
outreg2 using "$result/warming_soy.tex", append

/*est use "hw"
areg
nlcom (tempbin_negative_1-tempbin_negative)*_b[tempbin_negative]+ ///
(DD0_10_1-DD0_10)*_b[DD0_10]+ ///
(DDfirst_hw_1-DDfirst_hw)*_b[DDfirst_hw]+ ///
(DDsecond_hw_1-DDsecond_hw)*_b[DDsecond_hw]+ ///
(DDthird_hw_1-DDthird_hw)*_b[DDthird_hw], post
outreg2 using "$result/warming_soy.tex", append
*/

rm total.ster
rm drought.ster
rm moisture.ster
rm heat.ster
rm freeze.ster
*rm hw.ster






