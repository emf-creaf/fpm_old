% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/smooth_stand.r
\name{smooth_stand}
\alias{smooth_stand}
\title{Convolution of discrete tree stands}
\usage{
smooth_stand(a, idplot, smooth_type = "gaussian", width = 2, progressbar = T)
}
\arguments{
\item{a}{a \code{sf} object containing a number of POINT geometry types.}

\item{idplot}{identifiers of POINT elements representing tree stands to smooth.}

\item{smooth_type}{string indicating which smoothing window to use. Presently,
only \code{smooth_type = "gaussian"} option is available.}

\item{width}{width of smoothing window.}

\item{progressbar}{logical to print a progress bar with package \code{progress}.}
}
\value{
A \code{sf} object with a continuous distributions of trees per species as a
function of dbh, instead of a set of individual dbh values (as would happen
if data came from observations).
}
\description{
Convolution of discrete tree stands per species with smoothing window
}
\details{
Convolution with a continuous window function is done with a numerical quadrature.
The default value (\code{smooth_type = "gaussian"}) such be good enough for
most purposes.
}
\examples{

# First initialize one single stand.
a <- start_stand("ID1", 5, 45, "EPSG:4326")
a <- set_attributes(a)

# Next, we merge other stands.
for (i in 2:10) {
b <- start_stand(paste0("ID",i), 5, 45, "EPSG:4326")
b <- set_attributes(b)
a <- merge_stands(a,b)
}

# Now we add tree information.
for (i in 1:10) {
df <- data.frame(species = c(sample(c("Pnigra","Phalep"),5,replace=T)),
dbh = 7.5+runif(5)*20, factor_diam = sample(c(127.324, 31.83099),5,replace=T))
a <- build_stand(a, paste0("ID",i), df, "trees", "individual", 1990)
}

# Convolve to obtain a continuous distribution.
x <- data.frame(Pnigra = seq(7.5,200,length=1000), Phalep = seq(7.5,250,length=1000))
a <- set_attributes(a, integvars = x)
b <- smooth_stand(a)

}
