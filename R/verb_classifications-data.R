#' @title VerbNet 3.3 verb classifications
#' @description
#' Verb class and type assignments from VerbNet 3.3, used to annotate the
#' verblist returned by [textnet_extract()].
#'
#' @details
#' Each row corresponds to a verb lemma and its associated VerbNet class and
#' type. These attributes are joined to the verblist by \code{head_verb_lemma}.
#' The data were processed from the VerbNet 3.3 source files using
#' \code{data-raw/verbnet_port.R}.
#'
#' @format A \code{data.table} with columns:
#' \describe{
#'   \item{head_verb_lemma}{Base form of the verb.}
#'   \item{classes}{VerbNet 3.3 class membership string.}
#'   \item{type_name}{VerbNet 3.3 type label.}
#'   \item{type_id}{Integer identifier for \code{type_name}.}
#' }
#'
#' @references
#' Schuler, Karin Kipper (2005). \emph{VerbNet: A Broad-Coverage, Comprehensive
#' Verb Lexicon}. University of Pennsylvania.
#'
#' @source \href{https://verbs.colorado.edu/verb-index/vn3.3/}{VerbNet 3.3}
#'
#' @examples
#' # number of verb entries
#' nrow(verb_classifications)
#'
#' # VerbNet types present in the data
#' unique(verb_classifications$type_name)
"verb_classifications"
