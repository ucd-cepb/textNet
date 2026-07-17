
library(textNet)
library(testthat)
library(stringr)

# Use bundled parsed and cleaned text data; no spaCy needed

# water_bodies and ent_types come from helper-fixtures.R

extracts <- lapply(
  list(textNet::example_plan_v1_parsed, textNet::example_plan_v2_parsed),
  function(parsed) {
    textnet_extract(parsed, cl = 2,
                    keep_entities = ent_types,
                    keep_incomplete_edges = TRUE)
  }
)

# Build acronym mappings from the cleaned text, then disambiguate
build_tofrom <- function(acronyms) {
  data.table::data.table(
    from = c(
      as.list(acronyms$acronym),
      list("Sub_basin", "Sub_Basin",
           "upper_and_lower_aquifers", "Upper_and_lower_aquifers",
           "Lower_and_upper_aquifers", "lower_and_upper_aquifers")
    ),
    to = c(
      as.list(acronyms$name),
      list("Subbasin", "Subbasin",
           c("upper_aquifer", "lower_aquifer"),
           c("upper_aquifer", "lower_aquifer"),
           c("upper_aquifer", "lower_aquifer"),
           c("upper_aquifer", "lower_aquifer"))
    )
  )
}

old_acronyms      <- find_acronyms(textNet::example_plan_v1_text)
new_acronyms      <- find_acronyms(textNet::example_plan_v2_text)
old_tofrom        <- build_tofrom(old_acronyms)
new_tofrom        <- build_tofrom(new_acronyms)

old_extract_clean <- disambiguate(
  textnet_extract      = extracts[[1]],
  from                 = old_tofrom$from,
  to                   = old_tofrom$to,
  match_partial_entity = c(rep(FALSE, nrow(old_acronyms)), TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)
)

new_extract_clean <- disambiguate(
  textnet_extract      = extracts[[2]],
  from                 = new_tofrom$from,
  to                   = new_tofrom$to,
  match_partial_entity = c(rep(FALSE, nrow(new_acronyms)), TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)
)

test_that("disambiguate does not change the structure of old extract", {
  expect_equal(length(old_extract_clean), length(extracts[[1]]))
})

test_that("disambiguate does not change the structure of new extract", {
  expect_equal(length(new_extract_clean), length(extracts[[2]]))
})

test_that("no acronyms remain in old node list after disambiguation", {
  acronym_pattern <- paste0("^", paste0(old_acronyms$acronym, collapse = "$|^"), "$")
  expect_false(any(str_detect(old_extract_clean$nodelist$entity_name, acronym_pattern)))
})

test_that("no acronyms remain in new node list after disambiguation", {
  acronym_pattern <- paste0("^", paste0(new_acronyms$acronym, collapse = "$|^"), "$")
  expect_false(any(str_detect(new_extract_clean$nodelist$entity_name, acronym_pattern)))
})
