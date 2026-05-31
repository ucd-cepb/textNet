# Exported function
# extract_front_matter_acronyms

# ---- internal regex / filter constants -------------------------------------

# Heading patterns.
# Accepts Title Case or ALL CAPS, with `and` or `&` as the connector word,
# and an optional `List of` / `Glossary of` prefix. Section numbers and
# leading dashes are tolerated. Anchored to a full line (multiline mode).
.heading_re <- paste0(
  "(?im)^[\\s\\d\\.\\-]*",
  "(?:list\\s+of\\s+|glossary\\s+of\\s+)?",
  "(?:",
    "acronyms?(?:\\s+(?:and|&)\\s+abbreviations?)?",
    "|abbreviations?(?:\\s+(?:and|&)\\s+acronyms?)?",
  ")\\s*$"
)

# Row pattern.
# Acronym: starts with a capital letter, ≤20 chars total of [A-Za-z0-9&/-];
#   optionally followed by a tab/space-separated second capital-start word
#   (handles "NASA InSAR", "Mather AFB", "C&E Plan", "Coordination Agreement").
#   IMPORTANT: the inner whitespace MUST be [ \t]+, not \s+, otherwise the
#   group can swallow a newline and capture a heading line into the acronym.
# Separator: 3+ dots, tabs, or 5+ spaces. Five spaces is the cutoff because
#   real tables are visually columnar; narrative prose has single spaces.
# Expansion: starts with a letter, 4-120 chars total (paragraph-leak guard).
.row_re <- paste0(
  "(?m)^[ \\t]*",
  "([A-Z][A-Za-z0-9&/\\-]{0,19}(?:[ \\t]+[A-Z][A-Za-z0-9&/\\-]*)?)",
  "[ \\t]*(?:\\.{3,}|\\t+|[ \\t]{5,})[ \\t]*",
  "([A-Za-z][^\\n]{3,118})",
  "\\s*$"
)

# Post-match expansion blacklist (applied to RAW expansion, before any
# stripping). Catches three observed footer / TOC residue shapes.
.expansion_reject <- c(
  "(?i)^[ivxlcdm]+$",       # roman numeral page numbers (page 'xii' footers)
  "^\\d+(-\\d+)?$",         # bare page numbers ("14", "B-3")
  "^[A-Z][a-z]+ \\d{4}$"    # Month YYYY date footers
)

# Acronym blacklist. "Item" is the column header in a glossary-style table
# layout (multi-section documents sometimes use Item | Description headers).
.acronym_reject <- c("Item")

# ---- main function ---------------------------------------------------------

#' Extract acronym definitions from a front-matter acronym table.
#'
#' Scans a character vector (typically one element per page, as returned by
#' \code{\link{pdf_clean}}) for one or more section headings that signal an
#' explicit acronym / abbreviation table (e.g., "Acronyms and Abbreviations",
#' "List of Acronyms", or just the bare word "Abbreviations"). For each
#' heading found, the function walks the heading page and subsequent pages
#' while they continue to contain table-shaped rows, and extracts rows of
#' the form \code{ACRONYM <separator> Full Name}.
#'
#' All heading occurrences in the document are processed, so a document
#' with separate "Abbreviations" and "Acronyms" sections (or per-chapter
#' acronym tables) is fully harvested. Conflicting acronym definitions are
#' resolved by keeping the first occurrence.
#'
#' The output has the same column shape as \code{\link{find_intext_acronyms}},
#' so the two can be \code{rbind()}'d (front-matter rows first, so
#' front-matter wins on conflict after \code{unique(by = "acronym")}) and the
#' combined table fed into \code{\link{disambiguate}}.
#'
#' By default only capital-letter-leading acronyms are captured. Lowercase
#' technical units (e.g., \code{bgs}, \code{cfs}, \code{mg/L}) are skipped
#' because they rarely correspond to entity nodes and admitting them
#' substantially increases the false-positive surface in justified-column
#' PDFs. Title Case "nickname" acronyms (\code{District}, \code{Authority},
#' \code{Mather AFB}) \emph{are} captured.
#'
#' @param str A character vector, typically one element per page of the
#'   document (as returned by \code{\link{pdf_clean}}).
#' @param max_window_pages Integer. Upper bound on how many pages after
#'   each heading the function will read (defaults to 10). The actual window
#'   stops earlier if two consecutive pages contain no table-shaped rows or
#'   if the next heading page is reached.
#'
#' @return A \code{data.table} with columns \code{name} (full expansion,
#'   spaces and hyphens replaced with underscores to match spaCy's
#'   concatenated entity tokens) and \code{acronym}. Returns an empty
#'   \code{data.table} (zero rows, both columns) when no front-matter
#'   acronym table is detected.
#'
#' @import data.table
#' @importFrom stringr str_match_all str_trim str_replace_all
#'
#' @examples
#' # Input is a character vector with one element per page, as returned by
#' # pdf_clean(). Here we hand-build a minimal two-page example.
#' pages <- c(
#'   paste(
#'     "Acronyms and Abbreviations",
#'     "",
#'     "EPA          Environmental Protection Agency",
#'     "DWR          Department of Water Resources",
#'     "GSA          Groundwater Sustainability Agency",
#'     "GSP          Groundwater Sustainability Plan",
#'     sep = "\n"
#'   ),
#'   "(next page of the document; no acronyms here)"
#' )
#' extract_front_matter_acronyms(pages)
#'
#' # Combine with find_intext_acronyms() so front-matter rows win on conflict.
#' fm <- extract_front_matter_acronyms(pages)
#' inline <- find_intext_acronyms(pages)
#' all_acronyms <- unique(rbind(fm, inline), by = "acronym")
#'
#' @export
extract_front_matter_acronyms <- function(str, max_window_pages = 10L) {
  if (!is.character(str)) {
    stop("'str' must be a character vector")
  }
  if (!is.numeric(max_window_pages) || length(max_window_pages) != 1L ||
      max_window_pages < 1) {
    stop("'max_window_pages' must be a single positive integer")
  }
  max_window_pages <- as.integer(max_window_pages)

  empty <- data.table(name = character(0), acronym = character(0))

  # Find every heading page in document order.
  heading_pages <- which(grepl(.heading_re, str, perl = TRUE))
  if (length(heading_pages) == 0L) return(empty)

  # For each heading, walk forward through pages collecting row matches.
  # Stop when: max_window_pages reached, end of document, next heading
  # page reached, or two consecutive zero-row pages.
  all_rows <- list()
  for (i in seq_along(heading_pages)) {
    hp <- heading_pages[i]
    next_hp <- if (i < length(heading_pages)) heading_pages[i + 1L] else Inf
    no_hit_streak <- 0L
    for (offset in 0L:max_window_pages) {
      pg <- hp + offset
      if (pg > length(str)) break
      if (pg >= next_hp) break
      matches <- stringr::str_match_all(str[pg], .row_re)[[1]]
      if (nrow(matches) > 0L) {
        all_rows[[length(all_rows) + 1L]] <- matches
        no_hit_streak <- 0L
      } else if (offset > 0L) {
        no_hit_streak <- no_hit_streak + 1L
        if (no_hit_streak >= 2L) break
      }
    }
  }
  if (length(all_rows) == 0L) return(empty)

  matches    <- do.call(rbind, all_rows)
  acronyms   <- stringr::str_trim(matches[, 2])
  expansions <- stringr::str_trim(matches[, 3])

  # Acronym blacklist (column header guards).
  keep <- !(acronyms %in% .acronym_reject)
  acronyms <- acronyms[keep]; expansions <- expansions[keep]

  # Expansion blacklist (applied to RAW expansion, before any cleanup).
  for (re in .expansion_reject) {
    drop <- grepl(re, expansions, perl = TRUE)
    acronyms <- acronyms[!drop]; expansions <- expansions[!drop]
  }
  if (length(acronyms) == 0L) return(empty)

  # Spaces and hyphens -> underscores to match spaCy entity tokens.
  names_clean <- stringr::str_replace_all(expansions, "-|\\s+", "_")
  result <- data.table(name = names_clean, acronym = acronyms)

  # First occurrence per acronym wins.
  result <- unique(result, by = "acronym")
  setcolorder(result, c("name", "acronym"))
  result
}
