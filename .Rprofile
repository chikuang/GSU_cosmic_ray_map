# Install required packages if not already installed (only in interactive sessions)
# This won't run on shinyapps.io
if (interactive()) {
  required_packages <- c("shiny", "leaflet", "dplyr", "DT", "readr")
  
  for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
    }
  }
}

