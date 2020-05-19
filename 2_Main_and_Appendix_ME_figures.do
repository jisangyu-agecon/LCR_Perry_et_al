clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use ddayreg_89_2014_`gs'.dta
keep if cropcode==41
summ loss_lia cause_25_loss_lia cold_related_loss_lia cause_10_loss_lia cause_12_loss_lia ///
cause_6_loss_lia cause_19_loss_lia cause_22_loss_lia cause_24_loss_lia cause_26_loss_lia cause_44_loss_lia if loss_lia!=.

drop prec

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

label var DDfirst_loss_lia "DDay 10 `c1' (LCR)"
label var DDsecond_loss_lia "DDay `c1' `c2' (LCR)"
label var DDthird_loss_lia "DDay `c2' (LCR)"

areg loss_lia DD*loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year)  
estimate save "total", replace
estimate store total

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)


preserve
local c1=27
local c2=37

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_loss_lia]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_loss_lia]*(`c1'-10) + _b[DDsecond_loss_lia]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_loss_lia]*(`c1'-10) + _b[DDsecond_loss_lia]*(`c2'-`c1') + _b[DDthird_loss_lia]*(temp-`c2')) ///
				  , se(SEmargeff)


gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(maroon)) (line Lower temp, lp(dash) lc(maroon)) (line Upper temp, lp(dash) lc(maroon)), ///
legend(off) graphregion(color(white)) ///
ytitle("LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") title("Corn") ///
ylabel(, angle(vertical) labsize(tiny)) xlabel(10(5)40) ylabel(-0.01(0.01)0.05) yscale(r(-0.01 0.05)) ///
 xline(`c1', lp(dot) lc(maroon)) xline(`c2', lp(dot) lc(maroon)) yline(0, lp(dash_dot) lc(black))
 graph save total_corn.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(maroon)) (line Lower prec, lp(dash) lc(maroon)) (line Upper prec, lp(dash) lc(maroon)), ///
legend(off) graphregion(color(white)) ///
ytitle("LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  title("Corn") ///
ylabel(, angle(vertical) labsize(tiny)) yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(0.001 100 "+1 SD of precipitation: +0.007" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save total_corn_p.gph, replace
restore

*four causes
*drought
local c1=29
local c2=43

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d

label var DDfirst_d "DDay 10 `c1' (Drought)"
label var DDsecond_d "DDay `c1' `c2' (Drought)"
label var DDthird_d "DDay `c2' (Drought)"

areg cause_10_loss_lia DD*d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "drought", replace
estimate store drought

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=29
local c2=43

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_d]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_d]*(`c1'-10) + _b[DDsecond_d]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_d]*(`c1'-10) + _b[DDsecond_d]*(`c2'-`c1') + _b[DDthird_d]*(temp-`c2')) ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(brown)) (line Lower temp, lp(dash) lc(brown)) (line Upper temp, lp(dash) lc(brown)), ///
legend(off) graphregion(color(white)) ///
ytitle("Drought LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)")  ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(brown)) yline(0, lp(dash_dot) lc(black))
graph save drought_corn.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(brown)) (line Lower prec, lp(dash) lc(brown)) (line Upper prec, lp(dash) lc(brown)), ///
legend(off) graphregion(color(white)) ///
ytitle("Drought LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical)) yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(0.0004 100 "+1 SD of precipitation: -0.020" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save drought_corn_p.gph, replace
restore

*moisture
local c1=28
local c2=37


	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C


rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

label var DDfirst_m "DDay 10 `c1' (Moisture)"
label var DDsecond_m "DDay `c1' `c2' (Moisture)"
label var DDthird_m "DDay `c2' (Moisture)"

areg cause_12_loss_lia DD*m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year)  
estimate save "moisture", replace
estimate store moisture

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=28
local c2=37

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_m]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_m]*(`c1'-10) + _b[DDsecond_m]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_m]*(`c1'-10) + _b[DDsecond_m]*(`c2'-`c1') + _b[DDthird_m]*(temp-`c2')) ///
				  , se(SEmargeff)


gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(green)) (line Lower temp, lp(dash) lc(green)) (line Upper temp, lp(dash) lc(green)), ///
legend(off) graphregion(color(white)) ///
ytitle("Moisture LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(green)) xline(`c2', lp(dot) lc(green))  yline(0, lp(dash_dot) lc(black))
graph save moisture_corn.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(green)) (line Lower prec, lp(dash) lc(green)) (line Upper prec, lp(dash) lc(green)), ///
legend(off) graphregion(color(white)) ///
ytitle("Moisture LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical)) yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(0.0006 100 "+1 SD of precipitation: +0.020" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save moisture_corn_p.gph, replace
restore

*Heat
local c1=30
local c2=39

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

label var DDfirst_h "DDay 10 `c1' (Heat)"
label var DDsecond_h "DDay `c1' `c2' (Heat)"
label var DDthird_h "DDay `c2' (Heat)"

areg cause_25_loss_lia DD*h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "heat", replace
estimate store heat

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=30
local c2=39

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_h]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_h]*(`c1'-10) + _b[DDsecond_h]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_h]*(`c1'-10) + _b[DDsecond_h]*(`c2'-`c1') + _b[DDthird_h]*(temp-`c2')) ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(red)) (line Lower temp, lp(dash) lc(red)) (line Upper temp, lp(dash) lc(red)), ///
legend(off) graphregion(color(white)) ///
ytitle("Heat LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(red)) xline(`c2', lp(dot) lc(red))  yline(0, lp(dash_dot) lc(black))
 graph save heat_corn.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(red)) (line Lower prec, lp(dash) lc(red)) (line Upper prec, lp(dash) lc(red)), ///
legend(off) graphregion(color(white)) ///
ytitle("Heat LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical))  yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(-0.0001 100 "+1 SD of precipitation: +0.0003" ///
, place(ne) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save heat_corn_p.gph, replace
restore

*freeze
local c1=24
local c2=36

	gen DD10_`c1' = dday10C - dday`c1'C
	gen DD`c1'_`c2'=dday`c1'C - dday`c2'C 
	gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

label var DDfirst_f "DDay 10 `c1' (Freeze)"
label var DDsecond_f "DDay `c1' `c2' (Freeze)"
label var DDthird_f "DDay `c2' (Freeze)"

areg cold_related_loss_lia DD*f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==41, absorb(stcofips) cluster(year) 
estimate save "freeze", replace
estimate store freeze

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=24
local c2=36

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_f]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_f]*(`c1'-10) + _b[DDsecond_f]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_f]*(`c1'-10) + _b[DDsecond_f]*(`c2'-`c1') + _b[DDthird_f]*(temp-`c2')) ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(blue)) (line Lower temp, lp(dash) lc(blue)) (line Upper temp, lp(dash) lc(blue)), ///
legend(off) graphregion(color(white)) ///
ytitle("Cold-related LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(blue)) xline(`c2', lp(dot) lc(blue))  yline(0, lp(dash_dot) lc(black))
graph save freeze_corn.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   

twoway (line margeff prec, lc(blue)) (line Lower prec, lp(dash) lc(blue)) (line Upper prec, lp(dash) lc(blue)), ///
legend(off) graphregion(color(white)) ///
ytitle("Cold-related LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical))  yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(-0.0002 100 "+1 SD of precipitation: +0.004" ///
, place(ne) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save freeze_corn_p.gph, replace
restore


**************************
 
*Soybeans

clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use ddayreg_89_2014_`gs'.dta
keep if cropcode==81
summ loss_lia cause_25_loss_lia cold_related_loss_lia cause_10_loss_lia cause_12_loss_lia ///
cause_6_loss_lia cause_19_loss_lia cause_22_loss_lia cause_24_loss_lia cause_26_loss_lia cause_44_loss_lia if loss_lia!=.

drop prec

*regressions
local c1=28
local c2=38

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_loss_lia
rename DD`c1'_`c2' DDsecond_loss_lia
rename DD`c2'_inf DDthird_loss_lia

areg loss_lia DDfirst_loss_lia DDsecond_loss_lia DDthird_loss_lia ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)  
estimate save "total", replace

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=28
local c2=38

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_loss_lia]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_loss_lia]*(`c1'-10) + _b[DDsecond_loss_lia]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_loss_lia]*(`c1'-10) + _b[DDsecond_loss_lia]*(`c2'-`c1') + _b[DDthird_loss_lia]*(temp-`c2')) ///
				  , se(SEmargeff)


gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(maroon)) (line Lower temp, lp(dash) lc(maroon)) (line Upper temp, lp(dash) lc(maroon)), ///
legend(off) graphregion(color(white)) ///
ytitle("LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") title("Soybeans") ///
ylabel(, angle(vertical) labsize(tiny)) xlabel(10(5)40)  ylabel(-0.01(0.01)0.05) yscale(r(-0.01 0.05)) ///
 xline(`c1', lp(dot) lc(maroon)) xline(`c2', lp(dot) lc(maroon))  yline(0, lp(dash_dot) lc(black))
 graph save total_soybeans.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(maroon)) (line Lower prec, lp(dash) lc(maroon)) (line Upper prec, lp(dash) lc(maroon)), ///
legend(off) graphregion(color(white)) ///
ytitle("LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  title("Soybeans") ///
ylabel(, angle(vertical) labsize(tiny))  yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(0.001 100 "+1 SD of precipitation: -0.012" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save total_soybeans_p.gph, replace
restore


 
*drought
local c1=30
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_d
rename DD`c1'_`c2' DDsecond_d
rename DD`c2'_inf DDthird_d

areg cause_10_loss_lia DDfirst_d DDsecond_d DDthird_d ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)  
estimate save "drought", replace

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=30
local c2=41

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}
		   
drop if temp > 40
drop if temp < 10


predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_d]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_d]*(`c1'-10) + _b[DDsecond_d]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_d]*(`c1'-10) + _b[DDsecond_d]*(`c2'-`c1') + _b[DDthird_d]*(temp-`c2')) ///
				  , se(SEmargeff)


gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff

twoway (line margeff temp, lc(brown)) (line Lower temp, lp(dash) lc(brown)) (line Upper temp, lp(dash) lc(brown)), ///
legend(off) graphregion(color(white)) ///
ytitle("Drought LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)")  ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(brown))   yline(0, lp(dash_dot) lc(black))
graph save drought_soy.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   

twoway (line margeff prec, lc(brown)) (line Lower prec, lp(dash) lc(brown)) (line Upper prec, lp(dash) lc(brown)), ///
legend(off) graphregion(color(white)) ///
ytitle("Drought LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical))  yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(0.0004 100 "+1 SD of precipitation: -0.032" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save drought_soy_p.gph, replace
restore

*moisture
local c1=32
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_m
rename DD`c1'_`c2' DDsecond_m
rename DD`c2'_inf DDthird_m

areg cause_12_loss_lia DDfirst_m DDsecond_m DDthird_m ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)   
estimate save "moisture", replace

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=32
local c2=36

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_m]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_m]*(`c1'-10) + _b[DDsecond_m]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_m]*(`c1'-10) + _b[DDsecond_m]*(`c2'-`c1') + _b[DDthird_m]*(temp-`c2')) ///
				  , se(SEmargeff)


gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(green)) (line Lower temp, lp(dash) lc(green)) (line Upper temp, lp(dash) lc(green)), ///
legend(off) graphregion(color(white)) ///
ytitle("Moisture LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(green)) xline(`c2', lp(dot) lc(green)) yline(0, lp(dash_dot) lc(black)) 
 graph save moisture_soy.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(green)) (line Lower prec, lp(dash) lc(green)) (line Upper prec, lp(dash) lc(green)), ///
legend(off) graphregion(color(white)) ///
ytitle("Moisture LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical)) yline(0, lp(dash_dot) lc(black))  ///
xlabel(100(200)1500) ///
text(0.0006 100 "+1 SD of precipitation: +0.016" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save moisture_soy_p.gph, replace
restore

*heat
local c1=33
local c2=41

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_h
rename DD`c1'_`c2' DDsecond_h
rename DD`c2'_inf DDthird_h

areg cause_25_loss_lia DDfirst_h DDsecond_h DDthird_h ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)  
estimate save "heat", replace

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=33
local c2=41

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}

drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_h]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_h]*(`c1'-10) + _b[DDsecond_h]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_h]*(`c1'-10) + _b[DDsecond_h]*(`c2'-`c1') + _b[DDthird_h]*(temp-`c2')) ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(red)) (line Lower temp, lp(dash) lc(red)) (line Upper temp, lp(dash) lc(red)), ///
legend(off) graphregion(color(white)) ///
ytitle("Heat LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(red))  yline(0, lp(dash_dot) lc(black)) 
 graph save heat_soy.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(red)) (line Lower prec, lp(dash) lc(red)) (line Upper prec, lp(dash) lc(red)), ///
legend(off) graphregion(color(white)) ///
ytitle("Heat LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical)) yline(0, lp(dash_dot) lc(black))  ///
xlabel(100(200)1500) ///
text(0.00003 100 "+1 SD of precipitation: -0.0006" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save heat_soy_p.gph, replace
restore

*Freeze
local c1=24
local c2=36

gen DD10_`c1' = dday10C - dday`c1'C
gen DD`c1'_`c2' = dday`c1'C - dday`c2'C
gen DD`c2'_inf= dday`c2'C

rename DD10_`c1' DDfirst_f
rename DD`c1'_`c2' DDsecond_f
rename DD`c2'_inf DDthird_f

areg cold_related_loss_lia DDfirst_f DDsecond_f DDthird_f ppt ppt2 i.statecode#c.time i.statecode#c.time2 i.year if cropcode==81, absorb(stcofips) cluster(year)   
estimate save "freeze", replace 

summ ppt if e(sample)==1
disp (_b[ppt]+_b[ppt2]*2*r(mean))*r(sd)

preserve
local c1=24
local c2=36

gen temp = _n - 1
foreach i in 10 `c1' `c2' {
  gen I`i' = 0
  replace I`i' = 1 if temp >= `i'
}
drop if temp > 40
drop if temp < 10

predictnl margeff = (1-I10)*(temp*0)+(I10)*(1-I`c1')*(_b[DDfirst_f]*(temp-10)) ///
                  + (I`c1')*(1-I`c2')*(_b[DDfirst_f]*(`c1'-10) + _b[DDsecond_f]*(temp-`c1')) ///
	              + (I`c2')*(_b[DDfirst_f]*(`c1'-10) + _b[DDsecond_f]*(`c2'-`c1') + _b[DDthird_f]*(temp-`c2')) ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff temp, lc(blue)) (line Lower temp, lp(dash) lc(blue)) (line Upper temp, lp(dash) lc(blue)), ///
legend(off) graphregion(color(white)) ///
ytitle("Cold-related LCR") ysca(titlegap(0)) xtitle("Temperature ({c 176}C)") ///
ylabel(, labsize(tiny) angle(vertical)) ///
xlabel(10(5)40) xline(`c1', lp(dot) lc(blue)) xline(`c2', lp(dot) lc(blue)) yline(0, lp(dash_dot) lc(black)) 
 graph save freeze_soy.gph, replace
restore

preserve
gen prec = _n - 1

drop if prec > 1500
drop if prec < 100

predictnl margeff = _b[ppt]+_b[ppt2]*2*prec ///
				  , se(SEmargeff)

gen Lower = margeff - 1.96*SEmargeff
gen Upper = margeff + 1.96*SEmargeff
		   
twoway (line margeff prec, lc(blue)) (line Lower prec, lp(dash) lc(blue)) (line Upper prec, lp(dash) lc(blue)), ///
legend(off) graphregion(color(white)) ///
ytitle("Cold-related LCR") ysca(titlegap(0)) xtitle("Precipitation (mm)")  ///
ylabel(, labsize(tiny) angle(vertical))  yline(0, lp(dash_dot) lc(black)) ///
xlabel(100(200)1500) ///
text(0.0001 100 "+1 SD of precipitation: +0.003" ///
, place(se) box just(left) margin(l+1 t+1 b+1) width(48) )
graph save freeze_soy_p.gph, replace
restore

*figures for main and appendix 
graph combine total_corn.gph total_soybeans.gph heat_corn.gph heat_soy.gph drought_corn.gph drought_soy.gph, col(2) graphregion(color(white))
graph export "fig3_corn_soy_total_heat_drought.eps", replace  

graph combine total_corn.gph total_soybeans.gph heat_corn.gph heat_soy.gph drought_corn.gph drought_soy.gph freeze_corn.gph freeze_soy.gph moisture_corn.gph moisture_soy.gph , col(2) graphregion(color(white)) imargin(tiny)
graph export "figA6_corn_soy_temp_only.eps", replace  

graph combine total_corn_p.gph total_soybeans_p.gph heat_corn_p.gph heat_soy_p.gph drought_corn_p.gph drought_soy_p.gph freeze_corn_p.gph freeze_soy_p.gph moisture_corn_p.gph moisture_soy_p.gph , col(2) graphregion(color(white)) imargin(tiny)
graph export "figA7_corn_soy_prec_only.eps", replace  

 
rm total.ster
rm drought.ster
rm moisture.ster
rm heat.ster
rm freeze.ster

rm heat_corn.gph
rm freeze_corn.gph
rm drought_corn.gph
rm moisture_corn.gph

rm heat_corn_p.gph
rm freeze_corn_p.gph
rm drought_corn_p.gph
rm moisture_corn_p.gph

rm heat_soy.gph
rm freeze_soy.gph
rm drought_soy.gph
rm moisture_soy.gph

rm heat_soy_p.gph
rm freeze_soy_p.gph
rm drought_soy_p.gph
rm moisture_soy_p.gph

rm total_corn.gph 
rm total_soybeans.gph
rm total_corn_p.gph
rm total_soybeans_p.gph
