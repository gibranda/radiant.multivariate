% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conjoint.R
\name{plot.conjoint}
\alias{plot.conjoint}
\title{Plot method for the conjoint function}
\usage{
\method{plot}{conjoint}(x, plots = "pw", show = "", scale_plot = FALSE,
  shiny = FALSE, ...)
}
\arguments{
\item{x}{Return value from \code{\link{conjoint}}}

\item{plots}{Show either the part-worth ("pw") or importance-weights ("iw") plot}

\item{show}{Level in by variable to analyse (e.g., a specific respondent)}

\item{scale_plot}{Scale the axes of the part-worth plots to the same range}

\item{shiny}{Did the function call originate inside a shiny app}

\item{...}{further arguments passed to or from other methods}
}
\description{
Plot method for the conjoint function
}
\details{
See \url{https://radiant-rstats.github.io/docs/multivariate/conjoint.html} for an example in Radiant
}
\examples{
result <- conjoint(dataset = "mp3", rvar = "Rating", evar = "Memory:Shape")
plot(result, scale_plot = TRUE)
plot(result, plots = "iw")

}
\seealso{
\code{\link{conjoint}} to generate results

\code{\link{summary.conjoint}} to summarize results
}

