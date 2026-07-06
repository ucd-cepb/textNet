#' @title Parsed token data from version 1 of a groundwater plan
#' @description
#' Token-level linguistic annotations from the earlier version of a publicly
#' available groundwater plan. This is version 1; see [example_plan_v2_parsed]
#' for the later version.
#'
#' @details
#' The object has the same structure as the output of [parse_text()], which is
#' a thin wrapper around \code{spacyr::spacy_parse()}.
#'
#' @format A data frame of class \code{"spacyr_parsed"} containing token-level
#'   annotations with the following columns:
#'   \describe{
#'     \item{doc_id}{Unique identifier for each page.}
#'     \item{sentence_id}{Unique identifier for each sentence within a page.}
#'     \item{token_id}{Unique identifier for each token within a sentence.}
#'     \item{token}{The token string.}
#'     \item{lemma}{The canonical (dictionary) form of the token.}
#'     \item{pos}{Universal Dependencies part-of-speech tag.}
#'     \item{tag}{Penn Treebank part-of-speech tag.}
#'     \item{head_token_id}{Numeric token ID of the syntactic head of this token.}
#'     \item{dep_rel}{Dependency relation to the head token.}
#'     \item{entity}{Named-entity tag (IOB format).}
#'     \item{nounphrase}{Character; noun-phrase boundary marker (\code{"beg"}, \code{"mid"}, \code{"end"}, or \code{""}).}
#'     \item{whitespace}{Logical; whether a space follows the token.}
#'   }
#'
#' @examples
#' # number of parsed tokens
#' nrow(example_plan_v1_parsed)
#'
#' # inspect token, lemma, and part-of-speech annotations
#' head(example_plan_v1_parsed[, c("token", "lemma", "pos")])
#'
#' # most frequent part-of-speech tags
#' head(sort(table(example_plan_v1_parsed$pos), decreasing = TRUE), 5)
"example_plan_v1_parsed"
