# Regenerate bundled data objects from the package PDFs.
# Run pdf_clean() and parse_text() on the PDFs in inst/extdata/ as shown
# in the vignette appendix, then save the individual objects below.
#
# example_plan_v1_text   <- <output of pdf_clean for example_plan_v1.pdf>
# example_plan_v2_text   <- <output of pdf_clean for example_plan_v2.pdf>
# example_plan_v1_parsed <- <output of parse_text for example_plan_v1_text>
# example_plan_v2_parsed <- <output of parse_text for example_plan_v2_text>

usethis::use_data(example_plan_v1_text,   overwrite = TRUE)
usethis::use_data(example_plan_v2_text,   overwrite = TRUE)
usethis::use_data(example_plan_v1_parsed, overwrite = TRUE)
usethis::use_data(example_plan_v2_parsed, overwrite = TRUE)
