*Two-knot piecewise linear regs
clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use Dryland1989_2014_`gs'.dta

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

	
***Piecewise Linear***
 
forval c1 = 20/35 {
use ddayreg_89_2014_`gs'.dta, clear
  forval c2= 36/43{
    display "cut1: " `c1'
    display "cut2: " `c2'
	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C
    areg lnyield DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips)
    gen yrsq`c1'_`c2' = e(r2)
	areg loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips)
    gen lossrsq`c1'_`c2'= e(r2)
	areg cause_25_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips)
    gen heatrsq`c1'_`c2' = e(r2)
	areg cold_related_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips)
    gen freezersq`c1'_`c2'= e(r2)
	areg cause_10_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips)
    gen droughtrsq`c1'_`c2' = e(r2)
	areg cause_12_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips)
    gen moisturersq`c1'_`c2'= e(r2)
	drop DD*
	}
  collapse (mean) yrsq* lossrsq* heatrsq* freezersq* droughtrsq* moisturersq*
  gen model = "pwise linear"
  reshape long yrsq`c1'_ lossrsq`c1'_ heatrsq`c1'_ freezersq`c1'_ droughtrsq`c1'_ moisturersq`c1'_, i(model) string j(cut2)
  gen cut1=`c1'
  destring cut2, replace
  rename yrsq`c1'_ yrsq
  rename lossrsq`c1'_ lossrsq
  rename heatrsq`c1'_ heatrsq
  rename freezersq`c1'_ freezersq
  rename droughtrsq`c1'_ droughtrsq
  rename moisturersq`c1'_ moisturersq
  order model cut1 cut2
  save /Users/jisangyu/Dropbox/Temp/temp/Rsq_`c1'.dta, replace
  }

use /Users/jisangyu/Dropbox/Temp/temp/Rsq_20.dta, clear
forval c1 = 21/35 {
  append using /Users/jisangyu/Dropbox/Temp/temp/Rsq_`c1'.dta
  }
save /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, replace

quietly{
forval c1 =20/35 {
  rm /Users/jisangyu/Dropbox/Temp/temp/Rsq_`c1'.dta
  }
}

use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort yrsq
egen max = max(yrsq)
gen check = 0
replace check = 1 if yrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'

local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg lnyield DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips) //corn
outreg2 using "pwlinear_`gs'_twoknots.tex", replace keep(DD*) label ctitle(Corn, "$\ln(Yield)$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag)


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort lossrsq
egen max = max(lossrsq)
gen check = 0
replace check = 1 if lossrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips) //corn
outreg2 using "pwlinear_`gs'_twoknots.tex", append keep(DD*) label ctitle(Corn, "$\frac{Total\;Loss}{Lia}$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag)


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort heatrsq
egen max = max(heatrsq)
gen check = 0
replace check = 1 if heatrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "0\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cause_25_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips) //corn
outreg2 using "pwlinear_`gs'_twoknots_hf.tex", replace keep(DD*) label ctitle(Corn, "$\frac{Heat\;Loss}{Lia}$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag)


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort freezersq
egen max = max(freezersq)
gen check = 0
replace check = 1 if freezersq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cold_related_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips)  //corn
outreg2 using "pwlinear_`gs'_twoknots_hf.tex", append keep(DD*) label ctitle(Corn, "$\frac{Cold-related\;Loss}{Lia}$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag)


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort droughtrsq
egen max = max(droughtrsq)
gen check = 0
replace check = 1 if droughtrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cause_10_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips) //corn
outreg2 using "pwlinear_`gs'_twoknots_dm.tex", replace keep(DD*) label ctitle(Corn, "$\frac{Drought\;Loss}{Lia}$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag)


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort moisturersq
egen max = max(moisturersq)
gen check = 0
replace check = 1 if moisturersq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cause_12_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(stcofips) //corn
outreg2 using "pwlinear_`gs'_twoknots_dm.tex", append keep(DD*) label ctitle(Corn, "$\frac{Moisture\;Loss}{Lia}$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag) 

***soybeans***
forval c1 = 20/35 {
use ddayreg_89_2014_`gs'.dta, clear
  forval c2 = 36/43 {
    display "cut1: " `c1'
    display "cut2: " `c2'
	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
	gen DD`c2'_inf= dday`c2'C
    areg lnyield DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)
    gen yrsq`c1'_`c2' = e(r2)
	areg loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)
    gen lossrsq`c1'_`c2'= e(r2)
	areg cause_25_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)
    gen heatrsq`c1'_`c2' = e(r2)
	areg cold_related_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)
    gen freezersq`c1'_`c2'= e(r2)
	areg cause_10_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)
    gen droughtrsq`c1'_`c2' = e(r2)
	areg cause_12_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips)
    gen moisturersq`c1'_`c2'= e(r2)
	drop DD*
	}
  collapse (mean) yrsq* lossrsq* heatrsq* freezersq* droughtrsq* moisturersq*
  gen model = "pwise linear"
  reshape long yrsq`c1'_ lossrsq`c1'_ heatrsq`c1'_ freezersq`c1'_ droughtrsq`c1'_ moisturersq`c1'_, i(model) string j(cut2)
  gen cut1=`c1'
  destring cut2, replace
  rename yrsq`c1'_ yrsq
  rename lossrsq`c1'_ lossrsq
  rename heatrsq`c1'_ heatrsq
  rename freezersq`c1'_ freezersq
  rename droughtrsq`c1'_ droughtrsq
  rename moisturersq`c1'_ moisturersq
  order model cut1 cut2
  save /Users/jisangyu/Dropbox/Temp/temp/Rsq_`c1'.dta, replace
  }

use /Users/jisangyu/Dropbox/Temp/temp/Rsq_20.dta, clear
forval c1 = 21/35 {
  append using /Users/jisangyu/Dropbox/Temp/temp/Rsq_`c1'.dta
  }
save /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, replace

quietly{
forval c1 =20/35 {
  rm /Users/jisangyu/Dropbox/Temp/temp/Rsq_`c1'.dta
  }
}

use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort yrsq
egen max = max(yrsq)
gen check = 0
replace check = 1 if yrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg lnyield DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) //soy
outreg2 using "pwlinear_`gs'_twoknots.tex", append keep(DD*) label ctitle(Soybeans, "$\ln(Yield)$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag)


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort lossrsq
egen max = max(lossrsq)
gen check = 0
replace check = 1 if lossrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) //soy
outreg2 using "pwlinear_`gs'_twoknots.tex", append keep(DD*) label ctitle(Soybeans, "$\frac{Total\;Loss}{Lia}$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag) 


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort heatrsq
egen max = max(heatrsq)
gen check = 0
replace check = 1 if heatrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cause_25_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) //soy
outreg2 using "pwlinear_`gs'_twoknots_hf.tex", append keep(DD*) label ctitle(Soybeans, "$\frac{Heat\;Loss}{Lia}$") addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag)  


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort freezersq
egen max = max(freezersq)
gen check = 0
replace check = 1 if freezersq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cold_related_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) //soy
outreg2 using "pwlinear_`gs'_twoknots_hf.tex", append keep(DD*) label ctitle(Soybeans, "$\frac{Cold-related\;Loss}{Lia}$")  addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag) 


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort droughtrsq
egen max = max(droughtrsq)
gen check = 0
replace check = 1 if droughtrsq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cause_10_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) //soy
outreg2 using "pwlinear_`gs'_twoknots_dm.tex", append keep(DD*) label ctitle(Soybeans, "$\frac{Drought\;Loss}{Lia}$")  addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag) 


use /Users/jisangyu/Dropbox/Temp/temp/Rsq.dta, clear
sort moisturersq
egen max = max(moisturersq)
gen check = 0
replace check = 1 if moisturersq == max
keep if check == 1
local c1 = cut1[1]
display `c1'
local c2 = cut2[1]
display `c2'
local gs apr_sep 
use ddayreg_89_2014_`gs'.dta, clear
gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst
rename DD`c1'_`c2' DDsecond
rename DD`c2'_inf DDthird

label var DDfirst "10\celsius\;to Cut1"
label var DDsecond "Cut1 to Cut2"
label var DDthird "Cut2 to Inf"

areg cause_12_loss_lia DD* ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(stcofips) //soy
outreg2 using "pwlinear_`gs'_twoknots_dm.tex", append keep(DD*) label ctitle(Soybeans, "$\frac{Moisture\;Loss}{Lia}$")  addtext(Knot 1, `c1'\celsius, Knot 2, `c2'\celsius) tex(frag) 


