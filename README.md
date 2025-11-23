# percloo: Leave-one-out percentiles within groups

**percloo** is a Stata command that computes *leave-one-out percentiles* of a variable
within groups. For each observation, its own value is removed, the remaining
observations are re-ranked, and the requested percentile is calculated with linear
interpolation. This is useful in applications involving peer-relative comparisons that exclude
the focal observation.

## Key Features

- Computes leave-one-out percentiles for any numeric variable.
- Uses linear interpolation between integer ranks.
- Written with Mata for speed.

## Installation

From GitHub (example URL):

```stata
net install percloo, from("https://raw.githubusercontent.com/YOURNAME/percloo/main/")
