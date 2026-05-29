library(testthat)

# Helper: read a fixture text file (form-feed separated pages) and the
# matching ground-truth CSV. Returns a list(pages = chr, truth = data.frame).
.load_fixture <- function(stem) {
  txt_path <- testthat::test_path("testdata", "acronym_pages", paste0(stem, ".txt"))
  csv_path <- testthat::test_path("testdata", "acronym_pages", paste0(stem, "_truth.csv"))
  raw <- paste(readLines(txt_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  pages <- strsplit(raw, "\f", fixed = TRUE)[[1]]
  truth <- utils::read.csv(csv_path, stringsAsFactors = FALSE,
                           colClasses = "character", fileEncoding = "UTF-8")
  list(pages = pages, truth = truth)
}

# Compare function output to ground truth as character data.frames, sorted
# by acronym to make diffs readable when something drifts.
.expect_matches_truth <- function(stem) {
  fx <- .load_fixture(stem)
  res <- extract_front_matter_acronyms(fx$pages)
  # data.table -> data.frame for portable comparison
  got <- as.data.frame(res, stringsAsFactors = FALSE)
  got <- got[order(got$acronym), c("name", "acronym")]
  exp <- fx$truth[order(fx$truth$acronym), c("name", "acronym")]
  rownames(got) <- NULL; rownames(exp) <- NULL
  expect_equal(got, exp,
               info = paste0("fixture: ", stem,
                             " (got ", nrow(got), " rows, expected ",
                             nrow(exp), ")"))
}

fixtures <- c("example2", "example3", "example4", "example5",
              "example_acronyms_multi")

for (stem in fixtures) {
  local({
    s <- stem
    test_that(paste0("extract_front_matter_acronyms matches ground truth: ", s), {
      .expect_matches_truth(s)
    })
  })
}

test_that("extract_front_matter_acronyms returns empty data.table when no heading is present", {
  # Narrative text with no acronym section. Includes the word "acronyms"
  # mid-sentence to confirm narrative use does not trip heading detection.
  pages <- c(
    paste(
      "This document discusses groundwater sustainability planning.",
      "Several acronyms are used throughout, but they are defined inline.",
      "The agencies involved include DWR and SWRCB and the GSA framework.",
      sep = "\n"
    ),
    paste(
      "Page two has more narrative.",
      "There is no abbreviations table on this page either.",
      sep = "\n"
    )
  )
  res <- extract_front_matter_acronyms(pages)
  expect_s3_class(res, "data.table")
  expect_named(res, c("name", "acronym"))
  expect_equal(nrow(res), 0L)
})

test_that("extract_front_matter_acronyms validates inputs", {
  expect_error(extract_front_matter_acronyms(123),
               "must be a character vector")
  expect_error(extract_front_matter_acronyms("ok",
                                                     max_window_pages = 0),
               "positive integer")
  expect_error(extract_front_matter_acronyms("ok",
                                                     max_window_pages = c(1, 2)),
               "single positive integer")
})

test_that("extract_front_matter_acronyms returns identical-shape data.table to find_intext_acronyms", {
  fx <- .load_fixture("example3")
  res <- extract_front_matter_acronyms(fx$pages)
  expect_s3_class(res, "data.table")
  expect_named(res, c("name", "acronym"))
  expect_type(res$name, "character")
  expect_type(res$acronym, "character")
})
