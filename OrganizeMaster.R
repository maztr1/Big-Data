library(fs)

# Define the master folder path
master_folder <- "/Users/wilstermanlab/REU/MasterFolder"

# Get a list of all files in the master folder
files <- list.files(master_folder, full.names = TRUE)

# Loop through each file
for (file in files) {
  # Extract the tag ID from the file name
  tag_id <- tools::file_path_sans_ext(basename(file))

  # Create the tag ID folder if it doesn't exist
  tag_folder <- file.path(master_folder, tag_id)
  if (!dir.exists(tag_folder)) {
    dir.create(tag_folder)
  }

  # Move the file to the tag ID folder
  new_file <- file.path(tag_folder, basename(file))
  file.rename(file, new_file)
}

