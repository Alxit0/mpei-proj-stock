from datetime import datetime, timedelta
import os
import pandas as pd
import requests

# classes
class Stock:
    _image_cache = {}

    def __init__(self, symbol: str, name: str, value: float, currency: str, history: pd.DataFrame) -> None:
        self.symbol = symbol
        self.name = name
        self.value = value
        self.currency = currency
        self.history = history
    
    def image_url(self):
        if self.symbol in self._image_cache:
            return self._image_cache[self.symbol]

        base_url = f"https://trading212equities.s3.eu-central-1.amazonaws.com/"
        possible_suffixes = [".png", "_US_EQ.png", "_EQ.png", "CA_EQ.png"]

        for suffix in possible_suffixes:
            url = base_url + f"{self.symbol}{suffix}"
            response = requests.head(url)
            if response.status_code == 200:
                self._image_cache[self.symbol] = url
                return url

        self._image_cache[self.symbol] = None
        return None


def default_data_file(file_path):
    if not os.path.isfile(file_path):
        with open(file_path, 'x') as f:
            f.write("{}")

def calculate_start_date(range: str):
    """Function to calculate start date based on range

    Args:
        range (str): time range

    Returns:
        _Date: date of today minus the range
    """

    today = datetime.today().date()
    
    if range.endswith('d'):
        days = int(range[:-1])
        return today - timedelta(days=days)
    elif range.endswith('m'):
        months = int(range[:-1])
        return today.replace() - pd.DateOffset(months=months)
    elif range.endswith('y'):
        years = int(range[:-1])
        return today.replace() - pd.DateOffset(years=years)
