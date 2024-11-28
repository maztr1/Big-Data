install.packages("ggplot2")
library(ggplot2)
library(tidyverse)
library(dplyr)
library(fs)

# Define the main folder path
main_folder <- "/Users/wilstermanlab/REU/MasterFolder"

# Get a list of all subfolders (organized by tag ID)
subfolders <- fs::dir_ls(main_folder, type = "dir", recurse = FALSE)

# Loop through each subfolder
for (subfolder in subfolders) {
  # Extract the tag ID from the subfolder path
  subfolder_parts <- strsplit(as.character(subfolder), split = "/")[[1]]
  tag_id <- tail(subfolder_parts, n = 1)
  
  # Get the list of CSV files in the subfolder
  csv_files <- fs::dir_ls(subfolder, regexp = "\\.csv$")
  
  # Loop through each CSV file
  for (csv_file in csv_files) {
    # Read the CSV file into a data frame
    data <- read.csv(csv_file)
    
    # Check if "Time" and "Temp" columns exist in the data
    if ("Time" %in% colnames(data) && "Temp" %in% colnames(data)) {
      # Clean the Time column
      data$Time <- gsub("[^0-9:.]", "", data$Time)  # Remove non-numeric and non-standard characters
      
      # Convert Time to a valid time format
      data$DateTime <- as.POSIXct(data$Time, format = "%H:%M:%OS", tz = "GMT")
      
      # Check for missing values in Temp
      missing_values <- is.na(data$Temp)
      if (any(missing_values)) {
        # Remove rows with missing Temp values
        data <- data[!missing_values, ]
      }
      
      # Check if there are more than one observation after cleaning
      if (nrow(data) > 1) {
        # Create the wave graph
        ggplot(data, aes(x = DateTime, y = Temp, group = 1)) +
          geom_path(color = "blue", size = 1) +
          geom_smooth(method = "lm", se = FALSE) +  # Add a trendline using linear regression
          labs(title = paste("Tag ID:", tag_id), x = "Time", y = "Temperature") +
          theme_minimal() +
          theme(plot.title = element_text(size = 16, face = "bold"),
                axis.title = element_text(size = 12),
                axis.text = element_text(size = 10))
        
        # Create the output file name by removing the folder path and extension
        file_name <- gsub(".*/", "", csv_file)
        file_name <- gsub("\\.csv$", "", file_name)
        
        # Create the output file path with the same name as the input file, but with a different extension
        output_file <- gsub("\\.csv$", ".png", csv_file)
        
        # Save the graph as a PNG file
        ggsave(output_file, width = 8, height = 6, dpi = 300)
      } 
      else 
        {
        print(paste("Only one valid observation found in", csv_file))
      }
    } 
    else 
      {
      print(paste("Required columns not found in", csv_file))
    }
  }
}

