/********************************************************************
  Example do-file for percloo
  Computes leave-one-out percentiles for demonstration.
*********************************************************************/

clear all
set more off
which percloo


// Load sample dataset
sysuse auto, clear

// Inspect structure
describe
summarize price mpg weight

// Compute leave-one-out medians by car origin
percloo price, group(foreign) p(0.5) gen(p50_loo)

// Compare standard percentile vs leave-one-out version
summ price p50_loo

// Compute multiple percentiles
forvalues k = 10(10)90 {
    local p = `k'/100
    percloo price, group(foreign) p(`p') gen(p`k'_loo)
}

// List some examples
list make price foreign p50_loo p10_loo p90_loo in 1/10

// End
