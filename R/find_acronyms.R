# Exported function (deprecated)
# find_acronyms

#' @title Detect acronyms (deprecated)
#' @description
#' `find_acronyms()` is deprecated as of textNet 1.1.1.9000. Use
#' [find_intext_acronyms()] for parenthetically defined acronyms and
#' [extract_front_matter_acronyms()] for acronym tables. `find_acronyms()`
#' still works and returns the same result as in textNet 1.1.1, but emits a
#' deprecation warning.
#'
#' @param str A character vector
#' @param table_text Optional; used to detect acronyms from tables. A character vector representing the contents of a unique text file, such as the output of pdftools::pdf_text. Each element of the vector corresponds to a page of a pdf. It is recommended to use raw text output, rather than the results of textNet::pdf_clean, as the cleaning process removes white spaces that could hinder the detection of acronym tables. Single-letter acronyms are excluded. Parenthetically defined acronyms take precedence over table-defined acronyms.
#'
#' @return a data table with a "name" column and an "acronym" column representing its associated acronym.
#' Each row corresponds to a unique match in the document.
#'
#' @seealso [find_intext_acronyms()], [extract_front_matter_acronyms()]
#'
#' @importFrom stringr str_replace_all
#' @keywords internal
#' @export

find_acronyms <- function(str, table_text = NULL){
  .Deprecated(msg = paste0(
    "'find_acronyms()' is deprecated.\n",
    "Use 'find_intext_acronyms()' for parenthetically defined acronyms",
    " and 'extract_front_matter_acronyms()' for acronym tables."))

  acronym_matches <- find_intext_acronyms(str)

  if(!is.null(table_text)){
    if(!is.character(table_text)){
      stop("'table_text' must be a character vector.")
    }
    acron_table <- .find_table_acronyms(table_text)

    #prefer the acronyms that are parenthetically defined
    acronym_matches <- rbind(acronym_matches, acron_table)
    #can't accept one acronym going to multiple contradicting "to" nodes, so we filter duplicates
    acronym_matches <- acronym_matches[!duplicated(acronym_matches$acronym),]
  }

  return(acronym_matches)
}

# Two-column acronym table detection used by the deprecated find_acronyms().
.find_table_acronyms <- function(table_text){
  shorts <- vector(mode = "character", length = 0)
  longs <- vector(mode = "character", length = 0)
  mysplits <- strsplit(table_text, "\\n")
  #for each page in project
  for(j in 1:length(mysplits)){
    #split on more than one space
    linesplits <- strsplit(mysplits[[j]], "\\s\\s+")
    #for each line in page
    if(length(linesplits)>0){
      for(k in 1:length(linesplits)){
        #remove any empty strings
        linesplits[[k]] <- linesplits[[k]][linesplits[[k]] != ""]
        #if there's nothing else on that line, just those two strings:
        if(length(linesplits[[k]]) == 2){
          #if the capital letters match and one of them has lowercase and the other has uppercase
          if(linesplits[[k]][1] == 
             stringr::str_remove_all(linesplits[[k]][2], "[a-z]|_|\\s") & 
             stringr::str_detect(linesplits[[k]][2], "[a-z]") &
             stringr::str_detect(linesplits[[k]][1], "[A-Z]")){
            shorts <- append(shorts, linesplits[[k]][1])
            longs <- append(longs, linesplits[[k]][2])
            #if the capital letters match and one of them has lowercase and the other has uppercase
          }else if(linesplits[[k]][2] == 
                   stringr::str_remove_all(linesplits[[k]][1], "[a-z]|_|\\s") &
                   stringr::str_detect(linesplits[[k]][1], "[a-z]") &
                   stringr::str_detect(linesplits[[k]][2], "[A-Z]")){
            shorts <- append(shorts, linesplits[[k]][2])
            longs <- append(longs, linesplits[[k]][1])
          }
        }
      }
    }
    
  }
  if(length(longs)>0){
    acron_table <- data.frame(name=character(length(longs)), acronym=character(length(longs)))
    acron_table$name <- longs
    acron_table$acronym <- shorts
  }else{
    acron_table <- data.frame(name = vector(mode = "character", length = 0),
                              acronym = vector(mode = "character", length = 0))
  }
  
  
  
  #get rid of one-letter acronyms
  
  acron_table <- acron_table[nchar(acron_table$acronym)>1,]
  #replace non-word chars with underscore
  acron_table$acronym <- str_replace_all(acron_table$acronym, 
                                         "\\W", "_")
  acron_table$name <- str_replace_all(acron_table$name, 
                                      "\\W", "_")

  return(acron_table)
}
