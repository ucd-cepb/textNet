test_that("find_intext_acronyms detects parenthetical definitions", {
  text <- c(
    "The Department of Water Resources (DWR) coordinates with the State",
    "Water Resources Control Board (SWRCB) on groundwater policy."
  )
  res <- find_intext_acronyms(text)
  expect_s3_class(res, "data.table")
  expect_named(res, c("name", "acronym"))
  expect_equal(res[acronym == "DWR", name], "Department_of_Water_Resources")
  expect_error(find_intext_acronyms(1), "must be a character vector")

  none <- find_intext_acronyms("No parentheses here.")
  expect_equal(nrow(none), 0)
  expect_named(none, c("name", "acronym"))
})

test_that("find_acronyms is deprecated but matches find_intext_acronyms", {
  expect_warning(old <- find_acronyms(textNet::example_plan_v1_text),
                 "deprecated")
  expect_identical(old, find_intext_acronyms(textNet::example_plan_v1_text))
})

test_that("find_acronyms still reads two-column acronym tables", {
  table_text <- paste(
    "Department of Water Resources   DWR",
    "GSA          Groundwater Sustainability Agency",
    "X            Not An Acronym",
    sep = "\n"
  )
  res <- suppressWarnings(
    find_acronyms("The Department of Water Resources (DWR) is here.",
                  table_text = table_text)
  )
  expect_setequal(res$acronym, c("DWR", "GSA"))
  expect_equal(res[acronym == "GSA", name], "Groundwater_Sustainability_Agency")
  expect_error(suppressWarnings(find_acronyms("x", table_text = 1)),
               "must be a character vector")
})
