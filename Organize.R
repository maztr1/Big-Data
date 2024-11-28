install.packages("data.table")
install.packages("dplyr")
install.packages("fs")

library(data.table)
library(dplyr)
library(fs)

# Define the function to clean up the data
cleanup_data <- function(data) {
  # Rename the columns if needed
  colnames(data) <- c("Date", "Time", "Tag ID", "Temp")
  
  # Handle missing values
  data <- na.omit(data)
  
  # Convert the necessary columns to their appropriate data types
  data$Date <- as.Date(data$Date, format = "%m/%d/%Y")
  data$Time <- as.character(data$Time)
  data$Temp <- as.numeric(data$Temp)
  
  # Filter the data to remove outliers using quartiles and IQR
  quartiles_temp <- quantile(data$Temp, probs = c(0.25, 0.75), na.rm = TRUE)
  IQR_temp <- IQR(data$Temp, na.rm = TRUE)
  Lower_temp <- quartiles_temp[1] - 2 * IQR_temp
  Upper_temp <- quartiles_temp[2] + 2 * IQR_temp
  
  data <- data[Temp > Lower_temp & Temp < Upper_temp]
  
  return(data)
}

# Define the input and output directories
input_directory <- "/Users/wilstermanlab/REU/Data"
output_directory <- "/Users/wilstermanlab/REU/Organized"

# Get the list of CSV file names in the input directory
csv_files <- list.files(input_directory, pattern = "\\.csv$", full.names = TRUE)

# Create an empty data.table
combined_data <- data.table()

# Loop over the CSV files
for (csv_file in csv_files) {
  message("Processing file:", csv_file)
  
  # Read each CSV file into a data.table using fread
  data <- fread(csv_file, fill = TRUE)
  
  # Run the cleanup script (assuming cleanup_data is a function you defined)
  cleaned_data <- cleanup_data(data)
  
  # Check if the number of columns is consistent
  if (ncol(cleaned_data) == 4) {
    # Assign appropriate column names
    setnames(cleaned_data, c("Date", "Time", "TagID", "Temp"))
    
    # Sort the cleaned data by TagID
    cleaned_data <- cleaned_data[order(TagID)]
    
    # Append the cleaned data to the combined data.table
    combined_data <- rbind(combined_data, cleaned_data)
    message("Processed file:", csv_file)
  } else {
    message("Invalid number of columns in", csv_file)
  }
}

# Loop over unique Tag IDs
for (tag_id in unique(combined_data$TagID)) {
  # Subset the combined data for the current Tag ID
  tag_data <- combined_data[TagID == tag_id]
  
  # Create the directory path for the Tag ID
  directory <- file.path(output_directory, paste0("TagID_", tag_id))
  
  # Create the directory if it doesn't exist
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  
  # Generate the file path for the CSV file
  file_path <- file.path(directory, paste0("TagID_", tag_id, ".csv"))
  
  # Save the data to the CSV file using fwrite from data.table
  fwrite(tag_data, file_path)
  
  # Check if the file was created
  if (file.exists(file_path)) {
    message("File", file_path, "created successfully.")
  } else {
    message("Failed to create file", file_path)
  }
}

message("Data processing and organization completed.")
