# textNet (development version)

## New features

* New `parse_text_trf()` parses text with spaCy's `en_core_web_trf` transformer model through a bundled Python module (`inst/python/parse_text_trf.py`) instead of spacyr, so PyTorch can use a GPU when one is available. It takes the same preprocessing and EntityRuler arguments as `parse_text()`, plus `batch_size`, and finds Python the same way. Parsed output is saved as Parquet files via duckdb; the new `read_parsed_trf()` reads them back.

* New `find_intext_acronyms()` detects parenthetically defined acronyms ("Department of Water Resources (DWR)"). It replaces the in-text part of `find_acronyms()`, and its name makes clear how it differs from `extract_front_matter_acronyms()`. Text with no parentheses now returns an empty table instead of an error.

* New `extract_front_matter_acronyms()` extracts acronym definitions from explicit "Acronyms and Abbreviations" / "List of Acronyms" tables near the front of a document. It handles dot-leader and wide-whitespace layouts and harvests every acronym table in a document, including per-chapter ones. Title Case nicknames (`District`, `Mather AFB`) are kept when each word containing lowercase letters also appears in the expansion. Mixed-case technical terms (`InSAR`), geologic map symbols (`Qya`), two-letter `[A-Z][a-z]` short forms and units of measurement (`AFY`, `mg/L`) are dropped. The output has the same columns as `find_intext_acronyms()`, so the two can be `rbind()`'d before `disambiguate()`.

* New `build_structural_org_patterns()` builds spaCy EntityRuler patterns that match the grammatical shape of government organization names (e.g., "California Department of Fish & Wildlife") rather than exact strings. Combine its output with `entity_specify()` patterns and pass both to `parse_text()` or `parse_text_trf()`.

* `parse_text()` and `textnet_extract()` gain a `progress` argument to turn off progress bars.

## Deprecations

* `find_acronyms()` is deprecated. Use `find_intext_acronyms()` for parenthetically defined acronyms and `extract_front_matter_acronyms()` for acronym tables. `find_acronyms()`, including its `table_text` argument, still returns the same result as in 1.1.1 but now emits a deprecation warning.

## Behavior changes

* `textnet_extract()` now keeps nationalities and religious or political groups (`NORP`) by default: `keep_entities = c("ORG", "GPE", "PERSON", "NORP")`.

* `textnet_extract()` matches unsourced verbs to their parent verb's sources by exact key. Previously a regular-expression match could also attach sources from other verbs in the same sentence whose IDs share a prefix (e.g., verb 3 picking up sources of verbs 30-39).

* `parse_text()` compares tokens to the English word list case-insensitively, so capitalized words no longer count against the "fewer than 50% English words" warning.

## Performance

* The dependency crawl in `textnet_extract()` is now implemented in C++ via Rcpp, with the R implementation kept as a fallback (for example in forked parallel workers). textNet now requires compilation when installed from source.

* Appositive and adopted-source lookups and hedging/future-tense detection in `textnet_extract()` are vectorized or keyed joins instead of row-by-row scans.

## Dependencies

* Rcpp is added to Imports and LinkingTo.
* duckdb and DBI are added to Suggests (needed only for `parse_text_trf()` and `read_parsed_trf()`).

## Testing

* New tests for `extract_front_matter_acronyms()` pin its output against five real Groundwater Sustainability Plan acronym tables (386 expected rows; fixtures under `tests/testthat/testdata/acronym_pages/`).
* New sentence-level tests check the `textnet_extract()` edges produced for 36 sentences that exercise subjects, passive voice, objects, appositives, negation, xcomp chains and custom entities (`tests/testthat/testdata/sentences_that_work.txt`). They parse with spaCy, so they are skipped on CRAN and wherever Python with spaCy and `en_core_web_lg` is not found.

# textNet 1.1.1

* First release with a NEWS file. See the JOSS paper and the package vignette for the feature set at this version.
