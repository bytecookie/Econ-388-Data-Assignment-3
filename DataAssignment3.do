* Set the working directory
cd "C:\Users\jacookie\Box\Econometrics\Data Assignment 3\data"

* Step 1: Load the GDP per capita dataset
use "pwt1001.dta", clear

* Step 2: Standardize country naming conventions
gen country_name = lower(trim(country))  // Normalize country names

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

* Step 10: Run regression analysis on rates
drop if missing(gdp_growth, ag_harvester_rate, ag_tractor_rate, atm_rate, bed_hosp_rate, bed_longterm_rate, cellphone_rate, computer_rate, cheque_rate)
reg gdp_growth ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate cellphone_rate computer_rate cheque_rate if developed == 1
reg gdp_growth ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate cellphone_rate computer_rate cheque_rate if developed == 0

* Step 11: Summarize findings for rates
summarize gdp_growth country_name year ag_harvester_rate ag_tractor_rate atm_rate bed_hosp_rate bed_longterm_rate cellphone_rate computer_rate cheque_rate
