#' Removal of empty POINT
#'
#' @description
#' \code{remove_empty} removes empty POINT rows in a \code{stand} \code{sf} object.
#'
#' @param a a \code{sf} object containing a number of POINT geometry types.
#'
#' @details
#' \code{remove_empty} first uses \code{check_stand} to calculate the number of
#' adult trees, seedlings and saplings, and then removes all rows in the input
#' object with zeros in those three fields. It can be useful in those cases where
#' seed dispersal between tree stands is assumed to be negligible and, thus,
#' an empty stand will always remain empty.
#'
#' @return
#' \code{remove_empty} returns the input \code{sf} object but without rows
#' where the number of adults, seedlings AND saplings are zero.
#'
#' @export
#'
#' @examples
#'
#' # First initialize one single stand.
#' a <- start_stand("ID1", 5, 45, "EPSG:4326")
#' a <- set_attributes(a, country = "spain")
#'
#' # Next, we merge other stands.
#' for (i in 2:10) {
#' b <- start_stand(paste0("ID",i), 5, 45, "EPSG:4326")
#' b <- set_attributes(b, country = "spain")
#' a <- merge_stands(a,b)
#' }
#'
#' # Now we add tree information.
#' for (i in 1:6) {
#' df <- data.frame(species = c(sample(c("Pnigra","Phalep"),5,replace=T)),
#' dbh = 7.5+runif(5)*20, factor_diam = sample(c(127.324, 31.83099),5,replace=T))
#' a <- build_stand(a, paste0("ID",i), df, "trees", "individual", 1990)
#' }
#'
#'
remove_empty <- function(a, idplot = NULL) {

  id <- if (is.null(idplot)) 1:length(a$idplot) else match(idplot, a$idplot)
  if (any(is.na(i))) stop(cat(paste0("Could not find ",sum(is.na(i))," plots\n")))

  j <- rep(NA, length(id))
  icount <- 1
  for (i in id) {
    # if (length(a$trees[[i]]) == 0 & length(a$saplings[[i]]) == 0) j <- c(j, i)
    if (length(a$trees[[i]]) == 0 & length(a$saplings[[i]]) == 0) j[icount] <- i
    icount <- icount + 1
  }
  j <- j[!is.na(j)]
  if (length(j) > 0) a <- a[-j, ]

  return(a)
}


x <- runif(1000000)
t1 <- system.time({
  j <- NULL
  for (i in 1:length(x)) {
    if (x[i]>.5) j <- c(j, i)
  }
})

t2 <- system.time({
  k <- rep(NA, length(x))
  for (i in 1:length(x)) {
    if (x[i]>.5) k[i] <- i
  }
  k <- k[!is.na(k)]
})



