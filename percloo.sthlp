{smcl}
{* *! version 1.0.2  3 Dec 2025}{...}
{title:percloo — Leave-one-out percentile within groups}

{phang}
{bf:percloo} computes a leave-one-out percentile of a variable within groups.

{title:Syntax}

{p 8 16 2}
{cmd:percloo} {it:varname} ,
{cmd:group(}{it:varname}{cmd:)}
{cmd:p(}{it:#}{cmd:)}
{cmd:gen(}{it:newvar}{cmd:)}

{title:Description}

{pstd}
{cmd:percloo} calculates the percentile of {it:varname} within each group,
but in a leave-one-out (LOO) way: for each observation, its own value
is excluded before computing the percentile.

{pstd}
Formally, for observation {it:i} in group {it:g}, the leave-one-out percentile is defined as:

{p 12 12 2}
{it:LOO(p)} = min({it:k}) such that P({it:X_j} <= {it:k} | j ≠ i) = p

{pstd}
where the probability is computed over all other observations {it:j} in the group.

{title:Options}

{dlgtab:Main}

{phang}
{cmd:group(}{it:varname}{cmd:)}
required. The variable defining groups.  
Observations with missing group values are ignored and returned missing in {it:newvar}.

{phang}
{cmd:p(}{it:#}{cmd:)}
required. Percentile between 0 and 1.  
For example, {cmd:p(0.5)} computes the leave-one-out median.

{phang}
{cmd:gen(}{it:newvar}{cmd:)}
required. Name of the new variable created by the command.  
It must not already exist.

{title:Remarks}

{pstd}
The leave-one-out percentile is not simply the percentile adjusted by a factor;
removing a value shifts order statistics discontinuously.  {cmd:percloo}
handles this by recomputing the effective rank of the desired percentile
under each leave-one-out sample.

{pstd} 
Vetcorization avoids costly loops and it's based on the intuition that (exept for boundary cases treated separately) the LOO(p) is the same for all individuals on each side of a well defined rank.

{pstd}
You can install or update {cmd:percloo} directly from GitHub using:

. {cmd:net install} percloo, from("https://raw.githubusercontent.com/pietro-campa/percloo/main/") 

{title:Examples}

{pstd}
Compute the leave-one-out 25th percentile of variable {cmd:x} within {cmd:group},
saving the result in {cmd:x_p25_loo}:

. {cmd:percloo} x, group(group) p(0.25) gen(x_p25_loo)

{title:Stored results}

{pstd}
{cmd:percloo} stores no results in r().

{title:Author}

{pstd}
Pietro Campa  
Version 1.0.2 — 3 December 2025


