AI Trading Strategies in R
================

## Purpose

This repository contains R code implementations of two popular trading
strategies: the Fibonacci trading strategy and the momentum trading
strategy. Both strategies are implemented using the `tidyverse` syntax
and are demonstrated on historical stock price data for NVIDIA (NVDA).

More will come and I encourage you to contribute to this repository by
adding more trading strategies or improving the existing ones.

This document will evolve over time.

## Strategy 1: Fibonacci Trading Strategy

The Fibonacci trading strategy is a technical analysis strategy that
uses Fibonacci retracement levels to identify potential buy and sell
points in a financial instrument. The strategy is based on the idea that
markets tend to retrace a portion of a previous move before continuing
in the direction of the trend.

The Fibonacci trading strategy is implemented in the
`fibonacci_strategy()` function in the `fibonacci_strategy.R` script.
The function takes a data frame of historical prices and a lookback
period as input and returns a data frame with trading signals based on
Fibonacci retracement levels.

Each file has as it’s first line a comment that starts with `Transcrip:`
and contains a URL to the original question. This is useful to keep
track of the source of the code snippet.

Here is an example of how to apply the Fibonacci trading strategy to
NVIDIA stock price data:

``` r
library(tidyverse)
library(tidyquant)

source("fibonacci_strategy.R")

# Get NVIDIA data using tidyquant
NVDA <- tq_get("NVDA", from = "2024-01-01", to = Sys.Date())

# Apply the strategy
NVDA$signals <- fibonacci_strategy(NVDA)

# View the results
tail(NVDA)
#> # A tibble: 6 × 9
#>   symbol date        open  high   low close    volume adjusted signals
#>   <chr>  <date>     <dbl> <dbl> <dbl> <dbl>     <dbl>    <dbl>   <dbl>
#> 1 NVDA   2024-08-28  128.  128.  123.  126. 448101100     126.       0
#> 2 NVDA   2024-08-29  121.  124.  117.  118. 453023300     118.       0
#> 3 NVDA   2024-08-30  120.  122.  117.  119. 333751600     119.       1
#> 4 NVDA   2024-09-03  116.  116.  107.  108  474040800     108        0
#> 5 NVDA   2024-09-04  105.  113.  104.  106. 372470300     106.       0
#> 6 NVDA   2024-09-05  105.  110.  105.  107. 305774900     107.       1

# Plot the closing prices and trading signals
ggplot(NVDA, aes(x = date, y = adjusted)) +
  geom_line() +
  geom_point(data = NVDA[NVDA$signals == 1, ], aes(color = "Buy")) +
  geom_point(data = NVDA[NVDA$signals == -1, ], aes(color = "Sell")) +
  labs(title = "Fibonacci Strategy for NVIDIA", y = "Adjusted Price", x = "Date",
       color = "Signal") +
  theme_minimal()
```

<img src="man/figures/README-fibonacci-strategy-1.png" width="100%" />

## Strategy 2: Momentum Trading Strategy

The momentum trading strategy is a trend-following strategy that aims to
capture gains in a financial instrument by buying when the price is
rising and selling when the price is falling. The strategy is based on
the idea that assets that have performed well in the past will continue
to perform well in the future.

The momentum trading strategy is implemented in the
`momentum_strategy()` function in the `momentum_strategy.R` script. The
function takes a data frame of historical prices and a lookback period
as input and returns a data frame with trading signals based on momentum
indicators.

Here is an example of how to apply the momentum trading strategy to
NVIDIA stock price data:

``` r
source("momentum_strategy.R")

# Get NVIDIA data using tidyquant
NVDA <- tq_get("NVDA", from = "2020-01-01", to = Sys.Date())

# Apply the strategy
NVDA_strategy <- momentum_strategy(NVDA, short_window = 20)

# View the results
tail(NVDA_strategy)
#> # A tibble: 6 × 11
#>   symbol date        open  high   low close    volume adjusted short_ma long_ma
#>   <chr>  <date>     <dbl> <dbl> <dbl> <dbl>     <dbl>    <dbl>    <dbl>   <dbl>
#> 1 NVDA   2024-08-28  128.  128.  123.  126. 448101100     126.     117.    116.
#> 2 NVDA   2024-08-29  121.  124.  117.  118. 453023300     118.     117.    116.
#> 3 NVDA   2024-08-30  120.  122.  117.  119. 333751600     119.     118.    116.
#> 4 NVDA   2024-09-03  116.  116.  107.  108  474040800     108      118.    116.
#> 5 NVDA   2024-09-04  105.  113.  104.  106. 372470300     106.     118.    117.
#> 6 NVDA   2024-09-05  105.  110.  105.  107. 305774900     107.     119.    117.
#> # ℹ 1 more variable: signal <chr>

# Create a data frame for buy/sell points with colors
buy_sell_points <- NVDA_strategy %>%
  filter(signal != lag(signal, default = "hold")) %>%
  select(date, signal) %>%
  mutate(color = ifelse(signal == "buy", "green", "red"))

ggplot(NVDA_strategy, aes(x = date, y = adjusted)) +
  geom_line() +
  geom_line(aes(y = short_ma), color = "blue", linetype = "dashed") +
  geom_line(aes(y = long_ma), color = "red", linetype = "dashed") +
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
```

<img src="man/figures/README-momentum-strategy-1.png" width="100%" />
