import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings("ignore")

df = pd.read_csv("data/crunchbase_clean.csv", parse_dates=["founded_date", "first_funding_date", "last_funding_date"])

print(f"Loaded {len(df)} rows and {len(df.columns)} columns from crunchbase_clean.csv\n")

#Avoid division by zero
df["funding_efficiency"] = df.apply(lambda row: np.log10(row["total_funding_usd"] / row["funding_rounds"]) if row["funding_rounds"] > 0 else np.nan, axis=1)

def investor_tier(venture_usd):
    """Categorize investors based on total funding raised."""
    if pd.isna(venture_usd) or venture_usd == 0:
        return "No VC"
    elif venture_usd < 1_000_000:
        return "Micro VC (<$1M)"
    elif venture_usd < 10_000_000:
        return "Small VC ($1M-$10M)"
    elif venture_usd < 50_000_000:
        return "Mid VC ($10M-$50M)"
    elif venture_usd < 200_000_000:
        return "Large VC ($50M-$200M)"
    else:
        return "Mega VC ($200M+)"
    

df["investor_tier"] = df["venture"].apply(investor_tier)
