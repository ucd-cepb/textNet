# textNet (development version)

## New features

* New `extract_front_matter_acronyms()` extracts acronym definitions from explicit "Acronyms and Abbreviations" / "List of Acronyms" tables found near the front of a document. The output has the same column shape as `find_intext_acronyms()`, so the two can be `rbind()`'d before feeding into `disambiguate()`. The function handles Title Case nicknames (`District`, `Authority`, `Mather AFB`), mixed-case acronyms (`InSAR`, `LiDAR`, `C2VSimCG`), and both dot-leader and wide-whitespace separator styles. All heading occurrences in a document are processed, so per-chapter acronym tables are fully harvested.

## Breaking changes

* `find_acronyms()` has been renamed to `find_intext_acronyms()` to clarify its scope (parenthetical patterns found inline in the text, as opposed to the front-matter table extractor). The old name is preserved as a deprecated alias that emits a `.Deprecated()` warning when called.

## Testing

* New regression tests under `tests/testthat/test-extract_front_matter_acronyms.R` pin behavior against five real GSP fixture page sets (438 total expected rows in ground-truth CSVs under `tests/testthat/testdata/acronym_pages/`).
