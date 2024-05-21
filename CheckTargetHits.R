#### Running the updated model comparing to targets
# Uses tbmod version 3.6.0

suppressPackageStartupMessages({
  rm(list=ls())
  require(tbmod)
  require(tidyverse)
  library(XML)
  library(data.table)
})


#1. Set up the paths (with the input.csv and target.csv)
# paths = set.paths(countries   = "countries", 
#                   countrycode = "IND", 
#                   xml         = "XMLinput_target.xml", 
#                   parameters  = "input_all.csv",
#                   targets     = "target_count.csv")
# 
# # Run the model, sample parameters from the input.csv each time
# output <- run(paths, sample.parameters = T, output.flows = F, write.to.file = F)

#2. Set up the paths (with target.csv ONLY)
paths = set.paths(countries   = "countries",
                  countrycode = "IND",
                  xml         = "XMLinput_target.xml",
                  targets     = "target_count.csv")

# Run the model, sample parameters from the input.csv each time
output <- run(paths, sample.parameters = F, output.flows = T, write.to.file = T, output.format = "txt")

# Extract the "hits" dataframe
target_hits <- output$hits

# Sum the number of targets that were hit
sum(target_hits$fit)

### Look at TB trends 
TB_trends <- output$stocks
TB_trends <- TB_trends[age_from == 0 & age_thru == 14, `Age Group` := "[0,14]"]
TB_trends <- TB_trends[age_from == 0 & age_thru == 99, `Age Group` := "[0,99]"]
TB_trends <- TB_trends[age_from == 15 & age_thru == 99, `Age Group` := "[15,99]"]
TB_trends <- TB_trends[, !c("age_from", "age_thru")]

#str(TB_trends)

# Copy Old dataframe to New DataFrame.
TB_trends_new <- TB_trends 

# Change the order of Users column of DataFrame
TB_trends_new$`Age Group` <- factor(TB_trends_new$`Age Group`, 
                      levels = c("[0,14]", "[15,99]", "[0,99]"))

# Number in each TB strata over time by Age
### (Note: no treatment in mode yet so Rt = 0)
ggplot(TB_trends_new[VXa=="never"]) +
  geom_line(aes(x = year, y = value, col = `Age Group`)) +
  scale_y_continuous(limits = c(0, NA)) +
  facet_wrap(~ TB, scales = "free_y") +
  scale_color_viridis_d() +
  labs(title = "Number in each TB strata") +
  ylab("Number (1000s)") + xlab("Year") 


# ggplot(TB_trends_new[VXa=="vac"]) +
#   geom_line(aes(x = year, y = value, col = `Age Group`)) +
#   scale_y_continuous(limits = c(0, NA)) +
#   facet_wrap(~ TB, scales = "free_y") +
#   scale_color_viridis_d() +
#   labs(title = "Number in each TB strata") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# ggplot(TB_trends_new[VXa=="prev"]) +
#   geom_line(aes(x = year, y = value, col = `Age Group`)) +
#   scale_y_continuous(limits = c(0, NA)) +
#   facet_wrap(~ TB, scales = "free_y") +
#   scale_color_viridis_d() +
#   labs(title = "Number in each TB strata") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# #Ds
# ggplot(TB_trends_new[VXa=="never"][TB == "Ds"]) +
#   geom_line(aes(x = year, y = value, col = `Age Group`)) +
#   ylim(c(0, NA)) +
#   scale_color_viridis_d() +
#   labs(title = "Numbers in Subclinical Disease by Age") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# 
# # Flows into Minimal Disease by Age
# ggplot(TB_trends_new[TB == "Dmcount"][VXa=="never"]) +
#   geom_line(aes(x = year, y = value, col = `Age Group`)) +
#   ylim(c(0, NA)) + 
#   scale_color_viridis_d() +
#   labs(title = "Flows into Minimal Disease by Age") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# # Flows into Subclinical Disease by Age
# ggplot(TB_trends_new[TB == "Dscount"][VXa=="never"]) +
#   geom_line(aes(x = year, y = value, col = `Age Group`)) +
#   ylim(c(0, NA)) +
#   scale_color_viridis_d() +
#   labs(title = "Flows into Subclinical Disease by Age") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# # Flows into Clinical Disease by Age
# ggplot(TB_trends_new[TB == "Dccount"][VXa=="never"]) +
#   geom_line(aes(x = year, y = value, col = `Age Group`)) +
#   ylim(c(0, NA)) + 
#   scale_color_viridis_d() +
#   labs(title = "Flows into Clinical Disease by Age") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# ggplot(TB_trends_new[TB == "DcTcount"][VXa=="never"]) +
#   geom_line(aes(x = year, y = value, col = `Age Group`)) +
#   ylim(c(0, NA)) + 
#   scale_color_viridis_d() +
#   labs(title = "Flows into Treatment by Age") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# 
# # Population over time
# population <- output$population
# population <- setDT(population)
# population <- population[year %% 1 == 0.5]
# population <- population[, `99` := `0` + `15`]
# population <- melt(population, id.vars = c("year", "country"),
#                    measure.vars = c("0", "15", "99"),
#                    variable.name = "Age Group", value.name = "Population")
# 
# population <- population[`Age Group` == 0, `Age Group` := "[0,14]"]
# population <- population[`Age Group` == 15, `Age Group` := "[15,99]"]
# population <- population[`Age Group` == 99, `Age Group` := "[0,99]"]
# 
# 
# ggplot(population) +
#   geom_line(aes(x = year, y = Population, col = `Age Group`)) +
#   ylim(c(0, NA)) + 
#   scale_color_viridis_d() +
#   labs(title = "Population by Age") +
#   ylab("Number (1000s)") + xlab("Year")
# 
# # Calculate the prevalence 
# Prev_disease <- TB_trends[TB == "Ds" | TB == "Dc"][VXa=="never"]
# Prev_disease <- Prev_disease[, .(total_value = sum(value)),
#                              by = .(country, year, `Age Group`)]
# 
# Prev_disease <- Prev_disease[, year := floor(year)]
# 
# population <- population[, year := floor(year)]
# population <- population[year > 1998 & year < 2050]
# 
# prev <- merge(Prev_disease, population)
# 
# prev <- prev[, Prev_DsDc := (total_value/Population)*100000]
# 
# ggplot(prev) +
#   geom_line(aes(x = year, y = Prev_DsDc, col = `Age Group`)) +
#   ylim(c(0, NA)) + 
#   scale_color_viridis_d() +
#   labs(title = "Prevalence") +
#   ylab("Prevalence per 100,000") + xlab("Year")

# --- end

#3. Set up XML with multiple varying multiple parameters and combination 

# read in input_all.csv to read in ranges to vary parameters which are TRUE
# FALSE parameter values are a constant
input_all = fread("countries/IND/parameters/input_all.csv")
input_param = input_all[name %in% input_all$name & choose == TRUE]


# # Function to update singular TB parameter
# update_TB_parameter <- function(parameter_name, min_value, max_value) {
#   # Find TB parameters with the given name
#   # to return one parameter you can so this by setting parameter_name = input_param$parameter[1] 
#   # or to return a list of all you are interested in set parameter_name = input_param$parameter
#   # to return ALL parameters, you can simply run: getNodeSet(doc, "//TB.parameter")
#   tb_parameters <- getNodeSet(doc, paste("//TB.parameter[@name='", parameter_name, "']", sep = ""))
#   
#   # Update the values within the specified range
#   for (tb_param in tb_parameters) {
#     tb_param_value <- as.numeric(xmlAttrs(tb_param)["value"]) # Access attribute directly
#     updated_value <- runif(1, min_value, max_value) # Random value within the range
#     xmlAttrs(tb_param)["value"] <- updated_value # Update attribute directly
#   }
# }
# 
# 
# # Example usage: Update the 'infclr' parameter within a range
# update_TB_parameter("infclr", 1, 3)  # Specify your desired range
# 
# # Save the modified XML file
# saveXML(doc, file = "countries/IND/parameters/XMLinput_target_updated.xml")

update_TB_parameter <- function(param_df) {
  # Store results
  results <- data.frame()
  
  parameters = colnames(param_df)
  # Find TB parameters with the given name
  tb_parameters <- getNodeSet(doc, paste("//TB.parameter[@name='", parameters, "']", sep = ""))
  
  # Loop through each row in input_param
  for (i in 1:nrow(param_df)) {
    # Update the values for the current parameter
    for (n in 1:length(tb_parameters)) {
      param_name = as.character(xmlAttrs(tb_parameters[[n]])["name"])
      xmlAttrs(tb_parameters[[n]])["value"] <- as.numeric(param_df[i,param_name]) # Update attribute directly
      
    }
    
    # Save the modified XML file
    saveXML(doc, file = "countries/IND/parameters/XMLinput_new_UpdateParam.xml")
    
    paths = set.paths(countries   = "countries",
                      countrycode = "IND",
                      xml         = "XMLinput_new_UpdateParam.xml",
                      targets     = "target_count.csv")
    
    # Run the model with updated parameters
    output <- run(paths, sample.parameters = F, output.flows = F, write.to.file = F)
    
    # Extract hits
    hits <- output$hits
    
    # Store results in data frame
    result_row <- data.frame(target_name = paste0(hits$xTB, "_", hits$name, "_", hits$type),
                             Value = hits$model,
                             Hits = hits$fit)
    
    colnames(result_row)[2:3] <- c(paste0("Value",i), paste0("Hits",i))
    
    if(i == 1){
      results <- rbind(results, result_row)
    }else{
      results <- cbind.data.frame(results, result_row[,2:3])
    }
    
  }
  
  return(results)
}

param_df <- expand_grid(
  kappa =   runif(1, as.numeric(input_param[name=="kappa"]$min), as.numeric(input_param[name=="kappa"]$max)), 
  eta   =   runif(1, as.numeric(input_param[name=="eta"]$min), as.numeric(input_param[name=="eta"]$max)),
  muTB =    runif(1, as.numeric(input_param[name=="muTB"]$min), as.numeric(input_param[name=="muTB"]$max)),
  
  
  infclr = runif(3, as.numeric(input_param[name=="infclr"]$min),  as.numeric(input_param[name=="infclr"]$max)),
  minrec = runif(1, as.numeric(input_param[name=="minrec"]$min), as.numeric(input_param[name=="minrec"]$max)),
  infmin = runif(1, as.numeric(input_param[name=="infmin"]$min), as.numeric(input_param[name=="infmin"]$max)),
  infsub = runif(3, as.numeric(input_param[name=="infsub"]$min), as.numeric(input_param[name=="infsub"]$max)),
  minsub = runif(1, as.numeric(input_param[name=="minsub"]$min), as.numeric(input_param[name=="minsub"]$max)),
  submin = runif(1, as.numeric(input_param[name=="submin"]$min),  as.numeric(input_param[name=="submin"]$max)),
  subclin = runif(1, as.numeric(input_param[name=="subclin"]$min),  as.numeric(input_param[name=="subclin"]$max)),
  clinsub = runif(1, as.numeric(input_param[name=="clinsub"]$min), as.numeric(input_param[name=="clinsub"]$max)),
  
  relsub = runif(1, as.numeric(input_param[name=="relsub"]$min), as.numeric(input_param[name=="relsub"]$max)),
  relmin = runif(1, as.numeric(input_param[name=="relmin"]$min), as.numeric(input_param[name=="relmin"]$max)),
  
  lambda = runif(1, as.numeric(input_param[name=="lambda"]$min), as.numeric(input_param[name=="lambda"]$max)),
  p =      runif(1, as.numeric(input_param[name=="p"]$min),  as.numeric(input_param[name=="p"]$max)),
  r =      runif(1, as.numeric(input_param[name=="r"]$min),  as.numeric(input_param[name=="r"]$max))
)


# Example usage: Update TB parameters using input_param and store results
results <- update_TB_parameter(param_df)

#sum hits for each run of varying parameters
sum_hits = results %>%
  select(starts_with("H")) %>%
  colSums()





