library(tidyverse)
library(tidyquant)
library(PerformanceAnalytics)

# Define the stocks
symbols <- c("AAPL", "MSFT", "NVDA", "F", "GM", "TSLA") 

# Download historical data (replace with your preferred source if needed)
start_date <- "2020-01-01"
end_date <- "2023-11-24" 
data <- tq_get(symbols,
               from = start_date,
               to = end_date,
               get = "stock.prices")

# Calculate moving averages
calculate_ma_strategy <- function(data, short_window, long_window) {
  data %>%
    group_by(symbol) %>%
    mutate(short_ma = SMA(adjusted, n = short_window),
           long_ma = SMA(adjusted, n = long_window)) %>%
    mutate(signal = case_when(short_ma > long_ma ~ "buy",
                              short_ma < long_ma ~ "sell",
                              TRUE ~ "hold")) 
}

# Apply the strategy
short_window <- 20
long_window <- 50 
data_with_signals <- data %>% 
  calculate_ma_strategy(short_window, long_window)

#### **2. Applying the Strategy (AAPL, MSFT, NVDA, F, GM)**

# ... using the data_with_signals generated above

#### **3. Plotting the Strategy**

# Plotting for AAPL as an example
ggplot(data_with_signals, aes(x = date, y = adjusted)) +
  facet_wrap(~symbol, scales = "free_y") +
  geom_line() +
  geom_line(aes(y = short_ma), color = "blue") +
  geom_line(aes(y = long_ma), color = "red") +
  labs(title = "Moving Average Trading Strategy for: AAPL, MSFT, NVDA, F, GM, TSLA",
       x = "Date",
       y = "Adjusted Price") +
  theme_minimal() 

get_first_signals <- function(data) {
  data %>%
    group_by(symbol) %>%
    mutate(previous_signal = lag(signal, default = "hold")) %>%
    filter(signal != previous_signal) %>%
    select(-previous_signal)
}

first_signals <- data_with_signals %>% 
  get_first_signals()

# Plotting for AAPL as an example
ggplot(data_with_signals, aes(x = date, y = adjusted)) +
  facet_wrap(~symbol, scales = "free_y") +
  geom_line() +
  geom_line(aes(y = short_ma), color = "blue") +
  geom_line(aes(y = long_ma), color = "red") +
  geom_point(data = first_signals %>% filter(signal == "buy"), 
             color = "green", size = 3) +
  geom_point(data = first_signals %>% filter(signal == "sell"), 
             color = "red", size = 3) +
  labs(title = "Moving Average Trading Strategy for: AAPL, MSFT, NVDA, F, GM",
       x = "Date",
       y = "Adjusted Price") +
  theme_minimal() 

# Repeat for other stocks by changing the symbol in the filter

#### **4. Additional Notes**

#- This code provides a basic framework. You can adjust the `short_window`, `long_window`, and `start_date` to experiment with different parameters.
#- Backtesting with historical data is a good starting point, but keep in mind that past performance does not guarantee future returns.
#- Consider adding risk management rules and transaction costs to your strategy for a more realistic evaluation.

#Let me know if you have any specific aspects you'd like to explore further!
