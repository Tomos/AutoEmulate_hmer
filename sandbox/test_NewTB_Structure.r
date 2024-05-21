# ----------------------------------------------------
# Running the simple NIH2 model structure in tbmod
# Example plots of TB strata, flows into Dm, Ds, and Dc, and population size
# Rebecca Clark
# Updated 20 February 2024
# ----------------------------------------------------

#### Make sure the tbmod package is installed
library(here)

#build tbmod package
install.packages(here("tbmod-rpackage", "tbmod_3.6.1.tar.gz"), repos = NULL, type = "source")

library(tbmod)
tbmod::modelversion()
#### Currently using version 3.6.1
#### Open tbmod Rproj saved in tbmod(1) folder & then open r script within Rproj
#### save xml script in the appropriate pathway i.e. folders within tbmod(1) 

suppressPackageStartupMessages({
  rm(list=ls())
  require(tbmod)
  library(data.table)
  library(ggplot2)
  library(cowplot)
  library(patchwork)
  
  theme_set(theme_minimal_grid() + panel_border(color = "black"))
  
})


# IND is included here as an example, but this script works with BRA/ZAF as well

# set.paths = initialize the params
# paths = set.paths(countries   = "countries", 
#                   countrycode = "IND", 
#                   xml         = "XMLinput_NewTB_Structure.xml")

# with target csv 
paths = set.paths(countries   = "countries",
                  countrycode = "IND",
                  xml         = "XMLinput_NewTB_Structure.xml",
                  targets     = "target_new_OK2F.csv")

# paths = set.paths(countries   = "countries",
#                   countrycode = "IND",
#                   xml         = "XMLinput_NewTB_Structure_OK2D.xml",
#                   targets     = "target_new_OK2F.csv")

# Run the model, sample parameters from input.csv
# output = run(paths, sample.parameters = T, output.flows = F, write.to.file = F)

# take out sample.parameters
output = run(paths, output.flows = T, write.to.file = F)
hits = output$hits

### Look at TB trends 
TB_trends <- output$stocks
TB_trends <- TB_trends[age_from == 0 & age_thru == 14, `Age Group` := "[0,14]"]
TB_trends <- TB_trends[age_from == 0 & age_thru == 99, `Age Group` := "[0,99]"]
TB_trends <- TB_trends[age_from == 15 & age_thru == 99, `Age Group` := "[15,99]"]
TB_trends <- TB_trends[, !c("age_from", "age_thru")]

# Number in each TB strata over time by Age
### (Note: no treatment in mode yet so Rt = 0)
ggplot(TB_trends[VXa=="never"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  scale_y_continuous(limits = c(0, NA)) +
  facet_wrap(~ TB, scales = "free_y") +
  scale_color_viridis_d() +
  labs(title = "Number in each TB strata") +
  ylab("Number (1000s)") + xlab("Year")

ggplot(TB_trends[VXa=="vac"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  scale_y_continuous(limits = c(0, NA)) +
  facet_wrap(~ TB, scales = "free_y") +
  scale_color_viridis_d() +
  labs(title = "Number in each TB strata") +
  ylab("Number (1000s)") + xlab("Year")

ggplot(TB_trends[VXa=="prev"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  scale_y_continuous(limits = c(0, NA)) +
  facet_wrap(~ TB, scales = "free_y") +
  scale_color_viridis_d() +
  labs(title = "Number in each TB strata") +
  ylab("Number (1000s)") + xlab("Year")

#Ds
ggplot(TB_trends[VXa=="never"][TB == "Ds"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  ylim(c(0, NA)) +
  scale_color_viridis_d() +
  labs(title = "Numbers in Subclinical Disease by Age") +
  ylab("Number (1000s)") + xlab("Year")


# Flows into Minimal Disease by Age
ggplot(TB_trends[TB == "Dmcount"][VXa=="never"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  ylim(c(0, NA)) + 
  scale_color_viridis_d() +
  labs(title = "Flows into Minimal Disease by Age") +
  ylab("Number (1000s)") + xlab("Year")

# Flows into Subclinical Disease by Age
ggplot(TB_trends[TB == "Dscount"][VXa=="never"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  ylim(c(0, NA)) +
  scale_color_viridis_d() +
  labs(title = "Flows into Subclinical Disease by Age") +
  ylab("Number (1000s)") + xlab("Year")

# Flows into Clinical Disease by Age
ggplot(TB_trends[TB == "Dccount"][VXa=="never"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  ylim(c(0, NA)) + 
  scale_color_viridis_d() +
  labs(title = "Flows into Clinical Disease by Age") +
  ylab("Number (1000s)") + xlab("Year")

ggplot(TB_trends[TB == "DcTcount"][VXa=="never"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  ylim(c(0, NA)) + 
  scale_color_viridis_d() +
  labs(title = "Flows into Clinical Disease by Age") +
  ylab("Number (1000s)") + xlab("Year")


# Population over time
population <- output$population
population <- setDT(population)
population <- population[year %% 1 == 0.5]
population <- population[, `99` := `0` + `15`]
population <- melt(population, id.vars = c("year", "country"),
                   measure.vars = c("0", "15", "99"),
                   variable.name = "Age Group", value.name = "Population")

population <- population[`Age Group` == 0, `Age Group` := "[0,14]"]
population <- population[`Age Group` == 15, `Age Group` := "[15,99]"]
population <- population[`Age Group` == 99, `Age Group` := "[0,99]"]


ggplot(population) +
  geom_line(aes(x = year, y = Population, col = `Age Group`)) +
  ylim(c(0, NA)) + 
  scale_color_viridis_d() +
  labs(title = "Population by Age") +
  ylab("Number (1000s)") + xlab("Year")

# Calculate the prevalence 
Prev_disease <- TB_trends[TB == "Ds" | TB == "Dc"][VXa=="never"]
Prev_disease <- Prev_disease[, .(total_value = sum(value)),
                             by = .(country, year, `Age Group`)]

Prev_disease <- Prev_disease[, year := floor(year)]

population <- population[, year := floor(year)]
population <- population[year > 1998 & year < 2050]

prev <- merge(Prev_disease, population)

prev <- prev[, Prev_DsDc := (total_value/Population)*100000]

ggplot(prev) +
  geom_line(aes(x = year, y = Prev_DsDc, col = `Age Group`)) +
  ylim(c(0, NA)) + 
  scale_color_viridis_d() +
  labs(title = "Prevalence") +
  ylab("Prevalence per 100,000") + xlab("Year")


write.csv(hits, file = "countries/IND/output/hits/hits2.csv")

# --- end
