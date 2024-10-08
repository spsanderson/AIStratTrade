# Transcript: https://you.com/search?q=you+must+let+the+geom_rect+say+to+not+inherit+aes&cid=c1_02764f53-cf92-4645-ac23-f465df029544&tbm=youchat
# Install and load necessary packages
library(ggplot2)
library(tidyquant)
library(dplyr)

# Define the momentum trading strategy
momentum_strategy <- function(prices, short_window = 50, long_window = short_window * 4) {
  # Calculate short-term and long-term moving averages
  prices <- prices %>%
    mutate(short_ma = SMA(adjusted, n = short_window),
           long_ma = SMA(adjusted, n = long_window))
  
  # Generate trading signals
  prices <- prices %>%
    mutate(signal = case_when(short_ma > long_ma ~ "buy",
                              short_ma < long_ma ~ "sell",
                              TRUE ~ "hold"))
  
  return(prices)
}

# Get NVIDIA's historical prices
NVDA <- tq_get("NVDA",
               from = "2010-01-01",
               to = Sys.Date(),
               get = "stock.prices")

# Apply the momentum trading strategy
NVDA_strategy <- momentum_strategy(NVDA, 52)

# Print the last few rows of the data
tail(NVDA_strategy)

# Create a data frame for buy/sell points with colors
buy_sell_points <- NVDA_strategy %>%
  filter(signal != lag(signal, default = "hold")) %>%
  select(date, signal) %>%
  mutate(color = ifelse(signal == "buy", "green", "red"))

# Create a data frame for shaded regions
shaded_regions <- NVDA_strategy %>%
  mutate(group = cumsum(signal != lag(signal, default = "hold"))) %>%
  group_by(group) %>%
  summarise(start = min(date), end = max(date), signal = first(signal))

# Plot the trading signals with shaded regions
NVDA_strategy %>%
  ggplot(aes(x = date, y = adjusted)) +
  geom_line() +
  geom_line(aes(y = short_ma), color = "blue", linetype = "dashed",
            linewidth = 1) +
  geom_line(aes(y = long_ma), color = "red", linetype = "dashed",
            linewidth = 1) +
  geom_rect(
    data = shaded_regions, 
    aes(
      xmin = start, 
      xmax = end, 
      ymin = 0, 
      ymax = Inf, 
      fill = signal
      ), 
    inherit.aes = FALSE, 
    alpha = 0.328) +
  geom_vline(
    data = buy_sell_points, 
    aes(xintercept = date, color = color),
    linetype = "dashed",
    linewidth = 1
    ) +
  labs(title = "Momentum Trading Strategy for NVIDIA",
       x = "Date",
       y = "Adjusted Price",
       fill = "Signal") +
  theme_minimal() +
  scale_color_identity() +
  # Map fill colors
  scale_fill_manual(values = c("hold" = "white", "buy" = "green", "sell" = "red")) 

