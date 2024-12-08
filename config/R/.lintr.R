# config/R/.lintr.R

# Define custom linting functions
exclusions <- list(
  "renv/.*",
  "data/.*",
  "output/.*",
  "notebooks/.*\\.Rmd$",
  "notebooks/.*\\.qmd$"
)

# Define project-specific linting configuration
linters <- linters_with_defaults(
  # Code style
  line_length_linter(80),
  object_name_linter(styles = c("snake_case", "SNAKE_CASE")),
  assignment_linter(),

  # Code complexity
  cyclocomp_linter(complexity_limit = 15),
  object_length_linter(length = 50), # Replace `function_length_linter`

  # Best practices
  absolute_path_linter(),
  pipe_continuation_linter(),
  quotes_linter(),

  # Documentation
  function_left_parentheses_linter(),
  spaces_left_parentheses_linter(),

  # Spacing and formatting
  commas_linter(),
  infix_spaces_linter(),
  spaces_inside_linter(),
  trailing_whitespace_linter(),

  # Disabled linters
  object_usage_linter = NULL, # Handled by Language Server
  commented_code_linter = NULL # Allow commented code in development
)

# Export linters configuration
linters
