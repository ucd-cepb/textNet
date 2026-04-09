### package level settings ###
.datatable.aware <- TRUE

# Suppress R CMD check NOTEs for NSE column references (dplyr, data.table, etc.)
utils::globalVariables(c(
  ".", "..attr", "N", "acronym", "dep_rel", "doc_id",
  "doc_sent", "doc_sent_head_tok", "doc_sent_parent", "doc_sent_verb",
  "edgeiscomplete", "entity_id", "entity_name", "entity_type",
  "has_sources", "hascompleteedge", "head", "head_token_id",
  "head_verb_id", "head_verb_lemma", "head_verb_name", "head_verb_tense",
  "helper_lemma", "helper_token", "keep", "lemma", "name", "neg",
  "num_appearances", "num_graphs_in", "num_mentions", "parent_verb_id",
  "pos", "row_id", "sentence_id", "source_or_target", "tag",
  "token", "token_id", "xcomp_helper_lemma",
  "xcomp_helper_token", "xcomp_verb"
))