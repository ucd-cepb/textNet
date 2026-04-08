
library(textNet)
library(testthat)

pdfs <- c(
  system.file("extdata", "old.pdf", package = "textNet"),
  system.file("extdata", "new.pdf", package = "textNet")
)

old_new_text <- textNet::pdf_clean(
  pdfs,
  ocr = FALSE,
  maxchar = 10000,
  export_paths = NULL,
  return_to_memory = TRUE,
  suppressWarn = FALSE,
  auto_headfoot_remove = TRUE
)
names(old_new_text) <- c("old", "new")

test_that("output has one element per input PDF", {
  expect_equal(length(old_new_text), length(pdfs))
})

test_that("output is a named list of character vectors", {
  expect_type(old_new_text, "list")
  expect_named(old_new_text, c("old", "new"))
  expect_true(all(sapply(old_new_text, is.character)))
})

test_that("each document has at least one page of text", {
  expect_true(all(sapply(old_new_text, function(x) length(x) > 0)))
})
