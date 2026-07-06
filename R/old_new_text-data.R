#' @title Raw text from two versions of a groundwater plan
#' @description
#' Page-level text extracted from two versions of a publicly available
#' groundwater plan.
#'
#' @details
#' The list is named, with one element per document. Each element is a
#' character vector in which each string corresponds to one page of the PDF.
#' The data format matches the output of [pdf_clean()].
#'
#' @format A named list of two character vectors, one per plan version. Each
#'   vector element contains the extracted text of a single PDF page.
#'
#' @examples
#' # number of pages in each plan version
#' lengths(old_new_text)
#'
#' # preview the first page of the earlier version
#' substr(old_new_text[[1]][1], 1, 200)
"old_new_text"
