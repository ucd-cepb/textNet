# Working on this package

Use the following workflow to contribute to this package.

The `main` branch holds the latest release, and development happens on the `dev` branch. Base your work on `dev` and submit pull requests against `dev`. Changes reach `main` only when a new version is released.

1. Fork this repository.
1. Clone your fork.
1. Create a new branch from `dev` with your contribution.
1. Run `devtools::load_all()` to test your changes to the code.
1. Thoroughly update documentation for any changes made. To update documentation and NAMESPACE file `devtools::document()`.
1. Test the installation. To reinstall the package: `pak::local_install()`.
Note that the vignettes both end up slightly larger than `devtools::check()` prefers, so running as `devtools::check(build_args = "--compact-vignettes=both")` is preferred.
1. Conduct tests of the new functionality using `testthat`. 
1. Increment the development version number, i.e. the fourth component (`1.1.1.9000` becomes `1.1.1.9001`), for example with `usethis::use_dev_version()`. Do not change the release number; that is done only at release time.
1. Add a bullet describing your change under the `# textNet (development version)` heading in NEWS.md.
1. Stage and commit your changes with clear commit descriptions, then push to GitHub.
1. Submit a Pull Request against the `dev` branch of this repo, including a clear description of the alterations.

# Releasing a new version

1. On `dev`, drop the `.9000` suffix from the version in DESCRIPTION (e.g., `1.2.0`) and rename the NEWS heading to match (`# textNet 1.2.0`).
1. Run `devtools::check()` and confirm it passes.
1. Merge `dev` into `main`, tag the merge commit (e.g., `v1.2.0`), and publish a GitHub Release from the tag.
1. On `dev`, run `usethis::use_dev_version()` to start the next development version.

# Code style/formatting standards

Please minimize imports of additional functions. Where additional functions are necessary, please consider suggesting rather than importing functions. 

Use descriptive variable names in lower_snake_case, and provide descriptive comments to help users understand the new functionality.

Functions are documented with roxygen2. Please fully document any new changes before submitting a pull request.

# Testing requirements

This package uses `testthat` to test functionality against expected behavior.

See the tests folder for the existing test suite. When submitting a pull request, please demonstrate its functionality by including a testing file in the tests folder explaining its usage and incorporating relevant checks.

# Reporting bugs

Please ensure you are using the latest version of `textNet` and check existing [issues](https://github.com/ucd-cepb/textNet/issues) to ensure there is not already an existing bug report for your issue. 

Please use the [bug report template](https://github.com/ucd-cepb/textNet/tree/main/.github/issue_templates/bug_report.md) when reporting a bug.

# Asking questions and getting support

Before asking a question, please search for existing issues that may be relevant, and please ensure your question is not already addressed in the vignette or function documentation. If you still need clarification, please open an issue, with as much context as possible, including the output of `sessionInfo()`.

# Feature request template

Please use the [feature request template](https://github.com/ucd-cepb/textNet/tree/main/.github/issue_templates/feature_request.md) to request a feature. Please include a clear, complete description of the requested feature, as well as a step-by-step explanation of the enhancement. Include an explanation of the utility for the general user of the requested feature.
