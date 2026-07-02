-- category_survival_rates.sql
-- Aggregated outcome rates by startup category.
-- Answers: "Are some industries fundamentally better bets than others?"
WITH outcomes AS (
    SELECT * FROM {{ ref('startup_outcomes') }}
    WHERE primary_category IS NOT NULL
    AND primary_category != 'Unknown'
)
SELECT
    primary_category,
    -- Volume
    COUNT(*) AS total_startups,
    -- Outcome counts
    SUM(is_ipo) AS ipo_count,
    SUM(is_acquired) AS acquired_count,
    SUM(is_successful_exit) AS successful_exit_count,
    SUM(is_closed) AS closed_count,
    SUM(is_operating) AS still_operating_count,
    -- Rates (as percentages)
    ROUND(AVG(is_ipo) * 100, 2) AS ipo_rate_pct,
    ROUND(AVG(is_acquired) * 100, 2) AS acquired_rate_pct,
    ROUND(AVG(is_successful_exit) * 100, 2) AS success_rate_pct,
    ROUND(AVG(is_closed) * 100, 2) AS closure_rate_pct,
    -- Funding context
    ROUND(AVG(total_funding_usd) / 1e6, 1) AS avg_funding_m,
    ROUND(MEDIAN(total_funding_usd) / 1e6, 1) AS median_funding_m,
    ROUND(AVG(funding_rounds), 1) AS avg_rounds
FROM outcomes
GROUP BY primary_category
HAVING COUNT(*) >= 20 -- only categories with enough data to be meaningful
ORDER BY success_rate_pct DESC