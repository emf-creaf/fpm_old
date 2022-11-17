test_that("Numerical quadrature", {

  # First initialize one single stand.
  a <- start_stand("ID1", 5, 45, "EPSG:4326")
  a <- set_attributes(a)

  # Next, we merge other stands.
  for (i in paste0("ID",2:10)) {
    b <- start_stand(i, 5, 45, "EPSG:4326")
    b <- set_attributes(b)
    a <- merge_stands(a,b)
  }

  # Now we add tree information.
  for (i in paste0("ID",1:10)) {
    df <- data.frame(species = c(sample(c("Pnigra","Phalep"),5,replace=T)),
                     dbh1 = 7.5+runif(5)*20, factor_diam1 = sample(c(127.324, 31.83099),5,replace=T))
    a <- build_stand(a, i, df, "trees", "individual", 1990)
  }

  # Convolve to obtain a continuous distribution.
  x <- data.frame(Pnigra = seq(7.5,200,length=1000), Phalep = seq(7.5,250,length=1000))
  a <- set_attributes(a, integvars = x)
  ainit <- stand_descriptive(a)
  a <- smooth_stand(a)

  # IPM functions.
  gr <- data.frame(Pnigra=rep(.1, nrow(x)), Phalep=rep(.15, nrow(x)))
  va <- data.frame(Pnigra=rep(2, nrow(x)), Phalep=rep(2.5, nrow(x)))
  su <- data.frame(Pnigra=rep(1, nrow(x)), Phalep=rep(1, nrow(x)))

  # Apply quadrature.
  b <- ipm_quadrature(a, "ID1", gr, va, su, min_dbh = 7.5)
  for (i in paste0("ID",2:10)) b <- ipm_quadrature(b, i, gr, va, su, min_dbh = 7.5)

  # Check resulting data.frames have the same dimensions.
  expect_equal(nrow(a[1,]$trees[[1]]),nrow(b[1,]$trees[[1]]))
  expect_equal(ncol(a[1,]$trees[[1]]),ncol(b[1,]$trees[[1]]))

  # Check species are the same.
  expect_true(all(colnames(a[1,]$trees[[1]]) %in% colnames(b[1,]$trees[[1]])))

  # Check descriptive statistics.
  ainit <- stand_descriptive(ainit)
  a <- stand_descriptive(a)
  b <- stand_descriptive(b)
  ab <- sapply(1:nrow(a), function(i) {
    colna <- colnames(a$N_species[[i]])
    colnb <- colnames(b$N_species[[i]])
    j <- match(colna, colnb)
    sum(abs(a$N_species[[i]]$N - b$N_species[[i]]$N[j]))
  })



})
