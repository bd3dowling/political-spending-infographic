library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggrepel)
library(here)
library(arrow)
library(scales)
library(patchwork)

custom_theme <- theme_economist() +
  theme(
    plot.title = element_text(size = 30, face = "bold"),
    plot.subtitle = element_text(
      size = 24,
      hjust = 0,
      margin = margin(t = 10, r = 0, b = 10, l = 0)
    ),
  )

theme_set(custom_theme)

# Data loading

min_date <- "1979-01-01"
max_date <- "1981-01-01"

df <- here("data", "parquets", "analysis__federal_senate_general.parquet") %>%
  read_parquet() %>%
  filter(contribution_date >= min_date, contribution_date <= max_date) %>%
  mutate()

# Line chart (cumulative contribution amount over time)

# customer label function to place years beneath first month on x-axis;
# months are just by their first letter
# TODO: create package
line_labeller <- function(dates) {
  # Get first letter of month
  labels <- paste0(substr(months(dates, abbreviate = TRUE), 1, 1), "\n")
  years <- format(dates, "%y") # Format years to get the last two digits
  full_years <- format(dates, "    %Y") # Format years to get all four digits
  unique_years <- unique(years)

  # Ensure that we handle the first year differently
  first_year_full <- TRUE

  for (year in unique_years) {
    # Find the first occurrence of each year
    first_index <- which(years == year)[1]

    if (first_year_full) {
      # For the first year, use the full year format
      labels[first_index] <- paste0(labels[first_index], full_years[first_index])
      first_year_full <- FALSE # Set to FALSE after processing the first year
    } else {
      # For subsequent years, use the two-digit year format
      labels[first_index] <- paste0(labels[first_index], year)
    }
  }

  return(labels)
}

line_df <- df %>%
  arrange(candidate_party, contribution_date) %>%
  group_by(candidate_party) %>%
  mutate(cumulative_contribution_amount = cumsum(contribution_amount)) %>%
  ungroup()

line_chart <- line_df %>%
  ggplot(
    aes(
      x = contribution_date,
      y = cumulative_contribution_amount,
      color = candidate_party
    )
  ) +
  geom_line(linewidth = 3) +
  # Set x axis; min-max date, year under January
  scale_x_date(
    breaks = seq(as.Date(min_date), as.Date(max_date), by = "month"),
    labels = line_labeller,
    expand = c(0.025, 0)
  ) +
  # Set y axis; right hand side, scaled down to millions of dollars
  scale_y_continuous(
    labels = dollar_format(scale = 1e-3, accuracy = 1, prefix = ""),
    position = "right",
    expand = c(-0.005, 0, 0.05, 0)
  ) +
  scale_color_manual(
    values = c("democrat" = "#006BA2", "republican" = "#DB444B"),
    labels = c("Democrat", "Republican")
  ) +
  labs(
    title = "When's it coming?",
    subtitle = "Cumulative contributions over the election cycle, $'000",
    color = "Party"
  ) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(size = 20),
    axis.text.y = element_text(vjust = -0.75, size = 20),
    legend.title = element_text(size = 24),
    legend.title.align = 0.5,
    legend.text = element_text(size = 20),
    legend.key.size = unit(3, "lines"),
    plot.title = element_text(
      size = 26,
      face = "bold",
      margin = margin(t = 5, r = 0, b = 0, l = 0)
    ),
    panel.grid.major = element_line(color = "darkgrey"),
    axis.ticks.length = unit(10, "pt") # Change the length of tick marks
  )

# Scatter

source_state_df <- df %>%
  rename(state = contributor_state) %>%
  group_by(state) %>%
  summarise(source_amount = sum(contribution_amount))

target_state_df <- df %>%
  rename(state = candidate_state) %>%
  group_by(state) %>%
  summarise(target_amount = sum(contribution_amount))

scatter_df <- source_state_df %>%
  full_join(target_state_df, by = "state") %>%
  # Filter out states for which there is not a senate election
  filter(!is.na(target_amount))

scatter_labels <- c(
  "NJ", "AR", "TX", "CT"
)

scatter_chart <- scatter_df %>%
  ggplot(aes(x = source_amount, y = target_amount, group = state)) +
  geom_point(
    shape = 21,
    fill = "#3EBCD2",
    color = "#3EBCD2",
    size = 4,
    stroke = 1.5
  ) +
  geom_text(
    data = filter(scatter_df, state %in% scatter_labels),
    aes(label = state),
    vjust = -0.8,
    size = 6
  ) +
  scale_x_continuous(
    labels = dollar_format(scale = 1e-3, accuracy = 1, prefix = ""),
    expand = c(0.1, 0, 0.075, 0)
  ) +
  scale_y_continuous(
    labels = dollar_format(scale = 1e-3, accuracy = 1, prefix = ""),
    position = "right",
    expand = c(0.065, 0, 0.15, 0)
  ) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  geom_hline(yintercept = 0, color = "#E3120B") +
  geom_vline(xintercept = 0, color = "#E3120B") +
  labs(
    title = "Where's it going and where's it coming from?",
    subtitle = "Total contributions by source state and target state",
    x = "Contributed, $'000",
    y = "Received, $'000"
  ) +
  theme(
    axis.text.x = element_text(size = 20),
    axis.text.y = element_text(vjust = -0.75, size = 20),
    legend.key.size = unit(3, "lines"),
    panel.grid.major.x = element_line(color = "darkgrey", linewidth = 1),
    panel.grid.major.y = element_line(color = "darkgrey", linewidth = 1),
    axis.ticks.length = unit(10, "pt"),
    axis.title.x = element_text(
      size = 24,
      margin = margin(t = 20, r = 0, b = 10, l = 0)
    ),
    axis.title.y.right = element_text(
      size = 24,
      margin = margin(t = 0, r = 10, b = 0, l = 10)
    ),
    panel.border = element_rect(colour = "darkgrey", fill = NA, linewidth = 2),
    plot.margin = margin(5.5, 5.5, 5.5, 5.5, "points"),
    plot.title = element_text(
      size = 26,
      face = "bold",
      margin = margin(t = 5, r = 0, b = 0, l = 0)
    ),
  )

# Donut chart (total contribution amount from indivs/orgs by party)

donut_chart <- df %>%
  mutate(
    contributor_type = ifelse(
      contributor_is_individual,
      "Individual",
      "Organisation"
    )
  ) %>%
  group_by(contributor_type, candidate_party) %>%
  summarise(
    contribution_amount = sum(contribution_amount),
    .groups = "drop_last"
  ) %>%
  mutate(
    # Compute percentages
    fraction = contribution_amount / sum(contribution_amount),
    # Compute the cumulative percentages (top of each rectangle)
    ymax = cumsum(fraction),
    # Compute the bottom of each rectangle
    ymin = c(0, head(ymax, n = -1)),
    # Compute label positions
    label_position = (ymax + ymin) / 2,
    label = paste(
      tools::toTitleCase(candidate_party),
      dollar(contribution_amount, scale = 1e-6, suffix = "M"),
      sep = "\n"
    )
  ) %>%
  ggplot(
    aes(ymax = ymax, ymin = ymin, xmax = 4, xmin = 3, fill = candidate_party)
  ) +
  geom_rect() +
  geom_label(
    aes(y = label_position, label = label),
    x = 3,
    size = 6,
    color = "white"
  ) +
  coord_polar(theta = "y") +
  xlim(c(0, 4)) +
  facet_wrap(~contributor_type, nrow = 1) +
  labs(
    title = "Who's it coming from?",
    subtitle = "Individual contribution amount ratios by party"
  ) +
  scale_color_manual(
    values = c("democrat" = "#006BA2", "republican" = "#DB444B"),
    labels = c("Democrat", "Republican")
  ) +
  scale_fill_manual(
    values = c("democrat" = "#006BA2", "republican" = "#DB444B"),
    labels = c("Democrat", "Republican")
  ) +
  theme(
    legend.position = "none",
    strip.text = element_text(size = 28),
    strip.clip = "off",
    panel.spacing = unit(0.1, "lines"),
    axis.line = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    plot.subtitle = element_text(
      size = 24,
      hjust = 0,
      margin = margin(t = 10, r = 0, b = 20, l = 0)
    ),
    plot.title = element_text(
      size = 26,
      face = "bold",
      margin = margin(t = 5, r = 0, b = 0, l = 0)
    ),
  )

# Infographic generation

infographic <- line_chart /
  scatter_chart /
  donut_chart +
  plot_annotation(
    title = "Political Contributions in the 1980 Election Cycle",
    caption = paste(
      "Bonica, Adam. 2023. Database on Ideology, Money in Politics, and Elections: Public version 3.1 [Computer file].",
      "Stanford, CA: Stanford University Libraries. https://data.stanford.edu/dime.",
      sep = "\n"
    )
  )

ggsave(
  here("output", "1980_senate_contributions_infographic.pdf"),
  infographic,
  width = unit(20, "cm"),
  height = unit(24, "cm")
)
