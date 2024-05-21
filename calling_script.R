# ------------------------------ 
# Plotting functions
# original script by Tomos Prys-Jones
# 27/02/2024
# ------------------------------
rm(list=ls())

source("../tbmod_stocks_plotting/tbmod_stocks_plotting_funcs.R")

ft <- read.csv(file = paste0(here("../tbmod_stocks_plotting/filters3.csv")))
example_stocks <- as.data.table(read_tsv(path = here(ft$stocks.file.path[1])))

test_filtered_stocks <- filter.stocks(filter.table = ft)
test_plots <- plot.stocks(stocks.dt.list = test_filtered_stocks) 

i <- 1

test_plot_x <- test_plots[[i]]
test_plot_x <- test_plot_x +
  xlim(2029, NA)

ggsave(filename = here("plots", paste0("test_plot.png")),
       plot = test_plot_x, 
       width = 8, 
       height = 4, 
       dpi = 500)
