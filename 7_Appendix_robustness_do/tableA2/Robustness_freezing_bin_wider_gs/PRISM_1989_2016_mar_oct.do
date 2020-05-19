# delimit;
clear all;
set more off;
set memory 16g;

* #############################################################################;
* set parameters in following section;
* #############################################################################;
* part 1: degree days bound list;
local boundList -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43;
local gs mar_oct;
* part 2: range of years in analysis (can be between 1950 and 2005);
local yearMin = 1989;
local yearMax = 2016;

* part 3: define growing season;
* first month and day of month used in a year;
local monthBegin = 3;  local dayMonthBegin = 1;
* last month and day of month used in a year;
local monthEnd   = 10; local dayMonthEnd   = 30;

* part 4: states that are included in analysis;
local stateList 1 4 5 6 8 9 10 11 12 13 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56;

* #############################################################################;
* program code from here on, no need to change anything;
* #############################################################################;
* load grid information;
*use "\\tsclient\(root)\Users\jisangyu\Documents\PRISM_raw\cropArea", clear;
use "/Users/jisangyu/Dropbox/PRISM/cropArea", clear;


gen longitude = -125 + mod(gridNumber-1,1405)/24;
label var longitude "longitude of grid centroid (decimal degrees)";
gen latitude  = 49.9375+1/48 - ceil(gridNumber/1405)/24;
label var latitude  "latitude of grid centroid (decimal degrees)";
*merge 1:1 gridNumber using  "\\tsclient\(root)\Users\jisangyu\Documents\PRISM_raw\linkGridnumberFIPS";
merge 1:1 gridNumber using  "/Users/jisangyu/Dropbox/PRISM/linkGridnumberFIPS";

drop _merge;
compress;
sort gridNumber;
save gridInfo, replace;

******************************************************************************;
* loop over states;
local appendID = 0;
foreach s of local stateList {;
    * loop over years;
    forvalues t = `yearMin'/`yearMax' {;
        ******************************************************************************;
        display("Working on state `s' in year `t'");
        * load data;
    	use if (dateNum >= mdy(`monthBegin',`dayMonthBegin',year(dateNum)))
    			& (dateNum <= mdy(`monthEnd',`dayMonthEnd',year(dateNum)))
				using  "/Users/jisangyu/Dropbox/PRISM/year`t'/state`s'_year`t'", clear;
				*using  "\\tsclient\(root)\Users\jisangyu\Documents\PRISM_raw\year`t'\state`s'", clear;
        gen tAvg = (tMin+tMax)/2;
        label var tAvg "average temperature - average of minimum and maximum temperature";

        * merge in grid weights;
        * make sure there is no (_merge == 1) as gridInfo should have data for each gridNumber;
        qui merge m:1 gridNumber using gridInfo, assert(2 3);

        * keep only were weights are nonzero;
        qui keep if (_merge == 3) & (cropArea > 0);
        drop _merge;

        if (_N > 0) {;
            ******************************************************************************;
            * generate degree days;
            foreach b of local boundList {;
                * create label for negative bounds by adding Minus;
                if (`b' < 0) {; 
                	local b2 = abs(`b'); 
                	local bLabel Minus`b2'; 
                }; else {; 
                	local bLabel `b'; 
                };

                * default case 1: tMax <= bound;
                qui gen dday`bLabel'C = 0;

                * case 2: bound <= tMin;
                qui replace dday`bLabel'C = tAvg - `b' if (`b' <= tMin);

                * case 3: tMin < bound < tMax;
                qui gen tempSave = acos( (2*`b'-tMax-tMin)/(tMax-tMin) );
                qui replace dday`bLabel'C = ( (tAvg-`b')*tempSave + (tMax-tMin)*sin(tempSave)/2 )/_pi 
                        if ( (tMin < `b') & (`b' < tMax) );
                drop tempSave;
            };
			
			*Temp bins;
			forvalues b=-9/50{;
			if (`b' < 0) {;
				local b2 = abs(`b') ;
				local bLabel Minus`b2' ;
			} ;
			else { ;
				local bLabel `b' ;
			};
		
			* default case 1: tMax <= bound;
			gen time`bLabel'C = 0;

			* case 2: bound <= tMin;
			replace time`bLabel'C = 1 if (`b' <= tMin);

			* case 3: tMin < bound < tMax;
			replace time`bLabel'C = acos( (2*`b'-tMax-tMin)/(tMax-tMin) )/_pi if ( (tMin < `b') & (`b' < tMax) );

	};
	
			forvalues b=-9/49{;
			if (`b' < 0) {;
				local b2 = abs(`b') ;
				local bLabel Minus`b2' ;
			};
			else { ;
				local bLabel `b' ;
			};
			if (`b'+1<0){;
				local b2p1=abs(`b'+1);
				local bLabelp1 Minus`b2p1';
			};
			else {;
			    local bp1 = `b'+1;
				local bLabelp1 `bp1';
			};
			gen tempBin`bLabel'C=time`bLabel'C - time`bLabelp1'C;
	
			};
			
            ******************************************************************************;
			* save variable labels;
			foreach v in tMin tMax tAvg prec {;
				local l_`v': variable label `v';
			};
             
            * collapse by aggregation level;
            collapse tMin tMax tAvg prec dday* tempBin* [aweight=cropArea], by(fips dateNum);

            * collapse by year;
            gen year = year(dateNum);
            collapse (sum) prec dday* tempBin* (mean) tMin tMax tAvg, by(fips year);

			* label variables;
			foreach v in tMin tMax tAvg prec {;
				label var `v' "`l_`v''";
			};
			foreach b of local boundList {;
				* create label for negative bounds by adding Minus;
				if (`b' < 0) {; 
					local b2 = abs(`b'); 
					local bLabel Minus`b2'; 
				}; else {; 
					local bLabel `b'; 
				};
				label var dday`bLabel'C "total degree days above `b'C (Celcius and days)";
			};
			label var year "year";

            ******************************************************************************;
            * save data;
            if (`appendID' > 0) {;
	            *append using "\\tsclient\(root)\Users\jisangyu\Documents\PRISM_raw\PRISM_1989_2016_`gs'.dta";
				append using "/Users/jisangyu/Dropbox/PRISM/PRISM_1989_2016_`gs'.dta";
	        };
	        local appendID = 1;
            sort fips year;
            *qui save "\\tsclient\(root)\Users\jisangyu\Documents\PRISM_raw\PRISM_1989_2016_`gs'.dta", replace;
			qui save "/Users/jisangyu/Dropbox/PRISM/PRISM_1989_2016_`gs'.dta", replace;
        };
    };
};
* clear up files;
! rm gridInfo.dta;
rename prec prec_`gs';
save "/Users/jisangyu/Dropbox/PRISM/PRISM_1989_2016_`gs'", replace;
