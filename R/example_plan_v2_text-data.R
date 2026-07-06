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
