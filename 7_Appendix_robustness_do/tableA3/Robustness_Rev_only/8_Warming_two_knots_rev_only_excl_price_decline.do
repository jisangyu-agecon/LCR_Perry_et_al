clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
local gs apr_sep
use ddayreg_89_2014_`gs'_rev.dta

replace loss_lia=(total_loss-total_cause_9)/total_liability

summ loss_lia if cropcode==41

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

*warming impact 
use warming_corn.dta, clear

est use "total"
areg
nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
(DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
(DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
outreg2 using warming_corn_lcr_no_pd_rev.tex, replace

rm total.ster


*Soybeans

clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/data_jisang"
local gs apr_sep
use ddayreg_89_2014_`gs'_rev.dta

replace loss_lia=(total_loss-total_cause_9)/total_liability


summ loss_lia if cropcode==81

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


*warming impacts
use warming_soy.dta, clear

est use "total"
areg
nlcom (DDfirst_loss_lia_1-DDfirst_loss_lia)*_b[DDfirst_loss_lia]+ ///
(DDsecond_loss_lia_1-DDsecond_loss_lia)*_b[DDsecond_loss_lia]+ ///
(DDthird_loss_lia_1-DDthird_loss_lia)*_b[DDthird_loss_lia], post
outreg2 using warming_soy_lcr_no_pd_rev.tex, replace

rm total.ster






