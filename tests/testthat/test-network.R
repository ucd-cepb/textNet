
library(textNet)
library(testthat)
library(stringr)

# Use bundled data; no spaCy needed
old_new_parsed <- textNet::old_new_parsed
old_new_text   <- textNet::old_new_text

# water_bodies and ent_types come from helper-fixtures.R

# --- Setup: extraction + disambiguation (mirrors test-disambiguate.R setup) ---

extracts <- lapply(old_new_parsed, function(parsed) {
  textnet_extract(parsed, cl = 2,
                  keep_entities = ent_types,
                  keep_incomplete_edges = TRUE)
})

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

old_acronyms      <- find_acronyms(old_new_text[[1]])
new_acronyms      <- find_acronyms(old_new_text[[2]])

old_extract_clean <- disambiguate(
  textnet_extract      = extracts[[1]],
  from                 = build_tofrom(old_acronyms)$from,
  to                   = build_tofrom(old_acronyms)$to,
  match_partial_entity = c(rep(FALSE, nrow(old_acronyms)), TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)
)

new_extract_clean <- disambiguate(
  textnet_extract      = extracts[[2]],
  from                 = build_tofrom(new_acronyms)$from,
  to                   = build_tofrom(new_acronyms)$to,
  match_partial_entity = c(rep(FALSE, nrow(new_acronyms)), TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)
)

set.seed(50000)
old_extract_net <- export_to_network(old_extract_clean, "igraph",
                                     keep_isolates = FALSE,
                                     collapse_edges = FALSE,
                                     self_loops = TRUE)
set.seed(50000)
new_extract_net <- export_to_network(new_extract_clean, "igraph",
                                     keep_isolates = FALSE,
                                     collapse_edges = FALSE,
                                     self_loops = TRUE)

composite_net <- combine_networks(
  list(old_extract_net[[1]], new_extract_net[[1]]),
  mode = "weighted"
)

# --- export_to_network: return structure ---

test_that("export_to_network returns a 2-element list for old network", {
  expect_type(old_extract_net, "list")
  expect_length(old_extract_net, 2)
})

test_that("old network first element is an igraph", {
  expect_true(igraph::is_igraph(old_extract_net[[1]]))
})

test_that("new network first element is an igraph", {
  expect_true(igraph::is_igraph(new_extract_net[[1]]))
})

test_that("network stats table has expected columns", {
  expected_cols <- c("num_nodes", "num_edges", "connectedness",
                     "centralization", "transitivity",
                     "pct_entitytype_homophily", "reciprocity",
                     "mean_in_degree", "mean_out_degree",
                     "median_in_degree", "median_out_degree")
  expect_true(all(expected_cols %in% names(old_extract_net[[2]])))
})

# --- export_to_network: network content ---

test_that("old network has nodes and edges", {
  expect_gt(igraph::vcount(old_extract_net[[1]]), 0)
  expect_gt(igraph::ecount(old_extract_net[[1]]), 0)
})

test_that("new network has nodes and edges", {
  expect_gt(igraph::vcount(new_extract_net[[1]]), 0)
  expect_gt(igraph::ecount(new_extract_net[[1]]), 0)
})

test_that("network nodes have entity_type attribute", {
  expect_true("entity_type" %in% igraph::vertex_attr_names(old_extract_net[[1]]))
  expect_true("entity_type" %in% igraph::vertex_attr_names(new_extract_net[[1]]))
})

test_that("network edges have head_verb_lemma and head_verb_tense attributes", {
  edge_attrs <- igraph::edge_attr_names(old_extract_net[[1]])
  expect_true("head_verb_lemma" %in% edge_attrs)
  expect_true("head_verb_tense" %in% edge_attrs)
})

test_that("entity_type values are drawn from expected set", {
  valid_types <- c("ORG", "GPE", "PERSON", "WATER")
  old_types <- unique(igraph::vertex_attr(old_extract_net[[1]], "entity_type"))
  new_types <- unique(igraph::vertex_attr(new_extract_net[[1]], "entity_type"))
  expect_true(all(old_types %in% valid_types))
  expect_true(all(new_types %in% valid_types))
})

# --- top_features ---

top_feats <- top_features(list(old_extract_net[[1]], new_extract_net[[1]]))

test_that("top_features returns named list with entities and lemmas", {
  expect_type(top_feats, "list")
  expect_named(top_feats, c("entities", "lemmas"))
})

test_that("top_features entities has expected columns and is non-empty", {
  expect_true(all(c("names", "avg_fract_of_a_doc") %in% names(top_feats$entities)))
  expect_gt(nrow(top_feats$entities), 0)
})

test_that("top_features lemmas has expected columns and is non-empty", {
  expect_true(all(c("names", "avg_fract_of_a_doc") %in% names(top_feats$lemmas)))
  expect_gt(nrow(top_feats$lemmas), 0)
})

test_that("top_features entity fractions are between 0 and 1", {
  expect_true(all(top_feats$entities$avg_fract_of_a_doc >= 0))
  expect_true(all(top_feats$entities$avg_fract_of_a_doc <= 1))
})

# --- combine_networks ---

test_that("composite network is an igraph", {
  expect_true(igraph::is_igraph(composite_net))
})

test_that("composite network nodes are a subset of the union of source node lists", {
  all_source_nodes <- c(
    old_extract_clean$nodelist$entity_name,
    new_extract_clean$nodelist$entity_name
  )
  expect_true(
    all(igraph::vertex_attr(composite_net, "name") %in% all_source_nodes)
  )
})

test_that("composite network num_graphs_in attribute is 1 or 2", {
  n_in <- igraph::vertex_attr(composite_net, "num_graphs_in")
  expect_true(all(n_in %in% c(1, 2)))
})
