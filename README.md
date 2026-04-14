# textNet

textNet is a set of tools in the R language that uses part-of-speech tagging and dependency parsing to generate semantic networks from text data. It is compatible with Universal Dependencies and has been tested on English-language text data.

To be used in the main project repo: 
https://github.com/ucd-cepb/textNet

# Overview
Network extraction from documents has typically required manual coding.
Furthermore, existing network extraction methods that use co-occurrence
leave a vast amount of data on the table, namely, the rich edge
attribute data and directionality of each verb phrase defining the
particular relationship between two entities, and the respective roles
of the entity nodes involved in that verb phrase. We present an R
package, *textNet*, designed to enable directed, multiplex, multimodal
network extraction from text documents through syntactic dependency
parsing, in a replicable, automated fashion for collections of
arbitrarily long documents. The *textNet* package facilitates the
automated analysis and comparison of many documents, based on their
respective network characteristics. Its flexibility allows for any
desired entity categories, such as organizations, geopolitical entities,
dates, or custom-defined categories, to be preserved.

See paper/paper.pdf for an overview of the package functionality and potential use cases.  

To demo the package, see vignettes/textNet_vignette_2025.pdf for a reproducible example that transforms raw text data into event networks.

# Installation

Downloading packages from Github requires creating a Personal Access Token (PAT). Instructions here: https://github.com/orgs/community/discussions/140956

For troubleshooting common problems with PAT, see: https://stackoverflow.com/questions/70908295/failed-to-install-unknown-package-from-github 

You will also need RTools, if not already installed: https://cran.r-project.org/bin/windows/Rtools/

Install the `pak` package if you don't already have it:

```
install.packages("pak")
```

Then install textNet from GitHub:

```
pak::pak('ucd-cepb/textNet')
```

Alternatively, clone this repo and install from within the project directory:

```
pak::local_install()
```

# Suggested packages
The primary function, textnet_extract(), can be used without the use of spaCy, if the user prefers to import compatible data from a separate tool. A wrapper of the spacyr package is included for convenience, to enable preprocessing in-house. Use of this functionality requires installation of the reticulate and spacyr packages, as seen below. Use of the spacyr wrapper 'parse_text' also requires installing spaCy and the 'en_core_web_lg' model (see below). 

```
pak::pak(c("reticulate", "spacyr"))
library(spacyr)
spacy_install()
spacy_download_langmodel('en_core_web_lg')
```
Users of spaCy may encounter a variety of unique challenges with this process based on their particular computer setup. For assistance and guidance with common spaCy challenges, please see the spacyr documentation page: https://spacyr.quanteda.io/index.html, the spacy_install documentation page: https://spacyr.quanteda.io/reference/spacy_install.html and the spacyr README: https://cran.r-project.org/web/packages/spacyr/readme/README.html. Windows users experiencing challenges with permissions or access may benefit from this forum post: https://stackoverflow.com/questions/56974927/permission-denied-trying-to-run-python-on-windows-10

A wrapper of pdftools is also included for convenience. Use of this wrapper 'pdf_clean' requires installation of pdftools, which in turn requires the poppler library. 
On Ubuntu/Debian: sudo apt-get install libpoppler-cpp-dev
On macOS: brew install poppler
On Windows (in Anaconda Prompt): conda install conda-forge::poppler
For support and troubleshooting on pdftools and/or poppler, please visit the pdftools documentation page: https://www.rdocumentation.org/packages/pdftools/versions/3.7.0/topics/pdftools
and the poppler website: https://poppler.freedesktop.org/

# Guidelines for Contributions and Testing
See CONTRIBUTING.md for guidelines for working on this package. Note: testing of test-pdf_clean.R requires installation of poppler and pdftools (see above).

# Contact

Elise Zufall ezufall at ucdavis dot edu

Tyler Scott tascott at ucdavis dot edu

