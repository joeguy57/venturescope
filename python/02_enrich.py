import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings("ignore")

df = pd.read_csv("data/crunchbase_clean.csv", parse_dates=["founded_date", "first_funding_date", "last_funding_date"])

print(f"Loaded {len(df)} rows and {len(df.columns)} columns from crunchbase_clean.csv\n")

#Avoid division by zero
df["funding_efficiency"] = df.apply(lambda row: np.log10(row["total_funding_usd"] / row["funding_rounds"]) if row["funding_rounds"] > 0 else np.nan, axis=1)
