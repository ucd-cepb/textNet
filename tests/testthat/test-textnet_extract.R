
library(textNet)
library(testthat)
library(stringr)

# Use the bundled parsed data (equivalent to parse_text() output on the
# extdata PDFs; avoids spaCy dependency in tests)

# water_bodies and ent_types come from helper-fixtures.R

parsed_versions <- list(
  v1 = textNet::example_plan_v1_parsed,
  v2 = textNet::example_plan_v2_parsed
)

extracts <- lapply(parsed_versions, function(parsed) {
  textnet_extract(parsed, cl = 2,
                  keep_entities = ent_types,
                  keep_incomplete_edges = TRUE)
})

# For each document, all node entities should be recoverable from the
# raw parsed token stream. (Appositives may cause a node entity to be a
# substring of the original, so we use regex substring matching.)
for (doc_label in names(parsed_versions)) {

  onp <- parsed_versions[[doc_label]] |>
    dplyr::mutate(entitynum = cumsum(str_detect(entity, "_B")))
  onp$entitynum <- ifelse(onp$entity == "", NA, onp$entitynum)
  onp <- onp |>
    dplyr::group_by(entitynum) |>
    dplyr::mutate(entityconcat = paste(token, collapse = "_"))
  onp$entityconcat <- ifelse(
    str_detect(onp$entity, paste0(ent_types, "_B", sep = "", collapse = "|")),
    onp$entityconcat,
    NA
  )

  remove_nums <- !any(c("DATE", "CARDINAL", "QUANTITY", "TIME", "MONEY", "PERCENT") %in% ent_types)

  allentities <- unique(sort(clean_entities(
    onp$entityconcat[!is.na(onp$entityconcat)],
    remove_nums
  )))

  nodentities <- unique(sort(extracts[[doc_label]]$nodelist$entity_name)) |>
    str_replace_all("_", "_.*_*")

  test_that(paste("all node entities found in parsed token stream:", doc_label), {
    expect_true(
      all(vapply(nodentities, function(j) {
        any(str_detect(string = allentities, pattern = j))
      }, logical(1)))
    )
  })
}
