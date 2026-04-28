#' Extract acronym definitions from a front-matter acronym table.
#'
#' Scans a character vector (one element per page or chunk) for a section
#' heading that signals an explicit acronym/abbreviation table (e.g.,
#' "Acronyms and Abbreviations", "List of Acronyms"). When found, pastes
#' that page and up to five following pages, then extracts rows of the form
#' \code{ACRONYM <separator> Full Name}.
#'
#' This is the highest-precision source for acronym definitions because the
#' document authors have already resolved any ambiguity. It is called
#' automatically by \code{\link{find_acronyms}} when
#' \code{use_front_matter = TRUE}.
#'
#' @param str A character vector, typically one element per page of the
#'   document (as returned by \code{pdf_clean}).
#'
#' @return A \code{data.table} with columns \code{name} (full expansion,
#'   spaces and hyphens replaced with underscores to match spaCy entity
#'   format) and \code{acronym}. Returns an empty \code{data.table} if no
#'   front-matter acronym table is detected.
#'
#' @import data.table
#' @importFrom stringr str_match_all str_remove str_trim str_replace_all
#'
#' @export

# Check that the letter-only portion of `acronym` is a subsequence of the
# first letters of the words in `expansion`. This filters out rows where the
# regex matched a stray line of text rather than a real acronym entry.
#
# Example: "EPA" vs "Environmental Protection Agency"
#   acr_letters = "epa"
#   word initials = e, p, a  ->  "epa"   -> "epa" is a subsequence -> TRUE
#
# Example: "DWR" vs "Department of Water Resources"
#   acr_letters = "dwr"
#   word initials = d, o, w, r -> "dowr"  -> "dwr" subsequence (skip "o") -> TRUE
#
# Non-letter characters in the acronym (digits, &, /) are stripped before
# matching, so "SB 1383" -> "sb" checked against "Senate Bill ..." -> TRUE.
.acronym_fits_expansion <- function(acronym, expansion) {
  acr_letters <- tolower(gsub("[^A-Za-z]", "", acronym))
  if (nchar(acr_letters) == 0L) return(TRUE)

  words    <- unlist(strsplit(expansion, "\\s+"))
  initials <- tolower(substr(words, 1L, 1L))
  initials <- initials[grepl("[a-z]", initials, perl = TRUE)]
  if (length(initials) == 0L) return(FALSE)

  ini_str   <- paste(initials, collapse = "")
  acr_chars <- strsplit(acr_letters, "")[[1]]

  # Walk through acr_chars in order; each must be found in ini_str at or
  # after the current position (subsequence check).
  pos <- 1L
  for (ch in acr_chars) {
    hit <- regexpr(ch, substring(ini_str, pos), fixed = TRUE)
    if (hit < 0L) return(FALSE)
    pos <- pos + hit  # advance past the matched character
  }
  TRUE
}

extract_front_matter_acronyms <- function(str) {
  if (!is.character(str)) {
    stop("'str' must be a character vector")
  }

  # Section headings that signal an explicit acronym table.
  # Anchored to the full line (after optional leading section numbers like
  # "3.2" or "Appendix A") so mid-paragraph uses of the word "acronyms"
  # do not trigger a false match.
  heading_re <- paste0(
    "(?im)",                          # case-insensitive, multiline
    "^[\\s\\d\\.\\-]*",              # optional leading "3.2 " / "A. " etc.
    "(?:",
      "acronyms?\\s+and\\s+abbreviations?",
      "|abbreviations?\\s+and\\s+acronyms?",
      "|list\\s+of\\s+acronyms?",
      "|list\\s+of\\s+abbreviations?",
      "|glossary\\s+of\\s+acronyms?",
      "|acronyms?",
      "|abbreviations?",
    ")",
    "\\s*$"
  )

  # A page that contains a "Table of Contents" / "Contents" heading is a TOC
  # page — any acronym heading found there is just a TOC entry, not the real
  # section. Skip such pages entirely.
  toc_page_re <- paste0(
    "(?im)^[\\s\\d\\.\\-]*",
    "(?:table\\s+of\\s+contents?|contents?)",
    "\\s*$"
  )

  candidate_pages <- which(grepl(heading_re, str, perl = TRUE))

  heading_page <- NA_integer_
  for (pg in candidate_pages) {
    if (!grepl(toc_page_re, str[pg], perl = TRUE)) {
      heading_page <- pg
      break
    }
  }

  if (is.na(heading_page)) {
    return(data.table(name = character(0), acronym = character(0)))
  }

  # Paste that page and up to 5 following pages. The heading will not appear
  # at the very bottom of a page, so the table content always starts on the
  # same page. Five extra pages handles even unusually long acronym lists.
  window_idx <- heading_page:min(heading_page + 5L, length(str))
  text <- paste(str[window_idx], collapse = "\n")

  # Row pattern: ACRONYM <separator> Full Name
  #
  # Acronym: 2+ uppercase chars (digits, &, / allowed); optionally followed
  #   by a space and a second all-caps token to cover things like "SB 1383".
  # Separator: 2 or more of: dash, colon, tab, or space.
  # Expansion: starts with a letter, continues to end of line.
  row_re <- paste0(
    "(?m)",
    "^\\s*",
    "([A-Z][A-Z0-9&/\\-]{1,}(?:\\s[A-Z0-9]+)?)",  # acronym
    "\\s*[-:\\t ]{2,}\\s*",                          # separator
    "([A-Za-z][^\\n]{3,})",                          # expansion
    "\\s*$"
  )

  matches <- stringr::str_match_all(text, row_re)[[1]]

  if (nrow(matches) == 0L) {
    return(data.table(name = character(0), acronym = character(0)))
  }

  acronyms   <- matches[, 2]
  expansions <- matches[, 3]

  # Strip trailing footnote markers and stray page numbers that sometimes
  # appear in PDF-extracted text (e.g., "Agency Name ....... 14").
  expansions <- stringr::str_remove(expansions, "\\s*\\.{2,}\\s*\\d+\\s*$")
  expansions <- stringr::str_remove(expansions, "\\s+\\d+\\s*$")
  expansions <- stringr::str_trim(expansions)

  # Drop rows where the expansion is empty after cleaning.
  keep       <- nchar(expansions) > 0L
  acronyms   <- acronyms[keep]
  expansions <- expansions[keep]

  # Validate acronym-expansion consistency: the letter-only portion of the
  # acronym must appear as a subsequence of the word initials in the expansion.
  # This catches stray lines of text that happen to match the row regex.
  if (length(acronyms) > 0L) {
    valid    <- mapply(.acronym_fits_expansion, acronyms, expansions,
                       USE.NAMES = FALSE)
    acronyms   <- acronyms[valid]
    expansions <- expansions[valid]
  }

  if (length(acronyms) == 0L) {
    return(data.table(name = character(0), acronym = character(0)))
  }

  # Spaces and hyphens -> underscores to match spaCy's entity token format.
  names_clean <- stringr::str_replace_all(expansions, "-|\\s+", "_")

  result <- data.table(name = names_clean, acronym = acronyms)

  # Front-matter tables are authoritative: keep first occurrence per acronym.
  result <- unique(result, by = "acronym")

  return(result)
}
