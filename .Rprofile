# Install required packages if not already installed
required_packages <- c("shiny", "leaflet", "googlesheets4", "dplyr", "DT", "tidygeocoder")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}


