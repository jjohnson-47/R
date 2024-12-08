# config/R/linter_setup.R

library(lintr)
library(cli)

#' Lint a specific file or directory with project settings
#' @param path Path to file or directory to lint
#' @param ... Additional arguments passed to lint()
#' @return lint results
lint_project <- function(path = ".", ...) {
  cli::cli_alert_info("Linting: {path}")
  lint(path, linters = linters, ...)
}

#' Check function documentation completeness
#' @param source_file Source file to check
#' @return lint results for documentation issues
check_function_docs <- function(source_file) {
  # Get all function definitions
  funs <- parse(text = source_file$content)
  funs <- funs[sapply(funs, is.call)]

  # Check for roxygen documentation
  issues <- list()
  for (fun in funs) {
    if (fun[[1]] == "function") {
      # Check if previous line contains roxygen comments
      fun_line <- attr(fun, "srcref")[1]
      if (fun_line > 1) {
        prev_lines <- source_file$content[(fun_line - 3):fun_line]
        if (!any(grepl("^#'", prev_lines))) {
          issues[[length(issues) + 1]] <- Lint(
            filename = source_file$filename,
            line_number = fun_line,
            column_number = 1,
            type = "style",
            message = "Missing roxygen documentation for function",
            line = source_file$content[fun_line]
          )
        }
      }
    }
  }
  return(issues)
}

#' Run linting on entire project with exclusions
#' @param base_dir Base directory to lint
#' @return Combined lint results
lint_entire_project <- function(base_dir = ".") {
  cli::cli_h1("Running project-wide linting")

  # Define exclusion patterns
  exclude_patterns <- c(
    "renv/.*",
    "data/.*",
    "output/.*",
    ".*\\.(Rmd|qmd)$",
    ".*\\.(rds|csv|feather)$"
  )

  # Get all R files
  r_files <- list.files(
    path = base_dir,
    pattern = "\\.[Rr]$",
    recursive = TRUE,
    full.names = TRUE
  )

  # Filter out excluded files
  r_files <- r_files[!grepl(paste(exclude_patterns, collapse = "|"), r_files)]

  # Lint each file
  results <- lapply(r_files, function(file) {
    cli::cli_alert_info("Linting {file}")
    lint(file, linters = linters)
  })

  # Combine results
  do.call(c, results)
}

#' Generate lint report
#' @param lint_results Results from lint() or lint_entire_project()
#' @param output_file Path to save report (optional)
#' @return Invisibly returns the report data
generate_lint_report <- function(lint_results, output_file = NULL) {
  if (length(lint_results) == 0) {
    cli::cli_alert_success("No linting issues found!")
    return(invisible(NULL))
  }

  # Summarize results
  issues_by_type <- table(sapply(lint_results, `[[`, "type"))
  files_with_issues <- unique(sapply(lint_results, `[[`, "filename"))

  # Create report
  report <- c(
    "# Lint Report",
    "",
    "## Summary",
    paste("* Total issues:", length(lint_results)),
    paste("* Files with issues:", length(files_with_issues)),
    "",
    "## Issues by Type",
    paste("*", names(issues_by_type), ":", issues_by_type),
    "",
    "## Details"
  )

  # Add detailed findings
  for (issue in lint_results) {
    report <- c(report, sprintf(
      "* %s:%d:%d: %s",
      basename(issue$filename),
      issue$line_number,
      issue$column_number,
      issue$message
    ))
  }

  # Write report if requested
  if (!is.null(output_file)) {
    writeLines(report, output_file)
    cli::cli_alert_success("Lint report saved to: {output_file}")
  }

  # Print to console
  cat(paste(report, collapse = "\n"))
  invisible(report)
}
