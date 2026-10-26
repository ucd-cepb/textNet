# Exported functions 
# entity_consolidate_replicate 

#' @title Consolidate named entities while preserving dependency data
#' @description
#' Adds a concatenated-entity column to a parsed spacy data frame, keeping the
#' token-level dependency information that [spacyr::entity_consolidate()] drops.
#'
#' @details
#' Unlike [spacyr::entity_consolidate()], which returns a data frame that no
#' longer retains `head_token_id` and `dep_rel`, this function adds a new column
#' holding the concatenated entity while leaving the original annotations intact.
#' The concatenated entity is replicated across every token of the entity, which
#' is inefficient but preserves the remaining columns.
#'
#' @param x parsed spacy document in data.frame format
#' @param concatenator A character that separates string segments when they are collapsed into a single entity. Defaults to "_"
#' @param remove regex formatted strings to remove as entity components (like "the" in "the Seattle Supersonics")
#' @return original data frame with added column for concatenated entity
#' 
#' @import data.table
#' @importFrom stringr str_remove_all
#'

entity_consolidate_replicate <- function(x, concatenator = "_", remove = NULL) {
  # Input validation
  if (!is.data.frame(x)) {
    stop("'x' must be a data.frame")
  }
  
  if (!is.character(concatenator) || length(concatenator) != 1) {
    stop("'concatenator' must be a single character string")
  }
  
  if (!is.null(remove) && !is.character(remove)) {
    stop("'remove' must be NULL or a character vector")
  }

  spacy_result <- as.data.table(x)
  if(!is.null(remove)){
    index <- which(grepl(paste(remove,collapse = '|'),spacy_result$token,perl = TRUE)&spacy_result$entity!="")
    spacy_result$token[index] <- str_remove_all(spacy_result$token[index],paste(remove,collapse = '|'))
    spacy_result$entity[index] <- ""
  }
  
  entity <- entity_type <- entity_count <- iob <- entity_id <- .N <- .SD <-
    `:=` <- token <- lemma <- pos <- tag <- new_token_id <- token_id <-
    sentence_id <- doc_id <- NULL
  if (!"entity" %in% names(spacy_result)) {
    stop("no entities in parsed object: rerun spacy_parse() with entity = TRUE")
  }
  spacy_result[, entity_type := sub("_.+", "", entity)]
  spacy_result[, iob := sub(".+_", "", entity)]
  spacy_result[, entity_count := ifelse(iob == "B" | iob == "", 1, 0)]
  spacy_result[, entity_id := cumsum(entity_count), by = c("doc_id", "sentence_id")]
  #added source_or_target to by = c(...) so that appositives do not get concatenated together with the main entity
  spacy_result[, entity_name := paste(token, collapse = concatenator),by = c("doc_id", "sentence_id", "entity_id", "source_or_target")]
  spacy_result$entity_name[spacy_result$entity==''] <- ''
  spacy_result$entity_id[spacy_result$entity==''] <- -1
  ret <- as.data.table(spacy_result)
  class(ret) <- c("spacyr_parsed", class(ret))
  ret
}
