# Running HMER with Tbmod (using the AutoEmulateRerun.R script) for the a project evaluating vaccination in subclinical TB

**1) I have organized the project within a conda environment called cali_env** 

(I am assuming you already have Anaconda3 installed) 

- Initialize Anaconda3
```bash
conda init
```
- Create conda environment. Change *env_name* to a name of your choice:
```bash
conda create -n cali_env
```
- Active that environment:
```bash
conda activate cali_env
```

**2) Using an appropriate version of R within the conda environment**
- Here I have selected version 4.3.2, but this could vary based on the tbmod/tbvax dependencies:
```bash
conda install -c conda-forge r-base=4.3.2
```

**3) Installing R packages required by the AutoEmulateRerun.R script and the TBMod package**

- Install R packages:
```bash
conda install -c r r-matrix r-here r-assertthat r-stringi r-xml2 r-digest r-desolve r-data.table r-fst r-minpack.lm r-lubridate r-log4r r-lhs r-ggplot2 r-mass r-viridis r-ggally r-ggbeeswarm r-reshape2 r-tidyverse 
```
- Open R (verify the version loaded matches the version you selected in step #2):
```bash
R
```
- [From within R] load packages:
```R
pkgs <- c("Matrix", "here", "assertthat", "xml2", "digest", "deSolve", "data.table", "fst", "minpack.lm", "lubridate", "log4r")
lapply(pkgs, library, character.only = TRUE) 
```
- [From within R] Install hmer:
```R
install.packages(“hmer”)
```
- [From within R] Building TBMod tarball, using the relevant filepath and filename (here I am using tbmod_3.6.1.tar.gz):
```R
install.packages(here("tbmod-rpackage", "tbmod_3.6.1.tar.gz"), repos = NULL, type = "source")
```
- [From within R] Load TBMod and verify the correct version has been installed:
```R
library("tbmod")
packageVersion("tbmod")
```


----

Project files: 

Files used to run IND model:
1. R	       = "CheckTargetHits.R"
2. xml         = "XMLinput_target.xml"
3. xml schema  = "TBmod-schema-E.xsd"
4. targets     = "target_count.csv"

IND XML inputs are stored in countries/IND/data. Includes:
1. demographics.csv
2. deathrates.csv
3. all_contacts_2021.txt
4. M72_scaleup_med_prev_rate.txt

Files used to plot stocks outputs stored under SubclinicalTB-Vx folder:
1. calling_script.R
2. tbmod_stocks_plotting_funcs.R
3. filters3.csv
