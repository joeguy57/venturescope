-- startup_outcomes.sql
-- Gold layer: one row per startup with all features needed for outcome analysis.
-- This is the primary table for answering "what predicts startup survival?"

WITH base AS (
    SELECT * FROM {{ ref('stg_startups') }}
    WHERE outcome IS NOT NULL
),
with_flags AS (
    SELECT
        *,
        -- Binary outcome flags for easy aggregation
        CASE WHEN outcome IN ('ipo', 'acquired') THEN 1 ELSE 0 END
        AS is_successful_exit,
        CASE WHEN outcome = 'ipo' THEN 1 ELSE 0 END AS is_ipo,
        CASE WHEN outcome = 'acquired' THEN 1 ELSE 0 END AS is_acquired,
        CASE WHEN outcome = 'closed' THEN 1 ELSE 0 END AS is_closed,
        CASE WHEN outcome = 'operating' THEN 1 ELSE 0 END AS is_operating,
        -- Funding size buckets for grouping
        CASE
        WHEN total_funding_usd IS NULL THEN 'No Data'
        WHEN total_funding_usd = 0 THEN 'Bootstrapped'
        WHEN total_funding_usd < 1000000 THEN 'Under $1M'
        WHEN total_funding_usd < 10000000 THEN '$1M–$10M'
        WHEN total_funding_usd < 50000000 THEN '$10M–$50M'
        WHEN total_funding_usd < 200000000 THEN '$50M–$200M'
        ELSE '$200M+'
        END AS funding_bucket,
        -- Speed to first funding bucket
        CASE
        WHEN days_to_first_funding IS NULL THEN 'Unknown'
        WHEN days_to_first_funding < 0 THEN 'Pre-founded'
        WHEN days_to_first_funding < 180 THEN 'Under 6 months'
        WHEN days_to_first_funding < 365 THEN '6–12 months'
        WHEN days_to_first_funding < 730 THEN '1–2 years'
        WHEN days_to_first_funding < 1825 THEN '2–5 years'
        ELSE '5+ years'
        END AS speed_to_funding_bucket
    FROM base
)
SELECT * FROM with_flags