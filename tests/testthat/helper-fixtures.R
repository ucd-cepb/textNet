
# Shared test fixtures loaded automatically by testthat before all test files.

# Domain vocabulary used in parsing and extraction tests.
# These are water-body phrases concatenated by parse_text() and treated as
# custom WATER entities by textnet_extract().
water_bodies <- c(
  "surface water", "Surface water", "groundwater", "Groundwater",
  "San Joaquin River", "Cottonwood Creek", "Chowchilla Canal Bypass",
  "Friant Dam", "Sack Dam", "Friant Canal", "Chowchilla Bypass",
  "Fresno River", "Sacramento River", "Merced River", "Chowchilla River",
  "Bass Lake", "Crane Valley Dam", "Willow Creek", "Millerton Lake",
  "Mammoth Pool", "Dam 6 Lake", "Delta", "Tulare Lake",
  "Madera-Chowchilla canal", "lower aquifer", "upper aquifer",
  "upper and lower aquifers", "lower and upper aquifers",
  "Lower aquifer", "Upper aquifer", "Upper and lower aquifers",
  "Lower and upper aquifers"
)

# Entity types retained during extraction
ent_types <- c("ORG", "GPE", "PERSON", "WATER")
