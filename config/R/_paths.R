# Define the base directory of the project
base_dir <- tryCatch(
  normalizePath(
    dirname(rstudioapi::getActiveDocumentContext()$path),
    winslash = "/"
  ),
  error = function(e) {
    normalizePath(getwd(), winslash = "/")
  }
)

# Define common paths relative to the base directory
paths <- list(
  base = base_dir,
  config = file.path(base_dir, "config"),
  template = file.path(base_dir, "template"),
  projects = file.path(base_dir, "projects"),
  vscode = file.path(base_dir, ".vscode"),
  data = file.path(
    base_dir,
    "template",
    "data"
  ),
  notebooks = file.path(
    base_dir,
    "template",
    "notebooks"
  ),
  output = file.path(
    base_dir,
    "template",
    "output"
  ),
  scripts = file.path(
    base_dir,
    "template",
    "R"
  ),
  tests = file.path(
    base_dir,
    "template",
    "tests"
  ),
  lintr_config = file.path(
    base_dir,
    "config",
    "R",
    ".lintr.R" # Correct assignment
  )
)

# Export paths for convenience
assign("paths", paths, envir = .GlobalEnv)
