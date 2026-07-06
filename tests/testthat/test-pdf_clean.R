
library(textNet)
library(testthat)

pdfs <- c(
  system.file("extdata", "example_plan_v1.pdf", package = "textNet"),
  system.file("extdata", "example_plan_v2.pdf", package = "textNet")
)

plan_texts <- textNet::pdf_clean(
  pdfs,
  ocr = FALSE,
  maxchar = 10000,
  export_paths = NULL,
  return_to_memory = TRUE,
  suppressWarn = FALSE,
  auto_headfoot_remove = TRUE
)
names(plan_texts) <- c("v1", "v2")

test_that("output has one element per input PDF", {
  expect_equal(length(plan_texts), length(pdfs))
})

test_that("output is a named list of character vectors", {
  expect_type(plan_texts, "list")
  expect_named(plan_texts, c("v1", "v2"))
  expect_true(all(sapply(plan_texts, is.character)))
})

test_that("each document has at least one page of text", {
  expect_true(all(sapply(plan_texts, function(x) length(x) > 0)))
})
