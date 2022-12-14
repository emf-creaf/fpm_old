#' Convolution of discrete tree stands
#'
#' @description
#' Convolution of discrete tree stands per species with smoothing window
#'
#' @param a a \code{sf} object containing a number of POINT geometry types.
#' @param idplot identifiers of POINT elements representing tree stands to smooth.
#' @param stand_type string specifying which type of tree stand to obtain.
#' @param smooth_type string indicating which smoothing window to use. Presently,
#' only \code{smooth_type = "gaussian"} option is available.
#' #' @param width width of smoothing window.
#'
#' @return
#' A \code{sf} object with a continuous distributions of trees per species as a
#' function of dbh, instead of a set of individual dbh values (as would happen
#' if data came from observations).
#'
#' @details
#' Convolution with a continuous window function is done with a numerical quadrature.
#' The default value (\code{smooth_type = "gaussian"}) such be good enough for
#' most purposes.
#'
#' @export
#'
#' @examples
#'
#' # First initialize one single stand.
#' a <- start_stand("ID1", 5, 45, "EPSG:4326")
#' a <- set_attributes(a)
#'
#' # Next, we merge other stands.
#' for (i in 2:10) {
#' b <- start_stand(paste0("ID",i), 5, 45, "EPSG:4326")
#' b <- set_attributes(b)
#' a <- merge_stands(a,b)
#' }
#'
#' # Now we add tree information.
#' for (i in 1:10) {
#' df <- data.frame(species = c(sample(c("Pnigra","Phalep"),5,replace=T)),
#' dbh1 = 7.5+runif(5)*20, factor_diam1 = sample(c(127.324, 31.83099),5,replace=T))
#' a <- build_stand(a, paste0("ID",i), df, "trees", "individual", 1990)
#' }
#'
#' # Convolve to obtain a continuous distribution.
#' x <- data.frame(Pnigra = seq(7.5,200,length=1000), Phalep = seq(7.5,250,length=1000))
#' a <- set_attributes(a, integvars = x)
#' b <- smooth_stand(a)
#'
smooth_stand <- function(a, idplot, stand_type = c("individual", "mpm", "ipm"), smooth_type = "gaussian", width = 2) {

  mf <- match.call()
  m <- match(c("a", "idplot", "stand_type", "smooth_type", "width"), tolower(names(mf)[-1]))

  # Does 'idplot' exist?
  if (is.na(m[2])) idplot <- a$idplot
  id <- match(idplot, a$idplot)
  if (any(is.na(id))) stop("Could not find 'idplot' in 'a'")

  # If stands are not of "individual" type, smoothing cannot be performed.
  if (any(!(a[id, ]$stand_type %in% "individual"))) stop("Some stands are not of 'individual' type")

  # From discrete to matrix or ipm-type stands.
  stand_type <- match.arg(stand_type)

  # We need the integration variable for the calculations.
  x <- attr(a, "integvars")
  if (is.null(x)) stop("Attribute 'integvars' is missing")
  nx <- nrow(x)

  # Loop along all plots.
  for (i in id) {

    # Species to smooth.
    trees <- a[i, ]$trees[[1]]
    species <- unique(trees$species)
    nsp <- length(species)

    # Check that all species are in 'integvars' data.frame.
    colx <- colnames(x)
    if (any(!(species %in% colx))) stop(cat("Species in stand ",i," do not match those in 'integvars' attribute\n"))

    # Big matrix to store results per species column-wise.
    df <- matrix(0,nx, nsp, dimnames = list(c(), species))

    if (stand_type == "ipm") {
      for (j in species) {
        y <- trees[trees$species == j, , drop = F]
        for (k in 1:nrow(y)) {
          df[, j] <- df[, j] +
            MiscStat::fast_kernsmooth(x[, j], y$dbh1[k] , width = width) * y$factor_diam1[k]
        }
      }
    } else if (stand_type == "mpm") {
    }

    # Store and change 'stand_type' to "ipm".
    a[i, ]$trees[[1]] <- as.data.frame(df)
  }

  # Finally, stand_type is set.
  a[id, ]$stand_type <- "ipm"

  return(a)
}
