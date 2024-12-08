# Function to initialize paths
initialize_paths <- function(base_dir, project_name) {
  project_dir <- file.path(base_dir, project_name)

  paths <- list(
    base = project_dir,
    config = file.path(project_dir, "config"),
    data = file.path(project_dir, "data"),
    notebooks = file.path(project_dir, "notebooks"),
    output = file.path(project_dir, "output"),
    R = file.path(project_dir, "R"),
    tests = file.path(project_dir, "tests"),
    lintr_config = file.path(project_dir, "config", "R", ".lintr.R")
  )

  return(paths)
}

# Main setup function
setup_project <- function(project_name, base_dir = "projects") {
  # Store original directory
  original_dir <- getwd()

  # Normalize base directory path
  base_dir <- normalizePath(base_dir, mustWork = FALSE)

  # Initialize paths for the new project
  paths <- initialize_paths(base_dir, project_name)

  # Create all directories in paths
  cli::cli_h1("Creating base project structure")
  for (dir in paths) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(dir, ".gitkeep"))
  }

  # Add custom .gitignore rules
  cli::cli_h1("Adding .gitignore rules")
  gitignore_rules <- c(
    # R specific
    ".Rproj.user",
    ".Rhistory",
    ".RData",
    ".Ruserdata",
    "*.Rproj",
    "*.Rapp.history",

    # Data and outputs
    "data/*",
    "!data/.gitkeep",
    "output/*",
    "!output/.gitkeep",

    # System files
    ".DS_Store",
    "Thumbs.db",

    # Temporary files
    "*.swp",
    "*~",
    "*.tmp",
    "*.bak"
  )
  writeLines(gitignore_rules, file.path(paths$base, ".gitignore"))

  # Create .Rprofile for project
  rprofile_content <- c(
    "# Use shared renv library",
    'if (file.exists("../renv")) {',
    '  source("../renv/activate.R")',
    "}",
    "",
    "# Set project-specific options",
    'options(repos = c(CRAN = "https://cloud.r-project.org"))',
    'options(prompt = paste0("[", basename(getwd()), "] > "))'
  )
  writeLines(rprofile_content, file.path(paths$base, ".Rprofile"))

  # Add README with updated workflow information
  readme_lines <- c(
    paste("#", project_name),
    "",
    "## Overview",
    "[Project description]",
    "",
    "## Setup and Workflow",
    paste(
      "This project uses a shared renv environment located in the parent",
      "directory."
    ),
    "",
    "### Starting a New Session",
    "1. Open VSCode in this project directory:",
    "   ```bash",
    sprintf("   code %s", paths$base),
    "   ```",
    "2. Start R in the terminal - working directory will be automatically set",
    "3. The .Rprofile will activate the shared renv environment",
    "",
    "## Project Structure",
    sprintf("- `data/`: Data files (%s)", paths$data),
    sprintf("- `R/`: R scripts and functions (%s)", paths$R),
    sprintf("- `notebooks/`: Analysis notebooks (%s)", paths$notebooks),
    sprintf("- `output/`: Generated outputs (%s)", paths$output),
    sprintf("- `tests/`: Unit tests (%s)", paths$tests),
    sprintf("- `config/`: Configuration files (%s)", paths$config),
    "",
    "## Contact",
    "[Maintainer information]"
  )
  writeLines(readme_lines, file.path(paths$base, "README.md"))

  # Return to original directory
  setwd(original_dir)

  # Success messages
  cli::cli_alert_success("Project setup complete at: ", paths$base)
  cli::cli_alert_info("Next steps:")
  cli::cli_ul(
    c(
      paste0("Open the project in VSCode: code ", paths$base),
      "Start R in the terminal",
      "Verify shared renv activation"
    )
  )

  # Return paths invisibly for potential further use
  invisible(paths)
}
