-- stg_startups.sql
-- Silver Layer: clean types, rename columns, apply basic filters.
-- This model is a VIEW (no storage cost) that all mart models build on

WITH source AS (
    SELECT * FROM {{ source('venturescope', 'startups_raw')}}
),

typed AS (
    SELECT
        --Identity
        company_name,
        website,
        crunchbase_url,
        --Outcome
        LOWER(TRIM(outcome)) AS outcome,
        --Geography
        country,
        state,
        region,
        CAST(is_us_based AS BOOLEAN) AS is_us_startup,
        -- Category
        primary_category,
        CAST(category_count AS INT) as category_count,
        -- Funding totals
        CAST(total_funding_usd AS DOUBLE) AS total_funding_usd,
        CAST(funding_rounds AS INT) AS funding_rounds,
        CAST(seed AS DOUBLE) AS seed_usd,
        CAST(venture AS DOUBLE) AS venture_usd,
        CAST(angel AS DOUBLE) AS angel_usd,
        CAST(grant AS DOUBLE) AS grant_usd,
        CAST(private_equity AS DOUBLE) AS private_equity_usd,
        CAST(round_a AS DOUBLE) AS round_a_usd,
        CAST(round_b AS DOUBLE) AS round_b_usd,
        CAST(round_c AS DOUBLE) AS round_c_usd,
        CAST(round_d AS DOUBLE) AS round_d_usd,
        -- Derived funding metrics
        CAST(average_funding_per_round AS DOUBLE) AS avg_funding_per_round,
        CAST(funding_efficiency AS DOUBLE) AS funding_efficiency,
        highest_round_reached,
        investor_tier,
        CAST(reached_series_b AS BOOLEAN) AS reached_series_b,
        -- Dates
        CAST(founded_date AS DATE) AS founded_date,
        CAST(first_funding_date AS DATE) AS first_funding_date,
        CAST(last_funding_date AS DATE) AS last_funding_date,
        CAST(founded_year AS INT) AS founded_year,
        CAST(first_funding_year AS INT) AS first_funding_year,
        founded_decade,
        -- Time metrics
        CAST(days_to_first_funding AS INT) AS days_to_first_funding,
        CAST(days_between_first_last_funding AS INT) AS funding_runway_days,
        CAST(age_at_last_funding_date AS DOUBLE) AS age_at_last_funding_years
    FROM source
    WHERE company_name IS NOT NULL
    AND company_name != ''
)
SELECT
    *
FROM typed