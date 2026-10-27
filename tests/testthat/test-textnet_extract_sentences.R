library(testthat)

# These tests run real spaCy parses, so they need Python with spaCy and
# en_core_web_lg. Skip on CRAN and wherever that environment is missing.
skip_on_cran()
skip_if_not_installed("reticulate")
skip_if_not_installed("spacyr")
python_path <- tryCatch(textNet:::find_spacy_python(), error = function(e) NULL)
if (is.null(python_path)) skip("no Python with spaCy and en_core_web_lg found")
Sys.setenv(RETICULATE_PYTHON = python_path)

protocol <- read.table(
  testthat::test_path("testdata", "sentences_that_work.txt"),
  sep = "\t", header = TRUE, quote = '"', stringsAsFactors = FALSE
)

# Parse custom_entities column into R character vectors
get_custom <- function(arg_str) {
  if (is.na(arg_str) || !grepl("custom_entities", arg_str)) return(NULL)
  m <- regmatches(arg_str, gregexpr('"[^"]+"', arg_str))[[1]]
  gsub('"', "", m)
}

for (i in seq_len(nrow(protocol))) {
  local({
    row <- protocol[i, ]
    idx <- i
    test_that(paste0("[", idx, "] ", row$Test.Purpose), {
      ce     <- get_custom(row$textNet..parse_text.Arguments)
      remove_neg <- !grepl("remove_neg\\s*=\\s*FALSE",
                           row$textNet..textnet_extract.Arguments)
      result <- run_sentence(row$Sentence, custom_entities = ce,
                             remove_neg = remove_neg)

      expected_edges <- parse_expected_output(row$Expected.Output)
      for (e in expected_edges) {
        expect_true(
          has_edge(result$edgelist, e$source, e$verb, e$target),
          label = paste0("edge not found: ", e$source,
                         " -", e$verb, "-> ", e$target)
        )
      }
    })
  })
}
