# Load core packages:
suppressPackageStartupMessages({
  # Clear the environment, plots and console
  rm(list=ls())
  if(!is.null(dev.list())) dev.off()
  cat("\f")
  model = new.env()
  library(here)
  library(data.table)
  library(renv)
  library(digest)
  library(log4r)
  library(fst)
  library(viridis)
  library(xml2)
  library(assertthat)
  # Load linter and styler packages (not core packages):
  #library(styler)
  #library(lintr)
})

tarball <- here("tbmod-rpackage", "tbmod_3.6.1.tar.gz")

if(require(tbmod) == TRUE){ # if tbvax is already installed
  detach(package:tbmod, unload=TRUE)
  remove.packages("tbmod")
  install.packages(tarball, repos = NULL, type = "source")
  library(tbmod)
  print(paste0("TBMod package version: ", packageVersion("tbmod")))
}else{
  install.packages(tarball, repos = NULL, type = "source")
  library(tbmod)
  print(paste0("TBMod package version: ", packageVersion("tbmod")))
}