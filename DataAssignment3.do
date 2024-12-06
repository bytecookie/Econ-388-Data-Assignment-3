* Set the working directory
cd "C:\Users\jacookie\Box\Econometrics\Data Assignment 3\data"

* Step 1: Load the GDP per capita dataset
use "pwt1001.dta", clear

* Step 2: Standardize country naming conventions
gen country_name = lower(trim(country))  // Normalize country names

**# Bookmark #1
* Step 3: Calculate GDP growth rates (already a rate)
sort country_name year
gen gdppc = rgdpna / pop
gen gdp_growth = 100 * ((gdppc[_n+1] / gdppc) - 1) if _n < _N
drop if missing(gdp_growth)

* Save GDP growth dataset
save "gdp_growth.dta", replace

* Step 4: Load the Technological Progress dataset
use "chat.dta", clear

* Step 5: Standardize country naming conventions in this dataset
rename country_name country1
gen country_name = lower(trim(country1))  // Normalize country names

* Step 6: Reshape Technological Progress data to wide format
destring year, replace
drop if year < 1970
rename xlpopulation pop
keep country_name year ag_harvester ag_tractor atm bed_hosp bed_longterm cellphone computer cheque pop

* Step 7: Convert all variables to rates by dividing by population (or another appropriate denominator)
gen ag_harvester_rate = ag_harvester / pop
gen ag_tractor_rate = ag_tractor / pop
gen atm_rate = atm / pop
gen bed_hosp_rate = bed_hosp / pop
gen bed_longterm_rate = bed_longterm / pop
gen cellphone_rate = cellphone / pop
gen computer_rate = computer / pop
gen cheque_rate = cheque / pop

* Step 8: Merge GDP and Technological Progress datasets
save "tech_wide.dta", replace
use "gdp_growth.dta", clear
destring year, replace
sort country_name year
merge 1:1 country_name year using "tech_wide.dta"

* Step 9: Analyze the merged dataset
gen developed = inlist(country_name, "united states", "japan", "france", "germany", "italy", "united kingdom")
bysort developed (year): egen total_gdp_growth = total(gdp_growth * pop)
bysort developed (year): egen total_population = total(pop)
bysort developed (year): gen weighted_gdp_growth = total_gdp_growth / total_population

* Save the final dataset
save "final_data.dta", replace
br
* Step 10: Run regression analysis on rates
// drop if missing(gdp_growth, ag_harvester_rate, ag_tractor_rate, atm_rate, bed_hosp_rate, bed_longterm_rate, cellphone_rate, computer_rate, cheque_rate)
reg gdp_growth ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate cellphone_rate computer_rate cheque_rate if developed == 1
reg gdp_growth ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate cellphone_rate computer_rate cheque_rate if developed == 0

drop if year < 1970
drop if year > 2000
* Step 11: Summarize findings for rates
summarize gdp_growth country_name year ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate cellphone_rate computer_rate cheque_rate

* Step 12: Visualize trends in the variables over time

* Set up a time-series graph for GDP growth rates by developed status
twoway (line gdp_growth year if developed == 1, sort lcolor(blue) lwidth(medium) lpattern(solid) ///
        title("GDP Growth Rate Trends (Developed vs Developing)") ///
        ytitle("GDP Growth Rate (%)") xtitle("Year")) ///
       (line gdp_growth year if developed == 0, sort lcolor(red) lwidth(medium) lpattern(dash)), ///
       legend(order(1 "Developed" 2 "Developing")) name("gdp_growth_trends", replace)
	   
 * Save the graph to the working directory
graph export "gdp_growth_trends.png", replace

* Create individual graphs for key rates over time (example: cellphone rate)
twoway (line cellphone_rate year if developed == 1, sort lcolor(blue) lwidth(medium) lpattern(solid) ///
        title("Cellphone Adoption Rate Trends") ///
        ytitle("Cellphone Rate (per capita)") xtitle("Year")) ///
       (line cellphone_rate year if developed == 0, sort lcolor(red) lwidth(medium) lpattern(dash)), ///
       legend(order(1 "Developed" 2 "Developing")) name("cellphone_rate_trends", replace)
	   
* Save the graph to the working directory
graph export "cellphone_rate_trends.png", replace	  

* Repeat for other rates of interest
foreach var in ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate computer_rate cheque_rate {
    twoway (line `var' year if developed == 1, sort lcolor(blue) lwidth(medium) lpattern(solid) ///
            title("Trends in `var' Over Time") ///
            ytitle("`var' (per capita)") xtitle("Year")) ///
           (line `var' year if developed == 0, sort lcolor(red) lwidth(medium) lpattern(dash)), ///
           legend(order(1 "Developed" 2 "Developing")) name("`var'_trends", replace)
	* Save each graph
    graph export "`var'_trends.png", replace
}

* Create a panel of graphs for technological progress rates
graph combine gdp_growth_trends ag_tractor_rate_trends, title("Trends in GDP Growth and Technological Progress")
graph export "combined_trends.png", replace

* Run regressions separately for developed and developing nations
reg gdp_growth ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate ///
    bed_longterm_rate cellphone_rate computer_rate cheque_rate if developed == 1
estimates store developed_model

reg gdp_growth ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate ///
    bed_longterm_rate cellphone_rate computer_rate cheque_rate if developed == 0
estimates store developing_model


*************
*Averages
*************
* Calculate the mean for developed countries
summarize ag_harvester if developed == 1, meanonly
scalar ag_harvester_dev_avg = r(mean)

summarize ag_tractor if developed == 1, meanonly
scalar ag_tractor_dev_avg = r(mean)

summarize atm if developed == 1, meanonly
scalar atm_dev_avg = r(mean)

summarize bed_hosp if developed == 1, meanonly
scalar bed_hosp_dev_avg = r(mean)

summarize bed_longterm if developed == 1, meanonly
scalar bed_longterm_dev_avg = r(mean)

summarize cellphone if developed == 1, meanonly
scalar cellphone_dev_avg = r(mean)

summarize computer if developed == 1, meanonly
scalar computer_dev_avg = r(mean)

summarize cheque if developed == 1, meanonly
scalar cheque_dev_avg = r(mean)

summarize pop if developed == 1, meanonly
scalar pop_dev_avg = r(mean)

summarize ag_harvester_rate if developed == 1, meanonly
scalar ag_harvester_rate_dev_avg = r(mean)

summarize ag_tractor_rate if developed == 1, meanonly
scalar ag_tractor_rate_dev_avg = r(mean)

summarize atm_rate if developed == 1, meanonly
scalar atm_rate_dev_avg = r(mean)

summarize bed_hosp_rate if developed == 1, meanonly
scalar bed_hosp_rate_dev_avg = r(mean)

summarize bed_longterm_rate if developed == 1, meanonly
scalar bed_longterm_rate_dev_avg = r(mean)

summarize cellphone_rate if developed == 1, meanonly
scalar cellphone_rate_dev_avg = r(mean)

summarize computer_rate if developed == 1, meanonly
scalar computer_rate_dev_avg = r(mean)

summarize cheque_rate if developed == 1, meanonly
scalar cheque_rate_dev_avg = r(mean)

* Display the results for developed countries
display "Average ag_harvester (developed): " ag_harvester_dev_avg
display "Average ag_tractor (developed): " ag_tractor_dev_avg
display "Average atm (developed): " atm_dev_avg
display "Average bed_hosp (developed): " bed_hosp_dev_avg
display "Average bed_longterm (developed): " bed_longterm_dev_avg
display "Average cellphone (developed): " cellphone_dev_avg
display "Average computer (developed): " computer_dev_avg
display "Average cheque (developed): " cheque_dev_avg
display "Average pop (developed): " pop_dev_avg
display "Average ag_harvester_rate (developed): " ag_harvester_rate_dev_avg
display "Average ag_tractor_rate (developed): " ag_tractor_rate_dev_avg
display "Average atm_rate (developed): " atm_rate_dev_avg
display "Average bed_hosp_rate (developed): " bed_hosp_rate_dev_avg
display "Average bed_longterm_rate (developed): " bed_longterm_rate_dev_avg
display "Average cellphone_rate (developed): " cellphone_rate_dev_avg
display "Average computer_rate (developed): " computer_rate_dev_avg
display "Average cheque_rate (developed): " cheque_rate_dev_avg

* Calculate the mean for non-developed countries
summarize ag_harvester if developed == 0, meanonly
scalar ag_harvester_nondev_avg = r(mean)

summarize ag_tractor if developed == 0, meanonly
scalar ag_tractor_nondev_avg = r(mean)

summarize atm if developed == 0, meanonly
scalar atm_nondev_avg = r(mean)

summarize bed_hosp if developed == 0, meanonly
scalar bed_hosp_nondev_avg = r(mean)

summarize bed_longterm if developed == 0, meanonly
scalar bed_longterm_nondev_avg = r(mean)

summarize cellphone if developed == 0, meanonly
scalar cellphone_nondev_avg = r(mean)

summarize computer if developed == 0, meanonly
scalar computer_nondev_avg = r(mean)

summarize cheque if developed == 0, meanonly
scalar cheque_nondev_avg = r(mean)

summarize pop if developed == 0, meanonly
scalar pop_nondev_avg = r(mean)

summarize ag_harvester_rate if developed == 0, meanonly
scalar ag_harvester_rate_nondev_avg = r(mean)

summarize ag_tractor_rate if developed == 0, meanonly
scalar ag_tractor_rate_nondev_avg = r(mean)

summarize atm_rate if developed == 0, meanonly
scalar atm_rate_nondev_avg = r(mean)

summarize bed_hosp_rate if developed == 0, meanonly
scalar bed_hosp_rate_nondev_avg = r(mean)

summarize bed_longterm_rate if developed == 0, meanonly
scalar bed_longterm_rate_nondev_avg = r(mean)

summarize cellphone_rate if developed == 0, meanonly
scalar cellphone_rate_nondev_avg = r(mean)

summarize computer_rate if developed == 0, meanonly
scalar computer_rate_nondev_avg = r(mean)

summarize cheque_rate if developed == 0, meanonly
scalar cheque_rate_nondev_avg = r(mean)

* Display the results for non-developed countries
display "Average ag_harvester (non-developed): " ag_harvester_nondev_avg
display "Average ag_tractor (non-developed): " ag_tractor_nondev_avg
display "Average atm (non-developed): " atm_nondev_avg
display "Average bed_hosp (non-developed): " bed_hosp_nondev_avg
display "Average bed_longterm (non-developed): " bed_longterm_nondev_avg
display "Average cellphone (non-developed): " cellphone_nondev_avg
display "Average computer (non-developed): " computer_nondev_avg
display "Average cheque (non-developed): " cheque_nondev_avg
display "Average pop (non-developed): " pop_nondev_avg
display "Average ag_harvester_rate (non-developed): " ag_harvester_rate_nondev_avg
display "Average ag_tractor_rate (non-developed): " ag_tractor_rate_nondev_avg
display "Average atm_rate (non-developed): " atm_rate_nondev_avg
display "Average bed_hosp_rate (non-developed): " bed_hosp_rate_nondev_avg
display "Average bed_longterm_rate (non-developed): " bed_longterm_rate_nondev_avg
display "Average cellphone_rate (non-developed): " cellphone_rate_nondev_avg
display "Average computer_rate (non-developed): " computer_rate_nondev_avg
display "Average cheque_rate (non-developed): " cheque_rate_nondev_avg
**End of section



***************
*To use this code comment the section above that takes the average.
***************
// * Make Table
// * Collapse the dataset to calculate the average of each variable for each year
// collapse (mean) ag_harvester ag_tractor atm bed_hosp bed_longterm cellphone computer cheque pop ///
//                   ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate cellphone_rate ///
//                   computer_rate cheque_rate, by(year)
//
// * Rename the variables for clarity
// rename ag_harvester ag_harvester_avg
// rename ag_tractor ag_tractor_avg
// rename atm atm_avg
// rename bed_hosp bed_hosp_avg
// rename bed_longterm bed_longterm_avg
// rename cellphone cellphone_avg
// rename computer computer_avg
// rename cheque cheque_avg
// rename pop pop_avg
// rename ag_harvester_rate ag_harvester_rate_avg
// rename ag_tractor_rate ag_tractor_rate_avg
// rename atm_rate atm_rate_avg
// rename bed_hosp_rate bed_hosp_rate_avg
// rename bed_longterm_rate bed_longterm_rate_avg
// rename cellphone_rate cellphone_rate_avg
// rename computer_rate computer_rate_avg
// rename cheque_rate cheque_rate_avg
//
// * Display the averages for each year
// list year ag_harvester_avg ag_tractor_avg atm_avg bed_hosp_avg bed_longterm_avg ///
//      cellphone_avg computer_avg cheque_avg pop_avg, sep(0)
//	 
