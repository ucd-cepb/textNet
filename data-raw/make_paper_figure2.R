library(textNet)
library(ggraph)
library(ggplot2)
library(data.table)

# Load sample data
old_new_parsed <- textNet::old_new_parsed
old_new_text   <- textNet::old_new_text

# 2nd list item is the new network
extracts <- vector(mode = "list", length = length(old_new_parsed))
m <- 2
extracts <- textnet_extract(old_new_parsed[[m]],
                                   keep_entities = c("ORG", "GPE", "PERSON", "WATER"),
                                   keep_incomplete_edges = TRUE)

# Acronym-based disambiguation
new_acronyms <- find_acronyms(old_new_text[[m]])

tofrom_new <- data.table::data.table(
  from = c(as.list(new_acronyms$acronym),
           list("Sub_basin", "Sub_Basin",
                "upper_and_lower_aquifers", "Upper_and_lower_aquifers",
                "Lower_and_upper_aquifers", "lower_and_upper_aquifers")),
  to   = c(as.list(new_acronyms$name),
           list("Subbasin", "Subbasin",
                c("upper_aquifer", "lower_aquifer"),
                c("upper_aquifer", "lower_aquifer"),
                c("upper_aquifer", "lower_aquifer"),
                c("upper_aquifer", "lower_aquifer"))))

new_extract_clean <- disambiguate(
  textnet_extract      = extracts,
  from                 = tofrom_new$from,
  to                   = tofrom_new$to,
  match_partial_entity = c(rep(FALSE, nrow(new_acronyms)), TRUE, TRUE, FALSE, FALSE, FALSE, FALSE))

# Build weighted igraph for plotting
set.seed(50000)
new_extract_plot <- export_to_network(new_extract_clean, "igraph",
                                      keep_isolates  = FALSE,
                                      collapse_edges = TRUE,
                                      self_loops     = TRUE)[[1]]

# Generate figure 2
set.seed(50000)
p <- ggraph(new_extract_plot, layout = "fr") +
  geom_edge_fan(aes(alpha = weight),
                end_cap = circle(1, "mm"),
                color   = "#000000",
                width   = 0.3,
                arrow   = arrow(angle = 15, length = unit(0.07, "inches"),
                                ends = "last", type = "closed")) +
  scale_color_manual(values = c("#4477AA", "#228833", "#CCBB44", "#66CCEE")) +
  geom_node_point(aes(color = entity_type), size = 1, alpha = 0.8) +
  labs(title = "New Network") +
  theme_void()

out_dir <- "paper/paper_figures"  # relative to project root

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(out_dir, "figure2_new_network.png"), plot = p,
       width = 6, height = 5, dpi = 300)

message("Saved: ", file.path(out_dir, "figure2_new_network.png"))
