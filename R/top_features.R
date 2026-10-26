# Exported functions
# top_features

#' @title Identify top entities and verbs across documents
#' @description
#' Returns the highest-degree entities and most frequent verb lemmas across a
#' set of documents, normalized by each document's overall degree distribution or edge distribution, respectively.
#'
#' @param files vector of filepaths to igraph objects or list of igraph objects
#' @param from_file boolean whether files represent filepaths (TRUE) or igraph objects (FALSE)
#' 
#' @return list of all entities and lemmas in the corpus, along with their average normalized prevalence as a fraction of a plan. For entities, this is the entity degree over the sum of all entity degrees in the plan, averaged across all plans  
#' @importFrom magrittr %>%
#' @importFrom ohenery normalize
#' @importFrom tidyr tibble
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr arrange
#' @importFrom dplyr desc
#' @importFrom rlang .data
#' @importFrom igraph degree
#' @importFrom igraph edge_attr
#' 
#' @export

top_features <- function(files, from_file=FALSE){
  # Input validation
  if(!is.list(files) && !is.character(files)) {
    stop("'files' must be either a list of igraph objects or a character vector of file paths")
  }
  
  if(!is.logical(from_file) || length(from_file) != 1) {
    stop("'from_file' must be a single logical value")
  }

  all_lemmas<- vector("list", length = length(files))
  all_entities <- vector("list", length = length(files))
  
  for(i in 1:length(files)){
    
    if(from_file==TRUE){
      igr <- readRDS(files[i])
    }else{
      igr <- files[[i]]
    }
    all_entities[[i]] <- sort(igraph::degree(igr),decreasing = TRUE)
    all_lemmas[[i]] <- sort(table(igraph::edge_attr(
      igr, "head_verb_lemma")), decreasing = TRUE)
  }
  
  all_entities_normalized <- lapply(all_entities, function(x) ohenery::normalize(x))
  all_lemmas_normalized <- lapply(all_lemmas, function(x) ohenery::normalize(x))
  
  all_entities_normalized <- unlist(all_entities_normalized)
  all_lemmas_normalized <- unlist(all_lemmas_normalized)
  
  all_entities_df <- tidyr::tibble("names" = names(all_entities_normalized), 
                            "fraction_of_doc"= unname(all_entities_normalized))
  all_lemmas_df <- tidyr::tibble("names" =names(all_lemmas_normalized),
                          "fraction_of_doc"=unname(all_lemmas_normalized))
  #prevalence over entire corpus as avg fraction of a plan
  all_entity_percents <- all_entities_df %>% dplyr::group_by(.data$names) %>%
    dplyr::summarize("avg_fract_of_a_doc" = sum(.data$fraction_of_doc)/length(files)) %>% dplyr::arrange(dplyr::desc(.data$avg_fract_of_a_doc))
  all_lemma_percents <- all_lemmas_df %>% dplyr::group_by(.data$names) %>%
    dplyr::summarize("avg_fract_of_a_doc" = sum(.data$fraction_of_doc)/length(files)) %>% dplyr::arrange(dplyr::desc(.data$avg_fract_of_a_doc))
  
  #only keep entities that have letters
  all_entity_percents <- all_entity_percents[grepl("[A-Za-z]", all_entity_percents$names),]
  
  return(list(entities = all_entity_percents, lemmas = all_lemma_percents))
  
}
