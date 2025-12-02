*!version 1.0.2 3Dic2025
* Author: Pietro Campa
program define percloo, eclass sortpreserve
    version 16

    // ---- PARSE SYNTAX ----
    syntax varlist(max=1 numeric), GROUP(varname) P(real) GEN(name)

    // ---- PREVENT OVERWRITING ----
    capture confirm var `gen'
    if _rc == 0 {
        di as error "{red}Variable {bf:`gen'} already exists. Replace is not allowed."
        error 498
    }

    // ---- CHECK p ----
    if (`p' < 0 | `p' > 1) {
        di as error "{red}Percentile {bf:p()} must be between 0 and 1."
        error 498
    }

    // ---- CHECK FOR MISSING IN MEASURE ----
    quietly count if missing(`varlist')
    if r(N) {
        di as error "{red}`varlist' has `r(N)' missing values. Not allowed."
        error 498
    }

    tempvar r size id k1 belowk1 km perc0 perc 
    tempfile result

    // Identifier
    gen `id' = _n

    preserve

        quietly drop if missing(`group')
        keep `id' `group' `varlist'

        // ---- WITHIN GRP RANKS ----
        bys `group' (`varlist'): gen `r' = _n
        bys `group': egen `size' = count(`r')

        // ---- RANK OF PERCENTILE LEAVING OUT LOWEST REALIZATION ----
        bys `group': gen `k1' = 1 + floor(`p' * (`size' - 1))

        // ---- INDICATOR BELOW K1 ----
        gen `belowk1' = `r' < `k1'

        // ---- RANK OF PERCENTILE LEAVING OUT RANK K1 ----
        gen `km' = `k1' + 1

        // ---- VALUE OF X RANKING AT K1 COPIED INTO HIGHEST RANKING BELOW K1 ----
        bys `group' (`varlist'): gen `perc0' = `varlist'[_n+1] if `r' == `k1' - 1

        // ---- VALUE OF X RANKING AT KM COPIED INTO LOWEST RANKING ABOVE K1 ----
        replace `perc0' = `varlist' if `r' == `km'

        // ---- COPY ON OTHER OBSERVATIONS ON EACH SIDE OF CUTOFF ----
        bys `group' `belowk1': egen `perc' = mean(`perc0')

		// if `k1' == 1 | `k1' == `size' - 1, I handle this with min and max, respectively
		bys `group' (`varlist'): replace `perc' = `varlist'[1] if `k1' == 1 & `r' != 1
		bys `group' (`varlist'): replace `perc' = `varlist'[_n+1] if `k1' == 1 & `r' == 1

		bys `group' (`varlist'): replace `perc' = `varlist'[_N] if `k1' >= `size' - 1 & `r' != `size'
		bys `group' (`varlist'): replace `perc' = `varlist'[_N-1] if `k1' >= `size' - 1 & `r' == `size'

		
        // Final variable name
        rename `perc' `gen'

        save `result'

    restore

    // Merge back (respecting original missing group obs)
    quietly merge 1:1 `id' using `result', nogen keepusing(`gen')

end
