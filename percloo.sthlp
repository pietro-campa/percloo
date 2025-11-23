{smcl}
{title:percloo — Leave-one-out percentile within groups}

{p 4 4 2}
{cmd:percloo} computes the leave-one-out percentile of a variable within
groups. For each observation, its own value is removed, the remaining values
are re-ranked, and the percentile {it:p} is interpolated from the
leave-one-out distribution.

{title:Syntax}

{p 8 8 2}
{cmd:percloo} {it:varname}, {cmd:group(}{it:groupvar}{cmd:)} {cmd:p(}{it:#}{cmd:)} {cmd:gen(}{it:newvar}{cmd:)}

{title:Options}

{p 4 8 2}
{cmd:group(}{it:groupvar}{cmd:)}
    Specifies the grouping variable. Percentiles are computed separately
    within each group.

{p 4 8 2}
{cmd:p(}{it:#}{cmd:)}
    The desired percentile in [0,1], e.g. 0.5 for the median.

{p 4 8 2}
{cmd:gen(}{it:newvar}{cmd:)}
    Name of the new variable containing the leave-one-out percentile.
    The variable must not already exist.

{title:Description}

{p 4 4 2}
Within each group, observations are sorted by {it:varname}. For each
observation {it:i}, the program removes {it:i}, reduces the ranks of higher
observations by one, and computes the percentile rank

{p 8 8 2}
{k = p*(n–1)}

{p 4 4 2}
where {it:n} is the group size. The program identifies the closest integer
ranks to {it:k} and linearly interpolates the value of {it:varname}
corresponding to those ranks. The result is stored in {it:newvar}.

{title:Example}

{cmd:. sysuse auto}
{cmd:. percloo price, group(foreign) p(0.5) gen(p50_loo)}

{title:Stored results}

{p 4 4 2}
{cmd:percloo} is an {cmd:eclass} command but stores no additional
returned results.

{title:Author}

{p 4 4 2}
Pietro Campa — {it:percloo version 1.0.0 (23 Nov 2025)}
