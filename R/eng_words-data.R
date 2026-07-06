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
