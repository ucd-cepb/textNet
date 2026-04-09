#' Find a Python installation with spaCy and a spaCy model installed
#'
#' Searches conda environments and then PATH-accessible Python installations
#' for one that has spaCy and the specified model installed. Conda environments
#' are searched regardless of activation status.
#'
#' @param model Character string. The spaCy model to require (e.g. "en_core_web_lg").
#' @return A character string giving the path to a suitable Python executable.
#' @keywords internal

find_spacy_python <- function(model = "en_core_web_lg") {

  check_python <- function(path) {
    if (!nzchar(path) || !file.exists(path)) return(FALSE)
    script <- tempfile(fileext = ".py")
    on.exit(unlink(script))
    writeLines(c("import spacy", paste0('spacy.load("', model, '")')), script)
    exit_code <- tryCatch(
      system2(path, args = script, stdout = FALSE, stderr = FALSE),
      error = function(e) 1L
    )
    identical(exit_code, 0L)
  }

  candidates <- character(0)

  # Respect explicit user config first
  rp <- Sys.getenv("RETICULATE_PYTHON")
  if (nzchar(rp)) candidates <- c(candidates, rp)

  # Conda environments (found regardless of activation — the gap find_python_cmd can't cover)
  tryCatch({
    envs <- reticulate::conda_list()
    candidates <- c(candidates, envs$python)
  }, error = function(e) NULL)

  # PATH-based fallback (system python, activated envs)
  if (!requireNamespace("findpython", quietly = TRUE)) {
    warning("Package 'findpython' is not installed; skipping PATH-based Python search. ",
            "Install it with install.packages('findpython') for broader Python discovery.",
            call. = FALSE)
  } else {
    tryCatch({
      candidates <- c(candidates,
                      findpython::find_python_cmd(required_modules = c("spacy", model)))
    }, error = function(e) NULL)
  }

  for (path in unique(candidates)) {
    if (check_python(path)) return(path)
  }

  stop("Could not find Python with spaCy and '", model, "' installed. ",
       "Ensure your environment has both, or set RETICULATE_PYTHON in .Renviron.",
       call. = FALSE)
}
