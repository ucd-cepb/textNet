#' @title Parsed versions of a groundwater plan
#' @description
#' Token-level linguistic annotations from two versions of a publicly available
#' groundwater plan.
#'
#' @details
#' The first element contains the earlier version of the plan and the second
#' contains the later version. Each element has the same structure as an object
#' returned by [parse_text()].
#'
#' @format A list of two objects of class \code{"spacyr_parsed"}. Each element is a
#'   data frame containing token-level annotations, including document and
#'   sentence identifiers, tokens, lemmas, part-of-speech tags, dependency
#'   relations, named entities, noun-phrase markers, and whitespace indicators.
#'
#' @examples
#' # number of parsed tokens in each plan version
#' vapply(old_new_parsed, nrow, integer(1))
#'
#' # inspect token, lemma, and part-of-speech annotations
#' head(old_new_parsed[[1]][, c("token", "lemma", "pos")])
#'
#' # most frequent part-of-speech tags
#' head(sort(table(old_new_parsed[[1]]$pos), decreasing = TRUE), 5)
"old_new_parsed"
