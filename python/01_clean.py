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

# Standardize status values
df["status"] = df["status"].str.lower().str.strip()

# Map to clean labels
status_mapping = {
    "operating": "operating",
    "acquired": "acquired",
    "ipo": "ipo",
    "closed": "closed"
}
df["outcome"] = df["status"].map(status_mapping)

print(f"Outcome distribution:\n{df['outcome'].value_counts(dropna=False)}\n")

def clean_usd(val):
    """Convert funding_total_usd to float, handling commas and missing values."""
    if pd.isnull(val):
        return np.nan
    val = str(val).strip().replace(",", "").replace(" ", "")
    if val in ["-", "", "None", "nan", "N/A"]:
        return np.nan
    try:
        return float(val)
    except ValueError:
        return np.nan
    

# Apply to all funding columns
funding_columns = ["total_funding_usd", "seed", "venture", "equity_crowdfunding", "undisclosed", "convertible_note", "debt_financing", "angel", "grant", "private_equity", "post_ipo_equity", "post_ipo_debt", "secondary_market", "product_crowdfunding", "round_a", "round_b", "round_c", "round_d", "round_e", "round_f", "round_g", "round_h"]

for col in funding_columns:
    if col in df.columns:
        df[col] = df[col].apply(clean_usd)


# Clean Date Columns
from datetime import datetime

def parse_date(val):
    """Parse date strings into datetime objects, handling missing values."""
    if pd.isna(val) or str(val).strip() in ["-", "", "None", "nan", "N/A"]:
        return pd.NaT
    val = str(val).strip()
    for fmt in  ("%Y-%m-%d", "%m/%d/%Y", "%Y/%m/%d", "%d-%b-%Y", "%B %d, %Y"):
        try:
            return datetime.strptime(val, fmt)
        except ValueError:
            continue
    return pd.NaT


date_cols = ["founded_date", "first_funding_date", "last_funding_date"]
for col in date_cols:
    if col in df.columns:
        df[col] = df[col].apply(parse_date)
        df[col] = pd.to_datetime(df[col], errors='coerce')  # Ensure datetime format


df["categories_raw"] = df["categories_raw"].fillna("Unknown").str.lower().str.strip()

# Primary category = first item before the pipe character
df["primary_category"] = df["categories_raw"].apply(lambda x: x.split("|")[0] if pd.notnull(x) else "Unknown")

# Count how many categories each startup is tagged with
df["category_count"] = df["categories_raw"].apply(lambda x: len(x.split("|")) if pd.notnull(x) else 0)


# How long did it take to go from founded to funded? (in days)
df["days_to_first_funding"] = (df["first_funding_date"] - df["founded_date"]).dt.days

# How long between first and last funding? (in days)
df["days_between_first_last_funding"] = (df["last_funding_date"] - df["first_funding_date"]).dt.days

# Average funding per round (total funding / number of rounds) account for 0's in number of rounds
df["average_funding_per_round"] = df.apply(lambda row: row["total_funding_usd"] / row["funding_rounds"] if row["funding_rounds"] > 0 else np.nan, axis=1)

# What year was the startup founded? (extract year from founded_date)
df["founded_year"] = df["founded_date"].dt.year

# What year did they get their first funding? (extract year from first_funding_date)
df["first_funding_year"] = df["first_funding_date"].dt.year

# Funding stage bucket based on highest round reached
def highest_round(row):
    rounds = {
        "round_h": row.get("round_h", 0),
        "round_g": row.get("round_g", 0),
        "round_f": row.get("round_f", 0),
        "round_e": row.get("round_e", 0),
        "round_d": row.get("round_d", 0),
        "round_c": row.get("round_c", 0),
        "round_b": row.get("round_b", 0),
        "round_a": row.get("round_a", 0),
        "seed": row.get("seed", 0)
    }
    for label, val in rounds.items():
        if pd.notna(val) and val > 0:
            return label
    return "Unknown"

df["highest_round_reached"] = df.apply(highest_round, axis=1)

# Is this a US-based startup? (country code = USA)
df["is_us_based"] = df["country"].apply(lambda x: True if str(x).strip().upper() == "USA" else False)

# Has the startup raised Series B or higher?
df["reached_series_b"] = df["highest_round_reached"].apply(lambda x: True if x in ["round_b", "round_c", "round_d", "round_e", "round_f", "round_g", "round_h"] else False)


# Drop rows with no company name or outcome
df = df.dropna(subset=["company_name", "outcome"])

# Remove obvious duplicates
df = df.drop_duplicates(subset=["company_name", "founded_date"])

print(f"Cleaned data shape: {df.shape}\n")
print(f"Outcome distribution after cleaning:\n{df['outcome'].value_counts(dropna=False)}\n")
print(f"Countries: {df['country'].nunique()}\n")
print(f"Primary categories: {df['primary_category'].nunique()}\n")
print(f"Founded year range: {df['founded_year'].min()} - {df['founded_year'].max()}\n")


#save cleaned data to CSV
df.to_csv("data/crunchbase_cleaned.csv", index=False, encoding="utf-8")