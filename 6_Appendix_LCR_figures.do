clear all
set more off
set matsize 10000
cd "/Users/jisangyu/Dropbox/RMA_cause_of_loss/NCOMM Submission/NCOMM_do_data/"
local gs apr_sep
use Dryland1989_2014_`gs'.dta


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

*label variables
label var loss_lia "Total loss per liability"

label var cause_25_loss_lia "Heat loss per liability"
label var cause_21_loss_lia "Freeze loss per liability"
label var cause_10_loss_lia "Drought loss per liability"
label var cause_12_loss_lia "Excess moisture loss per liability"

drop if loss_lia==.

*create cold related loss lia
gen cold_related_loss_lia=cause_6_loss_lia+cause_21_loss_lia+cause_22_loss_lia

*Fig A2
preserve
collapse (mean) loss_lia cause_10_loss_lia cause_12_loss_lia  cause_25_loss_lia cold_related_loss_lia dday29 prec, by(year cropcode)

reshape wide loss_lia cause_10_loss_lia cause_12_loss_lia  cause_25_loss_lia cold_related_loss_lia dday29 prec, i(year) j(cropcode)

local dc=uchar(176)
tw (line loss_lia41 year, ytitle("Total LCR")) (line dday29C41 year, lpattern(dash) yaxis(2) ytitle("29C`dc' degree days", axis(2))), graphregion(color(white)) /// 
legend(off) title("Corn")
gr save LCR_corn, replace
tw (line loss_lia81 year, ytitle("Total LCR")) (line dday29C81 year, lpattern(dash) yaxis(2) ytitle("29C`dc' degree days", axis(2))), graphregion(color(white)) /// 
legend(label(1 "Dryland average Total LCR") label(2 "Dryland average 29C`dc' degree days") size(small)) title("Soybeans")
gr save LCR_soy, replace
gr combine LCR_corn.gph LCR_soy.gph, col(1) graphregion(color(white))
gr export "figA2_LCR.png", replace
restore

*Fig A2
preserve
keep if cropcode==41
local dc=uchar(176)
graph box dday29, over(year, sort(ord) label(angle(90) labsize(small))) ///
marker(1, mfcolor(none) msize(small)) graphregion(color(white)) ///
ytitle("Degree days 29`dc'C") ylabel(, nogrid) ysca(titlegap(0)) ylabel(, angle(horizontal)   labsize(vsmall)) scheme(lean2) ///
name(dday29_box, replace)
graph box prec, over(year, sort(ord) label(angle(90) labsize(small))) /// 
marker(1, mfcolor(none) msize(small)) graphregion(color(white)) ///
ytitle("Precipitation (mm)") ylabel(, nogrid) ysca(titlegap(0)) ylabel(, angle(horizontal) labsize(vsmall)) scheme(lean2) ///
name(prec_box, replace)
graph box loss_lia, over(year, sort(ord) label(angle(90) labsize(small))) ///
marker(1, mfcolor(none) msize(small)) graphregion(color(white)) ///
ytitle("LCR") ylabel(, nogrid) ysca(titlegap(0)) ylabel(, angle(horizontal)) scheme(lean2) ///
name(lcr_box, replace)
gr combine  lcr_box dday29_box prec_box, col(1) graphregion(color(white)) name(boxplot_corn, replace) title("Corn")
restore

preserve
keep if cropcode==81
local dc=uchar(176)
graph box dday29, over(year, sort(ord) label(angle(90) labsize(small))) ///
marker(1, mfcolor(none) msize(small)) graphregion(color(white)) ///
ytitle("Degree days 29`dc'C") ylabel(, nogrid) ysca(titlegap(0)) ylabel(, angle(horizontal)   labsize(vsmall)) scheme(lean2) ///
name(dday29_box, replace)
graph box prec, over(year, sort(ord) label(angle(90) labsize(small))) /// 
marker(1, mfcolor(none) msize(small)) graphregion(color(white)) ///
ytitle("Precipitation (mm)") ylabel(, nogrid) ysca(titlegap(0)) ylabel(, angle(horizontal)  labsize(vsmall)) scheme(lean2) ///
name(prec_box, replace)
graph box loss_lia, over(year, sort(ord) label(angle(90) labsize(small))) ///
marker(1, mfcolor(none) msize(small)) graphregion(color(white)) ///
ytitle("LCR") ylabel(, nogrid) ysca(titlegap(0)) ylabel(, angle(horizontal)) scheme(lean2) ///
name(lcr_box, replace)
gr combine  lcr_box dday29_box prec_box, col(1) graphregion(color(white)) name(boxplot_soybeans, replace) title("Soybeans")
restore

gr combine  boxplot_corn boxplot_soybeans, col(2) graphregion(color(white)) 
gr export "figA1_boxplots.eps", replace

*Fig A3
gr bar cause_10_loss_lia cause_12_loss_lia if cropcode==41, over(year, label(labsize(vsmall) angle(45))) bar(1, color(brown)) bar(2, color(green)) graphregion(color(white)) ///
legend(off) title("Corn")
gr save LCR_corn, replace
gr bar cause_10_loss_lia cause_12_loss_lia if cropcode==81, over(year, label(labsize(vsmall) angle(45))) bar(1, color(brown)) bar(2, color(green)) graphregion(color(white)) ///
legend(label(1 "Drought LCR") label(2 "Excess moisture LCR")) title("Soybeans")
gr save LCR_soy, replace
gr combine LCR_corn.gph LCR_soy.gph, col(1) graphregion(color(white))
gr export "figA3_LCR_by_drought_moisture.png", replace

*Fig A4
gr bar cause_25_loss_lia cold_related_loss_lia if cropcode==41, over(year, label(labsize(vsmall) angle(45))) bar(1, color(red)) bar(2, color(blue)) graphregion(color(white)) ///
legend(off) title("Corn")
gr save LCR_corn, replace
gr bar cause_25_loss_lia cold_related_loss_lia if cropcode==81, over(year, label(labsize(vsmall) angle(45))) bar(1, color(red)) bar(2, color(blue)) graphregion(color(white)) ///
legend(label(1 "Heat LCR") label(2 "Cold-related LCR"))  title("Soybeans")
gr save LCR_soy, replace
gr combine LCR_corn.gph LCR_soy.gph, col(1) graphregion(color(white))
gr export "figA4_LCR_by_heat_freeze.png", replace


rm LCR_corn.gph 
rm LCR_soy.gph


*Fig A5 
preserve
keep if cropcode==41
collapse (mean) loss_lia cause_10_loss_lia cause_25_loss_lia dday29, by(year state_abb statecode)
bys state_abb statecode: gen no_years=_N
keep if no_years==26
collapse (mean) loss_lia cause_10_loss_lia cause_25_loss_lia dday29, by(state_abb statecode)
summ dday29

local dc=uchar(176)
tw (sc loss_lia dday29, mlabel(state_abb) mcolor(maroon) msymbol(D) mlabsize(tiny)) ///
(lfit loss_lia dday29, legend(off) ytitle("Avg. Total LCR") xtitle("Avg. Degree days above 29`dc'C") ylabel(, angle(vertical) labsize(vsmall))), ///
graphregion(color(white)) legend(off) 
gr save c_LCR_dday, replace
tw (sc cause_10_loss_lia dday29, mlabel(state_abb) mcolor(brown) msymbol(T) mlabsize(tiny)) ///
(lfit cause_10_loss_lia dday29, legend(off) ytitle("Avg. Drought LCR") xtitle("Avg. Degree days above 29`dc'C") ylabel(, angle(vertical) labsize(vsmall))), ///
graphregion(color(white)) legend(off) 
gr save c_dLCR_dday, replace
tw (sc cause_25_loss_lia dday29, mlabel(state_abb) mcolor(red) mlabsize(tiny)) ///
(lfit cause_25_loss_lia dday29, legend(off) ytitle("Avg. Heat LCR") xtitle("Avg. Degree days above 29`dc'C") ylabel(, angle(vertical) labsize(vsmall))), ///
graphregion(color(white)) legend(off) 
gr save c_hLCR_dday, replace
restore
gr combine c_LCR_dday.gph c_dLCR_dday.gph c_hLCR_dday.gph, col(1) graphregion(color(white)) title("Corn")
gr save corn_avg, replace

preserve
keep if cropcode==81
collapse (mean) loss_lia cause_10_loss_lia cause_25_loss_lia dday29, by(year state_abb statecode)
bys state_abb statecode: gen no_years=_N
keep if no_years==26
collapse (mean) loss_lia cause_10_loss_lia cause_25_loss_lia dday29, by(state_abb statecode)
summ dday29

local dc=uchar(176)
tw (sc loss_lia dday29, mlabel(state_abb) mcolor(maroon) msymbol(D) mlabsize(tiny)) ///
(lfit loss_lia dday29, legend(off) ytitle("Avg. Total LCR") xtitle("Avg. Degree days above 29`dc'C") ylabel(, angle(vertical) labsize(vsmall))), ///
graphregion(color(white)) legend(off) 
gr save s_LCR_dday, replace
tw (sc cause_10_loss_lia dday29, mlabel(state_abb) mcolor(brown) msymbol(T) mlabsize(tiny)) ///
(lfit cause_10_loss_lia dday29, legend(off) ytitle("Avg. Drought LCR") xtitle("Avg. Degree days above 29`dc'C") ylabel(, angle(vertical) labsize(vsmall))), ///
graphregion(color(white)) legend(off) 
gr save s_dLCR_dday, replace
tw (sc cause_25_loss_lia dday29, mlabel(state_abb) mcolor(red) mlabsize(tiny)) ///
(lfit cause_25_loss_lia dday29, legend(off) ytitle("Avg. Heat LCR") xtitle("Avg. Degree days above 29`dc'C") ylabel(, angle(vertical) labsize(vsmall))), ///
graphregion(color(white)) legend(off) 
gr save s_hLCR_dday, replace
restore
gr combine s_LCR_dday.gph s_dLCR_dday.gph s_hLCR_dday.gph, col(1) graphregion(color(white)) title("Soybeans")
gr save soybeans_avg, replace

gr combine corn_avg.gph soybeans_avg.gph, col(2) graphregion(color(white))
gr export "figA5_sc_avg_lcr_dday.eps", replace

rm c_LCR_dday.gph
rm c_dLCR_dday.gph
rm c_hLCR_dday.gph
rm corn_avg.gph

rm s_LCR_dday.gph
rm s_dLCR_dday.gph
rm s_hLCR_dday.gph
rm soybeans_avg.gph



