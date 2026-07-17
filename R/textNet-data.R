## Package datasets
## Documentation for all data objects shipped with textNet.

# ---- Reference data --------------------------------------------------------

#' @title English word list from SCOWL
#' @description
#' A character vector of English words drawn from the SCOWL 2020.12.07
#' word list compiled by Kevin Atkinson.
#'
#' @details
#' Includes words from files with extension \eqn{\leq} 60 whose filenames
#' contain \code{"variant"}, \code{"american"}, \code{"british"},
#' \code{"canadian"}, or \code{"australian"}. Used by [filter_sentences()] to
#' remove non-English sentences from parsed text.
#'
#' @format A character vector of English words.
#'
#' @references
#' Kevin Atkinson (2020). SCOWL (Spell Checker Oriented Word Lists).
#'
#' @source \href{https://sourceforge.net/projects/wordlist/files/SCOWL/2020.12.07/scowl-2020.12.07.zip/download}{SCOWL 2020.12.07}
#'
#' @examples
#' # number of words in the list
#' length(eng_words)
#'
#' # check whether a word is present
#' "governance" %in% eng_words
"eng_words"

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
#' unique(unlist(verb_classifications$type_name))
"verb_classifications"

# ---- Example corpus --------------------------------------------------------

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
#' # most frequent dependency relationship tags by token 
#' head(sort(table(sample_20p$dep_rel), decreasing = TRUE), 5)
"sample_20p"

#' @title Raw text from version 1 of a groundwater plan
#' @description
#' Page-level text extracted from the earlier version of a publicly available
#' groundwater plan. This is version 1; see [example_plan_v2_text] for the
#' later version.
#'
#' @details
#' Each element of the character vector contains the extracted text of a single
#' PDF page. The data format matches the output of [pdf_clean()].
#'
#' @format A character vector in which each element contains the extracted text
#'   of a single PDF page.
#'
#' @examples
#' # number of pages
#' length(example_plan_v1_text)
#'
#' # preview the first page
#' substr(example_plan_v1_text[1], 1, 200)
#'
#' # find acronyms defined in the text
#' acronyms_v1 <- find_acronyms(example_plan_v1_text)
#' head(acronyms_v1)
"example_plan_v1_text"

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

#' @title Raw text from version 2 of a groundwater plan
#' @description
#' Page-level text extracted from the later version of a publicly available
#' groundwater plan. This is version 2; see [example_plan_v1_text] for the
#' earlier version.
#'
#' @details
#' Each element of the character vector contains the extracted text of a single
#' PDF page. The data format matches the output of [pdf_clean()].
#'
#' @format A character vector in which each element contains the extracted text
#'   of a single PDF page.
#'
#' @examples
#' # number of pages
#' length(example_plan_v2_text)
#'
#' # preview the first page
#' substr(example_plan_v2_text[1], 1, 200)
#'
#' # find acronyms defined in the text
#' acronyms_v2 <- find_acronyms(example_plan_v2_text)
#' head(acronyms_v2)
"example_plan_v2_text"

#' @title Parsed token data from version 2 of a groundwater plan
#' @description
#' Token-level linguistic annotations from the later version of a publicly
#' available groundwater plan. This is version 2; see [example_plan_v1_parsed]
#' for the earlier version.
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
#' nrow(example_plan_v2_parsed)
#'
#' # inspect token, lemma, and part-of-speech annotations
#' head(example_plan_v2_parsed[, c("token", "lemma", "pos")])
#'
#' # most frequent part-of-speech tags
#' head(sort(table(example_plan_v2_parsed$pos), decreasing = TRUE), 5)
"example_plan_v2_parsed"
