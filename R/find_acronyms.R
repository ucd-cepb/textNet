# Exported function
# find_acronyms

#' Detect acronym definitions in a character vector.
#'
#' Combines two sources:
#' \enumerate{
#'   \item \strong{Inline parenthetical patterns} -- matches like
#'     \code{"Long Form (ACRONYM)"} or \code{"ACRONYM (Long Form)"}
#'     anywhere in the text.
#'   \item \strong{Front-matter acronym table} (when
#'     \code{use_front_matter = TRUE}) -- an explicit two-column table under
#'     a heading such as "Acronyms and Abbreviations". These definitions are
#'     treated as authoritative and win when the two sources conflict.
#' }
#'
#' @param str A character vector, typically one element per page (as returned
#'   by \code{pdf_clean}).
#' @param use_front_matter Logical. When \code{TRUE} (default),
#'   \code{\link{extract_front_matter_acronyms}} is called and its results
#'   are merged with the inline results, with front-matter entries taking
#'   precedence on conflict.
#'
#' @return A \code{data.table} with columns \code{name} (full expansion,
#'   spaces and hyphens replaced with underscores) and \code{acronym}.
#'   Only acronyms with a unique expansion are returned. Rows are sorted
#'   shortest to longest acronym so that \code{\link{disambiguate}} applies
#'   shorter substitutions first.
#'
#' @import data.table
#' @importFrom stringr str_split str_remove_all str_replace_all
#' @importFrom stringi stri_match_last stri_match_all
#'
#' @export

find_acronyms <- function(str, use_front_matter = TRUE){
  # Input validation
  if(!is.character(str)) {
    stop("'str' must be a character vector")
  }

  # ------------------------------------------------------------------
  # Section 1: Inline parenthetical detection (existing logic)
  # ------------------------------------------------------------------
  paren_splits <- str_split(str, pattern = "\\)")
  paren_splits2 <- lapply(paren_splits, function (k) k[nchar(k)>0])
  paren_splits3 <- lapply(paren_splits2, function(m) stringr::str_split(m, pattern = "\\("))
  paren_splits4 <- lapply(paren_splits3, function (j) lapply(j, function(m) m[length(m)==2]))
  paren_splits4 <- unlist(paren_splits4, recursive=F)
  paren_splits5 <- do.call(rbind, paren_splits4)
  paren_splits$acr1 <- stri_match_last(str = paren_splits5[,1], regex ="\\b[A-Z]+\\b")
  paren_splits$acr2 <- stri_match_all(str = paren_splits5[,2], regex ="\\b[A-Z]+\\b")
  paren_splits$abb1 <- str_remove_all(paren_splits5[,1],"[^A-Z]")
  paren_splits$abb1 <- sapply(1:length(paren_splits$acr2),
                                  function(s) sapply(1:length(paren_splits$acr2[[s]]), function (m){
                                    stri_match_last(str=paren_splits$abb1[s],
                                        regex = paren_splits$acr2[[s]][m])
                                  }))
  sp_lower <- "[\\s|a-z]+"
  paren_splits$name1 <- sapply(1:length(paren_splits$acr2),
                               function(s) sapply(1:length(paren_splits$acr2[[s]]), function (m){
                                 stri_match_last(str=paren_splits5[s,1], regex = paste0(paste0(stringr::str_split(paren_splits$acr2[[s]][m],pattern="")[[1]],collapse=sp_lower),"[a-z]+"))
                               }))
  paren_splits$abb2 <- str_remove_all(paren_splits5[,2],"[^A-Z]")
  paren_splits$name2 <- sapply(1:length(paren_splits$abb2),
                               function(s)
                                 stri_match_last(str=paren_splits5[s,2], regex = paste0(paste0(stringr::str_split(paren_splits$acr1[s],pattern="")[[1]],collapse=sp_lower),"[a-z]+"))
                               )

  paren_splits$acr1 <- as.vector(paren_splits$acr1)
  paren_splits$name2

  paren_splits$acr2 <- unlist(paren_splits$acr2)
  paren_splits$name1 <- unlist(paren_splits$name1)

  acronym_matches <- setDT(list("name" = paren_splits$name2,"acronym" = paren_splits$acr1))
  acronym_matches2 <- setDT(list("name" = paren_splits$name1, "acronym" = paren_splits$acr2))

  acronym_matches <- rbind(acronym_matches, acronym_matches2)
  acronym_matches <- acronym_matches[!is.na(acronym) & !is.na(name) &nchar(acronym)>1,]

  acronym_matches$name <- str_replace_all(acronym_matches$name,"-|\\s+","_")
    #change hyphens and spaces to underscores, since in spacyparse they are treated as separate tokens

  #sort from shortest to longest acronym so the replacement happens in the right order
  acronym_matches <- acronym_matches[order(nchar(acronym_matches$acronym)),]
  acronym_matches <- unique(acronym_matches)
  #don't include non-unique acronyms (same acronym, different expansions found inline)
  acronym_matches <- acronym_matches[,c(.SD,.N),by=acronym]
  acronym_matches <- acronym_matches[N==1,]
  acronym_matches <- acronym_matches[,N:=NULL]

  # ------------------------------------------------------------------
  # Section 2: Front-matter table merge
  # Front-matter definitions are authoritative: they win on conflict,
  # and can reinstate acronyms that were dropped above due to inline
  # ambiguity (two inline expansions -> N > 1 -> dropped).
  # ------------------------------------------------------------------
  if (use_front_matter) {
    fm <- extract_front_matter_acronyms(str)
    if (nrow(fm) > 0L) {
      # rbind with fm first so that, after dedup, fm entry survives.
      combined <- rbind(fm, acronym_matches)
      # Keep first occurrence of each acronym (fm row, when present).
      combined <- combined[!duplicated(combined$acronym)]
      acronym_matches <- combined
    }
  }

  # ------------------------------------------------------------------
  # Section 3: Final ordering and column layout
  # ------------------------------------------------------------------
  #sort from shortest to longest so disambiguation applies in the right order
  acronym_matches <- acronym_matches[order(nchar(acronym_matches$acronym)),]
  setcolorder(x = acronym_matches, neworder = c("name", "acronym"))
  return(acronym_matches)
}
