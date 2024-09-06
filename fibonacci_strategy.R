# Transcrip: https://you.com/search?q=1+-+Propose+an+R+code+implementation+of+a+fibonacci+trading+strategy%2C+use+tidyverse+syntax.%0A2+-...&cid=c1_dbedb8f7-6893-4799-97be-5b710d24ed0e&tbm=youchat

library(tidyverse)
library(tidyquant)

fibonacci_strategy <- function(data, fib_levels = c(0.236, 0.382, 0.5, 0.618), lookback = 20) {
  data %>%
    mutate(
      price_diff = c(0, diff(adjusted)),
      highs = price_diff > 0 & lag(price_diff, default = 0) < 0,
      lows = price_diff < 0 & lag(price_diff, default = 0) > 0
    ) %>%
    mutate(
      last_high = ifelse(highs, row_number(), NA_integer_),
      last_low = ifelse(lows, row_number(), NA_integer_)
    ) %>%
    fill(last_high, last_low, .direction = "down") %>%
    mutate(
      price_range_high = adjusted - adjusted[last_low],
      price_range_low = adjusted[last_high] - adjusted,
      signals = case_when(
        row_number() <= lookback ~ 0,
        highs ~ ifelse(adjusted < (adjusted - fib_levels * price_range_high), 1, 0),
        lows ~ ifelse(adjusted > (adjusted + fib_levels * price_range_low), -1, 0),
        TRUE ~ 0
      )
    ) %>%
    pull(signals)
}

# Get NVIDIA data using tidyquant
NVDA <- tq_get("NVDA", from = "2022-01-01", to = Sys.Date())

# Apply the strategy
NVDA$signals <- fibonacci_strategy(NVDA)

# View the results
tail(NVDA)

# Plot the closing prices and trading signals
ggplot(NVDA, aes(x = date, y = adjusted)) +
  geom_line() +
  geom_point(data = NVDA[NVDA$signals == 1, ], aes(color = "Buy")) +
  geom_point(data = NVDA[NVDA$signals == -1, ], aes(color = "Sell")) +
  labs(title = "Fibonacci Strategy for NVIDIA", y = "Adjusted Price", x = "Date",
       color = "Signal") +
  theme_minimal()
