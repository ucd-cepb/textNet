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
