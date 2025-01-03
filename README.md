### **Objective**
Create a system to recommend stocks to users based on their investment profiles, market trends, and historical stock performance, leveraging data from structured CSV files.

---

### **Detailed Workflow**

#### **1. Data Preparation**

- **Data Sources**:
  - **Stock Overview CSV**: Contains general stock information with columns:
    - `Symbol`: Unique identifier for the stock.
    - `Name`: Full name of the company.
    - `Market Cap`: Market capitalization value.
    - `Country`: The country where the company is based.
    - `Sector`: The economic sector the company operates in.
    - `Industry`: The specific industry within the sector.
    - `Move`: A categorical column with values: `strong-buy`, `buy`, `hold`, `sell`, `strong-sell`.
  - **Stock Price History CSV**: Contains historical prices with columns:
    - `Symbol`: Matches with the stock overview data.
    - `day1, day2, ..., dayN`: Daily stock prices for the past 5 years.

- **Data Preprocessing**:
  - **Stock Overview**:
    - Encode `Move` as numerical categories (e.g., `strong-buy` = 5, ..., `strong-sell` = 1).
    - Normalize `Market Cap` to handle scale differences.
    - Standardize categorical columns (e.g., `Sector`, `Industry`, `Country`) using one-hot encoding.
  - **Stock Price History**:
    - Calculate additional features such as:
      - **Daily Returns**: Percentage change between consecutive days.
      - **Volatility**: Standard deviation of daily returns over specific periods (e.g., weeks, months).
      - **Trend Indicators**: Moving averages (e.g., 50-day, 200-day).
      - **Momentum**: Relative strength index (RSI) and other technical indicators.
  - Merge the two datasets on the `Symbol` column to create a comprehensive dataset for analysis.

---

#### **2. System Components**

##### **A. Naïve Bayes Classifier**

- **Purpose**: Classify stocks based on user preferences and investment goals.
- **Feature Set**:
  - From Stock Overview CSV:
    - `Market Cap`, `Sector`, `Industry`, `Country`, and encoded `Move`.
  - From Stock Price History CSV:
    - Historical performance features such as volatility, daily returns, and trend indicators.
- **Training Data**:
  - Use historical user transactions ("liked" or "disliked" stocks) to label training examples.
- **Output**:
  - Probability that a stock matches a user’s preferences (e.g., `P(Recommended | Stock Features)`).
- **Example**:
  - A tech stock with high growth potential (based on price history) and a "strong-buy" Move rating might have a high recommendation score for a user seeking high-growth investments.

##### **B. Bloom Filter**

- **Purpose**: Efficiently filter out stocks that the user has already interacted with (bought, sold, or rejected).
- **Implementation**:
  - Hash stock `Symbol` values from the user's portfolio or watchlist.
  - Quickly check if a stock has already been recommended to avoid duplication.
- **Benefits**:
  - Saves computational resources.
  - Enhances user experience by avoiding redundant recommendations.

##### **C. MinHash for Similarity Detection**

- **Purpose**: Identify stocks similar to the user’s past preferences or portfolio.
- **Steps**:
  - Represent each stock as a set of attributes (e.g., sector, risk level, and derived metrics like trend indicators).
  - Convert attributes into "shingles" (e.g., strings or n-grams).
  - Generate MinHash signatures for each stock.
  - Compare MinHash signatures to find stocks with high similarity to those the user owns or prefers.
- **Use Case**:
  - If a user holds Stock A, the system could recommend Stock B with similar volatility and trend patterns from the same sector.

---

#### **3. Integration of Components**

- **Step 1: Initial Filtering**
  - Remove already owned/rejected stocks using the Bloom Filter.
- **Step 2: Classification**
  - Use Naïve Bayes to calculate the probability of recommending each remaining stock based on user preferences and features from both CSV files.
- **Step 3: Similarity Matching**
  - Apply MinHash to identify stocks that are similar to those the user has interacted with positively.
- **Step 4: Ranking**
  - Combine Naïve Bayes probabilities and similarity scores to rank the stocks.
- **Step 5: Final Recommendation**
  - Present the top-ranked stocks to the user, along with justifications (e.g., "Recommended because it is similar to Stock X and aligns with your preference for high-growth tech stocks").

---

### **Example Workflow**

1. **Input**:
   - User: "I prefer high-growth, tech-focused stocks."
   - Current Portfolio: Stocks A, B, C.
2. **Bloom Filter**:
   - Stocks A, B, C excluded from recommendations.
3. **Naïve Bayes**:
   - Classifies stocks based on `Sector`, `Industry`, `Move`, and derived metrics (e.g., volatility, returns).
4. **MinHash**:
   - Identifies stocks D and E as similar to Stock A based on shared attributes and trends.
5. **Output**:
   - Recommends Stocks D, E, and F, ranked by their likelihood of matching the user’s preferences.

---

### **Extensions and Improvements**

- **Dynamic Updates**: Incorporate real-time stock price and news updates for recommendations.
- **Explainable AI**: Provide users with clear reasons for each recommendation.
- **User Feedback Loop**: Allow users to rate recommendations to improve the system over time.

