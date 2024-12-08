# Function to install and snapshot packages using renv
install_and_snapshot <- function(packages) {
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message(sprintf("Installing package: %s", pkg))
      install.packages(pkg, repos = "https://cran.rstudio.com/")
    }
  }
  renv::snapshot()
}

# Define common packages for R projects
common_packages <- c(
  "tidyverse", "data.table", "lubridate", "ggplot2", "dplyr",
  "readr", "forcats", "scales", "stringr", "usethis",
  "renv", "rmarkdown", "knitr", "testthat", "cli", "dotenv"
)

# Install packages and snapshot environment
install_and_snapshot(common_packages)

# Display session information
sessionInfo()
