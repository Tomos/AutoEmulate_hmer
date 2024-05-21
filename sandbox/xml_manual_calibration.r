library(XML)

# Load the XML file
xml_file <- "countries/IND/parameters/XMLinput_NewTB_Structure_MC.xml"
doc <- xmlTreeParse(xml_file, useInternalNodes = TRUE)

# Function to update TB parameters within a range
update_TB_parameter <- function(parameter_name, min_value, max_value) {
  # Find TB parameters with the given name
  tb_parameters <- getNodeSet(doc, paste("//TB.parameter[@name='", parameter_name, "']", sep = ""))
  
  # Update the values within the specified range
  for (tb_param in tb_parameters) {
    tb_param_value <- as.numeric(xmlAttrs(tb_param)["value"]) # Access attribute directly
    updated_value <- runif(1, min_value, max_value) # Random value within the range
    xmlAttrs(tb_param)["value"] <- updated_value # Update attribute directly
  }
}


# Example usage: Update the 'infclr' parameter within a range
update_TB_parameter("infclr", 1, 3)  # Specify your desired range

# Save the modified XML file
saveXML(doc, file = "countries/IND/parameters/XMLinput_NewTB_Structure_UpdateParam.xml")
