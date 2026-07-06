#' @title Parsed sample from a groundwater plan corpus
#' @description
#' Token-level linguistic annotations for 20 pages drawn from a collection
#' of publicly available groundwater sustainability plans.
#'
#' @details
#' Parsed with spaCy's \code{en_core_web_lg} model. The data format matches
#' the output of [parse_text()].
#'
#' @format An object of class \code{"spacyr_parsed"}: a data frame containing
#'   token-level annotations, including document and sentence identifiers,
#'   tokens, lemmas, part-of-speech tags, dependency relations, and named
#'   entity labels.
#'
#' @examples
#' # number of tokens
#' nrow(sample_20p)
#'
#' # inspect token, lemma, and part-of-speech annotations
#' head(sample_20p[, c("token", "lemma", "pos")])
#'
#' # most frequent named entity types
#' head(sort(table(sample_20p$entity_type), decreasing = TRUE), 5)
"sample_20p"
