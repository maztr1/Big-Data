library(dplyr)
library(fs)

# Define the main folder path
main_folder <- "/Users/wilstermanlab/REU/Organized"
# Define the master folder path
master_folder <- "/Users/wilstermanlab/REU/MasterFolder"

# Get a list of all subfolders (organized by tag ID)
subfolders <- fs::dir_ls(main_folder, type = "dir", recurse = FALSE)

# Loop through each subfolder
for (subfolder in subfolders) {
  # Extract the tag ID from the subfolder path
  subfolder_parts <- strsplit(as.character(subfolder), split = "/")[[1]]
  tag_id <- tail(subfolder_parts, n = 1)
  
  # Create the subfolder path within the master folder
  tag_folder <- file.path(master_folder, tag_id)
  
  # Create the subfolder if it doesn't exist
  dir.create(tag_folder, recursive = TRUE, showWarnings = FALSE)
  
  # Get the list of CSV files in the subfolder
  csv_files <- fs::dir_ls(subfolder, regexp = "\\.csv$")
  
  # Loop through each CSV file
  for (csv_file in csv_files) {
    # Read the CSV file into a data frame
    data <- read.csv(csv_file)
    
    # Filter out all columns except "Time" and "Temp"
    filtered_data <- data %>%
      select(Time, Temp)
    
    # Create the output file name by removing the folder path and extension
    file_name <- gsub(".*/", "", csv_file)
    file_name <- gsub("\\.csv$", "", file_name)
    file_name <- paste0(file_name, "_filtered")
    
    # Create the output file path within the tag subfolder
    output_file <- file.path(tag_folder, paste0(file_name, ".csv"))
    
    # Write the filtered data to the output file
    write.csv(filtered_data, file = output_file, row.names = FALSE)
  }
}
