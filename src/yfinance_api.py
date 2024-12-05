import json
import logging
import os
from typing import Set
import pandas as pd
import requests
import yfinance as yf
from tqdm import tqdm

# util
def merge_csvs(f1: str, f2: str, default=None):
    # Load the two CSV files into Pandas DataFrames
    df1 = pd.read_csv(f1)

    try:
        df2 = pd.read_csv(f2)
    except pd.errors.EmptyDataError:
        return

    # Concatenate the two DataFrames while aligning columns
    combined_df = pd.concat([df1, df2], ignore_index=True, sort=False)

    # If you want to handle missing values by replacing with `default`
    if default is not None:
        combined_df.fillna(default, inplace=True)

    # Save the merged data to a new CSV file
    combined_df.to_csv(f1, index=False)


# symbols functions
def get_all_symbols(n: int, start:int=0) -> Set[str]:
    a = pd.read_csv('./nasdaq_screener_1732918253375.csv')

    a = a.sort_values(by='Market Cap', ascending=False)
    
    return set(a['Symbol'].to_list()[start:start+n])

def get_downloaded_symbols(file: str) -> Set[str]:
    a = pd.read_csv(file)
    
    return set(a['Symbol'].to_list())


# data functions
def get_companys_info(symbols):
    # Fetch the company data using the ticker symbols
    tickers = yf.Tickers(" ".join(symbols))
    logging.getLogger('yfinance').setLevel(logging.CRITICAL)

    
    company_info_list = []

    for symbol in tqdm(symbols):
        company = tickers.tickers[symbol]
        
        # Retrieve the company info
        try:
            info = company.info
        except json.decoder.JSONDecodeError:
            tqdm.write(f"Request Limit ...")
            break

        except Exception as e:
            tqdm.write(f"Error {symbol} ({type(e)}): {e}")
            info = {}

        # Extract relevant fields from the info
        company_info = {
            'Symbol': symbol,
            'Security': info.get('longName', 'N/A'),
            'GICS Sector': info.get('sector', 'N/A'),
            'GICS Sub-Industry': info.get('industry', 'N/A'),
            'Headquarters Location': info.get('city', 'N/A') + ', ' + info.get('country', 'N/A'),
        }
        
        # Add the extracted info to the list
        company_info_list.append(company_info)

    if not company_info_list:
        return

    # Convert the list of dictionaries to a pandas DataFrame
    df = pd.DataFrame(company_info_list)

    return df

def fetch_historical_data_pivot(symbols, period="1y", interval="1d"):
    """
    Fetch historical data for a list of symbols using the Tickers class
    and return it as a pivoted DataFrame.

    :param symbols: List of stock ticker symbols
    :param period: Historical period to fetch (e.g., '1mo', '1y', 'max')
    :param interval: Data interval (e.g., '1d', '1wk', '1mo')
    :return: Pivoted DataFrame with symbols as rows and dates as columns.
    """
    logging.getLogger('yfinance').setLevel(logging.CRITICAL)
    
    # Create a Tickers object for the list of symbols
    tickers = yf.Tickers(" ".join(symbols))

    all_data = []
    max_req_limit_flag = 5

    # Fetch historical data for each symbol
    for symbol in tqdm(symbols):
        try:
            # Fetch historical market data for the symbol
            try:
                data = tickers.tickers[symbol].history(period=period, interval=interval, raise_errors=True)
            except yf.exceptions.YFInvalidPeriodError:
                data = tickers.tickers[symbol].history(period="max", interval=interval)

            if data.empty:
                tqdm.write(f"No data found for {symbol}.")
                continue
            
            data["Symbol"] = symbol
            data.reset_index(inplace=True)
            
            # Format the Date column to only include YYYY-MM-DD
            data["Date"] = data["Date"].dt.strftime("%Y-%m-%d")
            
            # Keep only Date, Symbol, and Close columns
            all_data.append(data[["Date", "Symbol", "Close"]])

        except requests.exceptions.JSONDecodeError as e:
            tqdm.write(f"Error in Json: {e}")
            max_req_limit_flag -= 1

        except Exception as e:
            tqdm.write(f"Error {symbol} ({type(e)}): {e}")
        
        # flag for max request
        if max_req_limit_flag == 0:
            tqdm.write("Max requests limit reached")
            break
        
        max_req_limit_flag = 5

    if not all_data:
        return None

    # Combine all data into a single DataFrame
    combined_data = pd.concat(all_data, ignore_index=True)

    # Pivot data to have symbols as rows and dates as columns
    pivot_table = combined_data.pivot(index="Symbol", columns="Date", values="Close")

    # Round values to 3 decimal places and replace NaN with -1
    pivot_table = pivot_table.round(3).fillna(-1)

    return pivot_table


# main functions
def main_info_data():
    info_file = "company_info.csv"

    symbols = get_all_symbols(1600)
    known_symbols = get_downloaded_symbols(info_file)

    df = get_companys_info(symbols.difference(known_symbols))

    if df is None:
        return

    # Save the DataFrame to a CSV file
    df.to_csv('temp.csv', index=False)

    merge_csvs(info_file, 'temp.csv')

def main_historical_data():
    hist_file = "hist_data.csv"
    n = 3000

    # Check if the hist_file exists
    if not os.path.exists(hist_file):
        pd.DataFrame(columns=["Symbol"]).to_csv(hist_file, index=False)

    # symbols = get_sp500_symbols()
    symbols = get_all_symbols(n)
    known_symbols = get_downloaded_symbols(hist_file)

    # Fetch and pivot historical data
    historical_data = fetch_historical_data_pivot(symbols.difference(known_symbols), '5y')

    if historical_data is None:
        return

    # Save to a single CSV file
    out_file = "./temp.csv"
    historical_data.to_csv(out_file)

    merge_csvs(hist_file, 'temp.csv', default=-1)


def temp():
    file = './company_info.csv'
    
    a = pd.read_csv('./nasdaq_screener_1732918253375.csv', index_col='Symbol')

    a = a.sort_values(by='Market Cap', ascending=False)
    a = a[['Name', 'Market Cap', 'Country', 'Sector', 'Industry']]

    a.to_csv(file)


if __name__ == '__main__':
    # main_info_data()
    main_historical_data()
    # temp()
