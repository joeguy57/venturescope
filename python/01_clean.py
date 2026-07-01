import pandas as pd
import numpy as np
import warnings

warnings.filterwarnings("ignore", category=FutureWarning)

# Load raw data
raw_data = pd.read_csv("data/crunchbase_raw.csv", encoding="latin-1", low_memory=False)

print(f"Raw data shape: {raw_data.shape}\n")
print(f"Raw data columns: {raw_data.columns.tolist()}\n")
print(f"Null counts:\n{raw_data.isnull().sum()}\n")
print(f"Status values:\n{raw_data['status'].value_counts(dropna=False)}\n")
print(f"Sample funding_total_usd values:\n{raw_data[' funding_total_usd '].head(10)}\n")

# lowercase, strip whitespace, replace spaces with underscores, and remove special characters from column names
raw_data.columns = (raw_data.columns.str.lower()
                    .str.strip()
                    .str.replace(" ", "_")
                    .str.replace("[^a-zA-Z0-9_]", "", regex=True))

# Rename abmiguous columns to clearer names

df = raw_data.rename(columns={
    "permalink": "crunchbase_url",
    "name": "company_name",
    "homepage_url": "website",
    "category_list": "categories_raw",
    "funding_total_usd": "total_funding_usd",
    "country_code": "country",
    "state_code": "state",
    "founded_at": "founded_date",
    "first_funding_at": "first_funding_date",
    "last_funding_at": "last_funding_date",
})