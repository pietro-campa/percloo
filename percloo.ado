*! version 1.0.0 23Nov2025
* Atuhor : Pietro Campa 
program define percloo, eclass sortpreserve
    version 16
    
    // ---- PARSE SYNTAX ----
    // varlist:    exactly 1 numeric variable (the variable whose percentile is computed)
    // group():    required grouping variable
    // p():        required percentile between 0 and 1
    // gen():      required new variable to store LOO percentile
    syntax varlist(max=1 numeric), GROUP(string) P(real) GEN(string)
	    
    // ---- PREVENT OVERWRITING ----
    capture confirm var `gen'
    if _rc == 0 {
        display `"{red}Variable {bf:`gen'} already exists. Replace is not allowed."'
        error 498
    }
	
    // ---- P FROMAT ----
	
	if (`p' < 0 | `p' > 1) {
        display as error `"{red}Parameter {bf:p} must be between 0 and 1."'
		error 198
	}	
    
    tempvar r size
    tempname A
    
    // ---- WITHIN-GROUP RANK ----
    // r    = rank of each observation within group (ascending)
    // size = number of obs in each group
    bys `group' (`varlist') : gen `r' = _n
    bys `group' : egen `size' = count(`r')

    // ---- CALL MATA FUNCTION TO COMPUTE LOO PERCENTILES ----
    mata: `A' = percloo_mata("`varlist'", "`r'", "`size'", `p')
    
    // ---- STORE RESULT BACK INTO STATA ----
    getmata `gen' = `A'
    
end


/***********************************************************************
   MATA FUNCTION: percloo_mata()
   Computes the leave-one-out percentile p of variable X within groups.
   For each observation o:
     1. Remove observation o from group.
     2. Re-rank remaining values.
     3. Identify the left/right integer percentile ranks around p*(n−1)
     4. Linearly interpolate between them.
************************************************************************/

mata:
real matrix percloo_mata(
          string scalar varnm,   // variable name: X
          string scalar ranknm,  // original ranks within group
          string scalar sizenm,  // group sizes
          real   scalar perc     // percentile p (0–1)
)
{
    real vector X, r, n, LOO
    real scalar p

    // ---- READ VARIABLES FROM STATA ----
    X = st_data(., varnm)
    r = st_data(., ranknm)
    n = st_data(., sizenm)

    p = perc
    LOO = J(rows(X), 1, .)   // output vector

    // ---- LOOP OVER POSSIBLE RANKS WITHIN GROUP ----
    for (o = 1; o <= max(n); o++) {

        // Observations with original rank o = omitted individual
        id       = selectindex(r :== o)

        // Observations above rank o → their rank drops by 1 when o removed
        id_above = selectindex(r :> o)

        // ---- Construct leave-one-out ranks ----
        rloo = r
        rloo[id_above] = r[id_above] :- 1       // shift down
        rloo[id]       = J(rows(id),1,.)        // omitted obs have missing rank

        // ---- Target rank k = p*(n–1) ----
        k = p * (n :- 1)

        // ---- Closest integer ranks around k ----
        right_k = ceil(k)
        left_k  = floor(k)

        // Left rank is at least 1
        zero = selectindex(left_k :< 1)
        left_k[zero] = J(rows(zero),1,1)

        // ---- Distance from left integer rank ----
        a = k[id] - left_k[id]

        // ---- Identify the observations with those ranks ----
        id_l = selectindex(rloo :== left_k)
        id_r = selectindex(rloo :== right_k)

        // ---- Linear interpolation between X[left] and X[right] ----
        LOO[id] = a :* X[id_l] + (J(rows(a),1,1) - a) :* X[id_r]
    }

    return(LOO)
}
end
