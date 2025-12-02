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
percloo price, group(foreign) p(0.01) gen(p50_loo)

sort foreign price
li foreign price p50

/////////////////////////
// Alternative example
clear all
set obs 21
gen group = 1 if _n <12
replace group = 2 if group == .
gen x = runiform()
gsort group x
percloo x, group(group) p(0.01) gen(p50_loo)
li
