-- funding_efficiency.sql
-- Compares funding efficiency scores across outcomes and geographies.
-- Answers: "Is it better to raise a lot, or raise efficiently?"
WITH outcomes AS (
    SELECT * FROM {{ ref('startup_outcomes') }}
    WHERE total_funding_usd > 0
    AND funding_rounds > 0
),
-- Quartile the efficiency scores so we can compare top vs bottom
with_quartiles AS (
    SELECT
    *,
    NTILE(4) OVER (ORDER BY funding_efficiency) AS efficiency_quartile
    FROM outcomes
    WHERE funding_efficiency IS NOT NULL
)
SELECT
    efficiency_quartile,
    CASE efficiency_quartile
    WHEN 1 THEN 'Q1 — Least Efficient'
    WHEN 2 THEN 'Q2'
    WHEN 3 THEN 'Q3'
    WHEN 4 THEN 'Q4 — Most Efficient'
    END AS quartile_label,
    COUNT(*) AS startups,
    ROUND(AVG(total_funding_usd) / 1e6, 1) AS avg_funding_m,
    ROUND(AVG(funding_rounds), 1) AS avg_rounds,
    ROUND(AVG(funding_efficiency), 2) AS avg_efficiency_score,
    ROUND(AVG(is_successful_exit) * 100, 1) AS success_rate_pct,
    ROUND(AVG(is_ipo) * 100, 1) AS ipo_rate_pct,
    ROUND(AVG(is_closed) * 100, 1) AS closure_rate_pct,
    ROUND(AVG(days_to_first_funding), 0) AS avg_days_to_first_funding
FROM with_quartiles
GROUP BY efficiency_quartile, quartile_label
ORDER BY efficiency_quartile